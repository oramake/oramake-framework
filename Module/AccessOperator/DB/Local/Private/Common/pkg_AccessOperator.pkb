create or replace package body pkg_AccessOperator is
/* package body: pkg_AccessOperator::body */



/* group: Переменные */

/* ivar: lg_logger_t
  Интерфейсный объект для модуля Logging
*/
logger lg_logger_t := lg_logger_t.GetLogger(
  moduleName => Module_Name
  , objectName => 'pkg_AccessOperator'
);



/* group: Функции */



/* group: Служебные функции */

/* proc: addSqlCondition
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
procedure addSqlCondition(
  searchCondition in out nocopy varchar2
  , fieldExpr varchar2
  , operation varchar2
  , isNullValue boolean
  , parameterExpr varchar2 := null
)
is
  -- Признак добавления бинарной операции
  isBinaryOp boolean := coalesce( not isNullValue, false);

-- addSqlCondition
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
end addSqlCondition;

/* iproc: addPublicGroupToOperator
  Процедура выдачи группы "Публичные права зарегистрированных пользователей"
  созданному оператору.

  Входные параметры:
    operatorId                       - Идентификатор оператора, которому выдается группа
    operatorIdIns                    - Идентификатор оператора, который выдает группу
    computerName                     - Имя компьютера, с которого производятся действия
    ipAddress                        - Ip адрес компьютера, с которого производятся действия

  Выходные параметры отсуствуют.
*/
procedure addPublicGroupToOperator(
  operatorId integer
  , operatorIdIns integer
  , computerName varchar2
  , ipAddress varchar2
)
is
-- addPublicGroupToOperator
begin
  insert into op_operator_group(
    operator_id
    , group_id
    , action_type_code
    , computer_name
    , ip_address
    , change_operator_id
    , operator_id_ins
  )
  select
    operatorId as operator_id
    , g.group_id
    , pkg_AccessOperator.CreateOperatorGroup_ActTpCd
    , computerName as computer_name
    , ipAddress as ip_address
    , operatorIdIns as change_operator_id
    , operatorIdIns as operator_id_ins
  from
    op_group g
  where
    upper( g.group_name ) = upper( 'Публичные права зарегистрированных пользователей' )
  ;
exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
          'Во время выдачи группы публичных прав доступа оператору '
          || 'произошла ошибка.'
        )
      , true
    );
end addPublicGroupToOperator;

/* iproc: addRoleToAdminGroup
  Выдает роль группам полного доступа.

  Входные параметры:
    roleId                           - Id роли
    operatorId                       - Id оператора, выполняющего процедуру
    computerName                     - Имя компьютера, с которого производятся действия
    ipAddress                        - Ip адрес компьютера, с которого производятся действия

  Выходные параметры отсутствуют.
*/
procedure addRoleToAdminGroup(
  roleId integer
  , operatorId integer
  , computerName varchar2 default null
  , ipAddress varchar2 default null
)
is
-- addRoleToAdminGroup
begin
  -- Полный доступ
  insert into op_group_role(
    group_id
    , role_id
    , action_type_code
    , computer_name
    , ip_address
    , change_operator_id
    , operator_id
  )
  with admin_group as (
    select
      g.group_id
    from
      op_group g
    where
      upper( g.group_name) in (
        upper( 'Полный доступ')
        , upper( 'Полный доступ (грант группа)')
      )
  )
  select
    t.group_id
    , t.role_id
    , pkg_AccessOperator.CreateGroupRole_ActTpCd as action_type_code
    , computerName as computer_name
    , ipAddress as ip_address
    , operatorId as change_operator_id
    , operatorId as operator_id
  from
    (
    select
      g.group_id
      , roleId as role_id
    from
      admin_group g
    minus
    select
      gr.group_id
      , gr.role_id
    from
      op_group_role gr
    inner join
      admin_group g
    on
      g.group_id = gr.group_id
      and gr.role_id = roleId
    ) t
  ;
exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , 'Во время выдачи роли группам полного доступа '
      || 'произошла ошибка ('
      || 'roleId="' || to_char( roleId ) || '"'
      || ', operatorId="' || to_char( operatorId ) || '"'
      || ').'
      , true
    );
end addRoleToAdminGroup;



/* group: Функции для работы с операторами */

/* func: createOperator
  Функция создания пользователя

  Входные параметры:
    operatorName                - Наименование пользователя на языке по умолчанию
    operatorNameEn              - Наименование пользователя на английском языке
    login                       - Логин
    password                    - Пароль
    changePassword              - Признак необходимости изменения пароля
                                  пользователем:
                                  1 – пользователю необходимо изменить пароль;
                                  0 – пользователю нет необходимости менять пароль.
    operatorIdIns               - Пользователь, создавший запись
    operatorComment             - коментарий к записи
    loginAttemptGroupId         - Группа параметров блокировки
    computerName                - Имя компьютера, с которого производится действие
    ipAddress                   - IP адрес компьютера, с которого производится действие
   Возврат:
     operator_id                - ID созданного оператора
*/
function createOperator(
  operatorName varchar2
  , operatorNameEn varchar2
  , login varchar2
  , password varchar2
  , changePassword integer
  , operatorIdIns integer
  , operatorComment varchar2 default null
  , loginAttemptGroupId integer default null
  , computerName varchar2 default null
  , ipAddress varchar2 default null
)
return integer
is
  operatorId integer;
  useLoginAttemptGroupId integer;


  /*
    Функция поиска значения ИД группы по умолчанию
  */
  function getDefaultGrpId
  return integer
  is
    dataDefault user_tab_cols.data_default%type;
    defaultGrpId integer;

  -- getDefaultGrpId
  begin
    select
      t.data_default
    into
      dataDefault
    from
      user_tab_cols t
    where
      t.table_name = 'OP_OPERATOR'
      and t.column_name = 'LOGIN_ATTEMPT_GROUP_ID'
    ;

    defaultGrpId := to_number( substr( dataDefault, 1, 4000 ) );

    return defaultGrpId;
  exception
    when others then
      return null;
  end getDefaultGrpId;

-- createOperator
begin
  pkg_Operator.IsUserAdmin( operatorIdIns, null );

  useLoginAttemptGroupId := coalesce(
    loginAttemptGroupId
    , getDefaultGrpId()
  );

  insert into op_operator(
    login
    , operator_name
    , operator_name_en
    , password
    , date_begin
    , change_password
    , operator_comment
    , login_attempt_group_id
    , action_type_code
    , computer_name
    , ip_address
    , change_operator_id
    , operator_id_ins
  )
  values(
    login
    , operatorName
    , operatorNameEn
    , pkg_Operator.getHash( password )
    , sysdate
    , changePassword
    , operatorComment
    , useLoginAttemptGroupId
    , pkg_AccessOperator.CreateOperator_ActTpCd
    , computerName
    , ipAddress
    , operatorIdIns
    , operatorIdIns
  )
  returning
    operator_id
  into
    operatorId
  ;

  -- Выдаем оператору группу публичных прав доступа
  addPublicGroupToOperator(
    operatorId => operatorId
    , operatorIdIns => operatorIdIns
    , computerName => computerName
    , ipAddress => ipAddress
  );

  return operatorId;
exception
  when dup_val_on_index then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
          'Оператор с таким логином уже существует ('
          || ' login="' || login || '"'
          || ').'
        )
      , true
    );
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
          'При создании оператора возникла ошибка ('
          || 'operatorName="' || operatorName || '"'
          || ', operatorNameEn="' || operatorNameEn || '"'
          || ', login="' || login || '"'
          || ', password="' || password || '"'
          || ', changePassword="' || changePassword || '"'
          || ', operatorIdIns="' || operatorIdIns || '"'
          || ', operatorComment="' || operatorComment || '"'
          || ', loginAttemptGroupId="'
            || to_char( loginAttemptGroupId ) || '"'
          || ', computerName="' || computerName || '"'
          || ', ipAddress="' || ipAddress || '"'
          || ').'
        )
      , true
    );
end createOperator;

/* proc: updateOperator
  Процедура обновления пользователя UpdateOperator

  Входные параметры:
    operatorId                  - ID оператора для изменения
    operatorName                - Наименование пользователя на языке по умолчанию
    operatorNameEn              - Наименование пользователя на английском языке
    login                       - Логин
    password                    - Пароль
    changePassword              - Признак необходимости изменения пароля
                                  пользователем:
                                  1 – пользователю необходимо изменить пароль;
                                  0 – пользователю нет необходимости менять пароль.
    operatorIdIns               - Пользователь, создавший запись
    operatorComment             - коментарий оператора
    loginAttemptGroupId         - Группа параметров блокировки
    computerName                - Имя компьютера, с которого производится действие
    ipAddress                   - IP адрес компьютера, с которого производится действие

   Выходные параметры отсутствуют.
*/
procedure updateOperator(
  operatorId integer
  , operatorName varchar2
  , operatorNameEn varchar2
  , login varchar2
  , password varchar2
  , changePassword integer
  , operatorIdIns integer
  , operatorComment varchar2
  , loginAttemptGroupId integer default null
  , computerName varchar2 default null
  , ipAddress varchar2 default null
)
is
-- updateOperator
begin
  pkg_operator.IsUserAdmin( operatorIdIns, operatorId );

  -- Для исключения дэдлока сначала выполняется смена пароля,
  -- а потом смена данных оператора, т.к. при смене пароля
  -- вызывается функция pkg_Operator.setCurentOperatorId,
  -- которая логирует оператора по ид-ку и , соответственно,
  -- блокирует запись с оператором, но т.к. она работает в автономной
  -- транзакции - возникал дэдлок.
  if password is not null then
    pkg_Operator.changePassword(
      operatorId => operatorId
      , password => password
      , operatorIdIns => operatorIdIns
    );
  end if;

  update
    op_operator t
  set
    t.operator_name = operatorName
    , t.operator_name_en = operatorNameEn
    , t.login = updateOperator.login
    , t.change_password = changePassword
    , t.operator_comment = operatorComment
    , t.login_attempt_group_id = loginAttemptGroupId
    , t.action_type_code = pkg_AccessOperator.ChangePersonalData_ActTpCd
    , t.computer_name = computerName
    , t.ip_address = ipAddress
    , t.change_date = sysdate
    , t.change_operator_id = operatorIdIns
  where
    t.operator_id = operatorId
  ;

exception
  when dup_val_on_index then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
          'Оператор с таким логином уже существует ('
          || ' login="' || login || '"'
          || ').'
        )
      , true
    );
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
          'При изменении данных оператора произошла ошибка ('
          || 'operatorId="' || to_char( operatorId ) || '"'
          || ').'
        )
      , true
    );
end updateOperator;

/* proc: deleteOperator
   Процедура удаления пользователя

   Входные параметры:
     operatorId          - ИД оператора
     operatorIdIns       - ИД оператора дл проверки прав
     operatorComment     - Комментарии
     computerName        - Имя компьютера, с которого производится действие
     ipAddress           - IP адрес компьютера, с которого производится действие

  Выходные параметры отсутствуют.
*/
procedure deleteOperator(
  operatorId integer
  , operatorIdIns integer
  , operatorComment varchar2 default null
  , computerName varchar2 default null
  , ipAddress varchar2 default null
)
is
-- deleteOperator
begin
  pkg_operator.IsUserAdmin( operatorIdIns, operatorId );

  update
    op_operator t
  set
    t.date_finish = sysdate
    , t.operator_comment = operatorComment
    , t.curr_login_attempt_count = 0
    , t.action_type_code = pkg_AccessOperator.BlockOperator_ActTpCd
    , t.computer_name = computerName
    , t.ip_address = ipAddress
    , t.change_date = sysdate
    , t.change_operator_id = operatorIdIns
  where
    t.operator_id = operatorId
  ;

exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
          'При удалении оператора возникла ошибка ('
          || ' operator_id="' || to_char( operatorId ) || '"'
          || ').'
        )
      , true
    );
end deleteOperator;

/* func: findOperator
   Функция поиска пользователя.

   Входные параметры:
     operatorId                     - Идентификатор пользователя
     login                          - Логин пользователя
     operatorName                   - Наименование пользователя на языке
                                      по умолчанию
     operatorNameEn                 - Наименование пользователя на
                                      английском языке
     loginAttemptGroupId            - Группа параметров блокировки
     deleted                        - Признак отображения удаленных записей:
                                      0 – не отображать удаленные;
                                      1 – отображать удаленные.
     rowCount                       -  Максимальное количество
                                      возвращаемых записей
     operatorIdIns                  - Пользователь, осуществляющий поиск

   Возврат (в виде курсора):
     operator_id                    - Идентификатор пользователя
     login                          - Логин пользователя
     operator_name                  - Наименование пользователя на языке
                                      по умолчанию
     operator_name_en               - Наименование пользователя на английском языке
     date_begin                     - Дата начала действия записи
     date_finish                    - Дата окончания действия записи
     change_password                - Признак необходимости смены пароля:
                                      0 – пароль менять не нужно;
                                      1 – необходимо сменить пароль.
     date_ins                       - Дата создания записи
     operator_id_ins                - Пользователь, создавший запись
     operator_name_ins              - Пользователь на языке по умолчанию,
                                      создавший запись
     operator_name_ins_en           - Пользователь на английском языке,
                                      создавший запись
     operator_comment               - комментарий, причина блокировки
     curr_login_attempt_count       - Текущее количество неуспешных попыток входа
     login_attempt_group_id         - Группа параметров блокировки
     login_attempt_group_name       - Наименование группы параметров блокировки
     is_default                     - Признак по умолчанию
     lock_type_code                 - Тип блокировки
     max_login_attempt_count        - Максимально допустимое количество
                                      попыток входа в систему
     locking_time                   - Время блокировки в секундах
     lock_type_name                 - Наименование типа
     block_wait_period              - Количество дней ожидания блокировки оператора
                                      после увольнения сотрудника
*/
function findOperator(
  operatorId integer default null
  , login varchar2 default null
  , operatorName varchar2 default null
  , operatorNameEn varchar2 default null
  , loginAttemptGroupId integer default null
  , deleted integer default null
  , rowCount integer default null
  , operatorIdIns integer default null
)
return sys_refcursor
is
  sqlStr varchar2(4000);
  resultSet sys_refcursor;

-- findOperator
begin
  pkg_operator.IsUserAdmin( operatorIdIns, null );

  sqlStr := '
select
  op.operator_id
  , op.login
  , op.operator_name
  , op.operator_name_en
  , op.date_begin
  , op.date_finish
  , op.change_password
  , op.date_ins
  , op.operator_id_ins
  , (
    select
      op1.operator_name
    from
      op_operator op1
    where
      op1.operator_id = op.operator_id_ins
    ) as operator_name_ins
  , (
    select
      op1.operator_name_en
    from
      op_operator op1
    where
      op1.operator_id = op.operator_id_ins
    ) as operator_name_ins_en
  , op.operator_comment
  , op.curr_login_attempt_count
  , op.login_attempt_group_id
  , grp.login_attempt_group_name
  , grp.is_default
  , grp.lock_type_code
  , lt.lock_type_name
  , grp.max_login_attempt_count
  , grp.locking_time
  , coalesce( grp.block_wait_period, 0 ) as block_wait_period
from
  op_operator op
left join
  v_op_login_attempt_group grp
on
  op.login_attempt_group_id = grp.login_attempt_group_id
left join
  op_lock_type lt
on
  grp.lock_type_code = lt.lock_type_code
where
  1 = 1'
  ;

  if deleted = 0 then
    sqlStr := sqlStr
      || ' and ( op.date_finish is null or op.date_finish > sysdate ) '
    ;
  elsif deleted = 1 then
    sqlStr := sqlStr || ' and op.date_finish is not null ';
  end if;

  addSqlCondition(
    sqlStr
    , 'op.operator_id'
    , '='
    , operatorId is null
  );
  addSqlCondition(
    sqlStr
    , 'upper( op.login )'
    , 'like'
    , login is null
    , 'login'
  );
  addSqlCondition(
    sqlStr
    , 'upper( op.operator_name )'
    , 'like'
    , operatorName is null
    , 'operatorName'
  );
  addSqlCondition(
    sqlStr
    , 'upper(op.operator_name_en)'
    , 'like'
    , operatorNameEn is null
    , 'operatorNameEn'
  );
  addSqlCondition(
    sqlStr
    , 'op.login_attempt_group_id'
    , '='
    , loginAttemptGroupId is null
    , 'loginAttemptGroupId'
  );
  addSqlCondition(
    sqlStr
    , 'rownum'
    , '<='
    , rowCount is null
    , 'rowCount'
  );

  -- dbms_output.put_line('sql="' || sqlStr || '"');

  open
    resultSet
  for
    sqlStr
  using
    operatorId
    , upper( login )
    , upper( operatorName )
    , upper( operatorNameEn )
    , loginAttemptGroupId
    , rowCount
  ;

  -- Выдаем результат
  return resultSet;

-- Стандартная отработка исключений
exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , 'Возникла ошибка при поиске оператора ('
        || 'operatorId="' || to_char( operatorId ) || '"'
        || ', login="' || login || '"'
        || ', operatorName="' || operatorName || '"'
        || ', operatorNameEn="' || operatorNameEn || '"'
        || ', deleted="' || to_char( deleted ) || '"'
        || ', rowCount="' || to_char( rowCount ) || '"'
        || ', operatorIdIns="' || to_char( operatorIdIns ) || '"'
        || ').'
      , true
    );
end findOperator;

/* proc: restoreOperator
   Процедура восстановления удаленного пользователя RestoreOperator

   Входные параметры:
     operatorId                  - Пользователь, которого необходимо восстановить
     restoreOperatorId           - Пользователь, который восстанавливает запись
     computerName                - Имя компьютера, с которого производится действие
     ipAddress                   - IP адрес компьютера, с которого производится действие

   Выходные параметры отсутствуют.
*/
procedure restoreOperator(
  operatorId integer
  , restoreOperatorId integer
  , computerName varchar2 default null
  , ipAddress varchar2 default null
)
is
-- restoreOperator
begin
  pkg_Operator.isUserAdmin(
    operatorId => restoreOperatorId
    , targetOperatorId => operatorId
  );

  update
    op_operator op
  set
    op.date_finish = null
    --, op.operator_comment = null
    , op.curr_login_attempt_count = 0
    , op.action_type_code = pkg_AccessOperator.UnblockOperator_ActTpCd
    , op.computer_name = computerName
    , op.ip_address = ipAddress
    , op.change_date = sysdate
    , op.change_operator_id = restoreOperatorId
  where
    op.operator_id = operatorId
  ;

exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
          'Во время восстановления оператора произошла ошибка ('
          || 'operatorId="' || to_char( operatorId ) || '"'
          || ', restoreOperatorId="' || to_char( restoreOperatorId ) || '"'
          || ').'
        )
      , true
    );
end restoreOperator;

/* func: createOperatorHash
  Создает нового оператора и возвращает его ID.

  Входные параметры:
    operatorName               - имя оператора
    operatorNameEn             - имя оператора (на английском)
    login                      - логин
    passwordHash               - Hash пароль
    changepassword             - флаг смены пароля оператора
    operatorIDIns              - ID оператора, выполняющего процедуру
    computerName               - Имя компьютера, с которого производится действие
    ipAddress                  - IP адрес компьютера, с которого производится действие

   Возврат:
     operator_id               - ID созданного оператора
*/
function createOperatorHash(
  operatorName varchar2
  , operatorNameEn varchar2
  , login varchar2
  , passwordHash varchar2
  , changePassword integer
  , operatorIdIns integer
  , computerName varchar2 default null
  , ipAddress varchar2 default null
)
return integer
is
  -- ID нового оператора
  operatorId integer;

-- createOperatorHash
begin
  -- Проверяем права оператора
  pkg_operator.IsUserAdmin(
    operatorId => operatorIdIns
    , targetOperatorId => null
  );

  -- Создаем запись
  insert into op_operator(
    operator_name
    , operator_name_en
    , login
    , password
    , change_password
    , date_begin
    , operator_id_ins
    , computer_name
    , ip_address
    , change_operator_id
  )
  values(
    operatorName
    , operatorNameEn
    , login
    , passwordHash
    , changePassword
    , sysdate
    , operatorIdIns
    , computerName
    , ipAddress
    , operatorIdIns
  )
  returning
    operator_id
  into
    operatorId
  ;

  -- Выдаем оператору группу публичных прав доступа
  addPublicGroupToOperator(
    operatorId => operatorId
    , operatorIdIns => operatorIdIns
    , computerName => computerName
    , ipAddress => ipAddress
  );

  return operatorId;
exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
          'Ошибка при создании оператора ('
          || ' login="' || login || '"'
          || ').'
       )
    , true
  );
end createOperatorHash;

/* func: getOperatorManuallyChanged
   Функция получения признака ручного изменения пользователя.

   Входные параметры:
     operatorId                     - Идентификатор пользователя

   Возврат:
     is_manually_changed            - Флаг вручную измененных данных по пользователю
*/
function getOperatorManuallyChanged(
  operatorId integer
)
return integer
is
  isManuallyChanged integer;
  -- Избавляемся от статической зависимости
  dSql varchar2(32767) := '
select
  case when
    t.op_group_count = 1
    and t.op_role_count = 0
    and t.op_group_history_count = 0
    and t.op_role_history_count = 0
    and t.operator_id_ins = 1
    and t.change_number = 1
  then
    0
  else
    1
  end as is_manually_changed
from
  (
  select
    op.operator_id_ins
    , op.change_number
    , (
      select
        count(*)
      from
        op_operator_group g
      where
        g.operator_id = op.operator_id
        and g.user_access_flag = 1
      ) as op_group_count
    , (
      select
        count(*)
      from
        op_operator_role r
      where
        r.operator_id = op.operator_id
        and r.user_access_flag = 1
      ) as op_role_count
    , (
      select
        count(*)
      from
        oph_operator_group_history gh
      where
        gh.operator_id = op.operator_id
      ) as op_group_history_count
    , (
      select
        count(*)
      from
       oph_operator_role_history rh
      where
        rh.operator_id = op.operator_id
      ) as op_role_history_count
  from
    op_operator op
  where
    op.operator_id = :operatorId
  ) t'
  ;

-- getOperatorManuallyChanged
begin
  execute immediate
    dSql
  into
    isManuallyChanged
  using
    operatorId
  ;

  return isManuallyChanged;

exception
  when no_data_found then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , 'Указанный оператор не найден ('
        || 'operatorId="' || to_char( operatorId ) || '"'
        || ').'
    );
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , 'Во время получения признака ручного изменения '
        || 'пользователя произошла ошибка ('
        || 'operatorId="' || to_char( operatorId ) || '"'
        || ').'
    );
end getOperatorManuallyChanged;

/* proc: restoreOperator
   Процедура восстановления удаленного пользователя

   Входные параметры:
     operatorId          - ID оператора для восстановления
     operatorIdIns	     - Пользователь, восстанавливающий оператора
     computerName        - Имя компьютера, с которого производится действие
     ipAddress           - IP адрес компьютера, с которого производится действие

   Выходные параметры отсутствуют
*/
procedure restoreOperator(
  operatorId integer
  , operatorIdIns integer
  , computerName varchar2 default null
  , ipAddress varchar2 default null
)
is
-- restoreOperator
begin
  pkg_operator.IsUserAdmin(operatorIdIns, operatorId);

  update
    op_operator t
  set
    t.date_finish = null
    --, t.operator_comment = null
    , t.curr_login_attempt_count = 0
    , t.action_type_code = pkg_AccessOperator.UnblockOperator_ActTpCd
    , t.computer_name = computerName
    , t.ip_address = ipAddress
    , t.change_date = sysdate
    , t.change_operator_id = operatorIdIns
  where
    t.operator_id = operatorId
  ;

exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , 'Ошибка при восстановлении удаленного оператора ('
        || 'operator_id="' || to_char( operatorId ) || '"'
        || ', operatorIdIns="' || to_char( operatorIdIns ) || '"'
        || ', computerName="' || computerName || '"'
        || ', ipAddress="' || ipAddress || '"'
        || ').'
    , true
  );
end restoreOperator;



/* group: Функции для работы с ролями */

/* iproc: setRoleUnused
  Процедура установки для роли флага "неиспользуемая" (удаление роли
  из <op_operator_role> и <op_group_role>).

  Входные параметры:
    roleId                                 - ID роли
    operatorId                             - ИД оператора
    computerName                           - Имя компьютера, с которого производится действие
    ipAddress                              - IP адрес компьютера, с которого производится действие

  Выходные параметры отсутствуют.
*/
procedure setRoleUnused(
  roleId integer
  , operatorId integer
  , computerName varchar2 default null
  , ipAddress varchar2 default null
)
is
-- setRoleUnused
begin
  -- Удаляем роль
  -- Фиксируем имя и ip адрес компьютера, с которого производится действие
  update
    op_operator_role opr
  set
    opr.action_type_code = pkg_AccessOperator.DeleteOperatorRole_ActTpCd
    , opr.computer_name = computerName
    , opr.ip_address = ipAddress
    , opr.change_date = sysdate
    , opr.change_operator_id = operatorId
  where
    opr.role_id = roleId
  ;

  -- Отбираем роль у операторов
  delete
    op_operator_role opr
  where
    opr.role_id = roleId
  ;

  -- Фиксируем имя и ip адрес компьютера, с которого производится действие
  update
    op_group_role opr
  set
    opr.action_type_code = pkg_AccessOperator.DeleteOperatorRole_ActTpCd
    , opr.computer_name = computerName
    , opr.ip_address = ipAddress
    , opr.change_date = sysdate
    , opr.change_operator_id = operatorId
  where
    opr.role_id = roleId
  ;

  -- Отбираем роль у групп
  delete
    op_group_role opr
  where
    opr.role_id = roleId
  ;

exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
          'Во время установки для роли флага "неиспользуемая" произошла ошибка ('
           || 'roleId="' || to_char( roleId ) || '"'
           || ', operatorId="' || to_char( operatorId ) || '"'
           || ', computerName="' || computerName || '"'
           || ', ipAddress="' || ipAddress || '"'
           || ').'
        )
      , true
    );
end setRoleUnused;

/* func: createRole
  Функция создания роли.

  Входные параметры:
    roleName                               - Наименование роли на языке по умолчанию
    roleNameEn                             - Наименование роли на английском языке
    shortName                              - Краткое наименование роли
    description                            - Описание роли на языке по умолчанию
    isUnused                               - признак неиспользуемой роли
    operatorId                             - ИД оператора

  Возврат:
    role_id                                - Идентификатор созданной записи роли
*/
function createRole(
  roleName varchar2
  , roleNameEn varchar2
  , shortName varchar2
  , description varchar2
  , isUnused number default 0
  , operatorId integer
)
return integer
is
  roleId integer;

-- createRole
begin
  pkg_operator.IsRole( operatorId, RoleAdmin_Role );

  insert into op_role(
    short_name
    , role_name
    , role_name_en
    , description
    , is_unused
    , change_operator_id
    , operator_id
  )
  values(
    shortName
    , roleName
    , roleNameEn
    , description
    , isUnused
    , operatorId
    , operatorId
  )
  returning
    role_id
  into
    roleId
  ;
  return roleId;
exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
          'Во время создания роли произошла ошибка ('
          || 'roleName="' || roleName || '"'
          || ', roleNameEn="' || roleNameEn || '"'
          || ', shortName="' || shortName || '"'
          || ', description="' || description || '"'
          || ', operatorId="' || to_char( operatorId ) || '"'
          || ').'
        )
      , true
    );
end createRole;

/* proc: updateRole
  Процедура редактирования роли.

  Входные параметры:
    roleId                                 - ID роли
    roleName                               - Наименование роли на языке по умолчанию
    roleNameEn                             - Наименование роли на английском языке
    shortName                              - Краткое наименование роли
    description                            - Описание роли на языке по умолчанию
    isUnused                               - признак неиспользуемой роли
    computerName                           - Имя компьютера, с которого производится действие
    ipAddress                              - IP адрес компьютера, с которого производится действие
    operatorId                             - Пользователь, создавший запись

  Выходные параметры отсутствуют.
*/
procedure updateRole(
  roleId integer
  , roleName varchar2
  , roleNameEn varchar2
  , shortName varchar2
  , description varchar2
  , isUnused number default 0
  , computerName varchar2 default null
  , ipAddress varchar2 default null
  , operatorId integer
)
is
-- updateRole
begin
  pkg_operator.IsRole( operatorId, RoleAdmin_Role );

  update
    op_role t
  set
    t.short_name = shortName
    , t.role_name = roleName
    , t.role_name_en = roleNameEn
    , t.description = updateRole.description
    , t.is_unused = isUnused
    , t.change_date = sysdate
    , t.change_operator_id = operatorId
  where
    t.role_id = roleId
  ;

  -- Если роль становится недоступной для назначения -
  -- забираем ее у операторов и групп
  if coalesce( isUnused, 0 ) = 1 then
    setRoleUnused(
      roleId => roleId
      , operatorId => operatorId
      , computerName => computerName
      , ipAddress => ipAddress
    );
  end if;
exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
          'Во время редактирования роли произошла ошибка ('
          || 'roleId="' || to_char( roleId ) || '"'
          || ').'
        )
      , true
    );
end updateRole;

/* proc: deleteRole
  Процедура удаления роли.

  Входные параметры:
    roleId                                 - ID роли
    operatorId                             - ИД оператора
    computerName                           - Имя компьютера, с которого производится действие
    ipAddress                              - IP адрес компьютера, с которого производится действие

  Выходные параметры отсутствуют.
*/
procedure deleteRole(
  roleId integer
  , operatorId integer
  , computerName varchar2 default null
  , ipAddress varchar2 default null
)
is
-- deleteRole
begin
  pkg_operator.IsRole( operatorId, RoleAdmin_Role );

  -- Фиксируем имя и ip адрес компьютера, с которого производится действие
  update
    op_operator_role opr
  set
    opr.action_type_code = pkg_AccessOperator.DeleteOperatorRole_ActTpCd
    , opr.computer_name = computerName
    , opr.ip_address = ipAddress
    , opr.change_date = sysdate
    , opr.change_operator_id = operatorId
  where
    opr.role_id = roleId
  ;
  -- Отбираем роль у операторов
  delete
    op_operator_role opr
  where
    opr.role_id = roleId
  ;

  -- Фиксируем имя и ip адрес компьютера, с которого производится действие
  update
    op_group_role opr
  set
    opr.action_type_code = pkg_AccessOperator.DeleteOperatorRole_ActTpCd
    , opr.computer_name = computerName
    , opr.ip_address = ipAddress
    , opr.change_date = sysdate
    , opr.change_operator_id = operatorId
  where
    opr.role_id = roleId
  ;
  -- Отбираем роль у групп
  delete
    op_group_role opr
  where
    opr.role_id = roleId
  ;

  -- Фиксируем ИД оператора, который производит действие
  update
    op_role r
  set
    r.change_date = sysdate
    , r.change_operator_id = operatorId
  where
    r.role_id = roleId
  ;
  delete
    op_role t
  where
    t.role_id = roleId
  ;
exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
          'Во время удаления роли произошла ошибка ('
           || 'roleId="' || to_char( roleId )
           || ').'
        )
      , true
    );
end deleteRole;

/* func: mergeRole
  Добавление или обновление роли.

  Параметры:
  roleShortName               - короткое наименование роли
  roleName                    - наименование роли
  roleNameEn                  - наименование роли на английском
  description                 - описание роли

  Возврат:
  - была ли роль изменена ( добавлена или обновлена);
*/
function mergeRole(
  roleShortName varchar2
  , roleName varchar2
  , roleNameEn varchar2
  , description varchar2
)
return integer
is
  -- Количество изменённых записей
  changed integer;



  /*
    Процедура добавления роли в группу администраторов.
  */
  procedure mergeRoleToAdminGroup
  is

    -- Идентификатор роли
    roleId integer;

  -- mergeRoleToAdminGroup
  begin
    select
      r.role_id
    into
      roleId
    from
      v_op_role r
    where
      r.role_short_name = roleShortName
    ;
    addRoleToAdminGroup(
      roleId            => roleId
      , operatorId      => pkg_Operator.getCurrentUserId()
    );
  end mergeRoleToAdminGroup;



-- mergeRole
begin
  merge into
    v_op_role r
  using
  (
  select
    roleShortName as role_short_name
    , roleName as role_name
    , roleNameEn as role_name_en
    -- Обязательно указывать алиас для переменной
    , description as description
  from
    dual
  minus
  select
    role_short_name
    , role_name
    , role_name_en
    , description
  from
    v_op_role
  ) s
  on (
    s.role_short_name = r.role_short_name
  )
  when not matched then insert (
    role_short_name
    , role_name
    , role_name_en
    , description
  )
  values (
    s.role_short_name
    , s.role_name
    , s.role_name_en
    , s.description
  )
  when matched then update set
    r.role_name       = s.role_name
    , r.role_name_en  = s.role_name_en
    , r.description   = s.description
  ;
  changed := sql%rowcount;

  -- Добавляем роль в группу администраторов
  mergeRoleToAdminGroup();

  return
    changed
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка добавления или обновления роли ('
        || 'roleShortName="' || roleShortName || '"'
        || ', roleName="' || roleName || '"'
        || ', roleNameEn="' || roleNameEn || '"'
        || ')'
      )
    , true
  );
end mergeRole;

/* func: findRole
  Функция поиска роли.

  Входные параметры:
    roleId	                               - Идентификатор роли
    roleName	                             - Наименование роли на языке по умолчанию
    roleNameEn	                           - Наименование роли на английском языке
    shortName	                             - Краткое наименование роли
    description	                           - Описание роли на языке по умолчанию
    isUnused                               - Признак неиспользуемой роли
    rowCount	                             - Максимальное количество возвращаемых записей
    operatorId	                           - Пользователь, осуществляющий поиск

  Возврат (в виде курсора):
    role_id	                               - Идентификатор роли
    short_name	                           - Краткое наименование роли
    role_name	                             - Наименование роли на языке по умолчанию
    role_name_en	                         - Наименование роли на английском языке
    description	                           - Описание роли на языке по умолчанию
    date_ins	                             - Дата создания записи
    operator_id	                           - Пользователь, создавший запись
    operator_name	                         - Пользователь на языке по умолчанию, создавший запись
    operator_name_en	                     - Пользователь на английском языке, создавший запись
    is_unused                              - Признак неиспользуемой роли
*/
function findRole(
  roleId integer default null
  , roleName varchar2 default null
  , roleNameEn varchar2 default null
  , shortName varchar2 default null
  , description varchar2 default null
  , isUnused number default null
  , rowCount integer default null
  , operatorId integer
)
return sys_refcursor
is
  sqlStr varchar2(32767);
  -- Курсор с результатом поиска
  resultSet  sys_refcursor;

-- findRole
begin
  pkg_operator.IsRole( operatorId, RoleAdmin_Role);

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
  , opr.is_unused
from
  op_role opr
inner join
  op_operator op
on
  op.operator_id = opr.operator_id
where
  1 = 1 '
  ;

  addSqlCondition( sqlStr, 'opr.role_id', '=', roleId is null);
  addSqlCondition( sqlStr, 'upper( opr.role_name )', 'like', roleName is null, 'roleName');
  addSqlCondition( sqlStr, 'upper( opr.role_name_en )', 'like', roleNameEn is null,'roleNameEn');
  addSqlCondition( sqlStr, 'upper( opr.short_name )', 'like', shortName is null,'shortName');
  addSqlCondition( sqlStr, 'upper( opr.description )', 'like', description is null,'description');
  addSqlCondition( sqlStr, 'opr.is_unused', '=', isUnused is null);

  addSqlCondition( sqlStr,'rownum', '<=', rowCount is null, 'rowCount');

  open
    resultSet
  for
    sqlStr
    || ' order by opr.role_id'
	using
    roleId
    , upper( roleName )
    , upper( roleNameEn )
    , upper( shortName )
    , upper( description )
    , isUnused
    , rowCount
  ;

  -- Выдаем результат
  return resultSet;

-- Стандартная отработка исключений
exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , 'Возникла ошибка при поиске роли.'
      , true
    );
end findRole;



/* group: Функции для работы с группами */

/* iproc: setGroupUnused
  Процедура установки для группы флага "неиспользуемая" (удаление группы
  из <op_operator_group>).

  Входные параметры:
    groupId                                - ИД группы
    operatorId                             - ИД оператора
    computerName                           - Имя компьютера, с которого производится действие
    ipAddress                              - IP адрес компьютера, с которого производится действие

  Выходные параметры отсутствуют.
*/
procedure setGroupUnused(
  groupId integer
  , operatorId integer
  , computerName varchar2 default null
  , ipAddress varchar2 default null
)
is
-- setGroupUnused
begin
  -- Фиксируем имя и ip адрес компьютера, с которого производится действие
  update
    op_operator_group opr
  set
    opr.action_type_code = pkg_AccessOperator.DeleteOperatorGroup_ActTpCd
    , opr.computer_name = computerName
    , opr.ip_address = ipAddress
    , opr.change_date = sysdate
    , opr.change_operator_id = operatorId
  where
    opr.group_id = groupId
  ;

  -- Забираем группу у всех операторов
  delete
    op_operator_group opr
  where
    opr.group_id = groupId
  ;

exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
          'Во время установки для группы флага "неиспользуемая" произошла ошибка ('
           || 'groupId="' || to_char( groupId ) || '"'
           || ', operatorId="' || to_char( operatorId ) || '"'
           || ', computerName="' || computerName || '"'
           || ', ipAddress="' || ipAddress || '"'
           || ').'
        )
      , true
    );
end setGroupUnused;

/* func: createGroup
  Функция создания группы.

  Входные параметры:
    groupName                              - Наименование группы на языке по умолчанию
    groupNameEn                            - Наименование группы на английском языке
    description                            - описание
    isUnused                               - признак неиспользуемой роли
    operatorId                             - Пользователь, создавший запись

  Возврат:
    group_id                               - ИД группы
*/
function createGroup(
  groupName varchar2
  , groupNameEn varchar2
  , description varchar2 default null
  , isUnused integer default 0
  , operatorId integer
)
return integer
is
  groupId integer;

-- createGroup
begin
  pkg_operator.IsRole( operatorId, RoleAdmin_Role );

  select
    op_group_seq.nextval
  into
    groupId
  from
    dual
  ;

  insert into op_group(
    group_name
    , group_name_en
    , description
    , is_unused
    , change_operator_id
    , operator_id
  )
  values(
    groupName
    , groupNameEn
    , description
    , isUnused
    , operatorId
    , operatorId
  )
  returning
    group_id
  into
    groupId
  ;
  return groupId;
exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
          'При создании группы возникла ошибка ('
          || 'groupName="' || groupName || '"'
          || ', groupNameEn="' || groupNameEn || '"'
          || ', description="' || description || '"'
          || ', isUnused="' || to_char( isUnused ) || '"'
          || ', operatorId="' || to_char( operatorId ) || '"'
          || ').'
        )
      , true
    );
end createGroup;

/* proc: updateGroup
  Процедура редактирования группы.

  Входные параметры:
    groupId                                - ID группы
    groupName                              - Наименование группы на языке по умолчанию
    groupNameEn                            - Наименование группы на английском языке
    description                            - описание
    isUnused                               - признак неиспользуемой роли
    computerName                           - Имя компьютера, с которого производится действие
    ipAddress                              - IP адрес компьютера, с которого производится действие
    operatorId                             - Пользователь, создавший запись

  Выходные параметры отсутствуют.
*/
procedure updateGroup(
  groupId integer
  , groupName varchar2
  , groupNameEn varchar2
  , description varchar2 default null
  , isUnused number default 0
  , computerName varchar2 default null
  , ipAddress varchar2 default null
  , operatorId integer
)
is
-- updateGroup
begin
  pkg_operator.IsRole( operatorId, RoleAdmin_Role );

  update
    op_group t
  set
    t.group_name = groupName
    , t.group_name_en = groupNameEn
    , t.description = updateGroup.description
    , t.is_unused = isUnused
    , t.change_date = sysdate
    , t.change_operator_id = operatorId
  where
    t.group_id = groupId
  ;

  -- Если группа становится недоступной для назначения -
  -- забираем ее у операторов и грант групп
  if coalesce( isUnused, 0 ) = 1 then
    setGroupUnused(
      groupId => groupId
      , operatorId => operatorId
      , computerName => computerName
      , ipAddress => ipAddress
    );
  end if;

exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
          'Во время редактирования группы произошла ошибка ('
          || 'groupId="' || to_char( groupId ) || '"'
          || ').'
        )
      , true
    );
end updateGroup;

/* proc: deleteGroup
  Процедура удаления группы.

  Входные параметры:
    groupId                                - ИД группы
    operatorId                             - ИД оператора
    computerName                           - Имя компьютера, с которого производится действие
    ipAddress                              - IP адрес компьютера, с которого производится действие

  Выходные параметры отсутствуют.
*/
procedure deleteGroup(
  groupId integer
  , operatorId integer
  , computerName varchar2 default null
  , ipAddress varchar2 default null
)
is
-- deleteGroup
begin
  pkg_operator.IsRole( operatorId, RoleAdmin_Role );

  -- Фиксируем имя и ip адрес компьютера, с которого производится действие
  update
    op_operator_group opr
  set
    opr.action_type_code = pkg_AccessOperator.DeleteOperatorGroup_ActTpCd
    , opr.computer_name = computerName
    , opr.ip_address = ipAddress
    , opr.change_date = sysdate
    , opr.change_operator_id = operatorId
  where
    opr.group_id = groupId
  ;

  -- Забираем группу у всех операторов
  delete
    op_operator_group opr
  where
    opr.group_id = groupId
  ;

  -- Фиксируем имя и ip адрес компьютера, с которого производится действие
  update
    op_group_role opr
  set
    opr.action_type_code = pkg_AccessOperator.DeleteGroupRole_ActTpCd
    , opr.computer_name = computerName
    , opr.ip_address = ipAddress
    , opr.change_date = sysdate
    , opr.change_operator_id = operatorId
  where
    opr.group_id = groupId
  ;

  -- Удаляем все роли группы
  delete
    op_group_role opr
  where
    opr.group_id = groupId
  ;

  -- Фиксируем оператора, который производит действие
  update
    op_group t
  set
    t.change_date = sysdate
    , t.change_operator_id = operatorId
  where
    t.group_id = groupId
  ;

  -- Удаляем группу
  delete
    op_group t
  where
    t.group_id = groupId
  ;

exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
          'Во время удаления группы произошла ошибка ('
           || 'groupId="' || to_char( groupId ) || '"'
           || ').'
        )
      , true
    );
end deleteGroup;

/* func: findGroup
  Функция поиска групп.

  Входные параметры:
    groupId                                - ИД группы
    groupId                                - Идентификатор группы
    groupName                              - Наименование группы на языке по умолчанию
    groupNameEn                            - Наименование группы на английском языке
    isGrantOnly                            - Признак отобразить только grant-группы:
                                             если 1, то отображаем только grant-группы;
                                             если 0  или null, то отображаем все группы.
    description                            - Описание
    isUnused                               - признак неиспользуемой группы
    rowCount                               - Максимальное количество возвращаемых записей
    operatorId                             - Пользователь, осуществляющий поиск

  Возврат (в виде курсора):
    group_id                               - Идентификатор группы
    group_name                             - Наименование группы на языке по умолчанию
    group_name_en                          - Наименование группы на английском языке
    date_ins                               - Дата создания записи
    operator_id                            - Пользователь, создавший запись
    operator_name                          - Пользователь на языке по умолчанию, создавший запись
    operator_name_en                       - Пользователь на английском языке, создавший запись
    description                            - Описание группы
    is_unused                              - признак неиспользуемой группы
*/
function findGroup(
  groupId integer default null
  , groupName varchar2 default null
  , groupNameEn varchar2 default null
  , description varchar2 default null
  , isUnused integer default null
  , rowCount integer default null
  , operatorId integer
)
return sys_refcursor
is
  sqlStr varchar2(32767);
  -- Курсор с результатом поиска
  resultSet sys_refcursor;

-- findGroup
begin
  pkg_operator.IsUserAdmin(operatorId, null);

  sqlStr := '
select
  opg.group_id
  , opg.group_name
  , opg.group_name_en
  , opg.date_ins
  , opg.operator_id
  , op.operator_name
  , op.operator_name_en
  , opg.description
  , opg.is_unused
from
  op_group opg
inner join
  op_operator op
on
  op.operator_id = opg.operator_id
where
  1 = 1 '
  ;

  addSqlCondition( sqlStr, 'opg.group_id', '=', groupId is null );
  addSqlCondition( sqlStr, 'upper( opg.group_name )', 'like', groupName is null, 'groupName' );
  addSqlCondition( sqlStr, 'upper( opg.group_name_en )', 'like', groupNameEn is null, 'groupNameEn' );
  addSqlCondition( sqlStr, 'upper( opg.description )', 'like', description is null, 'description' );
  addSqlCondition( SQLstr, 'opg.is_unused', '=', isUnused is null );
  addSqlCondition( sqlStr, 'rownum', '<=', rowCount is null, 'rowCount' );

  open
    resultSet
  for
    sqlStr
    || ' order by 1'
	using
    groupId
    , upper( groupName )
    , upper( groupNameEn )
    , upper( description )
    , isUnused
    , rowCount
  ;

  -- Выдаем результат
  return resultSet;

-- Стандартная отработка исключений
exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , 'Во время поиска групп произошла ошибка.'
      , true
    );
end findGroup;



/* group: Функции для работы с ролями оператора */


/* proc: createOperatorRole
  Процедура создания связи пользователя и роли.

  Входные параметры:
    operatorId                             - ИД оператора
    roleId                                 - ИД роли
    userAccessFlag                         - право на использование роли
    grantOptionFlag                        - право на выдачу роли другим операторам
    operatorIdIns                          - ИД текущего оператора
    computerName                           - Имя компьютера, с которого производится действие
    ipAddress                              - IP адрес компьютера, с которого производится действие

  Выходные параметры отсутсвуют.
*/
procedure createOperatorRole(
  operatorId integer
  , roleId integer
  , userAccessFlag integer default null
  , grantOptionFlag integer default null
  , operatorIdIns	integer
  , computerName varchar2 default null
  , ipAddress varchar2 default null
)
is
-- createOperatorRole
begin
  pkg_Operator.IsUserAdmin(
    operatorId => operatorIdIns
    , roleId => roleId
  );

  insert into op_operator_role(
    operator_id
    , role_id
    , user_access_flag
    , grant_option_flag
    , action_type_code
    , computer_name
    , ip_address
    , change_operator_id
    , operator_id_ins
  )
  values(
    operatorId
    , roleId
    , coalesce( userAccessFlag, 1 )
    , coalesce( grantOptionFlag, 0 )
    , pkg_AccessOperator.CreateOperatorRole_ActTpCd
    , computerName
    , ipAddress
    , operatorIdIns
    , operatorIdIns
  );

exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
          'При добавлении роли оператору произошла ошибка ('
          || 'operatorId="' || to_char( operatorId ) || '"'
          || ' , roleId="' || to_char( roleId ) || '"'
          || ' , userAccessFlag="' || to_char( userAccessFlag ) || '"'
          || ' , grantOptionFlag="' || to_char( grantOptionFlag ) || '"'
          || ' , operatorIdIns="' || to_char( operatorIdIns ) || '"'
          || ' , computerName="' || computerName || '"'
          || ' , ipAddress="' || ipAddress || '"'
          || ').'
        )
    , true
  );
end createOperatorRole;

/* proc: updateOperatorRole
  Процедура редактирования связи пользователя и роли.

  Входные параметры:
    operatorId                             - ИД оператора
    roleId                                 - ИД роли
    userAccessFlag                         - право на использование группы
    grantOptionFlag                        - право на выдачу группы другим операторам
    operatorIdIns                          - ИД текущего оператора
    computerName                           - Имя компьютера, с которого производится действие
    ipAddress                              - IP адрес компьютера, с которого производится действие

  Выходные параметры отсутсвуют.

  ( <body::updateOperatorRole>)
*/
procedure updateOperatorRole(
  operatorId integer
  , roleId integer
  , userAccessFlag integer default null
  , grantOptionFlag integer default null
  , operatorIdIns	integer
  , computerName varchar2 default null
  , ipAddress varchar2 default null
)
is
-- updateOperatorRole
begin
  pkg_Operator.IsUserAdmin(
    operatorId => operatorIdIns
    , roleId => roleId
  );

  update
    op_operator_role
  set
    user_access_flag = coalesce( userAccessFlag, 1 )
    , grant_option_flag = coalesce( grantOptionFlag, 0 )
    , action_type_code = pkg_AccessOperator.UpdateOperatorRole_ActTpCd
    , computer_name = computerName
    , ip_address = ipAddress
    , change_operator_id = operatorIdIns
  where
    operator_id = operatorId
    and role_id = roleId
  ;

exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
          'При обновлении связи роли и оператора произошла ошибка ('
          || 'operatorId="' || to_char( operatorId ) || '"'
          || ' , roleId="' || to_char( roleId ) || '"'
          || ' , userAccessFlag="' || to_char( userAccessFlag ) || '"'
          || ' , grantOptionFlag="' || to_char( grantOptionFlag ) || '"'
          || ' , operatorIdIns="' || to_char( operatorIdIns ) || '"'
          || ' , computerName="' || computerName || '"'
          || ' , ipAddress="' || ipAddress || '"'
          || ').'
        )
    , true
  );
end updateOperatorRole;

/* proc: deleteOperatorRole
  Процедура удаления роли у оператора.

  Входные параметры:
    operatorId                             - ИД оператора
    roleId                                 - ИД роли
    operatorIdIns                          - ИД текущего оператора
    computerName                           - Имя компьютера, с которого производится действие
    ipAddress                              - IP адрес компьютера, с которого производится действие

  Выходные параметры отсутсвуют.
*/
procedure deleteOperatorRole(
  operatorId integer
  , roleId integer
  , operatorIdIns	integer
  , computerName varchar2 default null
  , ipAddress varchar2 default null
)
is
-- deleteOperatorRole
begin
  -- Проверяем права доступа
  pkg_operator.IsUserAdmin(
    operatorId => operatorIdIns
    , roleId => roleId
  );

  -- Фиксируем имя и ip адрес компьютера, с которого производится действие
  update
    op_operator_role opr
  set
    opr.action_type_code = pkg_AccessOperator.DeleteOperatorRole_ActTpCd
    , opr.computer_name = computerName
    , opr.ip_address = ipAddress
    , opr.change_date = sysdate
    , opr.change_operator_id = operatorIdIns
  where
    opr.operator_id = operatorId
    and opr.role_id = roleId
  ;

  -- Отбираем роль
  delete from
    op_operator_role opr
  where
    opr.operator_id = operatorId
    and opr.role_id = roleId
  ;

exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
          'Ошибка при удалении роли у оператора ('
          || 'operatorId="' || to_char( operatorId ) || '"'
          || ' roleId="' || to_char( roleId ) || '"'
          || ' operatorIdIns="' || to_char( operatorIdIns ) || '"'
          || ' computerName="' || computerName || '"'
          || ' ipAddress="' || ipAddress || '"'
          || ').'
        )
      , true
    );
end deleteOperatorRole;

/* func: findOperatorRole
  Функция поиска связи пользователя и роли FindOperatorRole

  Входные параметры:
    operatorId                 - Идентификатор пользователя
    roleId                     - Идентификатор роли
    rowCount                   - Максимальное количество возвращаемых записей
    operatorIdIns              - Пользователь, осуществляющий поиск

  Возврат (в виде курсора):
    operator_id                - Идентификатор пользователя
      role_id                  - Идентификатор роли
      short_name               - Краткое наименование роли
      role_name                - Наименование роли на языке по умолчанию
      role_name_en             - Наименование роли на английском языке
      description              - Описание роли на языке по умолчанию
      date_ins                 - Дата создания записи
      operator_id_ins          - Пользователь, создавший запись
      operator_name_ins        - Пользователь на языке по умолчанию, создавший запись
      operator_name_ins_en     - Пользователь на английском языке, создавший запись
      user_access_flag         - Признак доступа к роли
      grant_option_flag        - Признак выдачи прав к роли
*/
function findOperatorRole(
  operatorId integer default null
  , roleId integer default null
  , rowCount integer default null
  , operatorIdIns integer
)
return sys_refcursor
is
  dSql varchar2(32767);
  rc sys_refcursor;

-- findOperatorRole
begin
  pkg_Operator.IsUserAdmin( operatorIdIns, null );

  dSql := '
select
  t.operator_id
  , t.role_id
  , opr.short_name
  , opr.role_name
  , opr.role_name_en
  , opr.description
  , t.date_ins
  , t.operator_id_ins
  , (
    select
      op1.operator_name
    from
      op_operator op1
    where
      op1.operator_id = t.operator_id_ins
    ) as operator_name_ins
  , (
    select
      op1.operator_name_en
    from
      op_operator op1
    where
      op1.operator_id = t.operator_id_ins
    ) as operator_name_ins_en
  , t.user_access_flag
  , t.grant_option_flag
from
  op_operator_role t
inner join
  op_role opr
on
  opr.role_id = t.role_id
inner join
  op_operator op
on
  op.operator_id = t.operator_id_ins
where
  1 = 1'
  ;

  addSqlCondition( dSql, 't.operator_id', '=', operatorId is null );
  addSqlCondition( dSql, 't.role_id', '=', roleId is null );
  addSqlCondition( dSql, 'rownum', '<=', rowCount is null, 'rowCount' );

  open
    rc
  for
    dSql || ' order by t.operator_id , t.role_id '
	using
    operatorId
    , roleId
    , rowCount
  ;

  return rc;
exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , 'Возникла ошибка при поиске роли оператора.'
      , true
    );
end findOperatorRole;



/* group: Функции для работы с группами оператора */

/* proc: createOperatorGroup
  Процедура назначения группы оператору.

  Входные параметры:
    operatorID                             - ID оператора
    groupID                                - ID группы
    userAccessFlag                         - право на использование группы
    grantOptionFlag                        - право на выдачу группы другим операторам
    operatorIDIns                          - ID оператора, выполняющего процедуру
    computerName                           - Имя компьютера, с которого производится действие
    ipAddress                              - IP адрес компьютера, с которого производится действие

  Выходные параметры отсутствуют.
*/
procedure createOperatorGroup(
  operatorId integer
  , groupId integer
  , userAccessFlag integer default null
  , grantOptionFlag integer default null
  , operatorIdIns integer
  , computerName varchar2 default null
  , ipAddress varchar2 default null
)
is
-- createOperatorGroup
begin
  -- Проверяем права доступа
  pkg_operator.IsUserAdmin(
    operatorId => operatorIdIns
    , groupId => groupId
  );

  -- Выдаем группу оператору
  insert into op_operator_group(
    operator_id
    , group_id
    , user_access_flag
    , grant_option_flag
    , action_type_code
    , computer_name
    , ip_address
    , change_operator_id
    , operator_id_ins
  )
  values(
    operatorId
    , groupId
    , coalesce( userAccessFlag, 0 )
    , coalesce( grantOptionFlag, 0 )
    , pkg_AccessOperator.CreateOperatorGroup_ActTpCd
    , computerName
    , ipAddress
    , operatorIdIns
    , operatorIdIns
  );

exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
          'Ошибка при включении оператора в группу ('
          || ' operatorId="' || to_char( operatorId ) || '"'
          || ' , groupId="' || to_char( groupId ) || '"'
          || ' , userAccessFlag="' || to_char( userAccessFlag ) || '"'
          || ' , grantOptionFlag="' || to_char( grantOptionFlag ) || '"'
          || ' , operatorIdIns="' || to_char( operatorIdIns ) || '"'
          || ' , computerName="' || computerName || '"'
          || ' , ipAddress="' || ipAddress || '"'
          || ').'
        )
      , true
    );
end createOperatorGroup;

/* proc: updateOperatorGroup
  Процедура редактирования связи группы и оператора.

  Входные параметры:
    operatorID                             - ID оператора
    groupID                                - ID группы
    userAccessFlag                         - право на использование группы
    grantOptionFlag                        - право на выдачу группы другим операторам
    operatorIDIns                          - ID оператора, выполняющего процедуру
    computerName                           - Имя компьютера, с которого производится действие
    ipAddress                              - IP адрес компьютера, с которого производится действие

  Выходные параметры отсутствуют.

  ( <body::updateOperatorGroup>)
*/
procedure updateOperatorGroup(
  operatorId integer
  , groupId integer
  , userAccessFlag integer default null
  , grantOptionFlag integer default null
  , operatorIdIns integer
  , computerName varchar2 default null
  , ipAddress varchar2 default null
)
is
-- updateOperatorGroup
begin
  -- Проверяем права доступа
  pkg_operator.IsUserAdmin(
    operatorId => operatorIdIns
    , groupId => groupId
  );

  -- Обновляем связь группы и оператора
  update
    op_operator_group
  set
    user_access_flag = coalesce( userAccessFlag, 0 )
    , grant_option_flag = coalesce( grantOptionFlag, 0 )
    , action_type_code = pkg_AccessOperator.CreateOperatorGroup_ActTpCd
    , computer_name = computerName
    , ip_address = ipAddress
    , change_operator_id = operatorIdIns
  where
    operator_id = operatorId
    and group_id = groupId
  ;

exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
          'Ошибка при обновлении связи оператора и группы ('
          || ' operatorId="' || to_char( operatorId ) || '"'
          || ' , groupId="' || to_char( groupId ) || '"'
          || ' , userAccessFlag="' || to_char( userAccessFlag ) || '"'
          || ' , grantOptionFlag="' || to_char( grantOptionFlag ) || '"'
          || ' , operatorIdIns="' || to_char( operatorIdIns ) || '"'
          || ' , computerName="' || computerName || '"'
          || ' , ipAddress="' || ipAddress || '"'
          || ').'
        )
      , true
    );
end updateOperatorGroup;

/* proc: deleteOperatorGroup
  Процедура удаления группы у оператора.

  Входные параметры:
    operatorID                             - ID оператора
    groupID                                - ID группы
    operatorIDIns                          - ID оператора, выполняющего процедуру
    computerName                           - Имя компьютера, с которого производится действие
    ipAddress                              - IP адрес компьютера, с которого производится действие

  Выходные параметры отсутствуют.
*/
procedure deleteOperatorGroup(
  operatorId integer
  , groupId integer
  , operatorIdIns integer
  , computerName varchar2 default null
  , ipAddress varchar2 default null
)
is
-- deleteOperatorGroup
begin
  -- Проверяем права доступа
  pkg_operator.IsUserAdmin(
    operatorId => operatorIdIns
    , groupId => groupId
  );

  -- Фиксируем имя и ip адрес компьютера, с которого производится действие
  update
    op_operator_group opg
  set
    opg.action_type_code = pkg_AccessOperator.DeleteOperatorGroup_ActTpCd
    , opg.computer_name = computerName
    , opg.ip_address = ipAddress
    , opg.change_date = sysdate
    , opg.change_operator_id = operatorIdIns
  where
    opg.operator_id = operatorId
    and opg.group_id = groupId
  ;

  -- Отбираем группу
  delete from
    op_operator_group opg
  where
    opg.operator_id = operatorId
    and opg.group_id = groupId
  ;

exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
          'Ошибка при исключении оператора из группы ('
          || ' operatorId="' || to_char( operatorId ) || '"'
          || ' , groupId="' || to_char( groupId ) || '"'
          || ' , operatorIdIns="' || to_char( operatorIdIns ) || '"'
          || ' , computerName="' || computerName || '"'
          || ' , ipAddress="' || ipAddress || '"'
          || ').'
        )
      , true
    );
end deleteOperatorGroup;

/* func: findOperatorGroup
  Функция поиска групп операторов.

  Входные параметры:
    operatorID                             - ID оператора
    groupId                                - Идентификатор группы
    isActualOnly                           - Признак выбора только незаблокированных операторов
    rowCount                               - Максимальное количество возвращаемых записей
    operatorIdIns                          - Пользователь, осуществляющий поиск

  Возврат (в виде курсора):
    operator_id                            - Идентификатор пользователя
    login                                  - Логин оператора
    operator_name                          - ФИО оператора
    group_id                               - Идентификатор группы
    group_name                             - Наименование группы на языке по умолчанию
    group_name_en                          - Наименование группы на английском языке
    date_ins                               - Дата создания записи
    operator_id_ins                        - Пользователь, создавший запись
    operator_name_ins                      - Пользователь на языке по умолчанию, создавший запись
    operator_name_ins_en                   - Пользователь на английском языке, создавший запись
    user_access_flag                       - Признак включения в группу
    grant_option_flag                      - Признак выдачи прав на группу
*/
function findOperatorGroup(
  operatorId integer default null
  , groupId integer default null
  , isActualOnly integer default null
  , rowCount integer default null
  , operatorIdIns	integer
)
return sys_refcursor
is
  sqlStr varchar2(32767);
  -- Курсор с результатом поиска
  resultSet sys_refcursor;

-- findOperatorGroup
begin
  -- Добавлена отдельная роль для просмотра информации по правам доступа
  if pkg_Operator.isRole(
       operatorId => operatorIdIns
       , roleShortName => pkg_AccessOperator.OpShowUsers_RoleSNm
     ) = 0
  then
    pkg_Operator.IsUserAdmin( operatorIdIns, null );
  end if;

  sqlStr := '
select
  opg.operator_id
  , op.login
  , op.operator_name
  , opg.group_id
  , g.group_name
  , g.group_name_en
  , opg.date_ins
  , opg.operator_id_ins
  , opins.operator_name as operator_name_ins
  , opins.operator_name_en as operator_name_ins_en
  , opg.user_access_flag
  , opg.grant_option_flag
from
  op_operator_group opg
inner join
  op_group g
on
  opg.group_id = g.group_id
inner join
  op_operator op
on
  opg.operator_id = op.operator_id
  ' || case when
         coalesce( isActualOnly, 0 ) = 1
       then
         'and op.date_finish is null'
       end
  || '
inner join
  op_operator opins
on
  opg.operator_id_ins = opins.operator_id
where
  1=1 '
  ;

  addSqlCondition( sqlStr, 'opg.operator_id', '=', operatorId is null );
  addSqlCondition( sqlStr, 'opg.group_id', '=', groupId is null );
  addSqlCondition( sqlStr, 'rownum', '<=', rowCount is null, 'rowCount' );

  open
    resultSet
  for
    sqlStr
    || ' order by opg.group_id, op.operator_name'
	using
    operatorId
    , groupId
    , rowCount
  ;

  -- Выдаем результат
  return resultSet;

-- Стандартная отработка исключений
exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
          'Во время поиска групп операторов произошла ошибка ('
          || 'operatorId="' || to_char( operatorId ) || '"'
          || ', groupId="' || to_char( groupId ) || '"'
          || ', rowCount="' || to_char( rowCount ) || '"'
          || ', operatorIdIns="' || to_char( operatorIdIns ) || '"'
          || ').'
        )
      , true
    );
end findOperatorGroup;




/* group: функции для работы со связями роль-группа*/

/* proc: createGroupRole
  Процедура добавления роли в группу.

  Входные параметры:
    groupID                                - ID группы
    roleID                                 - ID роли
    operatorID                             - ID оператора
    computerName                           - Имя компьютера, с которого производится действие
    ipAddress                              - IP адрес компьютера, с которого производится действие

  Выходные параметры отсутствуют.
*/
procedure createGroupRole(
  groupId integer
  , roleId integer
  , operatorId integer
  , computerName varchar2 default null
  , ipAddress varchar2 default null
)
is
-- createGroupRole
begin
  -- Проверяем права оператора
  pkg_operator.IsRole( operatorID, RoleAdmin_Role );

  -- Включаем роль в группу
  insert into op_group_role(
    group_id
    , role_id
    , action_type_code
    , computer_name
    , ip_address
    , change_operator_id
    , operator_id
  )
  values(
    groupId
    , roleId
    , pkg_AccessOperator.CreateGroupRole_ActTpCd
    , computerName
    , ipAddress
    , operatorId
    , operatorId
  );

exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
          'При включении роли в группу возникла ошибка ('
          || ' groupId="' || to_char( groupId ) || '"'
          || ', roleId="' || to_char( roleId ) || '"'
          || ', operatorId="' || to_char( operatorId ) || '"'
          || ', computerName="' || computerName || '"'
          || ', ipAddress="' || ipAddress || '"'
          || ').'
        )
      , true
    );
end createGroupRole;

/* proc: deleteGroupRole
  Процедура удаления роли из группы.

  Входные параметры:
    groupID                                - ID группы
    roleID                                 - ID роли
    operatorID                             - ID оператора
    computerName                           - Имя компьютера, с которого производится действие
    ipAddress                              - IP адрес компьютера, с которого производится действие

  Выходные параметры отсутствуют.
*/
procedure deleteGroupRole(
  groupId integer
  , roleId integer
  , operatorId integer
  , computerName varchar2 default null
  , ipAddress varchar2 default null
)
is
-- deleteGroupRole
begin
  -- Проверяем права оператора
  pkg_operator.IsRole( operatorID, RoleAdmin_Role );

  -- Фиксируем имя и ip адрес компьютера, с которого производится действие
  update
    op_group_role gr
  set
    gr.action_type_code = pkg_AccessOperator.DeleteGroupRole_ActTpCd
    , gr.computer_name = computerName
    , gr.ip_address = ipAddress
    , gr.change_date = sysdate
    , gr.change_operator_id = operatorId
  where
    gr.group_id = groupId
    and gr.role_id = roleId
  ;

  -- Удаляем роль из группы
  delete from
    op_group_role gr
  where
    gr.group_id = groupId
    and gr.role_id = roleId
  ;

exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
          'При удалении роли из группы возникла ошибка ('
          || ' groupId="' || to_char( groupId ) || '"'
          || ', roleId="' || to_char( roleId ) || '"'
          || ', operatorId="' || to_char( operatorId ) || '"'
          || ', computerName="' || computerName || '"'
          || ', ipAddress="' || ipAddress || '"'
          || ').'
        )
      , true
    );
end deleteGroupRole;

/* func: findGroupRole
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
function findGroupRole(
  groupId integer default null
  , roleId integer default null
  , rowCount integer default null
  , operatorId integer
)
return sys_refcursor
is
  dSql varchar2(32767);
  rc sys_refcursor;

-- findGroupRole
begin
  -- Добавлена отдельная роль для просмотра информации по правам доступа
  if pkg_Operator.isRole(
       operatorId => operatorId
       , roleShortName => pkg_AccessOperator.OpShowUsers_RoleSNm
     ) = 0
     and pkg_Operator.isRole(
           operatorId => operatorId
           , roleShortName => pkg_AccessOperator.RoleAdmin_Role
         ) = 0
  then
    raise_application_error(
      pkg_Error.RigthisMissed
      , 'Недостаточно прав для просмотра связей группа-роль.'
    );
  end if;

  dSql := '
select
  gr.group_id
  , gr.role_id
  , r.short_name
  , r.role_name
  , r.role_name_en
  , r.description
  , gr.date_ins
  , op.operator_id
  , op.operator_name
  , op.operator_name_en
from
  op_group_role gr
inner join
  op_role r
on
  r.role_id = gr.role_id
inner join
  op_operator op
on
  op.operator_id = gr.operator_id
where
  1 = 1'
  ;

  addSqlCondition( dSql, 'gr.group_id', '=', groupId is null );
  addSqlCondition( dSql, 'gr.role_id', '=', roleId is null );
  addSqlCondition( dSql, 'rownum', '<=', rowCount is null, 'rowCount' );

  open
    rc
  for
    dSql || ' order by gr.group_id, gr.role_id'
	using
    groupId
    , roleId
    , rowCount
  ;

  -- Выдаем результат
  return rc;

-- Стандартная отработка исключений
exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , 'Возникла ошибка при поиске связей группа-роль.'
    , true
  );
end findGroupRole;

/* func: operatorLoginReport
  Отчет по логинам.

  Входные параметры:
    operatorDateInsFrom             - дата создания оператора с
    operatorDateInsTo               - дата создания оператора по
    AccessOperatorId                - ID оператора
    AccessOperatorName              - ФИО оператора
    operatorBlockEnsign             - Признак блокировки
    groupId                         - ID группы
    groupDateInsFrom                - Дата добавления в групп с
    groupDateInsTo                  - Дата добавления в группу по
    roleId                          - ID роли
    roleDateInsFrom                 - Дата добавления роли с
    roleDateInsTo                   - Дата добавления роли по
    rowCount                        - Чссло строк

  Возврат( в виде курсора):
    operator_id                     - ID оператора
    operator_name                   - ФИО оператора
    employee_name                   - ФИО в справочнике сотрудников
    login                           - логин
    branch_name                     - название филиала
    operator_block_ensign           - признак блокировки
    date_ins                        - дата создания опептора
    operator_name_ins               - ФИО создателя
    date_finish                     - дата окончания действия записи о операторе
    group_id                        - ID группы
    group_name                      - название группы
    group_date_ins                  - дата добавления оператора в грппу
    group_operator_name_ins         - ФИО оператора который добавил в группу
    role_id                         - ID роли
    role_name                       - название роли
    role_date_ins                   - дата добавления роли оператору
    role_operator_name_ins          - ФИО оператора который выдал роль
*/
function operatorLoginReport(
  operatorDateInsFrom date
  , operatorDateInsTo date
  , accessOperatorId integer
  , accessOperatorName varchar2
  , operatorBlockEnsign integer
  , groupId integer
  , groupDateInsFrom date
  , groupDateInsTo date
  , roleId integer
  , roleDateInsFrom date
  , roleDateInsTo date
  , rowCount integer
  , operatorId integer
)
return sys_refcursor
is
  rc sys_refcursor;
  searchCondition varchar2(4000);
  dSql varchar2(32767) := '
select
  t.operator_id
  , t.operator_name
  , t.employee_name
  , t.login
  , t.branch_name
  , t.operator_block_ensign
  , t.date_ins
  , t.operator_name_ins
  , t.date_finish
  , t.group_id
  , t.group_name
  , t.group_date_ins
  , t.group_operator_name_ins
  , t.role_id
  , t.role_name
  , t.role_date_ins
  , t.role_operator_name_ins
from
  (
  select
    op.operator_id
    , op.operator_name
    , emp.first_name_rus || '' '' || emp.middle_name_rus
        || '' '' || emp.last_name_rus as employee_name
    , op.login
    , br.branch_name_rus as branch_name
    , case when
        op.date_finish is null
      then
        1
      else
        2
      end as operator_block_ensign
    , op.date_ins
    , (
      select
        opins.operator_name
      from
        op_operator opins
      where
        opins.operator_id = op.operator_id_ins
      ) as operator_name_ins
    , op.date_finish
    , opr.source_group_id as group_id
    , g.group_name
    , case when
        opr.source_group_id is not null
      then
        opr.date_ins
      end as group_date_ins
    , (
      select
        gop.operator_name
      from
        op_operator gop
      where
        gop.operator_id = opr.operator_id_ins
        and opr.source_group_id is not null
      ) as group_operator_name_ins
    , opr.role_id
    , r.role_name
    , case when
        opr.source_group_id is null
      then
        opr.date_ins
      end as role_date_ins
    , (
      select
        rop.operator_name
      from
        op_operator rop
      where
        rop.operator_id = opr.operator_id_ins
        and opr.source_group_id is null
      ) as role_operator_name_ins
  from
    op_operator op
  left join
    v_emp_employee emp
  on
    emp.employee_operator_id = op.operator_id
  left join
    v_ps_branch br
  on
    br.branch_id = emp.branch_id
  left join
    v_op_operator_role opr
  on
    opr.operator_id = op.operator_id
  left join
    op_group g
  on
    g.group_id = opr.source_group_id
  left join
    v_op_role r
  on
    r.role_id = opr.role_id
  where
    $(searchCondition)
    ' || case when
           operatorBlockEnsign = 1
         then
           ' and op.date_finish is null '
         when
           operatorBlockEnsign = 2
         then
           ' and op.date_finish is not null '
         end
      || case when
           groupDateInsFrom is not null
           or groupDateInsTo is not null
         then
           ' and opr.source_group_id is not null '
         when
           roleDateInsFrom is not null
           or roleDateInsTo is not null
         then
           ' and opr.source_group_id is null '
         end
  || '
  ) t
order by
  t.operator_name
  , t.group_name'
  ;

-- operatorLoginReport
begin
  -- Проверка прав
  if pkg_Operator.IsRole( operatorId, 'OpShowUsers' ) = 0 then
    raise_application_error(
      pkg_Error.RigthisMissed
      , logger.ErrorStack(
          'Недостаточно прав для формирования отчета по '
          || 'логинам операторов.'
        )
      , true
    );
  end if;

  -- Условия поиска
  addSqlCondition(
    searchCondition
    , 'trunc( op.date_ins )'
    , '>='
    , operatorDateInsFrom is null
    , 'operatorDateInsFrom'
  );
  addSqlCondition(
    searchCondition
    , 'trunc( op.date_ins )'
    , '<='
    , operatorDateInsTo is null
    , 'operatorDateInsTo'
  );
  addSqlCondition(
    searchCondition
    , 'op.operator_id'
    , '='
    , accessOperatorId is null
    , 'accessOperatorId'
  );
  addSqlCondition(
    searchCondition
    , 'upper( op.operator_name )'
    , 'like'
    , accessOperatorName is null
    , 'accessOperatorName'
  );
  addSqlCondition(
    searchCondition
    , 'opr.source_group_id'
    , '='
    , groupId is null
    , 'groupId'
  );
  addSqlCondition(
    searchCondition
    , 'trunc( opr.date_ins )'
    , '>='
    , groupDateInsFrom is null
    , 'groupDateInsFrom'
  );
  addSqlCondition(
    searchCondition
    , 'trunc( opr.date_ins )'
    , '<='
    , groupDateInsTo is null
    , 'groupDateInsTo'
  );
  addSqlCondition(
    searchCondition
    , 'opr.role_id'
    , '='
    , roleId is null
    , 'roleId'
  );
  addSqlCondition(
    searchCondition
    , 'trunc( opr.date_ins )'
    , '>='
    , roleDateInsFrom is null
    , 'roleDateInsFrom'
  );
  addSqlCondition(
    searchCondition
    , 'trunc( opr.date_ins )'
    , '<='
    , roleDateInsTo is null
    , 'roleDateInsTo'
  );
  addSqlCondition(
    searchCondition
    , 'rownum'
    , '<='
    , rowCount is null
    , 'rowCount'
  );
  logger.Debug(
    'sql="' || replace( dSql, '$(searchCondition)', searchCondition ) || '"'
  );

  open
    rc
  for
    replace( dSql, '$(searchCondition)', searchCondition )
	using
    operatorDateInsFrom
    , operatorDateInsTo
    , accessOperatorId
    , upper( AccessOperatorName )
    , groupId
    , groupDateInsFrom
    , groupDateInsTo
    , roleId
    , roleDateInsFrom
    , roleDateInsTo
    , rowCount
  ;

  return rc;
exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
          'Во время формирования отчета по логинам операторов '
          || 'произошла ошибка.'
        )
      , true
    );
end operatorLoginReport;

/* func: autoUnlockOperator
   Функция автоматической разбокировки операторов, у которых назначена группа временной блокировки.

   Входные параметры:
     operatorId                   - Идентификтаор оператора

   Возврат:
     operator_unlocked_count      - Количество разблокированных операторов
*/
function autoUnlockOperator(
  operatorId integer
)
return integer
is
-- unlockOperator
begin
  -- Разблокируем операторов
  update
    op_operator op
  set
    op.date_finish = null
    , op.curr_login_attempt_count = 0
    , op.change_operator_id = operatorId
  where
    exists(
      select
        null
      from
        v_op_login_attempt_group g
      where
        -- Временная блокировка
        g.lock_type_code = pkg_Operator.Temporal_LockTypeCode
        and g.login_attempt_group_id = op.login_attempt_group_id
        and g.max_login_attempt_count < op.curr_login_attempt_count
        and g.locking_time < ( sysdate - op.date_finish ) * 24 * 60 * 60
    )
  ;
  return sql%rowcount;
exception
  when others then
    raise_application_error(
      pkg_Error.ErrorInfo
      , 'Во время автоматической разбокировки операторов произошла ошибка.'
      , true
    );
end autoUnlockOperator;



/* group: Функции для работы с группами операторов */


/* func: createLoginAttemptGroup
   Функция создания группы параметров блокировки.

   Входные параметры:
     loginAttemptGroupName        - Наименование группы
     isDefault                    - Признак по умолчанию
     lockTypeCode                 - Тип блокировки
     maxLoginAttemptCount         - Максимально допустимое количество
                                    попыток входа в систему
     lockingTime                  - Время блокировки в секундах
     usedForCl                    - Использовать для CL
     blockWaitPeriod              - Количество дней, отложенной блокировки оператора
                                    при увольнении сотрудника
     operatorId                   - Пользователь, создавший запись

   Возврат:
     login_attempt_group_id       - Идентификатор созданной записи
*/
function createLoginAttemptGroup(
  loginAttemptGroupName varchar2
  , isDefault number default 0
  , lockTypeCode varchar2
  , maxLoginAttemptCount integer default null
  , lockingTime integer default null
  , usedForCl number default 0
  , blockWaitPeriod integer default null
  , operatorId integer
)
return integer
is
  loginAttemptGroupId integer;

-- createLoginAttemptGroup
begin
  -- Проверка прав
  pkg_Operator.isRole(
    operatorId => operatorId
    , roleShortName => pkg_Operator.OpLoginAttmptGrpAdmin_RoleName
  );

  if coalesce( isDefault, 0 ) = 1 then
    update
      op_login_attempt_group grp
    set
      grp.is_default = 0
    where
      grp.is_default = 1
    ;
  end if;

  -- Добавляем запись
  insert into op_login_attempt_group(
    login_attempt_group_name
    , is_default
    , lock_type_code
    , max_login_attempt_count
    , used_for_cl
    , locking_time
    , block_wait_period
    , change_operator_id
    , operator_id
  )
  values(
    loginAttemptGroupName
    , isDefault
    , lockTypeCode
    , maxLoginAttemptCount
    , usedForCl
    , lockingTime
    , blockWaitPeriod
    , operatorId
    , operatorId
  )
  returning login_attempt_group_id into loginAttemptGroupId
  ;

  return loginAttemptGroupId;

exception
  when dup_val_on_index then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , 'Группа с таким именем уже существует либо есть неудаленная запись '
        || 'репликации для CL ('
        || 'loginAttemptGroupName="' || loginAttemptGroupName || '"'
        || ', used_for_cl="' || to_char( usedForCl ) || '"'
        || ').'
      , true
    );
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , 'Во время создания группы параметров блокировки произошла ошибка ('
        || 'loginAttemptGroupName="' || loginAttemptGroupName || '"'
        || ', isDefault="' || to_char( isDefault ) || '"'
        || ', lockTypeCode="' || lockTypeCode || '"'
        || ', maxLoginAttemptCount="' || to_char( maxLoginAttemptCount ) || '"'
        || ', lockingTime="' || to_char( lockingTime ) || '"'
        || ', usedForCl="' || to_char( usedForCl ) || '"'
        || ', blockWaitPeriod="' || to_char( blockWaitPeriod ) || '"'
        || ', operatorId="' || to_char( operatorId ) || '"'
        || ').'
      , true
    );
end createLoginAttemptGroup;

/* proc: updateLoginAttemptGroup
   Процедура редактирования группы параметров блокировки.

   Входные параметры:
     loginAttemptGroupId          - ИД записи
     loginAttemptGroupName        - Наименование группы
     isDefault                    - Признак по умолчанию
     lockTypeCode                 - Тип блокировки
     maxLoginAttemptCount         - Максимально допустимое количество
                                    попыток входа в систему
     lockingTime                  - Время блокировки в секундах
     usedForCl                    - Использовать для CL
     blockWaitPeriod              - Количество дней, отложенной блокировки оператора
                                    при увольнении сотрудника
     operatorId                   - Пользователь,создавший запись

   Выходные параметры отсутствуют.
*/
procedure updateLoginAttemptGroup(
  loginAttemptGroupId integer
  , loginAttemptGroupName varchar2
  , isDefault number default 0
  , lockTypeCode varchar2
  , maxLoginAttemptCount integer default null
  , lockingTime integer default null
  , usedForCl number default null
  , blockWaitPeriod integer default null
  , operatorId integer
)
is
-- updateLoginAttemptGroup
begin
  -- Проверка прав
  pkg_Operator.isRole(
    operatorId => operatorId
    , roleShortName => pkg_Operator.OpLoginAttmptGrpAdmin_RoleName
  );

  if coalesce( isDefault, 0 ) = 1 then
    update
      op_login_attempt_group grp
    set
      grp.is_default = 0
    where
      grp.is_default = 1
    ;
  end if;

  update
    op_login_attempt_group grp
  set
    grp.login_attempt_group_name = loginAttemptGroupName
    , grp.is_default = isDefault
    , grp.lock_type_code = lockTypeCode
    , grp.max_login_attempt_count = maxLoginAttemptCount
    , grp.used_for_cl = usedForCl
    , grp.locking_time = lockingTime
    , grp.block_wait_period = blockWaitPeriod
    , grp.change_date = sysdate
    , grp.change_operator_id = operatorId
  where
    grp.login_attempt_group_id = loginAttemptGroupId
  ;

exception
  when dup_val_on_index then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , 'Группа с таким именем уже существует либо есть неудаленная запись '
        || 'репликации для CL ('
        || 'loginAttemptGroupName="' || loginAttemptGroupName || '"'
        || ', used_for_cl="' || to_char( usedForCl ) || '"'
        || ').'
      , true
    );
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , 'Во время редактирования группы параметров блокировки произошла ошибка ('
        || 'loginAttemptGroupId="' || to_char( loginAttemptGroupId ) || '"'
        || ', loginAttemptGroupName="' || loginAttemptGroupName || '"'
        || ', isDefault="' || to_char( isDefault ) || '"'
        || ', lockTypeCode="' || lockTypeCode || '"'
        || ', maxLoginAttemptCount="' || to_char( maxLoginAttemptCount ) || '"'
        || ', lockingTime="' || to_char( lockingTime ) || '"'
        || ', usedForCl="' || to_char( usedForCl ) || '"'
        || ', blockWaitPeriod="' || to_char( blockWaitPeriod ) || '"'
        || ', operatorId="' || to_char( operatorId ) || '"'
        || ').'
      , true
    );
end updateLoginAttemptGroup;

/* proc: deleteLoginAttemptGroup
   Процедура удаления группы параметров блокировки.

   Входные параметры:
     loginAttemptGroupId          - ИД записи
     operatorId                   - ИД оператора

   Выходные параметры отсутствуют.
*/
procedure deleteLoginAttemptGroup(
  loginAttemptGroupId integer
  , operatorId integer
)
is
  loginAttemptGroupRec op_login_attempt_group%rowtype;
  -- Флаг наличия в группе незаблокированных пользователей
  isUnblockedUsrInGrpExists integer;

-- deleteLoginAttemptGroup
begin
  -- Проверка прав
  pkg_Operator.isRole(
    operatorId => operatorId
    , roleShortName => pkg_Operator.OpLoginAttmptGrpAdmin_RoleName
  );
  -- Считываем параметры записи
  select
    *
  into
    loginAttemptGroupRec
  from
    op_login_attempt_group t
  where
    t.login_attempt_group_id = loginAttemptGroupId
  ;

  -- Проверям, существуют ли незаблокированные операторы,
  -- привязанные к удаляемой группе
  select
    max( 1 )
  into
    isUnblockedUsrInGrpExists
  from
    dual
  where
    exists(
      select
        null
      from
        op_operator op
      where
        op.login_attempt_group_id = loginAttemptGroupId
    )
  ;

  -- Обрабатываем параметры
  -- Запись не должна быть с флагом по умолчанию
  if loginAttemptGroupRec.Is_Default = 1 then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , 'Невозможно удалить запись с признаком по умолчанию.'
      , true
    );
  -- К записи не должны быть привязаны незаблокированные операторы
  elsif isUnblockedUsrInGrpExists is not null then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , 'Невозможно удалить запись, так как существуют '
        || 'незаблокированные пользователи, привязанные к этой группе.'
      , true
    );
  end if;

  -- Удаляем запись
  update
    op_login_attempt_group grp
  set
    grp.deleted = 1
    , grp.change_date = sysdate
    , grp.change_operator_id = operatorId
  where
    grp.login_attempt_group_id = loginAttemptGroupId
  ;

exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , 'Во время удаления группы параметров блокировки произошла ошибка ('
        || 'loginAttemptGroupId="' || to_char( loginAttemptGroupId ) || '"'
        || ', operatorId="' || to_char( operatorId ) || '"'
        || ').'
      , true
    );
end deleteLoginAttemptGroup;

/* func: findLoginAttemptGroup
   Функция поиска группы параметров блокировки.

   Входные параметры:
     loginAttemptGroupId          - ИД группы
     loginAttemptGroupName        - Наименование группы
     isDefault                    - Признак по умолчанию
     lockTypeCode                 - Тип блокировки
     maxRowCount                  - Количество записей в выборке
     operatorId                   - Пользователь,создавший запись

   Возврат (в виде курсора):
     login_attempt_group_id       - Идентификатор записи
     login_attempt_group_name     - Наименование группы
     is_default                   - Признак по умолчанию
     lock_type_code               - Тип блокировки
     lock_type_name               - Наименование типа
     max_login_attempt_count      - Максимально допустимое количество
                                    попыток входа в систему
     locking_time                 - Время блокировки в секундах
     used_for_cl                  - Признак использования для CL
     block_wait_period            - Количество дней, отложенной блокировки оператора
                                    при увольнении сотрудника
*/
function findLoginAttemptGroup(
  loginAttemptGroupId integer default null
  , loginAttemptGroupName varchar2 default null
  , isDefault number default null
  , lockTypeCode varchar2 default null
  , maxRowCount number default null
  , operatorId integer default null
)
return sys_refcursor
is
  resultSet sys_refcursor;
  sqlStr varchar2(4000);

-- findLoginAttemptGroup
begin
  -- Проверка прав
  pkg_Operator.isRole(
    operatorId => operatorId
    , roleShortName => pkg_Operator.OpLoginAttmptGrpAdmin_RoleName
  );

  -- Формируем запрос
  sqlStr :='
select
  grp.login_attempt_group_id
  , grp.login_attempt_group_name
  , grp.is_default
  , grp.lock_type_code
  , lt.lock_type_name
  , grp.max_login_attempt_count
  , grp.locking_time
  , grp.used_for_cl
  , grp.block_wait_period
from
  op_login_attempt_group grp
inner join
  op_lock_type lt
on
  grp.lock_type_code = lt.lock_type_code
  and grp.deleted = 0'
  ;

  addSqlCondition(
    sqlStr
    , 'grp.login_attempt_group_id'
    , '='
    , loginAttemptGroupId is null
    , 'loginAttemptGroupId'
  );
  addSqlCondition(
    sqlStr
    , 'upper( trim( grp.login_attempt_group_name ) )'
    , 'like'
    , loginAttemptGroupName is null
    , 'loginAttemptGroupName'
  );
  addSqlCondition(
    sqlStr
    , 'grp.is_default'
    , '='
    , isDefault is null
    , 'isDefault'
  );
  addSqlCondition(
    sqlStr
    , 'grp.lock_type_code'
    , '='
    , lockTypeCode is null
    , 'lockTypeCode'
  );
  addSqlCondition(
    sqlStr
    , 'rownum'
    , '<='
    , maxRowCount is null
    , 'maxRowCount'
  );

  open
    resultSet
  for
    sqlStr
  using
    loginAttemptGroupId
    , upper( trim( loginAttemptGroupName ) )
    , isDefault
    , lockTypeCode
    , maxRowCount
  ;

  return resultSet;

exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , 'Во время поиска группы параметров блокировки произошла ошибка ('
        || 'loginAttemptGroupId="' || to_char( loginAttemptGroupId ) || '"'
        || ', loginAttemptGroupName="' || loginAttemptGroupName || '"'
        || ', isDefault="' || to_char( isDefault ) || '"'
        || ', lockTypeCode="' || lockTypeCode || '"'
        || ', maxRowCount="' || to_char( maxRowCount ) || '"'
        || ', operatorId="' || to_char( operatorId ) || '"'
        || ').'
      , true
    );
end findLoginAttemptGroup;

/* func: getLoginAttemptGroup
   Функция получения списка группы параметров блокировки.

   Входные параметры:
     lockTypeCode                 - Тип блокировки

   Возврат (в виде курсора):
     login_attempt_group_id       - Идентификатор записи
     login_attempt_group_name     - Наименование группы
     is_default                   - Признак по умолчанию
     lock_type_code               - Тип блокировки
     lock_type_name               - Наименование типа
     max_login_attempt_count      - Максимально допустимое количество
                                    попыток входа в систему
     locking_time                 - Время блокировки в секундах
     block_wait_period            - Количество дней, отложенной блокировки оператора
                                    при увольнении сотрудника
*/
function getLoginAttemptGroup(
  lockTypeCode varchar2 default null
)
return sys_refcursor
is
  resultSet sys_refcursor;
  sqlStr varchar2(4000);

-- getLoginAttemptGroup
begin
  -- Формируем запрос
  sqlStr := '
select
  grp.login_attempt_group_id
  , grp.login_attempt_group_name
  , grp.is_default
  , grp.lock_type_code
  , lt.lock_type_name
  , grp.max_login_attempt_count
  , grp.locking_time
  , grp.used_for_cl
  , grp.block_wait_period
from
  op_login_attempt_group grp
inner join
  op_lock_type lt
on
  grp.lock_type_code = lt.lock_type_code
  and grp.deleted = 0
  and grp.used_for_cl = 0'
  ;
  addSqlCondition(
    sqlStr
    , 'grp.lock_type_code'
    , '='
    , lockTypeCode is null
    , 'lockTypeCode'
  );

  open
    resultSet
  for
    sqlStr
  using
    lockTypeCode
  ;

  return resultSet;

exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , 'Во время получения списка группы параметров блокировки '
        || ' произошла ошибка ('
        || 'lockTypeCode="' || lockTypeCode || '"'
        || ').'
      , true
    );
end getLoginAttemptGroup;

/* proc: changeLoginAttemptGroup
   Процедура массовой смена группы параметров блокировки.

   Входные параметры:
     oldLoginAttemptGroupId       - Идентификатор группы, с которой
                                    осуществляется перенос
     newLoginAttemptGroupId       - Идентификатор группы, на которую
                                    осуществляется перенос
     operatorId                   - ИД оператора

   Выходные параметры отсутствуют.
*/
procedure changeLoginAttemptGroup(
  oldLoginAttemptGroupId integer
  , newLoginAttemptGroupId integer
  , operatorId integer
)
is
-- changeLoginAttemptGroup
begin
  -- Проверка прав
  pkg_Operator.isRole(
    operatorId => operatorId
    , roleShortName => pkg_Operator.OpLoginAttmptGrpAdmin_RoleName
  );

  -- Регистрируем оператора для корректной фиксации change_operator_id,
  -- если такое поле есть
  pkg_Operator.setCurrentUserId( operatorId );

  -- Меняем группы
  update
    op_operator op
  set
    op.login_attempt_group_id = newLoginAttemptGroupId
  where
    op.login_attempt_group_id = oldLoginAttemptGroupId
    and op.date_finish is null
  ;

exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , 'Во время массовой смена группы параметров блокировки '
        || ' произошла ошибка ('
        || 'oldLoginAttemptGroupId="'
          || to_char( oldLoginAttemptGroupId ) || '"'
        || ', newLoginAttemptGroupId="'
          || to_char( newLoginAttemptGroupId ) || '"'
        || ', operatorId="' || to_char( operatorId ) || '"'
        || ').'
      , true
    );
end changeLoginAttemptGroup;



/* group: Функции по выдачу админских прав */

/* proc: setAdminGroup
  Функция выдает администраторские права оператору на группу

  Параметры:
  targetOperatorId            - идентификатор, которому выдаются права
  groupId                     - идентификатор группы
  operatorId                  - идентификатор пользователя
*/
procedure setAdminGroup(
  targetOperatorId            integer
, groupId                     integer
, operatorId                  integer
)
is
-- setAdminGroup
begin
  pkg_Operator.IsUserAdmin( operatorId, null );

  update
    op_operator_group
  set
    grant_option_flag = 1
  where
    group_id = groupId
    and operator_id = targetOperatorId
  ;

  if sql%rowcount = 0 then
    insert into
      op_operator_group
    (
      operator_id
    , group_id
    , user_access_flag
    , grant_option_flag
    , operator_id_ins
    )
    values (
      targetOperatorId
    , groupId
    , 0
    , 1
    , operatorId
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка выдачи администраторские права оператору. ('
      || 'targetOperatorId=' || to_char(targetOperatorId)
      || ', groupId=' || to_char(groupId)
      || ', operatorId=' || to_char(operatorId)
      || ').'
      )
    , true
  );
end setAdminGroup;

/* proc: setAdminRole
  Функция выдает администраторские права оператору на роль

  Параметры:
  targetOperatorId            - идентификатор, которому выдаются права
  roleId                      - идентификатор роли
  operatorId                  - идентификатор пользователя
*/
procedure setAdminRole(
  targetOperatorId            integer
, roleId                      integer
, operatorId                  integer
)
is
-- setAdminRole
begin
  pkg_Operator.IsUserAdmin( operatorId, null );

  update
    op_operator_role
  set
    grant_option_flag = 1
  where
    role_id = roleId
    and operator_id = targetOperatorId
  ;

  if sql%rowcount = 0 then
    insert into
      op_operator_role
    (
      operator_id
    , role_id
    , user_access_flag
    , grant_option_flag
    , operator_id_ins
    )
    values (
      targetOperatorId
    , roleId
    , 0
    , 1
    , operatorId
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка выдачи администраторские права оператору. ('
      || 'targetOperatorId=' || to_char(targetOperatorId)
      || ', roleId=' || to_char(roleId)
      || ', operatorId=' || to_char(operatorId)
      || ').'
      )
    , true
  );
end setAdminRole;

end pkg_AccessOperator;
/
