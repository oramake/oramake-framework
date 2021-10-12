CREATE OR REPLACE PACKAGE BODY PKG_OPERATOR is
/* package body: pkg_Operator::body */

/* Минимально допустимая длина пароля */
Password_MinLength CONSTANT INTEGER := 8;
/*Глубина просмотра истории паролей*/
Password_LogHistory CONSTANT INTEGER := 3;

/* ID текущего оператора */
CurrentOperatorId integer;

/* Логин текущего оператора */
CurrentLogin op_operator.login%type;

/* Имя текущего оператора (рус) */
CurrentOperatorName op_operator.operator_name%type;



/* group: Функции */

/* iproc: AddSqlCondition
  Добавляет условие с параметром в строку SQL-условий.
  В случае, если фактическое значение параметра не null ( isNullValue false),
  условие добавляется в виде бинарной операции сравнения над полем и параметром,
  в противном случае добавляется тождественно истинное условие с параметром.

  Указанная схема обеспечивает постоянное число и порядок параметров при
  выполнении динамического SQL при том, что фактически часть параметров
  может быть не задана ( имеет значение null). Также обеспечивается разный
  текст запроса в зависимости от наличия фактических значений параметров,
  что позволяет использовать разные планы выполнения запроса.

  Параметры:
  searchCondition             - текст с SQL-условиями поиска, в который
                                добавляется условие ( подставляется затем в SQL
                                после "where")
  fieldExpr                   - выражение над полем таблицы ( указывается в
                                левой части операции сравнения)
  operation                   - операция сравнения ( "=", ">=" и т.д.)
  isNullValue                 - признак передачи null в качесте значения
                                параметра
  parameterExpr               - выражение над параметром ( указывается в правой
                                части операции сравнения, в случае отсутствия
                                ":" оно добавляется в начало строки, по
                                умолчанию берется из fieldExpr с удалением
                                алиаса и добавлением ":")

  Замечания:
  - в случае нетривиального значения в fieldExpr ( не просто
    "[<alias>.]<fieldName>"), значение parameterExpr должно быть явно задано;

*/
procedure AddSqlCondition(
  searchCondition in out nocopy varchar2
  , fieldExpr varchar2
  , operation varchar2
  , isNullValue boolean
  , parameterExpr varchar2 := null
)
is

                                        --Признак добавления бинарной операции
  isBinaryOp boolean := coalesce( not isNullValue, false);

--AddSqlCondition
begin
  searchCondition := searchCondition
    || case when searchCondition is not null then ' and' end
    || case when isBinaryOp then
        ' ' || fieldExpr || ' ' || operation
      end
    || ' '
    || case when parameterExpr is null then
                                      --По умолчанию имя поля ( без алиаса)
          ':' || substr( fieldExpr, instr( fieldExpr, '.') + 1)
        else
                                      --Добавляем ":", если его нет
          case when instr( parameterExpr, ':') = 0 then
            ':'
          end
          || parameterExpr
        end
      || case when not isBinaryOp then
          ' is null'
        end
  ;
end AddSqlCondition;

/* ifunc: getPasswordValidityPeriod
  Функция получения срока действия пароля в днях.

  Входные параметры:
    operatorId                                - ИД оператора

  Возврат:
    passwordValidityPeriod                    - Срок действия пароля в днях
*/
function getPasswordValidityPeriod(
  operatorId integer
)
return integer
is
  passwordValidityPeriod integer;

-- getPasswordValidityPeriod
begin
  select
    max( t.password_validity_period )
  into
    passwordValidityPeriod
  from
    op_operator op
  inner join
    op_login_attempt_group t
  on
    op.login_attempt_group_id = t.login_attempt_group_id
  where
    op.operator_id = operatorId
  ;

  return passwordValidityPeriod;

exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , 'Во время получения срока действия пароля в днях'
        || ' произошла ошибка ('
        || 'operatorId="' || to_char( operatorId ) || '"'
        || ').'
      , true
    );
end getPasswordValidityPeriod;

/* func: getHash
  Возвращает hex-строку с MD5 контрольной суммой.

  Параметры:

  inputString                 - исходная строка для расчета контрольной суммы;

  Возврат:
  - возвращает hex-строку с MD5 контрольной суммой;
*/
function getHash(
  inputString varchar2
)
return varchar2
is
-- getHash
begin
  return
    case when inputString is not null then
      rawtohex( utl_raw.cast_to_raw(
        dbms_obfuscation_toolkit.md5( input_string => inputString)
      ))
    else
      null
    end
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , 'Ошибка при хэшировании строки'
    , true
  );
end getHash;

/* func: getHashSalt
  Функция хэширования пароля с "солью".

  Входные параметры:
    password                              - пароль

  Возврат:
    hashSalt                              - Хэш пароля с "солью"
*/
function getHashSalt(
  password varchar2
)
return varchar2
is
  hashSalt varchar2(4000);
  sqlStr varchar2(32767);

-- getHashSalt
begin
  -- Вынесено в динамический sql для обхода прямой
  -- зависимости от модуля Option, что в свою
  -- очередь необходимо для более простой
  -- первоначальной установки модуля
  sqlStr := '
declare
  -- Опции для работы с модулем
  optionList opt_option_list_t := opt_option_list_t(
    moduleName => pkg_Operator.Module_Name
  );
begin
  :hashSalt := optionList.getString(
    optionShortName => pkg_Operator.HashSalt_OptSName
    , raiseNotFoundFlag => 0
  );
end;';

  execute immediate
    sqlStr
  using
    out hashSalt
  ;

  return getHash( password || hashSalt );

exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , 'Во время хэширования пароля с "солью" произошла ошибка.'
      , true
    );
end getHashSalt;



/* group: Регистрация */

/* iproc: login
  Выполняет проверку и регистрирует оператора в БД. В случае успешной
  регистрации сохраняет данные оператора в переменных пакета, при ошибке
  регистрации - выбрасывает исключение.

  Входные параметры:
    operatorID                  - ID оператора;
    operatorLogin               - логин оператора ( используется только если
                                  operatorID null);
    password                    - пароль для проверки доступа;
    isCheckPassword             - нужно ли выполнять проверку пароля ( если
                                 null, то выполнять);
    passwordHash                - Хэш пароля

  Выходные параметры отсутствуют.

 Замечания:
   регистр логина значения не имеет, пароль проверяется с учетом регистра
*/
procedure login(
  operatorId integer default null
  , operatorLogin varchar2 default null
  , password varchar2 default null
  , isCheckPassword boolean default null
  , passwordHash varchar2 default null
)
is
  -- Данные оператора
  rec op_operator%rowtype;
  -- Дата проверки прав доступа
  checkDate date;

  /*
    Процедура установки информации о логине -
    либо увеличения счетчика некорректного ввода пароля
    оператором либо дата успешного логина.
  */
  procedure setLoginInfo(
    operatorId integer
    , isSuccessfulLogin integer default 0
    , currLoginAttemptCount integer default null
    , loginAttemptGroupId integer default null
  )
  is
  pragma autonomous_transaction;
    maxLoginAttemptCount integer;
    lockTypeCode op_lock_type.lock_type_code%type;

  -- setLoginInfo
  begin
    -- Если был успешный логин - устанавливаем дату
    if coalesce( isSuccessfulLogin, 0 ) = 1 then
      -- Фиксируем дату успешного логина и сбрасываем количество
      -- неудачных попыток входа
      update
        op_operator op
      set
        op.last_success_login_date = sysdate
        , op.curr_login_attempt_count = 0
      where
        op.operator_id = operatorId
      ;
    -- Если для оператора задана группа - увеличиваем
    -- количество попыток ввода пароля
    elsif loginAttemptGroupId is not null then
      select
        max( grp.max_login_attempt_count )
        , max( grp.lock_type_code )
      into
        maxLoginAttemptCount
        , lockTypeCode
      from
        op_login_attempt_group grp
      where
        grp.login_attempt_group_id = loginAttemptGroupId
      ;
      -- Если превышено максимально допустимое количество
      -- попыток ввода - блокируем оператора
      if coalesce( currLoginAttemptCount, 0 ) + 1 > maxLoginAttemptCount
        and lockTypeCode != pkg_Operator.Unused_LockTypeCode
      then
        -- Оператор не залогинен - значит, блокируем его от имени
        -- сервера
        pkg_Operator.setCurrentUserId( 1 );

        update
          op_operator op
        set
          op.curr_login_attempt_count =
            coalesce( currLoginAttemptCount, 0 ) + 1
          , op.date_finish = sysdate
          , op.operator_comment = nvl(
              op.operator_comment
              , 'Оператор заблокирован. Достигнут  максимум'
                || ' попыток входа в систему.'
            )
        where
          op.operator_id = operatorId
          -- Если оператор заблокирован - не блокируем его
          -- при следующей неуспешной попытке входа
          and op.date_finish is null
        ;
      -- Иначе - увеличиваем счетчик неудачных попыток
      elsif coalesce( currLoginAttemptCount, 0 ) + 1 <= maxLoginAttemptCount
        and lockTypeCode != pkg_Operator.Unused_LockTypeCode
      then
        update
          op_operator op
        set
          op.curr_login_attempt_count =
            coalesce( currLoginAttemptCount, 0 ) + 1
        where
          op.operator_id = operatorId
        ;
      end if;
    end if;

    commit;

  exception
    when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , 'Во время сохранения информации о логине'
          || ' произошла ошибка.'
        , true
      );
  end setLoginInfo;

-- login
begin
  -- Получаем учетные данные оператора
  begin
    if operatorId is not null then
      select
        op.*
      into
        rec
      from
        op_operator op
      where
        op.operator_id = operatorId
      ;
    else
      -- Подсказка для учета функционального
      -- индекса.
      select /*+ index( op) */
        op.*
      into
        rec
      from
        op_operator op
      where
        upper( op.login ) = upper( operatorLogin )
      ;
    end if;
  exception
    when no_data_found then
      null;
  end;
  -- Проверяем логин/пароль ( не разделяем
  -- ошибки из-за неверного логина
  -- и неправильного пароля)
  if rec.operator_id is null
    or (
      coalesce( isCheckPassword, true)
      and coalesce( rec.password <> GetHash( password ), true)
      -- Для логирования операторов из операционного CRM
      -- Microsoft Dynamics
      and coalesce( getHashSalt( rec.password ) <> passwordHash, true )
    )
  then
    -- Если был введен неправильный пароль - увеличиваем
    -- счетчик количества попыток
    setLoginInfo(
      operatorId => rec.operator_id
      , currLoginAttemptCount => rec.curr_login_attempt_count
      , loginAttemptGroupId => rec.login_attempt_group_id
    );

    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Указан неверный'
        || case when operatorID is not null then
            ' ID оператора'
          else
            ' логин'
          end
        || ' или пароль.'
    );
  end if;
  -- Проверяем дату действия оператора
  checkDate := sysdate;
  if checkDate < rec.date_begin or checkDate > rec.date_finish then
    raise_application_error(
      pkg_Error.RigthIsMissed
      , 'Доступ к системе запрещен.'
    );
  end if;

  -- Сохряняем данные оператора
  CurrentOperatorId := rec.operator_id;
  CurrentLogin := rec.login;
  CurrentOperatorName := rec.operator_name;

  -- Фиксируем дату успешного логина и сбрасываем количество
  -- неудачных попыток входа
  setLoginInfo(
    operatorId => rec.operator_id
    , isSuccessfulLogin => 1
  );

exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , 'Ошибка при регистрации оператора ('
      || substr(
        case when operatorID is not null then
          ', operator_id=' || to_char( operatorID)
        end
        || case when operatorLogin is not null then
          ', login="' || operatorLogin || '"'
        end
        , 2)
      || ').'
    , true
  );
end login;

/* func: login
  Регистрирует оператора в базе по логину и
  паролю/хэшу пароля и возвращает имя оператора.

  Входные параметры:
    operatorLogin               - логин оператора
    password                    - пароль

  Возврат:
    current_operator_name       - ФИО текущего оператора
*/
function login(
  operatorLogin varchar2
  , password varchar2
  , passwordHash varchar2 default null
)
return varchar2
is
-- login
begin
  login(
    operatorLogin => operatorLogin
    , password => password
    , isCheckPassword => true
    , passwordHash => passwordHash
  );

  return CurrentOperatorName;

end login;

/* func: login
  Регистрирует оператора в базе и возвращает имя оператора.

  Параметры:
  operatorLogin               - логин оператора;

  Выходные параметры:

 CurrentOperatorName - ;
)
*/
function login( operatorLogin varchar2)
return varchar2
is
-- login
begin
  login(
    operatorLogin       => operatorLogin
    , isCheckPassword   => false
  );
  return CurrentOperatorName;
end Login;

/* proc: login
  Регистрирует оператора в базе ( без проверки пароля).

  Параметры:
  operatorLogin               - логин оператора
*/
procedure login(
  operatorLogin varchar2
)
is
-- login
begin
  login(
    operatorLogin       => operatorLogin
    , isCheckPassword   => false
  );
end login;

/* proc: setCurrentUserId
  Регистрирует оператора в базе ( без проверки пароля).

  Параметры:
  operatorId                  - Id оператора;
*/
procedure setCurrentUserId( operatorId integer)
is
-- setCurrentUserId
begin
  login(
    operatorId          => operatorId
    , isCheckPassword   => false
  );
end setCurrentUserId;

/* proc: remoteLogin
  Регистрирует текущего оператора в удаленной БД.

  Параметры:
  dbLink                      - имя линка к удаленной БД;
*/
procedure remoteLogin(
  dbLink varchar2
)
is
-- remoteLogin
begin
  --Регистрируемся в удаленной БД
  execute immediate
    'begin'
      || ' pkg_Operator.login@' || dbLink || '( :login);'
    || ' end;'
  using
    in currentLogin
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , 'Ошибка при регистрации текущего оператора по линку "'
      || dbLink || '".'
    , true
  );
end remoteLogin;

/* proc: logoff
  Отменяет текущую регистрацию;
*/
procedure logoff
is
-- logoff
begin
  currentOperatorId           := null;
  currentLogin                := null;
  currentOperatorName         := null;
end logoff;

/* func: getCurrentUserId
   Возвращает ID текущего оператора.

   Входные параметры:
     isRaiseException - флаг выбрасывания исключения в случае,
                        если текущий оператор не определен
                        0 - флаг не активен
                        1 - флаг активен

   Возврат:
     oprator_id       - ИД текущего оператора

*/
function getCurrentUserId(
  isRaiseException integer default 1
)
return integer
is
-- getCurrentUserId
begin
  if CurrentOperatorId is null
    and coalesce(isRaiseException, 1) = 1
  then
    raise_application_error(
      pkg_Error.OperatorNotRegister
      , 'Вы не зарегистрировались.'
        || ' Для регистрации в системе выполните функцию Login.'
    );
  end if;
  return CurrentOperatorId;
end getCurrentUserId;

/* func: getCurrentUserName
   Возвращает имя текущего оператора.

   Входные параметры:
     isRaiseException - флаг выставления исключения в случае,
                        если текущий оператор не определен
                        0 - флаг не активен
                        1 - флаг активен

   Возврат:
     oprator_name     - Имя текущего оператора

*/
function getCurrentUserName(
  isRaiseException integer default 1
)
return varchar2
is
--getCurrentUserName
begin
  --Выполняем проверку регистрации
  if getCurrentUserID(
       isRaiseException => isRaiseException
     ) is null
  then
    null;
  end if;
  return CurrentOperatorName;
end getCurrentUserName;



/* group: Проверка */

/* ifunc: isRole
  Проверяет наличие роли у оператора.

  Входные параметры:

  operatorId                  - id оператора
  roleId                      - id роли
  roleShortName               - короткое наименование роли
  checkDate                   - дата, на момент которой проверяется наличие
                                роли

  Возвращаемые значения:
  1 - установлена;
  0 - не установлена;
*/
function isRole(
  operatorId integer
  , roleId integer := null
  , roleShortName varchar2 := null
  , makeError boolean := false
)
return integer
is
  -- Признак наличия роли
  isGrant integer := 0;
  -- Данные по оператору
  operatorNameRus op_operator.operator_name%type;
  dateBegin date;
  dateFinish date;
  -- Короткое наименование роли
  shortName v_op_role.role_short_name%type;
  -- Дата проверки прав доступа
  checkDate date;

--IsRole
begin
  begin
    select
      op.operator_name
      , op.date_begin
      , op.date_finish
      , rl.role_short_name
      , coalesce((
          select
            1
          from
            v_op_operator_role orv
          where
            orv.operator_id = op.operator_id
            and orv.role_id = rl.role_id
            and rownum <= 1
        ), 0)
        as is_grant
    into operatorNameRus, dateBegin, dateFinish, shortName, isGrant
    from
      op_operator op
      cross join v_op_role rl
    where
      op.operator_id = operatorId
      and (
        rl.role_id = roleId
        or rl.role_short_name = roleShortName
        )
    ;
  exception when NO_DATA_FOUND then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Указан несуществующий Id оператора или'
        || case when roleId is not null then
            ' Id'
          else
            ' имя'
          end
        || ' роли.'
    );
  end;
  --Проверяем дату действия оператора
  checkDate := sysdate;
  if checkDate < dateBegin or checkDate > dateFinish then
    isGrant := 0;
    --Генерим исключение ( если надо)
    if makeError then
      raise_application_error(
        pkg_Error.RigthIsMissed
        , 'Доступ к системе запрещен.'
      );
    end if;
  end if;
  --Генерим исключение ( если надо)
  if isGrant = 0 and makeError then
    raise_application_error(
      pkg_Error.RigthIsMissed
      , 'У вас, '
        || operatorNameRus
        || ', нет прав на выполнение данной операции ('
        || ' role_short_name="' || shortName || '"'
        ||').'
    );
  end if;
  return isGrant;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , 'Ошибка при проверке наличия роли у оператора ('
      || ' operator_id=' || to_char( operatorId)
      || case when roleId is not null then
          ', role_id=' || to_char( roleId)
        else
          ', short_name="' || to_char( roleShortName) || '"'
        end
      || ').'
    , true
  );
end isRole;

/* func: isRole(operatorId,DEPRECATED)
  Проверяет наличие роли у оператора.

  Параметры:
  operatorId                  - id оператора
  roleId                      - id роли

  Возвращаемые значения:
  1 - роль установлена;
  0 - роль не установлена;

  Замечание:
  - устаревшая функция. Не использовать.
*/
function isRole(
  operatorId integer
, roleId     integer
)
return integer
is
-- isRole
begin
  return
    isRole(
      operatorId        => operatorId
      , roleId          => roleId
      , makeError       => false
    )
  ;
end isRole;

/* func: isRole(operatorId)
  Проверяет наличие роли у оператора.

  Параметры:

  operatorId                  - id оператора
  roleShortName               - короткое наименование роли

  Возвращаемые значения:
  1 - роль установлена;
  0 - роль не установлена;
*/
function isRole(
  operatorId integer
  , roleShortName varchar2
)
return integer
is
-- isRole
begin
  return
    isRole(
      operatorId        => operatorId
      , roleShortName   => roleShortName
      , makeError       => false
    )
  ;
end isRole;

/* func: isRole
  Проверяет наличие роли у текущего оператора.

  Параметры:
  roleShortName               - имя роли;

  Возвращаемые значения:
  1 - роль установлена;
  0 - роль не установлена;
*/
function isRole(
  roleShortName varchar2
)
return integer
is
  -- Признак выдачи роли
  isGrant integer := 0;

--IsRole
begin
  if currentOperatorId is not null then
    isGrant := isRole(
      operatorId        => currentOperatorId
      , roleShortName   => roleShortName
      , makeError       => false
    );
  end if;
  return isGrant;
end isRole;

/* proc: isRole(operatorId,DEPRECATED)
  Проверяет наличие роли у оператора и в случае ее отсутствия выбрасывает
  исключение.

  Параметр:

  operatorID                  - ID оператора;
  roleID                      - ID роли;

  Замечание:
  - устаревшая функция. Не использовать.
*/
procedure isRole
 (OPERATORID INTEGER
 ,ROLEID INTEGER
 )
is
  --Признак наличия роли
  isGrant integer;

--IsRole
begin
  isGrant := isRole(
    operatorID        => operatorId
  , roleID            => roleId
  , makeError         => true
  );
end isRole;

/* proc: isRole(operatorId)
  Проверяет наличие роли у оператора и в случае ее отсутствия выбрасывает
  исключение.

  Параметр:

  operatorId                  - id оператора;
  roleShortName               - имя роли;
*/
procedure isRole(
  operatorId integer
  , roleShortName varchar2
)
is
  -- Признак наличия роли
  isGrant integer;

-- isRole
begin
  isGrant := isRole(
    operatorId        => operatorId
    , roleShortName   => roleShortName
    , makeError       => true
  );
end isRole;

/* proc: isRole
  Проверяет наличие роли у текущего оператора и в случае отсутствия
  регистрации или роли выбрасывает исключение.

  Параметр:
  roleShortName               - имя роли
*/
procedure isRole(
  roleShortName varchar2
)
is

  -- Признак наличия роли
  isGrant integer;

--IsRole
begin
  isGrant := isRole(
    operatorId        => getCurrentUserId()
    , roleShortName   => roleShortName
    , makeError       => true
  );
end isRole;

/* proc: isUserAdmin
  Проверяет права на администрирование операторов и в случае их отсутствия
  выбрасывает исключение.

  Входные параметры:

  operatorID                  - ID оператора, выполняющего действие;
  targetOperatorID            - ID оператора, над которым выполняется действие;
  roleID                      - ID выдаваемой/забираемой роли;
  groupID                     - ID выдаваемой/забираемой группы;

*/
procedure isUserAdmin
 (OPERATORID INTEGER
 ,TARGETOPERATORID INTEGER := null
 ,ROLEID INTEGER := null
 ,GROUPID INTEGER := null
 )
is

  procedure CheckGrantRole is
  --Проверяет права на выдачу роли.

    isGrant integer := 0;

  --CheckGrantRole
  begin
    select
      count(*) as is_grant
    into isGrant
    from
      v_op_operator_grant_role orv
    where
      orv.operator_id = operatorID
      and orv.role_id = roleID
      and rownum <= 1
    ;
    if isGrant = 0 then
      raise_application_error(
        pkg_Error.RigthIsMissed
        , 'Нет прав на выдачу роли ('
          || ' operator_id=' || to_char( operatorID)
          || ', role_id=' || to_char( roleID)
          || ').'
      );
    end if;
  end CheckGrantRole;



  procedure CheckGrantGroup is
  --Проверяет права на изменение состава группы.

    isGrant integer := 0;

  --CheckGrantGroup
  begin
    select
      count(*) as is_grant
    into isGrant
    from
      v_op_operator_grant_group ogg
    where
      ogg.operator_id = operatorID
      and ogg.group_id = groupID
      and rownum <= 1
    ;
    if isGrant = 0 then
      raise_application_error(
        pkg_Error.RigthIsMissed
        , 'Нет прав на выдачу группы ('
          || ' operator_id=' || to_char( operatorID)
          || ', group_id=' || to_char( groupID)
          || ').'
      );
    end if;
  end CheckGrantGroup;



  procedure CheckRights is
  --Проверяет, что права изменяемого оператора не больше прав администратора.
  --Это на случай, чтобы у администратора не отобрали права.

    roleID op_role.role_id%type;
    groupID op_group.group_id%type;

  --CheckRights
  begin
                                        --Проверяем назначенные роли
    select
      min( role_id)
    into roleID
    from
      (
      select distinct
        opr.role_id
      from
        op_operator_role opr
      where
        opr.operator_id = targetOperatorID
        and opr.user_access_flag = 1
      minus
      select
        opr.role_id
      from
        v_op_operator_role opr
      where
        opr.operator_id = operatorID
      minus
      select
        opgr.role_id
      from
        v_op_operator_grant_role opgr
      where
        opgr.operator_id = operatorID
      ) rl
    ;
    if roleID is not null then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , 'Изменения запрещены,'
          || ' т.к. у изменяемого оператора есть дополнительная роль ('
          || ' role_id=' || to_char( roleID)
          || ').'
      );
    end if;
                                        --Проверяем группы
    select
      min( d.group_id)
    into groupID
    from
      (
      select distinct
        opr.group_id
      from
        op_operator_group opr
      where
        opr.operator_id = targetOperatorID
        and opr.user_access_flag = 1
      minus
      select distinct
        opr.group_id
      from
        op_operator_group opr
      where
        opr.operator_id = operatorID
        and opr.user_access_flag = 1
      minus
      select distinct
        opgr.group_id
      from
        v_op_operator_grant_group opgr
      where
        opgr.operator_id = operatorID
      ) d
    ;
    if groupID is not null then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , 'Изменения запрещены,'
          || ' т.к. изменяемый оператор включен в дополнительную группу ('
          || ' group_id=' || to_char( groupID)
          || ').'
      );
    end if;
  end CheckRights;



--IsUserAdmin
begin
                                        --Проверяем права на администрирование
  IsRole( operatorID, UserAdmin_Role);
                                        --Проверяем права на выдачу роли
  if roleID is not null then
    CheckGrantRole;
  end if;
                                        --Проверяем права на включение в группу
  if groupID is not null then
    CheckGrantGroup;
  end if;
                                        --Сравниваем права операторов
  if operatorID <> targetOperatorID then
    CheckRights;
  end if;
end IsUserAdmin;



/* group: Изменение пароля (перенести в pkg_AccessOperator) */

/* proc: checkPassword
  Процедура проверки пароля.

  Входные параметры:
    operatorId          - Пользователь, которого необходимо восстановить
    password            - Текущий пароль
    newPassword         - Новый пароль
    newPasswordConfirm  - Новый пароль ( подтверждение)
    opratorIdIns        - Идентификатор оператора
    passwordPolicyCode  - Код парольной политики (
                          NUM_U_L - цифры + буквы в верхнем регистре + буквы в нижнем регистре
                          NUM_U_L_SP - цифры + буквы в верхнем регистре + буквы в нижнем регистре
                            + спецсимволы
                          ). По умолчанию "NUM_U_L_SP".
*/
procedure checkPassword(
  operatorId integer
  , password varchar2 default null
  , newPassword varchar2
  , newPasswordConfirm varchar2 default null
  , operatorIdIns integer default null
  , passwordPolicyCode varchar2 default null
)
is
  passwordHash varchar2(50) := pkg_Operator.getHash( password);
  newPasswordHash varchar2(50) := pkg_Operator.getHash( newPassword);
  operatorLogin varchar2(50);
  currentPasswordHash varchar2(50);
  operatorNameEn varchar2(100);



  /*
    Функция проверки повторения паролей.
  */
  function checkPasswordHistoryRepeat(
    passwordRepeatHistory integer default Password_LogHistory
  )
  return boolean
  is
    repeatCount integer;

  -- checkPasswordHistoryRepeat
  begin
    select
      count(*)
    into
      repeatCount
    from
      (
      select
        k.password
      from
        (
        select
          ph.password
        from
          op_password_hist ph
        where
          ph.operator_id = operatorId
        order by
          ph.password_history_id desc
        ) k
      where
        rownum <= passwordRepeatHistory
      ) t
    where
      t.password = newPasswordHash
    ;

    return repeatCount > 0;
  end checkPasswordHistoryRepeat;

-- checkPassword
begin
  -- Ищем текущий пароль оператора
  select
    op.password
    , op.login
    , op.operator_name_en
  into
    currentPasswordHash
    , operatorLogin
    , operatorNameEn
  from
    op_operator op
  where
    op.operator_id = operatorId
  for update of op.password nowait
  ;

  -- Проверяем права доступа
  if operatorIdIns is not null then
    isUserAdmin(
      operatorID          => operatorIdIns
      , targetOperatorID  => operatorId
    );
  else
    -- Проверяем текущий пароль
    if coalesce( currentPasswordHash != passwordHash, true) then
      raise_application_error(
        pkg_Error.IllegalArgument
        , 'Текущий пароль указан неверно'
      );

    -- Проверяем длину пароля
    elsif coalesce( length( newPassword), 0) < Password_MinLength then
      raise_application_error(
        pkg_Error.WrongPasswordLength
        , 'Новый пароль не может быть короче '
          || Password_MinLength
          || ' символов'
      );
    -- Новый пароль должен отличаться от текущего
    elsif currentPasswordHash = newPasswordHash then
      raise_application_error(
        pkg_Error.IllegalArgument
        , 'Новый пароль совпадает с текущим'
      );
    -- Проверяем множество символов
    elsif length( newPassword) =
            length( translate( newPassword, '.0123456789', '.'))
      or length( newPassword) =
           length( translate( newPassword, '.ABCDEFGHIJKLMNOPQRSTUVWXYZ', '.'))
      or length( newPassword) =
           length( translate( newPassword, '.abcdefghijklmnopqrstuvwxyz', '.'))
      -- Спец. символы
      or (
        length( newPassword) =
          length( translate( newPassword, 'E!%:*()@#$^&-_+,.<>/?\{}', 'E'))
        and coalesce( passwordPolicyCode, pkg_Operator.NumULSp_PasswordPolicyCode)
          = pkg_Operator.NumULSp_PasswordPolicyCode
      )
    then
      raise_application_error(
        pkg_Error.WrongPasswordLength
        , 'Пароль должен содержать символы из каждого множества '
          || '[a..z],[A..Z],[0..9]'
          || case when
               coalesce( passwordPolicyCode, pkg_Operator.NumULSp_PasswordPolicyCode)
                 = pkg_Operator.NumULSp_PasswordPolicyCode
             then
               ',[!%:*()@#$^&-_+,.<>/?\{}]'
             end
        , true
      );
    -- Проверяем совпадение новых паролей
    elsif coalesce(
            newPassword != newPasswordConfirm
            , coalesce( newPassword, newPasswordConfirm) is not null
          )
    then
      raise_application_error(
        pkg_Error.IllegalArgument
        , 'Новый пароль не совпадает с подтверждением'
      );
    -- Проверяем, что в новом пароле не содержится логин/фамилия/имя
    elsif instr( upper( newPassword), upper( trim( operatorLogin))) > 0
      or instr(
           upper( newPassword)
           , upper(
               trim(
                 regexp_substr( operatorNameEn, '[^ ]+', 1, 1)
               )
             )
         ) > 0
      -- Проверяем имя только если его длина >=3, иначе считаем,
      -- что в имени хранится мусор
      or (
        instr(
           upper( newPassword)
           , upper(
               trim(
                 regexp_substr( operatorNameEn, '[^ ]+', 1, 2)
               )
             )
        ) > 0
        and length( regexp_substr( operatorNameEn, '[^ ]+', 1, 2)) >= 3
      )
    then
      raise_application_error(
        pkg_Error.IllegalArgument
        , 'Пароль не может содержать в себе фамилию, имя или логин пользователя'
      );

    -- Проверяем повторение паролей
    elsif checkPasswordHistoryRepeat() then
      raise_application_error(
        pkg_Error.WrongPasswordLength
        , 'Новый пароль не может повторять старые значения'
      );
    end if;
  end if;
exception
  when no_data_found then
    raise_application_error(
      pkg_Error.RowNotFound
      , 'Оператор не найден'
    );
end checkPassword;

/* iproc: changePassword
  Меняет пароль у оператора.

  Параметры:
    operatorID                  - ID оператора;
    password                    - пароль;
    newPassword                 - новый пароль;
    newPasswordConfirm          - подтверждение пароля;
    operatorIDIns               - ID оператора, выполняющего процедуру;
*/
procedure changePassword(
  operatorId integer
  , password varchar2 default null
  , newPassword varchar2
  , newPasswordConfirm varchar2 default null
  , operatorIdIns integer default null
  , passwordPolicyCode varchar2 default null
)
is
-- changePassword
begin
  -- Регистрируем оператора для корректной фиксации change_operator_id,
  -- если такое поле есть
  pkg_Operator.setCurrentUserId( coalesce( operatorIdIns, operatorId));

  -- Проверка пароля
  pkg_Operator.checkPassword(
    operatorId => operatorId
    , password => password
    , newPassword => newPassword
    , newPasswordConfirm => newPasswordConfirm
    , operatorIdIns => operatorIdIns
    , passwordPolicyCode => passwordPolicyCode
  );

  -- Меняем пароль оператора
  update
    op_operator op
  set
    op.password = pkg_Operator.getHash( newPassword)
    -- Сбрасываем признак необходимости смены пароля
    , op.change_password = 0
  where
    op.operator_id = operatorId
  ;
exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , 'Ошибка при смене пароля оператора ('
        || ' operator_id=' || to_char( operatorId)
        || ').'
      , true
    );
end changePassword;

/* iproc: changePasswordHash
Меняет пароль у оператора.

Параметры:

operatorID                  - ID оператора;
passwordHash                    - пароль;
newPasswordHash             - Hash новый пароль;
newPasswordConfirmHash      - Hash подтверждение пароля;
operatorIDIns               - ID оператора, выполняющего процедуру;
*/
procedure changePasswordHash
 ( operatorId             integer
 , passwordHash           varchar2 := null
 , newPasswordHash        varchar2
 , newPasswordConfirmHash varchar2 := null
 , operatorIdIns          integer := null
 )
is
                                        --Хэши пароля
   vPasswordHash op_operator.password%type;

  cursor curPasswordLog is    --Курсор для повторения паролей
    select vh.password
      from v_op_password_hist vh
    where vh.operator_id = OPERATORID
    order by date_end desc;

  pass varchar(50);                --исторический пароль
  newPasswordUpper varchar2(100);  --переменная для множества [A..Z]
  newPasswordLower varchar2(100);  --переменная для множества [a..z]
  newPasswordDigit varchar2(100);  --переменная для множества [0..9]
  newPasswordEdit  varchar2(100);  --переменная для нового пароля

--ChangePasswordHash
begin
  -- Регистрируем оператора для корректной фиксации change_operator_id,
  -- если такое поле есть
  pkg_Operator.setCurrentUserId( coalesce( operatorIdIns, operatorId ) );

                                        --Проверяем существование и блокируем
                                        --(без ожидания) запись оператора
  begin

    select
      op.password
    into vPasswordHash
    from
      op_operator op
    where
      op.operator_id = operatorID
    for update of password nowait;

    exception when NO_DATA_FOUND then     --Уточняем сообщение об ошибке
        raise_application_error(  pkg_Error.RowNotFound , 'Оператор не найден');
  end;

  if operatorIDIns is not null
  then
                                        --Проверяем права доступа
    IsUserAdmin( operatorID        => operatorIDIns
               , targetOperatorID  => operatorID);
  else
                                        --Проверяем текущий пароль
    if coalesce( vPasswordHash <> passwordHash, true)
    then

      raise_application_error(pkg_Error.IllegalArgument
        , 'Текущий пароль указан неверно' );

    end if;

/* закоментировано т.к. динну hash пароля определить нельзя
                                        --Проверяем длину пароля
    if coalesce( length( newPassword), 0) < pkg_Operator.Password_MinLength then
      raise_application_error(
        pkg_Error.WrongPasswordLength
        , 'Новый пароль не может быть короче '
          || pkg_Operator.Password_MinLength
          || ' символов.'
      );
    end if;

                            --Проверяем множество символов

    newPasswordEdit:=newPassword;
    newPasswordDigit:=translate(newPasswordEdit,'.0123456789','.');

    newPasswordEdit:=newPassword;
    newPasswordUpper:=translate(newPasswordEdit,'.ABCDEFGHIJKLMNOPQRSTUVWXYZ','.');

    newPasswordEdit:=newPassword;
    newPasswordLower:=translate(newPasswordEdit,'.abcdefghijklmnopqrstuvwxyz','.');

    if (length(newPasswordEdit)=length(newPasswordDigit)) or
       (length(newPasswordEdit)=length(newPasswordUpper)) or
       (length(newPasswordEdit)=length(newPasswordLower)) then
      raise_application_error(pkg_Error.WrongPasswordLength,
      'Пароль должен содержать символы из каждого множества [a..z],[A..Z],[0..9]');
    end if;
                          --Проверяем повторение паролей
    open curPasswordLog;
    for element in 1..pkg_operator.password_log_history
    loop
      fetch curPasswordLog into pass;
      if GetHash(newpassword)=pass then
        raise_application_error(pkg_Error.WrongPasswordLength,
                                'Новый пароль не может повторять старые значения');
      end if;
    end loop;
    close curPasswordLog;
*/
                                        --Проверяем совпадение новых паролей
    if coalesce( newPasswordHash <> newPasswordConfirmHash
          , coalesce( newPasswordHash, newPasswordConfirmHash) is not null
        )
    then
        raise_application_error(pkg_Error.IllegalArgument
           ,'Новый пароль не совпадает с подтверждением' );
    end if;

  end if;

 --Меняем пароль и сбрасываем фла смены
 --пароля
  vPasswordHash := newPasswordHash;--GetHash( newPassword);

  update
    op_operator op
  set
      op.password = vPasswordHash
    , op.change_password = 0
  where op.operator_id = operatorID;

exception when others then
  raise_application_error(pkg_Error.ErrorStackInfo
    , 'Ошибка при смене пароля оператора ('||' operator_id='||to_char(operatorID)||').', true );

end ChangePasswordHash;

/* proc: changePasswordHash
Меняет пароль у оператора.

Параметры:

operatorID                  - ID оператора;
passwordHash                - Hash пароль;
operatorIDIns               - ID оператора, выполняющего процедуру;
*/
procedure changePasswordHash (operatorid integer
                             ,passwordHash varchar2
                             ,operatoridins integer
                             )
is
-- changePasswordHash
begin

ChangePasswordHash ( operatorId             => operatorid
                   , passwordHash           => null
                   , newPasswordHash        => passwordHash
                   , newPasswordConfirmHash => null
                   , operatorIdIns          => operatoridins
                   );

end;

/* proc: changePasswordHash
Меняет пароль у оператора.

Параметры:

operatorID                  - ID оператора;
passwordHash                    - Hash пароль;
newPasswordHash             - Hash новый пароль;
newPasswordConfirmHash      - подтверждение пароля;
(<body::changePasswordHash>)
*/
procedure changePasswordHash
 (operatorid integer
 ,passwordHash varchar2
 ,newPasswordHash varchar2
 ,newPasswordConfirmHash varchar2
 )
is
--ChangePasswordHash
begin

ChangePasswordHash ( operatorId             => operatorid
                   , passwordHash           => passwordHash
                   , newPasswordHash        => newPasswordHash
                   , newPasswordConfirmHash => newPasswordConfirmHash
                   , operatorIdIns          => null
                   );

end;

/* proc: changePassword
Меняет пароль у оператора.

Параметры:

operatorID                  - ID оператора;
password                    - пароль;
operatorIDIns               - ID оператора, выполняющего процедуру;

*/
procedure changePassword
 (OPERATORID INTEGER
 ,PASSWORD VARCHAR2
 ,OPERATORIDINS INTEGER
 )
is
-- changePassword
begin
  changePassword(
    operatorID            => operatorID
    , password            => null
    , newPassword         => password
    , newPasswordConfirm  => null
    , operatorIDIns       => operatorIDIns
  );
end ChangePassword;

/* proc: changePassword
Меняет пароль у оператора.

Параметры:

operatorID                  - ID оператора;
password                    - пароль;
newPassword                 - новый пароль;
newPasswordConfirm          - подтверждение пароля;

*/
PROCEDURE changePassword
 (OPERATORID INTEGER
 ,PASSWORD VARCHAR2
 ,NEWPASSWORD VARCHAR2
 ,NEWPASSWORDCONFIRM VARCHAR2
 )
is
--changePassword
begin
  changePassword(
    operatorID            => operatorID
    , password            => password
    , newPassword         => newPassword
    , newPasswordConfirm  => newPasswordConfirm
    , operatorIDIns       => null
  );
end changePassword;

/* proc: changePassword
Меняет пароль у оператора.

Параметры:
operatorID                  - ID оператора;
password                    - пароль;
newPassword                 - новый пароль;
newPasswordConfirm          - подтверждение пароля;
passwordPolicyCode  - Код парольной политики (
                      NUM_U_L - цифры + буквы в верхнем регистре + буквы в нижнем регистре
                      NUM_U_L_SP - цифры + буквы в верхнем регистре + буквы в нижнем регистре
                        + спецсимволы
                      ). По умолчанию "NUM_U_L_SP".
*/
PROCEDURE changePassword(
  OPERATORID INTEGER
  , PASSWORD VARCHAR2
  , NEWPASSWORD VARCHAR2
  , NEWPASSWORDCONFIRM VARCHAR2
  , passwordPolicyCode varchar2
)
is
--changePassword
begin
  changePassword(
    operatorID            => operatorID
    , password            => password
    , newPassword         => newPassword
    , newPasswordConfirm  => newPasswordConfirm
    , operatorIDIns       => null
    , passwordPolicyCode  => passwordPolicyCode
  );
end changePassword;

/* func: getOperatorName
  Функция поиска имени оператора.

  Входные параметры:
    operatorId                  - ID оператора

  Возврат:
    operator_name               - Имя оператора
*/
function getOperatorName(
  operatorId integer
)
return varchar2
is
  operatorName op_operator.operator_name%type;

-- getOperatorName
begin
  select
    op.operator_name
  into
    operatorName
  from
    op_operator op
  where
    op.operator_id = operatorId
  ;

  return operatorName;
exception
  when no_data_found then
    return null;
end getOperatorName;

/* func: isChangePassword
  Флаг необходимости принудительной смены пароля.

  Входные параметры:
    operatorId                  - ID оператора

  Возврат:
    result                      - 0 - Не меняем
                                  1 - Меняем
*/
function isChangePassword(
  operatorId integer
)
return number
is
  needChangePassword integer;
  currentPasswordHash varchar2(50);
  operatorBeginDate date;
  -- Кол-во дней действия пароля
  passwordDurationDay integer;

-- isChangePassword
begin
  select
    op.change_password
    , op.password
    , op.date_begin
  into
    needChangePassword
    , currentPasswordHash
    , operatorBeginDate
  from
    op_operator op
  where
    op.operator_id = operatorId
  ;

  -- Если признак смены пароля уже установлен - проверки не нужны
  if needChangePassword = 0
    -- Нагорный С.:
    -- здесь проверяем, что у пользователя пароль = 'report'
    -- Если пароль = 'report', значит дальнейшие проверки на срок действия пароля
    -- не производим
    and currentPasswordHash != 'E98D2F001DA5678B39482EFBDF5770DC'
  then
      -- Ищем срок действия текущего пароля
      select
        trunc(
          sysdate - coalesce( max( ph.date_ins), operatorBeginDate)
        ) as password_duration_day
      into
        passwordDurationDay
      from
        op_password_hist ph
      where
        ph.operator_id = operatorId
      ;
      -- Если срок действия пароля истек - устанавливаем флаг
      -- необходимости смены пароля
      if passwordDurationDay > getPasswordValidityPeriod( operatorId) then
        needChangePassword := 1;
      end if;
  end if;

  return needChangePassword;
exception
  when no_data_found then
    return -1;
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , 'Во время проверки необходимости принудительной смены пароля'
        || ' произошла ошибка.'
      , true
    );
end isChangePassword;



/* group: Функции для формирования различных списков ролей и групп */

/* func: getRoles
   Функция возвращает ID роли

Входные параметры:

  login - логин

Выходные параметры(в виде курсора):

    role_id       -  Идентификатор роли
    short_name    -  Краткое наименование роли
    role_name     -  Наименование роли на языке по умолчанию
    role_name_en  -  Наименование роли на английском языке
    description   -  Описание роли на языке по умолчанию
    date_ins      -  Дата создания записи
    operator_id   -  Пользователь, создавший запись
    operator_name     -  Пользователь на языке по умолчанию, создавший запись
    operator_name_en  -  Пользователь на английском языке, создавший запись

*/
FUNCTION getRoles(login  varchar2 )
return sys_refcursor
is

--Возвращаемый курсор
resultSet              sys_refcursor;
--Строка с запросом

sqlText                varchar2(4000);

begin

sqlText := 'select  distinct t.Role_Id
                  , r.short_name
                  , r.role_name
                  , r.role_name_en
                  , r.description
                  , r.date_ins
                  , op2.operator_id
                  , op2.operator_name
                  , op2.operator_name_en
           from v_op_operator_role t
           join op_role r
             on r.role_id = t.role_id
           join op_operator op1
             on op1.operator_id = t.operator_id
           join op_operator op2
             on op2.operator_id = r.operator_id
           where UPPER(op1.LOGIN) = upper(:login)
      order by r.short_name    ';

  --Поиск по логину

  open resultSet
      for sqlText
         using upper(login);

  return resultSet;

--Стандартная отработка исключений
exception
  when others then
  raise_application_error(pkg_Error.ErrorStackInfo
    , 'Возникла ошибка при поиске роли для логина: '||login, true);

end getRoles;

/* func: getRoles
   Функция возвращает ID роли

Входные параметры:

  operatorId - ИД оператора

Выходные параметры(в виде курсора):

    role_id       -  Идентификатор роли
    short_name    -  Краткое наименование роли
    role_name     -  Наименование роли на языке по умолчанию
    role_name_en  -  Наименование роли на английском языке
    description   -  Описание роли на языке по умолчанию
    date_ins      -  Дата создания записи
    operator_id   -  Пользователь, создавший запись
    operator_name     -  Пользователь на языке по умолчанию, создавший запись
    operator_name_en  -  Пользователь на английском языке, создавший запись

*/
FUNCTION getRoles(operatorId  integer )
return sys_refcursor
is

--Возвращаемый курсор
resultSet              sys_refcursor;
--Строка с запросом

sqlText                varchar2(4000);

begin

sqlText := 'select  distinct t.Role_Id
                  , r.short_name
                  , r.role_name
                  , r.role_name_en
                  , r.description
                  , r.date_ins
                  , op2.operator_id
                  , op2.operator_name
                  , op2.operator_name_en
           from v_op_operator_role t
           join op_role r
             on r.role_id = t.role_id
           join op_operator op1
             on op1.operator_id = t.operator_id
           join op_operator op2
             on op2.operator_id = r.operator_id
           where t.operator_id = :operatorId
      order by r.short_name    ';

  --Поиск по логину

  open resultSet
      for sqlText
         using operatorId;

  return resultSet;

--Стандартная отработка исключений
exception
  when others then
  raise_application_error(pkg_Error.ErrorStackInfo
    , 'Возникла ошибка при поиске роли для operator_id: '||operatorId, true);

end getRoles;

 /* func: getRolesShortName
     Функция возвращает short_name роли

Входные параметры:

  login - логин

Выходные параметры(в виде курсора):

   short_name - short_name роли;

*/
FUNCTION getRolesShortName
 (
  login        varchar2 := null
 )
return sys_refcursor
is

--Возвращаемый курсор
resultSet              sys_refcursor;
--Строка с запросом

sqlText                varchar2(4000);

begin

sqlText := 'select distinct (select t.short_name from op_role t
                    where t.role_id = opr.Role_Id ) short_name
     from v_op_operator_role opr
     join op_operator op
       on op.operator_id = opr.operator_id
     where 1=1 ';

  --Поиск по логину
  AddSqlCondition( sqlText,'upper(op.login)', '=', login is null, 'login');

  open resultSet
      for sqlText
         using upper(login);

  return resultSet;

--Стандартная отработка исключений
exception
  when others then
  raise_application_error(pkg_Error.ErrorStackInfo
    , 'Возникла ошибка при поиске роли для логина: '||login, true);

end getRolesShortName;

 /* func: getRolesShortName
     Функция возвращает short_name роли

Входные параметры:

  operatorID - operatorID

Выходные параметры(в виде курсора):

   short_name - short_name роли;

(<body::getRolesShortName>)
*/
FUNCTION getRolesShortName
 (
  operatorID      integer := null
 )
return sys_refcursor
is

--Возвращаемый курсор
resultSet              sys_refcursor;
--Строка с запросом

sqlText                varchar2(4000);

begin

sqlText := 'select distinct (select t.short_name from op_role t
                    where t.role_id = opr.Role_Id ) short_name
     from v_op_operator_role opr
     join op_operator op
       on op.operator_id = opr.operator_id
     where 1=1 ';

  --Поиск по логину
  AddSqlCondition( sqlText,'opr.operator_id', '=', operatorID is null, 'login');

  open resultSet
      for sqlText
         using operatorID;

  return resultSet;

--Стандартная отработка исключений
exception
  when others then
  raise_application_error(pkg_Error.ErrorStackInfo
    , 'Возникла ошибка при поиске роли для ID оператора: '||operatorID, true);

end getRolesShortName;

/* func: getOperator
  Данные по операторам.

  Входные параметры:
  operatorName                - имя оператора (рус.)
  operatorName_en             - имя оператора (англ.)
  rowCount                    - маскимальное количество строк в выходном
                                курсоре. Устаревшее поле. Оставлено для
                                совместимости.
  maxRowCount                 - маскимальное количество строк в выходном
                                курсоре. По-умолчанию 25.

  Возврат (в виде курсора):
  operator_id                 - id оператора
  operator_name               - ФИО оператора
  operator_name_en            - ФИО оператора (англ.)
  login                       - логин
*/
function getOperator(
  operatorName varchar2 default null
  , operatorName_en varchar2 default null
  , maxRowCount integer := null
  , rowCount integer default 25
)
return sys_refcursor
is
  dSql varchar2(32767);
  -- Курсор с результатом поиска
  rc sys_refcursor;

-- getOperator
begin
  -- Специально убрана зависимость от модуля DynamicSql
  dSql := '
select
  t.operator_id
  , t.operator_name
  , t.operator_name_en
  , t.login
from
  op_operator t
where
  ' || case when
         operatorName is not null
       then
         ' upper( t.operator_name ) like upper( :operatorName ) '
       else
         ' :operatorName is null '
       end
    || case when
         operatorName_en is not null
       then
         ' and upper( t.operator_name_en ) like upper( :operatorName_en ) '
       else
         ' and :operatorName_en is null '
       end
    || case when
         coalesce( maxRowCount, rowCount, 25) is not null
       then
         ' and rownum <= :rowCount '
       else
         ' and :rowCount is null '
       end
  ;

  open
    rc
  for
    dSql
	using
	  operatorName
	  , operatorName_en
    , coalesce( maxRowCount, rowCount, 25)
  ;

  -- Выдаем результат
  return rc;
-- Стандартная отработка исключений
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , 'Возникла ошибка при поиске оператора'
    , true
  );
end getOperator;

/* func: getNoOperatorRole
  Функция отображения ролей напрямую не принадлежащих пользователю.

  Входные параметры:
    operatorId                              - Идентификатор пользователя
    operatorIdIns                           - Пользователь, осуществляющий поиск

  Возврат (в виде курсора):
    role_id                                 -	Идентификатор роли
    short_name                              - Краткое наименование роли
    role_name                               - Наименование роли на языке по умолчанию
    role_name_en                            - Наименование роли на английском языке
    description                             - Описание роли на языке по умолчанию
    date_ins                                - Дата создания записи
    operator_id                             - Пользователь, создавший запись
    operator_name                           - Пользователь на языке по умолчанию, создавший запись
    operator_name_en                        - Пользователь на английском языке, создавший запись
*/
function getNoOperatorRole(
  operatorId integer
  , operatorIdIns	integer
)
return sys_refcursor
is
  sqlStr varchar2(32767);
  -- Курсор с результатом поиска
  resultSet  sys_refcursor;

-- getNoOperatorRole
begin
  isUserAdmin( operatorIdIns, null );

  sqlStr := '
select
  opr.role_id
  , opr.short_name
  , opr.role_name
  , opr.role_name_en
  , opr.description
  , opr.date_ins
  , opr.operator_id
  , op.operator_name
  , op.operator_name_en
from
  op_role opr
inner join
  op_operator op
on
  op.operator_id = opr.operator_id
where
  opr.is_unused = 0 '
  ;

  if operatorId is not null then
    sqlStr := sqlStr
      || ' and opr.role_id not in (
             select
               vop.role_id
             from
               op_operator_role vop
             where
               vop.operator_id = :operatorId
               and vop.user_access_flag = 1
             ) '
    ;
  else
    sqlStr := sqlStr
      || ' and :operatorId is null '
    ;
  end if;

  open
    resultSet
  for
    sqlStr
    || ' order by opr.role_id'
  using
    operatorId
  ;

  -- Выдаем результат
  return resultSet;

-- Стандартная отработка исключений
exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , 'Во время поиска роли произошла ошибка.'
      , true
    );
end getNoOperatorRole;

/* func: getNoOperatorGroup
  Функция отображения групп напрямую не принадлежащих пользователю.

  Входные параметры:
    operatorId                              -	Идентификатор пользователя
    operatorIdIns                           -	Пользователь, осуществляющий выборку

  Возврат (в виде курсора):
    group_id                                - Идентификатор группы
    group_name                              - Наименование группы на языке по умолчанию
    group_name_en                           - Наименование группы на английском языке
    date_ins                                - Дата создания записи
    operator_id                             - Пользователь, создавший запись
    operator_name                           - Пользователь на языке по умолчанию, создавший запись
    operator_name_en                        - Пользователь на английском языке, создавший запись
*/
function getNoOperatorGroup(
  operatorId integer
  , operatorIdIns integer
)
return sys_refcursor
is
  sqlStr varchar2(32767);
  -- Курсор с результатом поиска
  resultSet sys_refcursor;

-- getNoOperatorGroup
begin
  isUserAdmin( operatorIdIns, null );

  sqlStr := '
select
  g.group_id
  , g.group_name
  , g.group_name_en
  , g.date_ins
  , g.operator_id
  , op.operator_name
  , op.operator_name_en
from
  op_group g
inner join
  op_operator op
on
  op.operator_id = g.operator_id
where
  g.is_unused = 0 '

  ;

  if operatorId is not null then
    sqlStr := sqlStr
      || ' and g.group_id not in (
             select
               vop.group_id
             from
               op_operator_group vop
             where
               vop.operator_id = :operatorId
             ) '
    ;
  else
    sqlStr := sqlStr
      || ' and :operatorId is null '
    ;
  end if;

  open
    resultSet
  for
    sqlStr || ' order by g.group_id'
  using
    operatorId
  ;

  -- Выдаем результат
  return resultSet;

-- Стандартная отработка исключений
exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , 'Во время поиска групп, напрямую не принадлежащих'
        || ' пользователю произошла ошибка.'
      , true
    );
end getNoOperatorGroup;

/* func: getNoGroupRole
  Функция отображения ролей напрямую не принадлежащих группе.

  Входные параметры:
    groupId                                 - Идентификатор группы
    operatorId                              - Пользователь, осуществляющий выборку

  Возврат (в виде курсора):
    role_id                                 - Идентификатор роли
    short_name                              - Краткое наименование роли
    role_name                               - Наименование роли на языке по умолчанию
    role_name_en                            - Наименование роли на английском языке
    description                             - Описание роли на языке по умолчанию
    date_ins                                - Дата создания записи
    operator_id                             - Пользователь, создавший запись
    operator_name                           - Пользователь на языке по умолчанию, создавший запись
    operator_name_en                        - Пользователь на английском языке, создавший запись
*/
function getNoGroupRole(
  groupId integer
  , operatorId integer
)
return sys_refcursor
is
  sqlStr varchar2(32767);
  -- Курсор с результатом поиска
  resultSet  sys_refcursor;

-- getNoGroupRole
begin
  isRole( operatorID, RoleAdmin_Role );

  sqlStr := '
select
  r.role_id
  , r.short_name
  , r.role_name
  , r.role_name_en
  , r.description
  , r.date_ins
  , op.operator_id
  , op.operator_name
  , op.operator_name_en
from
  op_role r
inner join
  op_operator op
on
  op.operator_id = r.operator_id
where
  r.is_unused = 0 '
  ;

  if operatorId is not null then
    sqlStr := sqlStr
      || ' and r.role_id not in (
             select
               gr.role_id
             from
               op_group_role gr
             where
               gr.group_id = :groupId
           ) '
    ;
  else
    sqlStr := sqlStr
      || ' and :groupId is null '
    ;
  end if;

  open
    resultSet
  for
    sqlStr || ' order by r.role_id'
  using
    groupId
  ;

  -- Выдаем результат
  return resultSet;

-- Стандартная отработка исключений
exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , 'Во время поиска ролей, напрямую не принадлежащих группе,'
        || ' произошла ошибка.'
      , true
    );
end getNoGroupRole;

/* func: getRole
  Функция формирования списка ролей.

  Входные параметры:
    roleName                         - Слово для поиска роли

  Возврат (в виде курсора):
    role_id                          - ИД роли
    role_name                        - Наименование роли
*/
function getRole(
  roleName varchar2
)
return sys_refcursor
is
  -- Курсор с результатом поиска
  resultSet sys_refcursor;

-- getRole
begin
  open
    resultSet
  for
    select
      t.role_id
      , t.role_name
    from
      op_role t
    where
      (
      upper( t.short_name ) like upper( '%' || roleName || '%' )
      or upper( t.description ) like upper( '%' || roleName || '%' )
      or upper( t.role_name ) like upper( '%' || roleName || '%' )
      or upper( t.role_name_en ) like upper( '%' || roleName || '%' )
      )
      and t.is_unused = 0
    order by
      1
    ;

  -- Выдаем результат
  return resultSet;

-- Стандартная отработка исключений
exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , 'Во время формирования списка ролей произошла ошибка.'
      , true
    );
end getRole;

/* func: getGroup
  Функция формирования списка групп.

  Входные параметры:
    groupName                        - Слово для поиска группы

  Возврат (в виде курсора):
    group_id                         - ИД роли
    group_name                       - Наименование роли
*/
function getGroup(
  groupName varchar2
)
return sys_refcursor
is
  -- Курсор с результатом поиска
  resultSet sys_refcursor;

-- getGroup
begin
  open
    resultSet
  for
    select
      t.group_id
      , t.group_name
    from
      op_group t
    where
      (
      upper( t.group_name ) like upper( '%' || groupName || '%' )
      or upper( t.group_name_en ) like upper( '%' || groupName || '%' )
      )
      and t.is_unused = 0
    order by
      1
    ;

  -- Выдаем результат
  return resultSet;

-- Стандартная отработка исключений
exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , 'Во время формирования списка групп произошла ошибка.'
      , true
    );
end getGroup;

/* func: getOperatorIDByLogin
   Функция возвращает ID оператора по логину

   Входные параметры:
   login - логин оператора

   Выходные параметры:
    ID оператора
*/
function getOperatorIDByLogin(login varchar2 )
return integer
is
operatorID integer;
vLogin varchar2(50);
begin

vLogin := login;

 select t.operator_id
    into operatorID
   from op_operator t
   where UPPER(t.login) = UPPER(vLogin);

return operatorID;

exception  --Стандартная отработка исключений
  when NO_DATA_FOUND then
  raise_application_error( pkg_Error.ErrorStackInfo
    , 'Возникла ошибка: ID оператора не найден для логина: '||vLogin, true);
  when others then
  raise_application_error( pkg_Error.ErrorStackInfo
    , 'Возникла ошибка при поиске ID оператора.', true);
end;

/* func: GetRoleID
   Функция возвращает ID роли по краткому наименованию
*/
function GetRoleID(roleName	varchar2)
return integer
is
RoleID integer;
vRoleName varchar2(255);
begin

vRoleName := roleName;

 select t.role_id
    into RoleID
   from op_role t
   where UPPER(t.role_name) = UPPER(vRoleName)
       or UPPER(t.role_name_en) = UPPER(vRoleName)
       or UPPER(t.short_name) = UPPER(vRoleName);

return RoleID;

exception  --Стандартная отработка исключений
  when NO_DATA_FOUND then
  raise_application_error( pkg_Error.ErrorStackInfo
    , 'Возникла ошибка: ID роли не найден для role_name: '||vRoleName, true);
  when others then
  raise_application_error( pkg_Error.ErrorStackInfo
    , 'Возникла ошибка при поиске ID роли.', true);
end;

/* func: GetGroupID
   Функция возвращает ID группы по краткому наименованию
*/
function GetGroupID(groupName	varchar2)
return integer
is

groupID integer;
vgroupName varchar2(255);
begin

vgroupName := groupName;

 select t.group_id
    into groupID
   from op_group t
   where UPPER(t.group_name) = UPPER(vgroupName)
     or UPPER(t.group_name_en) = UPPER(vgroupName);

return groupID;

exception  --Стандартная отработка исключений
  when NO_DATA_FOUND then
  raise_application_error( pkg_Error.ErrorStackInfo
    , 'Возникла ошибка: ID группы не найден для group_name: '||vgroupName, true);
  when others then
  raise_application_error( pkg_Error.ErrorStackInfo
    , 'Возникла ошибка при поиске ID роли.', true);
end;



/* group: Функции для работы с блокировками */

/* func: getLockType
   Функция формирования списка типов блокировок.

   Входные параметры отсутствуют.

   Возврат (в виде курсора):
     lock_type_code               - Код типа блокировки
     lock_type_name               - Наименование типа
*/
function getLockType
return sys_refcursor
is
  resultSet sys_refcursor;
-- getLockType
begin
  open
    resultSet
  for
  select
    lt.lock_type_code
    , lt.lock_type_name
  from
    op_lock_type lt
  ;

  return resultSet;

exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , 'Во время формирования списка типов блокировок произошла ошибка.'
      , true
    );
end getLockType;

end pkg_Operator;
/
