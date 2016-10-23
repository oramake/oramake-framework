create or replace package body pkg_Operator is
/* package body: pkg_Operator::body */



/* group: Переменные пакета */

/* ivar: currentOperatorId
  Id текущего оператора.
*/
currentOperatorId op_operator.operator_id%type;

/* ivar: currentLogin
  Логин текущего оператора.
*/
currentLogin op_operator.login%type;

/* ivar: currentOperatorName
  Имя текущего оператора.
*/
currentOperatorName op_operator.operator_name%type;



/* group: Функции */

/* group: Функции для обратной совместимости */

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

/* func: getOperator
  Получение данных по операторам. В настоящее время *не реализовано* (
  является заглушкой для других модулей).

  Параметры:
  operatorName                - ФИО оператора
                                ( поиск по like без учета регистра)
                                ( по умолчанию без ограничений)
  maxRowCount                 - максимальное число возвращаемых поиском записей
                                ( по умолчанию без ограничений)

  Возврат ( курсор):
  operator_id                 - Id оператора
  operator_name               - ФИО оператора
*/
function getOperator(
  operatorName varchar2 := null
  , maxRowCount integer := null
)
return sys_refcursor
is
begin
  raise_application_error(
    pkg_Error.IllegalArgument
    , 'Not implemented'
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    ,  'Ошибка при получении данных по операторам ('
      || ' operatorName="' || operatorName || '"'
      || ', maxRowCount=' || maxRowCount
      || ').'
    , true
  );
end getOperator;

/* func: createOperator
  Создание пользователя. Обертка для <pkg_AccessOperator::createOperator>.
  Не использовать.
*/
function createOperator(
  operatorName      varchar2
, operatorNameEn  varchar2
, login           varchar2
, password        varchar2
, changePassword  integer
, operatorIdIns   integer
)
return integer
is
-- createOperator
begin
  return
    pkg_AccessOperator.createOperator(
      operatorName        => operatorName
    , operatorNameEn      => operatorNameEn
    , login               => login
    , password            => password
    , changePassword      => changePassword
    , operatorIdIns       => operatorIdIns
    );
end createOperator;

/* proc: deleteOperator
   Удаление пользователя. Обёртка для <pkg_AccessOperator::deleteOperator>.
   Не использовать.
*/
procedure deleteOperator(
  operatorId        integer
  , operatorIdIns   integer
)
is
-- deleteOperator
begin
  pkg_AccessOperator.deleteOperator(
    operatorId      => operatorId
    , operatorIdIns => operatorIdIns
  );
end deleteOperator;

/* proc: createOperatorGroup
  Процедура назначения группы оператору. Обёртка для
  <pkg_AccessOperator::createOperatorGroup>.  Не использовать.
*/
procedure createOperatorGroup(
  operatorId      integer
  , groupId       integer
  , operatorIdIns integer
)
is
-- createOperatorGroup
begin
  pkg_AccessOperator.createOperatorGroup(
    operatorId      => operatorId
    , groupId       => groupId
    , operatorIdIns => operatorIdIns
  );
end createOperatorGroup;



/* group: Регистрация */

/* iproc: login(internal)
  Выполняет проверку и регистрирует оператора в БД. В случае успешной
  регистрации сохраняет данные оператора в переменных пакета, при ошибке
  регистрации - выбрасывает исключение.

  Входные параметры:
  operatorId                  - id оператора;
  operatorLogin               - логин оператора ( используется только, если
                                operatorId null);
  password                    - пароль для проверки доступа;
  isCheckPassword             - нужно ли выполнять проверку пароля ( если
                                null, то выполнять);

  Замечание:
  - регистр логина значения не имеет, пароль проверяется с учетом регистра;
*/
procedure login(
  operatorId integer default null
  , operatorLogin varchar2 default null
  , password varchar2 default null
  , isCheckPassword boolean default null
)
is
  -- Данные оператора
  rec op_operator%rowtype;
  -- Дата проверки прав доступа
  checkDate date;

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
        upper( op.login ) = upper( operatorLogin)
      ;
    end if;
  exception
    when no_data_found then
      null;
  end;
  -- Проверяем логин/пароль ( не разделяем ошибки из-за неверного логина и
  -- неправильного пароля)
  if rec.operator_id is null
    or (
      coalesce( isCheckPassword, true)
      and coalesce( rec.password <> getHash( password ), true)
    )
  then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Указан неверный'
        || case when operatorId is not null then
            ' Id оператора'
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
  currentOperatorId := rec.operator_id;
  currentLogin := rec.login;
  currentOperatorName := rec.operator_name;

exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , 'Ошибка при регистрации оператора ('
      || substr(
        case when operatorId is not null then
          ', operator_id=' || to_char( operatorId)
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
  Регистрирует оператора в базе. Устаревшая функция. Использовать процедуру
  <login(password)>. Оставлена для обратной совместимости.

  Параметры:
  operatorLogin               - логин оператора
  password                    - пароль оператора

  Возврат:
  - логин оператора
*/
function login(
  operatorLogin varchar2
  , password varchar2 := null
)
return varchar2
is
-- login
begin
  login(
    operatorLogin       => operatorLogin
    , password          => password
    , isCheckPassword   => password is not null
  );
  return currentLogin;
end login;

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

/* proc: login(password)
  Регистрирует оператора в базе.

  Параметры:
  operatorLogin               - логин оператора
  password                    - пароль оператора
*/
procedure login(
  operatorLogin varchar2
  , password varchar2
)
is
-- login
begin
  login(
    operatorLogin       => operatorLogin
    , password          => password
    , isCheckPassword   => true
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
  Возвращает идентификатор текущего оператора.

  Входные параметры:
  isRaiseException            - флаг выбрасывания исключения в случае, если
                                текущий оператор не определен

  Возврат:
  oprator_id                  - идентификатор текущего оператора
*/
function getCurrentUserId(
  isRaiseException integer default null
)
return integer
is
-- getCurrentUserId
begin
  if currentOperatorId is null
    and coalesce(isRaiseException, 1) = 1
  then
    raise_application_error(
      pkg_Error.OperatorNotRegister
      , 'Вы не зарегистрировались.'
        || ' Для регистрации в системе выполните функцию Login.'
    );
  end if;
  return currentOperatorId;
end getCurrentUserId;

/* func: getCurrentUserName
  Возвращает имя текущего оператора.

  Входные параметры:
  isRaiseException            - флаг выставления исключения в случае, если
                                текущий оператор не определен;

  Возврат:
  - имя текущего оператора;
*/
function getCurrentUserName(
  isRaiseException integer default 1
)
return varchar2
is
-- getCurrentUserName
begin
  -- Выполняем проверку регистрации
  if getCurrentUserId(
       isRaiseException => isRaiseException
     ) is null
  then
    null;
  end if;
  return currentOperatorName;
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
  shortName op_role.role_short_name%type;
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
      cross join op_role rl
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

end pkg_Operator;
/
