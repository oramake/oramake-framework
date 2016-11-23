CREATE OR REPLACE PACKAGE BODY "PKG_OPERATOR" is
/* package body: pkg_Operator::body */




/* Минимально допустимая длина пароля */
PASSWORD_MINLENGTH CONSTANT INTEGER := 8;
/*Глубина просмотра истории паролей*/
PASSWORD_log_history CONSTANT INTEGER := 3;
/*Срок действия пароля*/
PASSWORD_validity_period CONSTANT INTEGER := 36500;

/* ID текущего оператора */
CURRENTOPERATORID OP_OPERATOR.OPERATOR_ID%TYPE;
/* Логин текущего оператора */
CURRENTLOGIN OP_OPERATOR.LOGIN%TYPE;
/* Имя текущего оператора (рус) */
CURRENTOPERATORNAMERUS OP_OPERATOR.OPERATOR_NAME_RUS%TYPE;

/* proc: AddSqlCondition
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


/* proc: LOGIN
 Выполняет проверку и регистрирует оператора в БД. В случае успешной
 регистрации сохраняет данные оператора в переменных пакета, при ошибке
 регистрации - выбрасывает исключение.

 Входные параметры:

 operatorID                  - ID оператора;
 operatorLogin               - логин оператора ( используется только если
                               operatorID null);
 password                    - пароль для проверки доступа;
 roleID                      - ID роли для проверки ( если null, то
                               проверка не производится);
 isCheckPassword             - нужно ли выполнять проверку пароля ( если
                               null, то выполнять);

 Замечания:
 регистр логина значения не имеет, пароль проверяется с учетом регистра.
*/
PROCEDURE LOGIN
 (OPERATORID INTEGER := null
 ,OPERATORLOGIN VARCHAR2 := null
 ,PASSWORD VARCHAR2 := null
 ,ROLEID INTEGER := null
 ,ISCHECKPASSWORD BOOLEAN := null
 );

/* func: ISROLE
  Проверяет наличие роли у оператора.

  Входные параметры:

  operatorID                  - ID оператора;
  roleID                      - ID роли;
  checkDate                   - дата, на момент которой проверяется наличие роли;

 Возвращаемые значения:

 1 - установлена;
 0 - не установлена;

*/
FUNCTION ISROLE
 (OPERATORID INTEGER
 ,ROLEID INTEGER := null
 ,ROLESHORTNAME VARCHAR2 := null
 ,MAKEERROR BOOLEAN := false
 )
 RETURN INTEGER;

/* proc: ISUSERADMIN
  Проверяет права на администрирование операторов и в случае их отсутствия
  выбрасывает исключение.

  Входные параметры:

  operatorID                  - ID оператора, выполняющего действие;
  targetOperatorID            - ID оператора, над которым выполняется действие;
  roleID                      - ID выдаваемой/забираемой роли;
  groupID                     - ID выдаваемой/забираемой группы;

*/
PROCEDURE ISUSERADMIN
 (OPERATORID INTEGER
 ,TARGETOPERATORID INTEGER := null
 ,ROLEID INTEGER := null
 ,GROUPID INTEGER := null
 );

/* proc: CHANGEPASSWORD
  Меняет пароль у оператора.

  Входные параметры:

  operatorID                  - ID оператора;
  password                    - пароль;
  newPassword                 - новый пароль;
  newPasswordConfirm          - подтверждение пароля;
  operatorIDIns               - ID оператора, выполняющего процедуру;

*/
PROCEDURE CHANGEPASSWORD
 (OPERATORID INTEGER
 ,PASSWORD VARCHAR2 := null
 ,NEWPASSWORD VARCHAR2
 ,NEWPASSWORDCONFIRM VARCHAR2 := null
 ,OPERATORIDINS INTEGER := null
 );


/* func: GETHASH
  Возвращает hex-строку с MD5 контрольной суммой.

  Параметры:

  inputString                 - исходная строка для расчета контрольной суммы;

  Выходные параметры

  Возвращает hex-строку с MD5 контрольной суммой.
*/
FUNCTION GETHASH
 (INPUTSTRING VARCHAR2
 )
 RETURN VARCHAR2
 IS
--GetHash
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
    , 'Ошибка при хэшировании строки.'
    , true
  );
end GetHash;


/* proc: LOGIN
  Выполняет проверку и регистрирует оператора в БД. В случае успешной
  регистрации сохраняет данные оператора в переменных пакета, при ошибке
  регистрации - выбрасывает исключение.

  Параметры:
  operatorID                  - ID оператора;
  operatorLogin               - логин оператора ( используется только если
                                operatorID null);
  password                    - пароль для проверки доступа;
  roleID                      - ID роли для проверки ( если null, то
                               проверка не производится);
  isCheckPassword             - нужно ли выполнять проверку пароля ( если
                               null, то выполнять);

 Замечания:
регистр логина значения не имеет, пароль проверяется с учетом регистра;

*/
PROCEDURE LOGIN
 (OPERATORID INTEGER := null
 ,OPERATORLOGIN VARCHAR2 := null
 ,PASSWORD VARCHAR2 := null
 ,ROLEID INTEGER := null
 ,ISCHECKPASSWORD BOOLEAN := null
 )
 IS
                                        --Данные оператора
  rec op_operator%rowtype;
                                        --Дата проверки прав доступа
  checkDate date;

--Login
begin
                                        --Получаем учетные данные оператора
  begin
    if operatorID is not null then
      select
        op.*
      into rec
      from
        op_operator op
      where
        op.operator_id = operatorID
      ;
    else
                                        --Подсказка для учета функционального
                                        --индекса.
      select /*+ index( op) */
        op.*
      into rec
      from
        op_operator op
      where
        upper( op.login) = upper( operatorLogin)
      ;
    end if;
  exception when NO_DATA_FOUND then
    null;
  end;
                                        --Проверяем логин/пароль ( не разделяем
                                        --ошибки из-за неверного логина
                                        --и неправильного пароля)
  if rec.operator_id is null
      or coalesce( isCheckPassword, true)
        and coalesce( rec.password <> GetHash( password), true)
      then
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
                                        --Проверяем дату действия оператора
  checkDate := sysdate;
  if checkDate < rec.date_begin or checkDate > rec.date_finish then
    raise_application_error(
      pkg_Error.RigthIsMissed
      , 'Доступ к системе запрещен.'
    );
  end if;

                                        --Проверяем наличие роли
  if roleID is not null then
    IsRole(
      operatorID        => rec.operator_id
      , roleID          => roleID
    );
  end if;
                                        --Сохряняем данные оператора
  currentOperatorID     := rec.operator_id;
  currentLogin          := rec.login;
  currentOperatorNameRus:= rec.operator_name_rus;
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
end Login;

/* func: LOGIN
  Регистрирует оператора в базе и возвращает имя оператора.

 Параметры:

 operatorLogin               - логин оператора;
 password                    - пароль;

 Выходные параметры:

 currentOperatorNameRus - ;

*/
FUNCTION LOGIN
 (OPERATORLOGIN VARCHAR2
 ,PASSWORD VARCHAR2
 )
 RETURN VARCHAR2
 IS
--Login
begin
  Login(
    operatorLogin       => operatorLogin
    , password          => password
    , isCheckPassword   => true
  );
  return currentOperatorNameRus;
end Login;


/* func: LOGIN
  Регистрирует оператора в базе и возвращает имя оператора.

 Параметры:

 operatorLogin               - логин оператора;

 Выходные параметры:

 currentOperatorNameRus - ;
)
*/
FUNCTION LOGIN
 (OPERATORLOGIN VARCHAR2
 )
 RETURN VARCHAR2
 IS
--Login
begin
  Login(
    operatorLogin       => operatorLogin
    , isCheckPassword   => false
  );
  return currentOperatorNameRus;
end Login;

/* func: LOGIN
  Регистрирует оператора в базе ( без проверки пароля) и возвращает имя
  оператора в случае наличия у него указанной роли, иначе выбрасывает
  исключение.

  Параметры:
 operatorLogin               - логин оператора;
 roleID                      - ID роли;

 Выходные параметры:

 currentOperatorNameRus - ;

*/
FUNCTION LOGIN
 (OPERATORLOGIN VARCHAR2
 ,ROLEID INTEGER
 )
 RETURN VARCHAR2
 IS
--Login
begin
  Login(
    operatorLogin       => operatorLogin
    , roleID            => roleID
    , isCheckPassword   => false
  );
  return currentOperatorNameRus;
end Login;

/* proc: LOGIN
  Регистрирует оператора в базе ( без проверки пароля).

  Параметры:
  operatorLogin               - логин оператора;

*/
PROCEDURE LOGIN
 (OPERATORLOGIN VARCHAR2
 )
 IS
--Login
begin
  Login(
    operatorLogin       => operatorLogin
    , isCheckPassword   => false
  );
end Login;

/* proc: SETCURRENTUSERID
  Регистрирует оператора в базе ( без проверки пароля).

  Параметры:
 operatorID                  - ID оператора;

*/
PROCEDURE SETCURRENTUSERID
 (OPERATORID INTEGER
 )
 IS
--SetCurrentUserID
begin
  Login(
    operatorID          => operatorID
    , isCheckPassword   => false
  );
end SetCurrentUserID;

/* proc: REMOTELOGIN
   Регистрирует текущего оператора в удаленной БД.

  Параметры:
  dbLink                      - имя линка к удаленной БД;

*/
PROCEDURE REMOTELOGIN
 (DBLINK VARCHAR2
 )
 IS
--RemoteLogin
begin
                                        --Регистрируемся в удаленной БД
  execute immediate
    'begin'
      || ' pkg_Operator.Login@' || dbLink || '( :login);'
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
end RemoteLogin;

/* proc: LOGOFF
   Отменяет текущую регистрацию;

*/
PROCEDURE LOGOFF
 IS

--Logoff
begin
  currentOperatorID           := null;
  currentLogin                := null;
  currentOperatorNameRus      := null;
end Logoff;

/* func: GETCURRENTUSERID
   Возвращает ID текущего оператора ( при отсутствии регистрации - выбрасывает
исключение).

*/
FUNCTION GETCURRENTUSERID
 RETURN INTEGER
 IS
--GetCurrentUserID
begin
  if currentOperatorID is null then
    raise_application_error(
      pkg_Error.OperatorNotRegister
      , 'Вы не зарегистрировались.'
        || ' Для регистрации в системе выполните функцию Login.'
    );
  end if;
  return currentOperatorID;
end GetCurrentUserID;

/* func: GETCURRENTUSERNAME
Возвращает имя текущего оператора ( при отсутствии регистрации - выбрасывает
исключение).

*/
FUNCTION GETCURRENTUSERNAME
 RETURN VARCHAR2
 IS
--GetCurrentUserName
begin
                                        --Выполняем проверку регистрации
  if GetCurrentUserID() is null then
    null;
  end if;
  return currentOperatorNameRus;
end GetCurrentUserName;

/* func: ISROLE
  Проверяет наличие роли у оператора.

  Входные параметры:

  operatorID                  - ID оператора;
  roleID                      - ID роли;
  checkDate                   - дата, на момент которой проверяется наличие роли;

 Возвращаемые значения:

 1 - установлена;
 0 - не установлена;

*/
FUNCTION ISROLE
 (OPERATORID INTEGER
 ,ROLEID INTEGER := null
 ,ROLESHORTNAME VARCHAR2 := null
 ,MAKEERROR BOOLEAN := false
 )
 RETURN INTEGER
 IS
                                        --Признак наличия роли
  isGrant integer := 0;
                                        --Данные по оператору
  operatorNameRus op_operator.operator_name_rus%type;
  dateBegin date;
  dateFinish date;
                                        --Имя роли
  shortName op_role.short_name%type;
                                        --Дата проверки прав доступа
  checkDate date;

--IsRole
begin
  begin
    select
      op.operator_name_rus
      , op.date_begin
      , op.date_finish
      , rl.short_name
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
      op.operator_id = operatorID
      and (
        rl.role_id = roleID
        or rl.short_name = roleShortName
        )
    ;
  exception when NO_DATA_FOUND then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Указан несуществующий ID оператора или'
        || case when roleID is not null then
            ' ID'
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
        || ' short_name="' || shortName || '"'
        ||').'
    );
  end if;
  return isGrant;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , 'Ошибка при проверке наличия роли у оператора ('
      || ' operator_id=' || to_char( operatorID)
      || case when roleID is not null then
          ', role_id=' || to_char( roleID)
        else
          ', short_name="' || to_char( roleShortName) || '"'
        end
      || ').'
    , true
  );
end IsRole;

/* func: ISROLE
  Проверяет наличие роли у оператора.

  Параметры:
  operatorID                  - ID оператора;
  roleID                      - ID роли;

 Возвращаемые значения:
 1 - роль установлена;
 0 - роль не установлена;

*/
FUNCTION ISROLE
 (OPERATORID INTEGER
 ,ROLEID INTEGER
 )
 RETURN INTEGER
 IS

--IsRole
begin
  return
    IsRole(
      operatorID        => operatorID
      , roleID          => roleID
      , makeError       => false
    )
  ;
end IsRole;

/* func: ISROLE
  Проверяет наличие роли у оператора.

  Параметры:

  operatorID                  - ID оператора;
  roleShortName                      - имя роли;

 Возвращаемые значения:

 1 - роль установлена;
 0 - роль не установлена;

*/
FUNCTION ISROLE
 (OPERATORID INTEGER
 ,ROLESHORTNAME VARCHAR2
 )
 RETURN INTEGER
 IS

--IsRole
begin
  return
    IsRole(
      operatorID        => operatorID
      , roleShortName   => roleShortName
      , makeError       => false
    )
  ;
end IsRole;

/* func: ISROLE
  Проверяет наличие роли у текущего оператора.

  Параметры:

  roleID                      - ID роли;

 Возвращаемые значения:

 1 - роль установлена;
 0 - роль не установлена;

*/
FUNCTION ISROLE
 (ROLEID INTEGER
 )
 RETURN INTEGER
 IS

                                        --Признак выдачи роли
  isGrant integer := 0;

--IsRole
begin
  if currentOperatorID is not null then
    isGrant := IsRole(
      operatorID        => currentOperatorID
      , roleID          => roleID
      , makeError       => false
    );
  end if;
  return isGrant;
end IsRole;

/* func: ISROLE
  Проверяет наличие роли у текущего оператора.

  Параметры:
  roleShortName               - имя роли;

 Возвращаемые значения:

 1 - роль установлена;
 0 - роль не установлена;

*/
FUNCTION ISROLE
 (ROLESHORTNAME VARCHAR2
 )
 RETURN INTEGER
 IS
                                        --Признак выдачи роли
  isGrant integer := 0;

--IsRole
begin
  if currentOperatorID is not null then
    isGrant := IsRole(
      operatorID        => currentOperatorID
      , roleShortName   => roleShortName
      , makeError       => false
    );
  end if;
  return isGrant;
end IsRole;

/* proc: ISROLE
 Проверяет наличие роли у оператора и в случае ее отсутствия выбрасывает
 исключение.

 Параметр:

 operatorID                  - ID оператора;
 roleID                      - ID роли;

*/
PROCEDURE ISROLE
 (OPERATORID INTEGER
 ,ROLEID INTEGER
 )
 IS
                                        --Признак наличия роли
  isGrant integer;

--IsRole
begin
  isGrant := IsRole(
    operatorID        => operatorID
    , roleID          => roleID
    , makeError       => true
  );
end IsRole;

/* proc: ISROLE
 Проверяет наличие роли у оператора и в случае ее отсутствия выбрасывает
 исключение.

 Параметр:

 operatorID                  - ID оператора;
 roleShortName               - имя роли;

*/
PROCEDURE ISROLE
 (OPERATORID INTEGER
 ,ROLESHORTNAME VARCHAR2
 )
 IS
                                       --Признак наличия роли
  isGrant integer;

--IsRole
begin
  isGrant := IsRole(
    operatorID        => operatorID
    , roleShortName   => roleShortName
    , makeError       => true
  );
end IsRole;

/* proc: ISROLE
Проверяет наличие роли у текущего оператора и в случае отсутствия регистрации
или роли выбрасывает исключение.

Параметр:

roleID                      - ID роли;
 */
PROCEDURE ISROLE
 (ROLEID INTEGER
 )
 IS
                                        --Признак наличия роли
  isGrant integer;

--IsRole
begin
  isGrant := IsRole(
    operatorID        => GetCurrentUserID()
    , roleID          => roleID
    , makeError       => true
  );
end IsRole;

/* proc: ISROLE
Проверяет наличие роли у текущего оператора и в случае отсутствия регистрации
или роли выбрасывает исключение.

Параметр:

roleShortName               - имя роли;

*/
PROCEDURE ISROLE
 (ROLESHORTNAME VARCHAR2
 )
 IS

                                        --Признак наличия роли
  isGrant integer;

--IsRole
begin
  isGrant := IsRole(
    operatorID        => GetCurrentUserID()
    , roleShortName   => roleShortName
    , makeError       => true
  );
end IsRole;

/* proc: ISUSERADMIN
  Проверяет права на администрирование операторов и в случае их отсутствия
  выбрасывает исключение.

  Входные параметры:

  operatorID                  - ID оператора, выполняющего действие;
  targetOperatorID            - ID оператора, над которым выполняется действие;
  roleID                      - ID выдаваемой/забираемой роли;
  groupID                     - ID выдаваемой/забираемой группы;

*/
PROCEDURE ISUSERADMIN
 (OPERATORID INTEGER
 ,TARGETOPERATORID INTEGER := null
 ,ROLEID INTEGER := null
 ,GROUPID INTEGER := null
 )
 IS

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
        , 'Изменеия запрещены,'
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
      minus
      select distinct
        opr.group_id
      from
        op_operator_group opr
      where
        opr.operator_id = operatorID
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
        , 'Изменеия запрещены,'
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

/* proc: CREATEROLE
Создает роль.

Параметры:

roleID                      - ID роли;
roleNameRus                 - название роли ( рус.);
roleNameEng                 - название роли ( анг.);
shortName                   - короткое название роли;
description                 - описание;
operatorID                  - ID оператора, выполняющего процедуру;

*/
PROCEDURE CREATEROLE
 (ROLEID INTEGER
 ,ROLENAMERUS VARCHAR2
 ,ROLENAMEENG VARCHAR2
 ,SHORTNAME VARCHAR2
 ,DESCRIPTION VARCHAR2 := null
 ,OPERATORID INTEGER
 )
 IS
--CreateRole
begin
                                        --Проверяем права оператора
  IsRole( operatorID, RoleAdmin_Role);
                                        --Создаем роль
  insert into
    op_role
  (
    role_id,
    role_name_rus,
    role_name_eng,
    short_name,
    description,
    operator_id
  )
  values
  (
    roleID,
    roleNameRus,
    roleNameEng,
    shortName,
    description,
    operatorID
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , 'Ошибка при создании роли ('
      || ' role_id=' || to_char( roleID)
      || ', short_name="' || to_char( shortName) || '"'
      || ').'
    , true
  );
end CreateRole;

/* func: CREATEROLE
Создает роль.

Параметры:

roleNameRus                 - название роли ( рус.);
roleNameEng                 - название роли ( анг.);
shortName                   - короткое название роли;
description                 - описание;
operatorID                  - ID оператора, выполняющего процедуру;

*/
function CREATEROLE
 ( ROLENAMERUS VARCHAR2
 ,ROLENAMEENG VARCHAR2
 ,SHORTNAME VARCHAR2
 ,DESCRIPTION VARCHAR2 := null
 ,OPERATORID INTEGER
 )
return integer
 IS
--CreateRole
id integer;
begin
                                        --Проверяем права оператора
  IsRole( operatorID, RoleAdmin_Role);
                                        --Создаем роль
  insert into
    op_role
  (
   -- role_id,
    role_name_rus,
    role_name_eng,
    short_name,
    description,
    operator_id
  )
  values
  (
   -- roleID,
    roleNameRus,
    roleNameEng,
    shortName,
    description,
    operatorID
  )
 returning role_id into id;

  return id;

exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , 'Ошибка при создании роли ('
      || ' role_id=' || to_char( id)
      || ', short_name="' || to_char( shortName) || '"'
      || ').'
    , true
  );
end CreateRole;


/* proc: UPDATEROLE
Изменяет роль.

Параметры:

roleID                      - ID роли;
roleNameRus                 - название роли ( рус.);
roleNameEng                 - название роли ( анг.);
shortName                   - короткое название роли;
description                 - описание;
operatorID                  - ID оператора, выполняющего процедуру;

*/
PROCEDURE UPDATEROLE
 (ROLEID INTEGER
 ,ROLENAMERUS VARCHAR2
 ,ROLENAMEENG VARCHAR2
 ,SHORTNAME VARCHAR2
 ,DESCRIPTION VARCHAR2
 ,OPERATORID INTEGER
 )
 IS
--UpdateRole
begin
                                        --Проверяем права оператора
  IsRole( operatorID, RoleAdmin_Role);
                                        --Изменяем роль
  update
    op_role r
  set
    r.role_name_rus = roleNameRus,
    r.role_name_eng = roleNameEng,
    r.short_name = shortName,
    r.description = UpdateRole.description
  where
    r.role_id = roleID
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , 'При исправлении данных по роли возникла ошибка ('
      || ' role_id=' || to_char( roleID)
      || ').'
    , true
  );
end UpdateRole;


/* func: CREATEGROUP
Создает группу и возвращает ее ID.

Параметры:

groupNameRus                - название группы ( рус.);
groupNameEng                - название группы ( анг.);
isGrantOnly                 - если 1, то группа предоставляет право только;
                              выдавать данные ей роли другим операторам;
operatorID                  - ID оператора, выполняющего действие;

Выходные параметры:

groupID

*/
FUNCTION CREATEGROUP
 (GROUPNAMERUS VARCHAR2
 ,GROUPNAMEENG VARCHAR2
 ,ISGRANTONLY INTEGER := null
 ,OPERATORID INTEGER
 )
 RETURN INTEGER
 IS
                                        --ID созданной группы
  groupID op_group.group_id%type;

--CreateGroup
begin
                                        --Проверяем права оператора
  IsRole( operatorID, RoleAdmin_Role);
                                        --Добавляем группу
  insert into
    op_group
  (
    group_name_rus,
    group_name_eng,
    is_grant_only,
    operator_id
  )
  values
  (
    groupNameRus,
    groupNameEng,
    coalesce( isGrantOnly, 0),
    operatorID
  )
  returning group_id into groupID;
  return groupID;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , 'При создании группы возникла ошибка ('
      || ' group_name_rus="' || groupNameRus || '"'
      || ').'
    , true
  );
end CreateGroup;

/* proc: UPDATEGROUP
Изменяет группу.

Параметры:

groupID                     - ID группы;
groupNameRus                - название группы ( рус.);
groupNameEng                - название группы ( анг.);
isGrantOnly                 - если 1, то группа предоставляет право только;
                              выдавать данные ей роли другим операторам;
operatorID                  - ID оператора, выполняющего процедуру;

*/
PROCEDURE UPDATEGROUP
 (GROUPID INTEGER
 ,GROUPNAMERUS VARCHAR2
 ,GROUPNAMEENG VARCHAR2
 ,ISGRANTONLY INTEGER
 ,OPERATORID INTEGER
 )
 IS
--UpdateGroup
begin
                                        --Проверяем права оператора
  IsRole( operatorID, RoleAdmin_Role);
                                        --Изменяем группу
  update
    op_group g
  set
    g.group_name_rus = groupNameRus,
    g.group_name_eng = groupNameEng,
    g.is_grant_only = isGrantOnly
  where
    g.group_id = groupID
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , 'При изменении группы возникла ошибка ('
      || ' group_id=' || to_char( groupID)
      || ').'
    , true
  );
end UpdateGroup;


/* proc: CREATEGROUPROLE
Включает роль в группу.

Параметры:

groupID                     - ID группы;
roleID                      - ID роли;
operatorID                  - ID оператора, выполняющего процедуру;

*/
PROCEDURE CREATEGROUPROLE
 (GROUPID INTEGER
 ,ROLEID INTEGER
 ,OPERATORID INTEGER
 )
 IS
--CreateGroupRole
begin
                                        --Проверяем права оператора
  IsRole( operatorID, RoleAdmin_Role);
                                        --Включаем роль в группу
  insert into
    op_group_role
  (
    group_id
    , role_id
    , operator_id
  )
  values
  (
    groupID
    , roleID
    , operatorID
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , 'При включении роли в группу возникла ошибка ('
      || ' role_id=' || to_char( roleID)
      || ' , role_id=' || to_char( groupID)
      || ').'
    , true
  );
end CreateGroupRole;

/* proc: DELETEGROUPROLE
Удаляет роль из группы.

Параметры:

groupID                     - ID группы
roleID                      - ID роли
operatorID                  - ID оператора, выполняющего процедуру

*/
PROCEDURE DELETEGROUPROLE
 (GROUPID INTEGER
 ,ROLEID INTEGER
 ,OPERATORID INTEGER
 )
 IS
--DeleteGroupRole
begin
                                        --Проверяем права оператора
  IsRole( operatorID, RoleAdmin_Role);
                                        --Удаляем роль из группы
  delete from
    op_group_role gr
  where
    gr.group_id = groupID
    and gr.role_id = roleID
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , 'При удалении роли из группы возникла ошибка ('
      || ' role_id=' || to_char( roleID)
      || ' , role_id=' || to_char( groupID)
      || ').'
    , true
  );
end DeleteGroupRole;

/* proc: CREATEGRANTGROUP
Добавляет право на выдачу группы.

Параметры:

groupID                     - ID группы, которой выдается право выдачи;
grantGroupID                - ID выдаваемой группы;
operatorID                  - ID оператора, выполняющего процедуру;

*/
PROCEDURE CREATEGRANTGROUP
 (GROUPID INTEGER
 ,GRANTGROUPID INTEGER
 ,OPERATORID INTEGER
 )
 IS
--CreateGrantGroup
begin
                                        --Проверяем права оператора
  IsRole( operatorID, RoleAdmin_Role);
                                        --Добавляем запись
  insert into
    op_grant_group
  (
    group_id
    , grant_group_id
    , operator_id
  )
  values
  (
    groupID
    , grantGroupID
    , operatorID
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , 'Ошибка при добавлении прав на выдачу группы ('
      || ' group_id=' || to_char( groupID)
      || ', grant_group_id=' || to_char( grantGroupID)
      || ').'
    , true
  );
end CreateGrantGroup;

/* proc: DELETEGRANTGROUP
Удаляет право на выдачу группы.

Параметры:

groupID                     - ID группы, у которой удаляет право выдачи;
grantGroupID                - ID выдаваемой группы;
operatorID                  - ID оператора, выполняющего процедуру;

*/
PROCEDURE DELETEGRANTGROUP
 (GROUPID INTEGER
 ,GRANTGROUPID INTEGER
 ,OPERATORID INTEGER
 )
 IS
--DeleteGrantGroup
begin
                                        --Проверяем права оператора
  IsRole( operatorID, RoleAdmin_Role);
                                        --Удяляем запись
  delete from
    op_grant_group gg
  where
    gg.group_id = groupID
    and gg.grant_group_id = grantGroupID
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , 'Ошибка при удалении прав на выдачу группы ('
      || ' group_id=' || to_char( groupID)
      || ', grant_group_id=' || to_char( grantGroupID)
      || ').'
    , true
  );
end DeleteGrantGroup;

/* func: CREATEOPERATOR
Создает нового оператора и возвращает его ID.

Параметры:

operatorNameRus                - имя оператора;
operatorNameEng             - имя оператора (на английском);
login                       - логин;
password                    - пароль;
changepassword              - флаг смены пароля оператора;
operatorIDIns               - ID оператора, выполняющего процедуру;

*/
FUNCTION CREATEOPERATOR
 (OPERATORNAMERUS VARCHAR2
 ,OPERATORNAMEENG VARCHAR2
 ,LOGIN VARCHAR2
 ,PASSWORD VARCHAR2
 ,CHANGEPASSWORD INTEGER
 ,OPERATORIDINS INTEGER
 )
 RETURN INTEGER
 IS
                                        --ID нового оператора
  operatorID op_operator.operator_id%type;

                                        --Хэш пароля
  passwordHash op_operator.password%type := GetHash( password);

--CreateOperator
begin
                                        --Проверяем права оператора
  IsUserAdmin(
    operatorID          => operatorIDIns
    , targetOperatorID  => null
  );
                                        --Создаем запись
  insert into
    op_operator
  (
    operator_name_rus
    , operator_name_eng
    , login
    , password
    , change_password
    , operator_id_ins
  )
  values
  (
    operatorNameRus
    , operatorNameEng
    , login
    , passwordHash
    , changepassword
    , operatorIDIns
  )
  returning operator_id into operatorID;
  return ( operatorID);
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , 'Ошибка при создании оператора ('
      || ' login="' || login || '"'
      || ').'
    , true
  );
end CreateOperator;

/* func: CreateOperatorHash
Создает нового оператора и возвращает его ID.

Параметры:

operatorName             - имя оператора;
operatorNameEn             - имя оператора (на английском);
login                       - логин;
passwordHash                - Hash пароль;
changepassword              - флаг смены пароля оператора;
operatorIDIns               - ID оператора, выполняющего процедуру;
(<body::CreateOperatorHash>)
*/
function createOperatorHash
 (operatorName varchar2
 ,operatorNameEn varchar2
 ,login           varchar2
 ,passwordHash    varchar2
 ,changePassword  integer
 ,operatorIdIns   integer
 )
 RETURN INTEGER
 IS
                                        --ID нового оператора
  operatorID op_operator.operator_id%type;

dr op_operator%rowtype;

--Хэш пароль
--PasswordHash op_operator.password%type;-- := GetHash( password);

--CreateOperator
begin
                                        --Проверяем права оператора
  IsUserAdmin(
    operatorID          => operatorIDIns
    , targetOperatorID  => null
  );
                                        --Создаем запись

     select
        op_operator_seq.nextval
       into dr.operator_id
     from dual;

     dr.operator_name_rus := operatorName;
     dr.login             := login;
     dr.password          := passwordHash;
     dr.date_begin        := sysdate;
     dr.date_finish       := null;--to_date('01.01.4000');
     dr.date_ins          := sysdate;
     dr.operator_id_ins   := operatorIdIns;
     dr.operator_name_eng := operatorNameEn;
     dr.change_password   := changePassword;
     dr.operator_name     := operatorName;
     dr.operator_name_en  := operatorNameEn;

insert into op_operator values dr;

   return dr.operator_id ;

  return ( operatorID);
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , 'Ошибка при создании оператора ('
      || ' login="' || login || '"'
      || ').'
    , true
  );
end createOperatorHash;

/* proc: UPDATEOPERATOR
Изменяет данные оператора.

Параметры:

operatorID                  - id оператора;
operatorNameRus             - имя оператора;
operatorNameEng             - имя оператора (на английском);
login                       - логин;
changePassword              - флаг смены пароля;
operatorIDIns               - ID оператора, выполняющего процедуру;

*/
PROCEDURE UPDATEOPERATOR
 (OPERATORID INTEGER
 ,OPERATORNAMERUS VARCHAR2
 ,OPERATORNAMEENG VARCHAR2
 ,LOGIN VARCHAR2
 ,CHANGEPASSWORD INTEGER
 ,OPERATORIDINS INTEGER
 )
 IS
--UpdateOperator
begin
                                        --Проверяем права доступа
  IsUserAdmin(
    operatorID          => operatorIDIns
    , targetOperatorID  => operatorID
  );
                                        --Выполняем обновление
  update
    op_operator opo
  set
    opo.operator_name_rus = OperatorNameRus,
    opo.operator_name_eng = OperatorNameEng,
    opo.login = UpdateOperator.Login,
    opo.change_password = ChangePassword
  where
    opo.operator_id = operatorID
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , 'Ошибка при изменении данных оператора ('
      || ' operator_id=' || to_char( operatorID)
      || ').'
    , true
  );
end UpdateOperator;

/* proc: CHANGEPASSWORD
Меняет пароль у оператора.

Параметры:

operatorID                  - ID оператора;
password                    - пароль;
newPassword                 - новый пароль;
newPasswordConfirm          - подтверждение пароля;
operatorIDIns               - ID оператора, выполняющего процедуру;

*/
PROCEDURE CHANGEPASSWORD
 (OPERATORID INTEGER
 ,PASSWORD VARCHAR2 := null
 ,NEWPASSWORD VARCHAR2
 ,NEWPASSWORDCONFIRM VARCHAR2 := null
 ,OPERATORIDINS INTEGER := null
 )
 IS
                                        --Хэши пароля
  passwordHash op_operator.password%type;

  cursor curPasswordLog is    --Курсор для повторения паролей
    select vh.password
    from v_op_password_hist vh
    where vh.operator_id=OPERATORID
    order by date_end desc;

  pass varchar(50);                --исторический пароль
  newPasswordUpper varchar2(100);  --переменная для множества [A..Z]
  newPasswordLower varchar2(100);  --переменная для множества [a..z]
  newPasswordDigit varchar2(100);  --переменная для множества [0..9]
  newPasswordEdit  varchar2(100);  --переменная для нового пароля

--ChangePassword
begin
                                        --Проверяем существование и блокируем
                                        --(без ожидания) запись оператора
  begin
    select
      op.password
    into passwordHash
    from
      op_operator op
    where
      op.operator_id = operatorID
    for update of password nowait;

  exception when NO_DATA_FOUND then     --Уточняем сообщение об ошибке
    raise_application_error(
      pkg_Error.RowNotFound
      , 'Оператор не найден.'
    );
  end;
  if operatorIDIns is not null then
                                        --Проверяем права доступа
    IsUserAdmin(
      operatorID          => operatorIDIns
      , targetOperatorID  => operatorID
    );
  else
                                        --Проверяем текущий пароль
    if coalesce( passwordHash <> GetHash( password), true) then
      raise_application_error(
        pkg_Error.IllegalArgument
        , 'Текущий пароль указан неверно.'
      );
    end if;
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

                                        --Проверяем совпадение новых паролей
    if coalesce( newPassword <> newPasswordConfirm
          , coalesce( newPassword, newPasswordConfirm) is not null
        )
        then
      raise_application_error(
        pkg_Error.IllegalArgument
        ,'Новый пароль не совпадает с подтверждением.'
      );
    end if;
  end if;
                                        --Меняем пароль и сбрасываем фла смены
                                        --пароля
  passwordHash := GetHash( newPassword);
  update
    op_operator op
  set
    op.password = passwordHash
    , op.change_password = 0
  where
    op.operator_id = operatorID
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , 'Ошибка при смене пароля оператора ('
      || ' operator_id=' || to_char( operatorID)
      || ').'
    , true
  );
end ChangePassword;



/* proc: changePasswordHash
Меняет пароль у оператора.

Параметры:

operatorID                  - ID оператора;
passwordHash                    - пароль;
newPasswordHash             - Hash новый пароль;
newPasswordConfirmHash      - Hash подтверждение пароля;
operatorIDIns               - ID оператора, выполняющего процедуру;
*/
procedure ChangePasswordHash
 ( operatorId             integer
 , passwordHash           varchar2 := null
 , newPasswordHash        varchar2
 , newPasswordConfirmHash varchar2 := null
 , operatorIdIns          integer := null
 )
 IS
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
        raise_application_error(  pkg_Error.RowNotFound , 'Оператор не найден.');
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
        , 'Текущий пароль указан неверно.' );

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
           ,'Новый пароль не совпадает с подтверждением.' );
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

/* proc: ChangePasswordHash
Меняет пароль у оператора.

Параметры:

operatorID                  - ID оператора;
passwordHash                - Hash пароль;
operatorIDIns               - ID оператора, выполняющего процедуру;
*/
procedure ChangePasswordHash (operatorid integer
                             ,passwordHash varchar2
                             ,operatoridins integer
                             )
is
--ChangePasswordHash
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


/* proc: CHANGEPASSWORD
Меняет пароль у оператора.

Параметры:

operatorID                  - ID оператора;
password                    - пароль;
operatorIDIns               - ID оператора, выполняющего процедуру;

*/
PROCEDURE CHANGEPASSWORD
 (OPERATORID INTEGER
 ,PASSWORD VARCHAR2
 ,OPERATORIDINS INTEGER
 )
 IS
--ChangePassword
begin
  ChangePassword(
    operatorID            => operatorID
    , password            => null
    , newPassword         => password
    , newPasswordConfirm  => null
    , operatorIDIns       => operatorIDIns
  );
end ChangePassword;

/* proc: CHANGEPASSWORD
Меняет пароль у оператора.

Параметры:

operatorID                  - ID оператора;
password                    - пароль;
newPassword                 - новый пароль;
newPasswordConfirm          - подтверждение пароля;

*/
PROCEDURE CHANGEPASSWORD
 (OPERATORID INTEGER
 ,PASSWORD VARCHAR2
 ,NEWPASSWORD VARCHAR2
 ,NEWPASSWORDCONFIRM VARCHAR2
 )
 IS
--ChangePassword
begin
  ChangePassword(
    operatorID            => operatorID
    , password            => password
    , newPassword         => newPassword
    , newPasswordConfirm  => newPasswordConfirm
    , operatorIDIns       => null
  );
end ChangePassword;

/* proc: DELETEOPERATORROLE
Отбирает роль у оператора.

Параметры:

operatorID                  - ID оператора;
roleID                      - ID роли;
operatorIDIns               - ID оператора, выполняющего процедуру;

*/
PROCEDURE DELETEOPERATORROLE
 (OPERATORID INTEGER
 ,ROLEID INTEGER
 ,OPERATORIDINS INTEGER
 )
 IS
--DeleteOperatorRole
begin
                                        --Проверяем права доступа
  IsUserAdmin(
    operatorID          => operatorIDIns
    , roleID            => roleID
  );
                                        --Отбираем роль
  delete from
    op_operator_role opr
  where
    opr.operator_id = operatorID
    and opr.role_id = roleID
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , 'Ошибка при отбирании роли у оператора ('
      || ' operator_id=' || to_char( operatorID)
      || ' , role_id=' || to_char( roleID)
      || ').'
    , true
  );
end DeleteOperatorRole;

/* proc: CREATEOPERATORGROUP
Включает оператора в группу.

Параметры:

operatorID                  - ID оператора;
groupID                     - ID группы;
operatorIDIns               - ID оператора, выполняющего процедуру;

*/
PROCEDURE CREATEOPERATORGROUP
 (OPERATORID INTEGER
 ,GROUPID INTEGER
 ,OPERATORIDINS INTEGER
 )
 IS
--CreateOperatorGroup
begin
                                        --Проверяем права доступа
  IsUserAdmin(
    operatorID          => operatorIDIns
    , groupID           => groupID
  );
                                        --Включаем в группу
  insert into
    op_operator_group
  (
    operator_id,
    group_id,
    operator_id_ins
  )
  values
  (
    operatorID,
    groupID,
    operatorIDIns
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , 'Ошибка при включении оператора в группу ('
      || ' operator_id=' || to_char( operatorID)
      || ' , group_id=' || to_char( groupID)
      || ').'
    , true
  );
end CreateOperatorGroup;

/* proc: DELETEOPERATORGROUP
Удаляет оператора из группы.

Параметры:

operatorID                  - ID оператора;
groupID                     - ID группы;
operatorIDIns               - ID оператора, выполняющего процедуру;

*/
PROCEDURE DELETEOPERATORGROUP
 (OPERATORID INTEGER
 ,GROUPID INTEGER
 ,OPERATORIDINS INTEGER
 )
 IS
--DeleteOperatorGroup
begin
                                        --Проверяем права доступа
  IsUserAdmin(
    operatorID          => operatorIDIns
    , groupID           => groupID
  );
                                        --Отбираем роль
  delete from
    op_operator_group opg
  where
    opg.operator_id = operatorID
    and opg.group_id = groupID
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , 'Ошибка при исключении оператора из группы ('
      || ' operator_id=' || to_char( operatorID)
      || ' , group_id=' || to_char( groupID)
      || ').'
    , true
  );
end DeleteOperatorGroup;

/* func: GETOPERATORNAME
Возвращает имя оператора

Параметры:
operatorID                  - ID оператора

Выходные параметры:

Имя оператора

*/
FUNCTION GETOPERATORNAME
 (OPERATORID INTEGER
 )
 RETURN VARCHAR2
 IS

   OperatorName op_operator.operator_name_rus%type;
begin
	 									--ф-я min() используется для
										--избежания исключения NO_DATA_FOUND
   select min(operator_name_rus)
     into OperatorName
	 from op_operator
    where operator_id = OperatorId;

   return OperatorName;
end getOperatorName;

/* func: ISCHANGEPASSWORD
Флаг необходимости принудительной смены пароля
0-НЕ меняем
1-Меняем

Параметры:
operatorID                  - ID оператора

 */
FUNCTION ISCHANGEPASSWORD
 (OPERATORID INTEGER
 )
 RETURN number
 IS


  TYPE curTypePassword IS REF CURSOR  ; --Тип курсор для выборки срока действия пароля
  CurPassword curTypePassword;          --Курсор
  sqlString varchar2(400);              --Строка с запросом
  countPassword integer;                --Кол-во дней действия пароля

  cursor curChangePassword is           --Курсор для проверки Change_Password и Password
    select o.change_password, o.password
    from op_operator o
    where o.operator_id=OPERATORID;

  ChangePassword number;
  PasswordHash varchar2(50);

--IsChangePassword
begin
  if OPERATORID is null then
    return -1;
  end if;

  open curChangePassword;
  fetch curChangePassword into ChangePassword, PasswordHash ;
  close curChangePassword;

  if ChangePassword=1 then
    return 1;
  end if;

  if ChangePassword is null then
    return -1;
  end if;

  /*Нагорный С.:
  здесь проверяем, что у пользователя пароль = 'report'
  Если пароль = 'report', значит дальнейшие проверки на срок действия пароля
  не производим
  Данное исключение работает для пользователей CL, которых залили в RFInfo
  для просмотра отчетов
  */
  if PasswordHash = 'E98D2F001DA5678B39482EFBDF5770DC' then
  return 0;
  end if;


                                 --проверка срок действия текущего пароля
  sqlString:='select (sysdate-vh.date_begin) d_b
              from v_op_password_hist vh
              where vh.operator_id=:op_id
              and vh.date_end>SYSDATE';

  open CurPassword for SQLString using OPERATORID;
  fetch CurPassword into countPassword;
  close CurPassword;

  if countPassword > pkg_operator.password_validity_period then
    return 1;
  end if;

  return 0;

end ISCHANGEPASSWORD;

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
                  , op2.operator_name_rus operator_name
                  , op2.operator_name_eng operator_name_en
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
                  , op2.operator_name_rus operator_name
                  , op2.operator_name_eng operator_name_en
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
     Функция возвращает

Входные параметры:

    operatorName - Имя оператора(рус)
    operatorName_en - Имя оператора(Англ.)

Выходные параметры(в виде курсора):

   operator_Id - ID оператора;
   Operator_Name - ФИО оператора;
   Operator_Name_en - ФИО оператора (END);
   maxRowCount                - максимальное количество записей

(<body::getOperator>)
*/
FUNCTION getOperator
 (
  operatorName        varchar2 := null
 ,operatorName_en     varchar2 := null
 , maxRowCount        integer  := null
 )
return sys_refcursor is

  SQLstr varchar2(2000);
  TYPE curTypeResult     IS REF CURSOR;          --Тип курсор для выборки результата
  curResult              curTypeResult;          --Курсор с результатом поиска

begin

SQLstr := '
select v.operator_id
            ,v.operator_name_rus Operator_Name
            ,v.operator_name_eng Operator_Name_en
      from op_operator v
   where 1=1 ' ;

 AddSqlCondition( SQLstr, ' upper(v.operator_name_rus)', 'like', operatorName is null,'operatorName');
 AddSqlCondition( SQLstr, ' upper(v.operator_name_eng)', 'like', operatorName_en is null,'operatorName_en');
 AddSqlCondition( SQLstr, ' rownum', '<=', maxRowCount is null,'maxRowCount');

 open  curResult FOR SQLstr
	using
		upper(operatorName)
		, upper(operatorName_en)
    , maxRowCount;


  return curResult;--Выдаем результат

exception  --Стандартная отработка исключений
  when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , 'Возникла ошибка при поиске оператора.'
    , true
  );
end;

/* proc: RestoreOperator
   Процедура восстановления удаленного пользователя RestoreOperator

   Входные параметры:
   operatorId	        -	Пользователь, которого необходимо восстановить
   restoreOperatorId	-	Пользователь, который восстанавливает запись

*/
procedure RestoreOperator( operatorId	integer,
                           restoreOperatorId	integer)
is

begin

ISUSERADMIN(OPERATORID => restoreOperatorId
                     , TARGETOPERATORID => operatorId);

update op_operator op
  set op.date_finish = null
  where op.operator_id = operatorId;

end;

/* func: CreateOperator
   Функция создания пользователя CreateOperator

   Входные параметры:
     operatorName	-	Наименование пользователя на языке по умолчанию
     operatorNameEn	-	Наименование пользователя на английском языке
     login	-	Логин
     password	-	Пароль
     changePassword	-	Признак необходимости изменения пароля пользователем:
                    1 – пользователю необходимо изменить пароль;
                    0 – пользователю нет необходимости менять пароль.
     operatorIdIns	-	Пользователь, создавший запись

    Выходные параметры:

    ID созданного оператора
*/
function CreateOperator(operatorName	  varchar2,
                        operatorNameEn	varchar2,
                        login	          varchar2,
                        password	      varchar2,
                        changePassword	integer,
                        operatorIdIns	  integer)
return integer
is
dr op_operator%rowtype;
begin

IsUserAdmin(operatorIdIns, null);

     select
        op_operator_seq.nextval
       into dr.operator_id
     from dual;

     dr.operator_name_rus := operatorName;
     dr.login             := login;
     dr.password          := GetHash(password);
     dr.date_begin        := sysdate;
     dr.date_finish       := null;--to_date('01.01.4000');
     dr.date_ins          := sysdate;
     dr.operator_id_ins   := operatorIdIns;
     dr.operator_name_eng := operatorNameEn;
     dr.change_password   := changePassword;
     dr.operator_name     := operatorName;
     dr.operator_name_en  := operatorNameEn;

insert into op_operator values dr;

   return dr.operator_id ;

exception when others then

  raise_application_error( pkg_Error.ErrorStackInfo
    , 'Ошибка при создании оператора ('
      || ' login="' || login || '"'  || ').', true );

end;

/* proc: UpdateOperator
   Процедура обновления пользователя UpdateOperator

   Входные параметры:
     operatorId - ID оператора для изменения
     operatorName	-	Наименование пользователя на языке по умолчанию
     operatorNameEn	-	Наименование пользователя на английском языке
     login	-	Логин
     password	-	Пароль
     changePassword	-	Признак необходимости изменения пароля пользователем:
                    1 – пользователю необходимо изменить пароль;
                    0 – пользователю нет необходимости менять пароль.
     operatorIdIns	-	Пользователь, создавший запись

*/
procedure UpdateOperator( operatorId	    integer,
                          operatorName	  varchar2,
                          operatorNameEn	varchar2,
                          login	          varchar2,
                          password	      varchar2,
                          changePassword	integer,
                          operatorIdIns	  integer)
is

dr op_operator%rowtype;

begin
 IsUserAdmin(operatorIdIns, null);

     dr.operator_name_rus := operatorName;
     dr.login             := login;
     dr.operator_name_eng := operatorNameEn;
     dr.change_password   := changePassword;
     dr.operator_name     := operatorName;
     dr.operator_name_en  := operatorNameEn;

 update op_operator t
   set
       t.operator_name_rus = dr.operator_name_rus
     , t.operator_name_eng = dr.operator_name_eng
     , t.operator_name     = dr.operator_name
     , t.operator_name_en  = dr.operator_name_en

     , t.login             = dr.login
     , t.change_password   = dr.change_password
   where t.operator_id = operatorId;

    if password is not null
    then
    pkg_operator.CHANGEPASSWORD( operatorId,
                                     password,
                                     operatorIdIns);
    end if;

 update op_operator t
   set t.change_password   = dr.change_password
   where t.operator_id = operatorId;

exception when others then
  raise_application_error( pkg_Error.ErrorStackInfo
    , 'Ошибка при изменении данных оператора ('
      || ' operator_id=' || to_char(operatorID) || ').'
    , true );
end;

/* proc: DeleteOperator
   Процедура удаления пользователя DeleteOperator

   Входные параметры:
     operatorId - ID оператора для удаления
     operatorIdIns	-	Пользователь, удалющий запись
*/
procedure DeleteOperator( operatorId	integer,
                          operatorIdIns	integer)
is

begin
 IsUserAdmin(operatorIdIns, operatorId);

  update op_operator t
   set
       t.date_finish = sysdate
   where t.operator_id = operatorId;

exception when others then
  raise_application_error( pkg_Error.ErrorStackInfo
    , 'Ошибка при удалении оператора ('
      || ' operator_id=' || to_char(operatorID) || ').'
    , true );
end;

/* func: FindOperator
   Функция поиска пользователя FindOperator

   Входные параметры:
       operatorId	-	Идентификатор пользователя
       login	-	Логин пользователя
       operatorName	-	Наименование пользователя на языке по умолчанию
       operatorNameEn	-	Наименование пользователя на английском языке
       deleted	-	Признак отображения удаленных записей:  0 – не отображать удаленные;  1 – отображать удаленные.
       rowCount	-	Максимальное количество возвращаемых записей
       operatorIdIns	-	Пользователь, осуществляющий поиск

    Выходные параметры(в виде курсора):
        operator_id	-	Идентификатор пользователя
        login	-	Логин пользователя
        operator_name	-	Наименование пользователя на языке по умолчанию
        operator_name_en	-	Наименование пользователя на английском языке
        date_begin	-	Дата начала действия записи
        date_finish	-	Дата окончания действия записи
        change_password	-	Признак необходимости смены пароля: 0 – пароль менять не нужно; 1 – необходимо сменить пароль.
        date_ins	-	Дата создания записи
        operator_id_ins	-	Пользователь, создавший запись
        operator_name_ins	-	Пользователь на языке по умолчанию, создавший запись
        operator_name_ins_en	-	Пользователь на английском языке, создавший запись
*/
function FindOperator(  operatorId	   integer,
                        login	         varchar2,
                        operatorName	 varchar2,
                        operatorNameEn	varchar2,
                        deleted	        integer,
                        rowCount	      integer,
                        operatorIdIns	  integer)
return sys_refcursor
is

  SQLstr varchar2(2000);
  curResult  sys_refcursor;          --Курсор с результатом поиска

begin

 IsUserAdmin(operatorIdIns, null);

SQLstr := 'select op.operator_id
                , op.login
                , op.operator_name
                , op.operator_name_en
                , op.date_begin
                , op.date_finish
                , op.change_password
                , op.date_ins
                , op.operator_id_ins
                , ( select op1.operator_name_rus
                      from op_operator op1
                       where op1.operator_id = op.operator_id_ins) operator_name_ins
                , ( select op1.operator_name_en
                      from op_operator op1
                       where op1.operator_id = op.operator_id_ins) operator_name_ins_en
          from op_operator op
          where 1=1' ;

 if deleted = 0
 then
   SQLstr := SQLstr || ' and (op.date_finish is null  or op.date_finish > sysdate ) ';

 elsif deleted = 1
 then
    SQLstr := SQLstr || ' and op.date_finish is not null ';

 end if;

 AddSqlCondition( SQLstr, 'op.operator_id', '=', operatorId is null);
 AddSqlCondition( SQLstr, 'upper(op.login)', 'like', login is null, 'login');
 AddSqlCondition( SQLstr, 'upper(op.operator_name)', 'like', operatorName is null,'operatorName');
 AddSqlCondition( SQLstr, 'upper(op.operator_name_en)', 'like', operatorNameEn is null,'operatorNameEn');
 AddSqlCondition( sqlStr,'rownum', '<=', rowCount is null, 'rowCount');

 open  curResult
    FOR SQLstr
	    using operatorId,
            upper(login),
            upper(operatorName),
            upper(operatorNameEn),
            rowCount;

  --Выдаем результат
  return curResult;

exception  --Стандартная отработка исключений
  when others then
  raise_application_error( pkg_Error.ErrorStackInfo
    , 'Возникла ошибка при поиске оператора.', true);

end;

/* proc: RestoreOperator
   Процедура восстановления удаленного пользователя

   Входные параметры:
     operatorId - ID оператора для удаления
     operatorIdIns	-	Пользователь, удалющий запись
*/
procedure RestoreOperator( operatorId	integer,
                          operatorIdIns	integer)
is
begin
 IsUserAdmin(operatorIdIns, operatorId);

  update op_operator t
   set
       t.date_finish = NULL--to_date('01.01.4000')
   where t.operator_id = operatorId;

exception when others then
  raise_application_error( pkg_Error.ErrorStackInfo
    , 'Ошибка при осстановления удаленного оператора ('
      || ' operator_id=' || to_char(operatorID) || ').'
    , true );

end;

/* func: CreateRole
   Функция создания роли CreateRole

   Входные параметры:
      roleName	-	Наименование роли на языке по умолчанию
      roleNameEn	-	Наименование роли на английском языке
      shortName	-	Краткое наименование роли
      description	-	Описание роли на языке по умолчанию
      operatorId	-	Пользователь, создавший запись

   Выходные параметры:
      Идентификатор созданной записи роли
*/
function CreateRole( roleName	    varchar2,
                     roleNameEn	  varchar2,
                     shortName	  varchar2,
                     description	varchar2,
                     operatorId	  integer)
return integer
is
dr op_role%rowtype;

begin

  IsRole( operatorID, RoleAdmin_Role);

  select
     op_role_seq.nextval
   into dr.role_id
  from dual;

  dr.role_name_rus   := roleName;
  dr.short_name      := shortName;
  dr.date_ins        := sysdate;
  dr.operator_id     := operatorId;
  dr.role_name_eng   := roleNameEn;
  dr.description     := description;
  dr.role_name       := roleName;
  dr.role_name_en    := roleNameEn;

  insert into op_role values dr;

return dr.role_id;

exception when others then
  raise_application_error( pkg_Error.ErrorStackInfo
    , 'Ошибка при создании роли ('
      || ' role_id=' || to_char(dr.role_id)
      || ', short_name="' || to_char( shortName) || '"' || ').', true);

end;

/* proc: UpdateRole
   Процедура обновления роли UpdateRole

   Входные параметры:
      roleId - ID роли
      roleName	-	Наименование роли на языке по умолчанию
      roleNameEn	-	Наименование роли на английском языке
      shortName	-	Краткое наименование роли
      description	-	Описание роли на языке по умолчанию
      operatorId	-	Пользователь, создавший запись

*/
procedure UpdateRole( roleId	     integer,
                      roleName	   varchar2,
                      roleNameEn	 varchar2,
                      shortName	   varchar2,
                      description	 varchar2,
                      operatorId	 integer)
is
dr op_role%rowtype;
begin

  IsRole( operatorID, RoleAdmin_Role);

  dr.role_name_rus   := roleName;
  dr.short_name      := shortName;
  dr.date_ins        := sysdate;
  dr.operator_id     := operatorId;
  dr.role_name_eng   := roleNameEn;
  dr.description     := description;
  dr.role_name       := roleName;
  dr.role_name_en    := roleNameEn;

   update op_role t
     set
        t.role_name_rus = dr.role_name_rus
      , t.short_name    = dr.short_name
      , t.role_name_eng = dr.role_name_eng
      , t.description   = dr.description
      , t.role_name     = dr.role_name
      , t.role_name_en  = dr.role_name_en
   where t.role_id =  roleId;

exception when others then
  raise_application_error( pkg_Error.ErrorStackInfo
    , 'Ошибка при изменении роли ('
      || ' role_id=' || to_char(roleId)
      || ', short_name="' || to_char( shortName) || '"' || ').', true);

end;

/* proc: DeleteRole
   Процедура удаления роли DeleteRole

   Входные параметры:
      roleId - ID роли
      operatorId	-	Пользователь, создавший запись
*/
procedure DeleteRole( roleId	integer,
                      operatorId	integer)
is

begin
  IsRole( operatorID, RoleAdmin_Role);

  delete OP_GROUP_ROLE t
    where t.role_id = roleId;

  delete op_role t
    where t.role_id = roleId;

exception when others then
  raise_application_error( pkg_Error.ErrorStackInfo
    , 'Ошибка при удалении роли ('
      || ' role_id=' || to_char(roleId) || ').', true);

end;

/* func: FindRole
   Функция поиска роли FindRole

   Входные параметры:
      roleId	        -	Идентификатор роли
      roleName	      -	Наименование роли на языке по умолчанию
      roleNameEn	    -	Наименование роли на английском языке
      shortName	      -	Краткое наименование роли
      description	    -	Описание роли на языке по умолчанию
      rowCount	      -	Максимальное количество возвращаемых записей
      operatorId	    -	Пользователь, осуществляющий поиск

   Выходные параметры(в виде курсора):
      role_id	          -	Идентификатор роли
      short_name	      -	Краткое наименование роли
      role_name	        -	Наименование роли на языке по умолчанию
      role_name_en	    -	Наименование роли на английском языке
      description	      -	Описание роли на языке по умолчанию
      date_ins	        -	Дата создания записи
      operator_id	      -	Пользователь, создавший запись
      operator_name	    -	Пользователь на языке по умолчанию, создавший запись
      operator_name_en	-	Пользователь на английском языке, создавший запись
*/
function FindRole(  roleId	     integer,
                    roleName	   varchar2,
                    roleNameEn	 varchar2,
                    shortName	   varchar2,
                    description	 varchar2,
                    rowCount	   integer,
                    operatorId	 integer)
return sys_refcursor
is

  SQLstr varchar2(2000);
  curResult  sys_refcursor;          --Курсор с результатом поиска

begin

  IsRole( operatorID, RoleAdmin_Role);

SQLstr := 'select  opr.role_id,
                   opr.short_name,
                   opr.role_name,
                   opr.role_name_en,
                   opr.description,
                   opr.date_ins,
                   opr.operator_id,
                   op.operator_name,
                   op.operator_name_en
            from op_role opr
            join op_operator op
              on op.operator_id = opr.operator_id
            where 1=1 ' ;


 AddSqlCondition( SQLstr, 'opr.role_id', '=', roleId is null);
 AddSqlCondition( SQLstr, 'upper(opr.role_name)', 'like', roleName is null, 'roleName');
 AddSqlCondition( SQLstr, 'upper(opr.role_name_en)', 'like', roleNameEn is null,'roleNameEn');
 AddSqlCondition( SQLstr, 'upper(opr.short_name)', 'like', shortName is null,'shortName');
 AddSqlCondition( SQLstr, 'upper(opr.description)', 'like', description is null,'description');
 AddSqlCondition( sqlStr,'rownum', '<=', rowCount is null, 'rowCount');

 open  curResult
    FOR SQLstr || ' order by opr.role_id'
	    using roleId,
            upper(roleName),
            upper(roleNameEn),
            upper(shortName),
            upper(description),
            rowCount;

  --Выдаем результат
  return curResult;

exception  --Стандартная отработка исключений
  when others then
  raise_application_error( pkg_Error.ErrorStackInfo
    , 'Возникла ошибка при поиске роли.', true);


end;

/* func: CreateGroup
   Функция создания группы CreateGroup

   Входные параметры:
      groupName	-	Наименование группы на языке по умолчанию
      groupNameEn	-	Наименование группы на английском языке
      isGrantOnly	-	Признак grant-группы: если 1, то группа предоставляет право только выдавать данные ей роли другим пользователям
      operatorId	-	Пользователь, создавший запись

   Выходные параметры:

     Идентификатор созданной записи группы
*/
function CreateGroup( groupName	  varchar2,
                      groupNameEn	varchar2,
                      isGrantOnly	number,
                      operatorId	integer)
return integer
is
dr op_group%rowtype;

begin

  IsRole( operatorID, RoleAdmin_Role);

   select
       op_group_seq.nextval
     into dr.group_id
    from dual;

  dr.group_name_rus  := groupName;
  dr.date_ins        := sysdate;
  dr.operator_id     := operatorId;
  dr.group_name_eng  := groupNameEn;
  dr.is_grant_only   := isGrantOnly;
  dr.group_name      := groupName;
  dr.group_name_en   := groupNameEn;

insert into op_group  values dr;

return dr.group_id;

exception when others then
  raise_application_error( pkg_Error.ErrorStackInfo
    , 'При создании группы возникла ошибка ('
      || ' group_name_rus="' || groupName || '"' || ').' , true);

end;

/* proc: UpdateGroup
   Процедура обновления группы UpdateGroup

   Входные параметры:
      groupId - ID группы
      groupName	-	Наименование группы на языке по умолчанию
      groupNameEn	-	Наименование группы на английском языке
      isGrantOnly	-	Признак grant-группы: если 1, то группа предоставляет право только выдавать данные ей роли другим пользователям
      operatorId	-	Пользователь, создавший запись
*/
procedure UpdateGroup(  groupId	    integer,
                        groupName	  varchar2,
                        groupNameEn	varchar2,
                        isGrantOnly	number,
                        operatorId	integer)
is
dr op_group%rowtype;

begin
  IsRole( operatorID, RoleAdmin_Role);

  dr.group_name_rus  := groupName;
  dr.date_ins        := sysdate;
  dr.operator_id     := operatorId;
  dr.group_name_eng  := groupNameEn;
  dr.is_grant_only   := isGrantOnly;
  dr.group_name      := groupName;
  dr.group_name_en   := groupNameEn;

  update op_group t
    set t.group_name_rus =  dr.group_name_rus
      , t.group_name_eng =  dr.group_name_eng
      , t.is_grant_only  =  dr.is_grant_only
      , t.group_name     =  dr.group_name
      , t.group_name_en  =  dr.group_name_en
  where t.group_id =  groupId;

exception when others then
  raise_application_error( pkg_Error.ErrorStackInfo
    , 'Ошибка при изменении группы ('
      || ' group_id=' || to_char(groupId)
      || ', group_name="' || to_char(groupName) || '"' || ').', true);
end;

/* proc: DeleteGroup
   Процедура удаления группы DeleteGroup

  Входные параметры:
      groupId - ID группы
      operatorId	-	Пользователь, создавший запись

*/
procedure DeleteGroup(  groupId	    integer,
                        operatorId	integer)
is
begin

  IsRole( operatorID, RoleAdmin_Role);

  delete op_group t
     where t.group_id = groupId;

exception when others then
  raise_application_error( pkg_Error.ErrorStackInfo
    , 'При удалении группы возникла ошибка ('
      || ' group_id=' || to_char( groupID)|| ').', true);

end;

/* func: FindGroup
   Функция поиска группы FindGroup

   Входные параметры:
      groupId	-	Идентификатор группы
      groupName	-	Наименование группы на языке по умолчанию
      groupNameEn	-	Наименование группы на английском языке
      isGrantOnly	-	Признак отобразить только grant-группы:      если 1, то отображаем только grant-группы;      если 0  или null, то отображаем все группы.
      rowCount	-	Максимальное количество возвращаемых записей
      operatorId	-	Пользователь, осуществляющий поиск

   Выходные параметры(в виде курсора):
      group_id	-	Идентификатор группы
      group_name	-	Наименование группы на языке по умолчанию
      group_name_en	-	Наименование группы на английском языке
      is_grant_only	-	Признак grant-группы:      если 1, то группа предоставляет право только выдавать данные ей роли другим пользователям      date_ins	date	Дата создания записи
      operator_id	-	Пользователь, создавший запись
      operator_name	-	Пользователь на языке по умолчанию, создавший запись
      operator_name_en	-	Пользователь на английском языке, создавший запись
*/
function FindGroup( groupId	     integer,
                    groupName	   varchar2,
                    groupNameEn	 varchar2,
                    isGrantOnly	 number,
                    rowCount	   integer,
                    operatorId	 integer)
return sys_refcursor
is

  SQLstr varchar2(2000);
  curResult  sys_refcursor;          --Курсор с результатом поиска

begin

 IsUserAdmin(operatorId, null);

SQLstr := 'select  opg.group_id,
                   opg.group_name,
                   opg.group_name_en,
                   opg.is_grant_only,
                   opg.date_ins,
                   opg.operator_id,
                   op.operator_name,
                   op.operator_name_en
              from op_group opg
              join op_operator op
                on op.operator_id = opg.operator_id
              where 1=1 '  ;

 if isGrantOnly = 1
 then
 SQLstr := SQLstr || ' and opg.is_grant_only = 1 ';

 end if;

 AddSqlCondition( SQLstr, 'opg.group_id', '=', groupId is null);
 AddSqlCondition( SQLstr, 'upper(opg.group_name)', 'like', groupName is null, 'groupName');
 AddSqlCondition( SQLstr, 'upper(opg.group_name_en)', 'like', groupNameEn is null,'groupNameEn');
-- AddSqlCondition( SQLstr, 'opg.is_grant_only', 'like', isGrantOnly is null);
 AddSqlCondition( sqlStr,'rownum', '<=', rowCount is null, 'rowCount');

 open  curResult
    FOR SQLstr || ' order by 1'
	    using groupId,
            upper(groupName),
            upper(groupNameEn),
--            isGrantOnly,
            rowCount;

  --Выдаем результат
  return curResult;

exception  --Стандартная отработка исключений
  when others then
  raise_application_error( pkg_Error.ErrorStackInfo
    , 'Возникла ошибка при поиске роли.', true);
end;

/* proc: CreateOperatorRole
   Процедура создания связи пользователя и роли CreateOperatorRole
*/
procedure CreateOperatorRole(  operatorId	  integer,
                              roleId	      integer,
                              operatorIdIns	integer)
is
dr op_operator_role%rowtype;
begin

  IsUserAdmin(
    operatorID          => operatorIDIns
    , roleID            => roleID
  );

 dr.operator_id      := operatorId;
 dr.role_id          := roleId;
 dr.date_ins         := sysdate;
 dr.operator_id_ins  := operatorIdIns;

 insert into op_operator_role values dr;

exception when others then
  raise_application_error( pkg_Error.ErrorStackInfo
    , 'При включении роли в группу возникла ошибка ('
      || ' role_id=' || to_char( roleID) || ').' , true );

end;

/* func: FindOperatorRole
   Функция поиска связи пользователя и роли FindOperatorRole

   Входные параметры:
      operatorId	    -	Идентификатор пользователя
      roleId	        -	Идентификатор роли
      rowCount	      -	Максимальное количество возвращаемых записей
      operatorIdIns	  -	Пользователь, осуществляющий поиск

   Выходные параметры(в виде курсора):
      operator_id	    -	Идентификатор пользователя
      role_id	        -	Идентификатор роли
      short_name	    -	Краткое наименование роли
      role_name	      -	Наименование роли на языке по умолчанию
      role_name_en	  -	Наименование роли на английском языке
      description	    -	Описание роли на языке по умолчанию
      date_ins	      -	Дата создания записи
      operator_id_ins	-	Пользователь, создавший запись
      operator_name_ins	    -	Пользователь на языке по умолчанию, создавший запись
      operator_name_ins_en	-	Пользователь на английском языке, создавший запись
*/
function FindOperatorRole(  operatorId	integer,
                            roleId	    integer,
                            rowCount	  integer,
                            operatorIdIns	integer)
return sys_refcursor
is

  SQLstr varchar2(2000);
  curResult  sys_refcursor;          --Курсор с результатом поиска

begin

IsUserAdmin(operatorIdIns, null);

SQLstr := ' select t.operator_id
                 , t.role_id
                 , opr.short_name
                 , opr.role_name
                 , opr.role_name_en
                 , opr.description
                 , t.date_ins
                 , t.operator_id_ins
                , ( select op1.operator_name_rus
                      from op_operator op1
                       where op1.operator_id = t.operator_id_ins) operator_name_ins
                , ( select op1.operator_name_en
                      from op_operator op1
                       where op1.operator_id = t.operator_id_ins) operator_name_ins_en
            from op_operator_role t
            join op_role opr
              on opr.role_id = t.role_id
            join op_operator op
              on op.operator_id = t.operator_id_ins
            where 1=1 ' ;

 AddSqlCondition( SQLstr, 't.operator_id', '=', operatorId is null);
 AddSqlCondition( SQLstr, 't.role_id', '=', roleId is null);
 AddSqlCondition( sqlStr,'rownum', '<=', rowCount is null, 'rowCount');

 open  curResult
    FOR SQLstr || ' order by t.operator_id , t.role_id '
	    using operatorId,
            roleId,
            rowCount;

  --Выдаем результат
  return curResult;

exception  --Стандартная отработка исключений
  when others then
  raise_application_error( pkg_Error.ErrorStackInfo
    , 'Возникла ошибка при поиске роли.', true);

end;

/* func: GetNoOperatorRole
   Функция отображения ролей напрямую не принадлежащих пользователю GetNoOperatorRole

   Входные параметры:
      operatorId	    -	Идентификатор пользователя
      operatorIdIns	  -	Пользователь, осуществляющий поиск

   Выходные параметры(в виде курсора):
      role_id	-	Идентификатор роли
      short_name	-	Краткое наименование роли
      role_name	-	Наименование роли на языке по умолчанию
      role_name_en	-	Наименование роли на английском языке
      description	-	Описание роли на языке по умолчанию
      date_ins	-	Дата создания записи
      operator_id	-	Пользователь, создавший запись
      operator_name	-	Пользователь на языке по умолчанию, создавший запись
      operator_name_en	-	Пользователь на английском языке, создавший запись
*/
function GetNoOperatorRole( operatorId	integer,
                            operatorIdIns	integer)
return sys_refcursor
is
  SQLstr varchar2(2000);
  curResult  sys_refcursor;          --Курсор с результатом поиска

begin

IsUserAdmin(operatorIdIns, null);

SQLstr := ' select opr.role_id
           , opr.short_name
           , opr.role_name
           , opr.role_name_en
           , opr.description
           , opr.date_ins
           , opr.operator_id
           , op.operator_name
           , op.operator_name_en
      from op_role opr
      join op_operator op
        on op.operator_id = opr.operator_id
      where 1=1' ;

if operatorId is not null
then

      SQLstr := SQLstr|| '  and opr.role_id not in ( select vop.role_id
                                 from op_operator_role vop
                                where vop.operator_id = :operatorId
                                )  ';

       open  curResult
          FOR SQLstr || ' order by opr.role_id   '
            using operatorId;

else

       open  curResult
          FOR SQLstr || ' order by opr.role_id';
end if;

  --Выдаем результат
  return curResult;

exception  --Стандартная отработка исключений
  when others then
  raise_application_error( pkg_Error.ErrorStackInfo
    , 'Возникла ошибка при поиске роли.', true);

end;

/* func: FindOperatorGroup
   Функция поиска связи пользователя и группы FindOperatorGroup

   Входные параметры:
      operatorId	-	Идентификатор пользователя
      groupId	-	Идентификатор группы
      rowCount	-	Максимальное количество возвращаемых записей
      operatorIdIns	-	Пользователь, осуществляющий поиск

   Выходные параметры(в виде курсора):
      operator_id	-	Идентификатор пользователя
      group_id	-	Идентификатор группы
      group_name	-	Наименование группы на языке по умолчанию
      group_name_en	-	Наименование группы на английском языке
      is_grant_only	-	Признак grant-группы:если 1, то группа предоставляет право только выдавать данные ей роли другим пользователямdate_ins	date	Дата создания записи
      operator_id_ins	-	Пользователь, создавший запись
      operator_name_ins	-	Пользователь на языке по умолчанию, создавший запись
      operator_name_ins_en	-	Пользователь на английском языке, создавший запись
*/
function FindOperatorGroup( operatorId	  integer,
                            groupId	      integer,
                            rowCount	    integer,
                            operatorIdIns	integer)
return sys_refcursor
is
  SQLstr varchar2(2000);
  curResult  sys_refcursor;          --Курсор с результатом поиска

begin

IsUserAdmin(operatorIdIns, null);

SQLstr := ' select opg.operator_id,
                   opg.group_id,
                   g.group_name,
                   g.group_name_en,
                   g.is_grant_only,
                   opg.date_ins,
                   opg.operator_id_ins
                , ( select op1.operator_name_rus
                      from op_operator op1
                       where op1.operator_id = opg.operator_id_ins) operator_name_ins
                , ( select op1.operator_name_en
                      from op_operator op1
                       where op1.operator_id = opg.operator_id_ins) operator_name_ins_en

              from op_operator_group opg
              join op_group g
                on g.group_id = opg.group_id
              join op_operator op
               on op.operator_id = opg.operator_id_ins
              where 1=1 ' ;


 AddSqlCondition( SQLstr, 'opg.operator_id', '=', operatorId is null);
 AddSqlCondition( SQLstr, 'opg.group_id', '=', groupId is null);
 AddSqlCondition( sqlStr,'rownum', '<=', rowCount is null, 'rowCount');

 open  curResult
    FOR SQLstr || ' order by  opg.group_id, op.operator_name'
	    using operatorId,
            groupId,
            rowCount;

  --Выдаем результат
  return curResult;

exception  --Стандартная отработка исключений
  when others then
  raise_application_error( pkg_Error.ErrorStackInfo
    , 'Возникла ошибка при поиске группы ролей.', true);

end;

/* func: GetNoOperatorGroup
   Функция отображения групп напрямую не принадлежащих пользователю GetNoOperatorGroup

   Входные параметры:
     operatorId	-	Идентификатор пользователя
     operatorIdIns	-	Пользователь, осуществляющий выборку

   Выходные параметры(в виде курсора):
      group_id	-	Идентификатор группы
      group_name	-	Наименование группы на языке по умолчанию
      group_name_en	-	Наименование группы на английском языке
      is_grant_only	-	Признак grant-группы:если 1, то группа предоставляет право только выдавать данные ей роли другим пользователямdate_ins	date	Дата создания записи
      operator_id	-	Пользователь, создавший запись
      operator_name	-	Пользователь на языке по умолчанию, создавший запись
      operator_name_en	-	Пользователь на английском языке, создавший запись
*/
function GetNoOperatorGroup(  operatorId	    integer,
                              operatorIdIns	integer)
return sys_refcursor
is
  SQLstr varchar2(2000);
  curResult  sys_refcursor;          --Курсор с результатом поиска

begin

IsUserAdmin(operatorIdIns, null);

SQLstr := '  select g.group_id
                  , g.group_name
                  , g.group_name_en
                  , g.is_grant_only
                  , g.date_ins
                  , g.operator_id
                  , op.operator_name
                  , op.operator_name_en
                  from op_group g
                  join op_operator op
                    on op.operator_id = g.operator_id
                  where 1=1 ' ;

if operatorId is not null
then

      SQLstr := SQLstr|| '  and g.group_id not in ( select vop.group_id
                                 from op_operator_group vop
                                where vop.operator_id = :operatorId
                                )  ';

       open  curResult
          FOR SQLstr || ' order by g.group_id '
            using operatorId;

else

       open  curResult
          FOR SQLstr || ' order by g.group_id ';
end if;


  --Выдаем результат
  return curResult;

exception  --Стандартная отработка исключений
  when others then
  raise_application_error( pkg_Error.ErrorStackInfo
    , 'Возникла ошибка при группы ролей.', true);

end;

/* func: FindGroupRole
   Функция поиска связи группы и роли FindGroupRole

   Входные параметры:
      groupId	-	Идентификатор группы
      roleId	-	Идентификатор роли
      rowCount	-	Максимальное количество возвращаемых записей
      operatorId	-	Пользователь, осуществляющий поиск

   Выходные параметры(в виде курсора):
      group_id	-	Идентификатор группы
      role_id	-	Идентификатор роли
      short_name	-	Краткое наименование роли
      role_name	-	Наименование роли на языке по умолчанию
      role_name_en	-	Наименование роли на английском языке
      description	-	Описание роли на языке по умолчанию
      date_ins	-	Дата создания записи
      operator_id	-	Пользователь, создавший запись
      operator_name	-	Пользователь на языке по умолчанию, создавший запись
      operator_name_en	-	Пользователь на английском языке, создавший запись
*/
function FindGroupRole( groupId	     integer,
                        roleId	     integer,
                        rowCount	   integer,
                        operatorId	 integer)
return sys_refcursor
is
  SQLstr varchar2(2000);
  curResult  sys_refcursor;          --Курсор с результатом поиска

begin

  IsRole( operatorID, RoleAdmin_Role);

SQLstr := 'select  gr.group_id,
                   gr.role_id,
                   r.short_name,
                   r.role_name,
                   r.role_name_en,
                   r.description,
                   gr.date_ins,
                   op.operator_id,
                   op.operator_name,
                   op.operator_name_en
            from op_group_role gr
            join op_role r
              on r.role_id = gr.role_id
            join op_operator op
              on op.operator_id = gr.operator_id
            where 1=1  ' ;


 AddSqlCondition( SQLstr, 'gr.group_id', '=', groupId is null);
 AddSqlCondition( SQLstr, 'gr.role_id', '=', roleId is null);
 AddSqlCondition( sqlStr,'rownum', '<=', rowCount is null, 'rowCount');

 open  curResult
    FOR SQLstr || ' order by gr.group_id , gr.role_id'
	    using groupId,
            roleId,
            rowCount;

  --Выдаем результат
  return curResult;

exception  --Стандартная отработка исключений
  when others then
  raise_application_error( pkg_Error.ErrorStackInfo
    , 'Возникла ошибка при поиске записи.', true);

end;

/* func: GetNoGroupRole
   Функция отображения ролей напрямую не принадлежащих группе GetNoGroupRole

   Входные параметры:
      groupId	-	Идентификатор группы
      operatorId	-	Пользователь, осуществляющий выборку

   Выходные параметры(в виде курсора):
      role_id	-	Идентификатор роли
      short_name	-	Краткое наименование роли
      role_name	-	Наименование роли на языке по умолчанию
      role_name_en	-	Наименование роли на английском языке
      description	-	Описание роли на языке по умолчанию
      date_ins	-	Дата создания записи
      operator_id	-	Пользователь, создавший запись
      operator_name	-	Пользователь на языке по умолчанию, создавший запись
      operator_name_en	-	Пользователь на английском языке, создавший запись
*/
function GetNoGroupRole( groupId	integer,
                         operatorId	integer)
return sys_refcursor
is
  SQLstr varchar2(2000);
  curResult  sys_refcursor;          --Курсор с результатом поиска

begin

 IsRole( operatorID, RoleAdmin_Role);

SQLstr := ' select
                   r.role_id,
                   r.short_name,
                   r.role_name,
                   r.role_name_en,
                   r.description,
                   r.date_ins,
                   op.operator_id,
                   op.operator_name,
                   op.operator_name_en
            from op_role r
            join op_operator op
              on op.operator_id = r.operator_id
            where 1=1  ' ;

if operatorId is not null
then

      SQLstr := SQLstr|| '  and r.role_id not in ( select gr.role_id
                                     from op_group_role gr
                                     where gr.group_id = :groupId )';

       open  curResult
          FOR SQLstr || ' order by r.role_id '
            using groupId;

else

       open  curResult
          FOR SQLstr || ' order by r.role_id ';
end if;


  --Выдаем результат
  return curResult;

exception  --Стандартная отработка исключений
  when others then
  raise_application_error( pkg_Error.ErrorStackInfo
    , 'Возникла ошибка при группы ролей.', true);

end;

/* func: FindGrantGroup
   Функция поиска связи grant-группы и группы FindGrantGroup

   Входные параметры:
      groupId	-	Идентификатор группы
      grantGroupId	-	Идентификатор группы, которую позволяем выдавать (грантовать)
      rowCount	-	Максимальное количество возвращаемых записей
      operatorId	-	Пользователь, осуществляющий поиск

   Выходные параметры(в виде курсора):
      group_id	-	Идентификатор группы
      grant_group_id	-	Идентификатор группы, которую позволяем выдавать (грантовать)
      grant_group_name	-	Наименование группы на языке по умолчанию
      grant_group_name_en	-	Наименование группы на английском языке
      is_grant_only	-	Признак grant-группы:      если 1, то группа предоставляет право только выдавать данные ей роли другим пользователям      date_ins	date	Дата создания записи
      operator_id	-	Пользователь, создавший запись
      operator_name	-	Пользователь на языке по умолчанию, создавший запись
      operator_name_en	-	Пользователь на английском языке, создавший запись
*/
function FindGrantGroup(  groupId	      integer,
                          grantGroupId	integer,
                          rowCount	    integer,
                          operatorId	  integer)
return sys_refcursor
is
  SQLstr varchar2(2000);
  curResult  sys_refcursor;          --Курсор с результатом поиска

begin

  IsRole( operatorID, RoleAdmin_Role);

SQLstr := 'select  gg.group_id,
                   gg.grant_group_id,
                   g.group_name grant_group_name,
                   g.group_name_en grant_group_name_en,
                   g.is_grant_only is_grant_only,
                   gg.date_ins,
                   gg.operator_id,
                   op.operator_name,
                   op.operator_name_en
              from op_grant_group gg
              join op_group g
               on g.group_id = gg.grant_group_id
              join op_operator op
               on op.operator_id = gg.operator_id
              where 1=1 ' ;


 AddSqlCondition( SQLstr, 'gg.group_id', '=', groupId is null);
 AddSqlCondition( SQLstr, 'gg.grant_group_id', '=', grantGroupId is null);
 AddSqlCondition( sqlStr,'rownum', '<=', rowCount is null, 'rowCount');

 open  curResult
    FOR SQLstr || ' order by gg.group_id ,  gg.grant_group_id'
	    using groupId,
            grantGroupId,
            rowCount;

  --Выдаем результат
  return curResult;

exception  --Стандартная отработка исключений
  when others then
  raise_application_error( pkg_Error.ErrorStackInfo
    , 'Возникла ошибка при поиске записи.', true);

end;

/* func: GetNoGrantGroup
   Функция отображения групп напрямую не принадлежащих grant-группе GetNoGrantGroup

   Входные параметры:
      groupId	-	Идентификатор группы
      operatorId	-	Пользователь, осуществляющий выборку

   Выходные параметры( в виде курсора):
      group_id	-	Идентификатор группы
      group_name	-	Наименование группы на языке по умолчанию
      group_name_en	-	Наименование группы на английском языке
      is_grant_only	-	Признак grant-группы:      если 1, то группа предоставляет право только выдавать данные ей роли другим пользователям      date_ins	date	Дата создания записи
      operator_id	-	Пользователь, создавший запись
      operator_name	-	Пользователь на языке по умолчанию, создавший запись
      operator_name_en	-	Пользователь на английском языке, создавший запись
*/
function GetNoGrantGroup( groupId	integer,
                          operatorId	integer)
return sys_refcursor
is
  SQLstr varchar2(2000);
  curResult  sys_refcursor;          --Курсор с результатом поиска

begin

 IsRole( operatorID, RoleAdmin_Role);

SQLstr := 'select g.group_id,
                   g.group_name,
                   g.group_name_en,
                   g.is_grant_only,
                   g.date_ins,
                   g.operator_id,
                   op.operator_name,
                   op.operator_name_en
              from op_group g
              join op_operator op
                on op.operator_id = g.operator_id
              where 1=1 ' ;

if groupId is not null
then

      SQLstr := SQLstr|| '   and g.group_id not in ( select gg.grant_group_id
                            from op_grant_group gg
                             where gg.group_id = :groupId
                             )   ';

       open  curResult
          FOR SQLstr || ' order by g.group_id '
            using groupId;

else

       open  curResult
          FOR SQLstr || ' order by g.group_id ';
end if;


  --Выдаем результат
  return curResult;

exception  --Стандартная отработка исключений
  when others then
  raise_application_error( pkg_Error.ErrorStackInfo
    , 'Возникла ошибка при группы ролей.', true);

end;

end pkg_Operator;
/
