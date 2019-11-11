create or replace package pkg_AccessOperator is
/* package: pkg_AccessOperator
  Внутренний пакет модуля Operator.

  SVN root: Module/AccessOperator
*/

/* const: ROLEADMIN_ROLEID
 ID роли "Администратор прав доступа" */
ROLEADMIN_ROLEID CONSTANT INTEGER := 5;

/* const: ROLEADMIN_ROLE
Имя роли "Администратор прав доступа" */
ROLEADMIN_ROLE CONSTANT VARCHAR2(50) := 'RoleAdmin';

/* const: USERADMIN_ROLEID
ID роли "Администратор пользователей" */
USERADMIN_ROLEID CONSTANT INTEGER := 1;

/* const: USERADMIN_ROLE
Имя роли "Администратор пользователей" */
USERADMIN_ROLE CONSTANT VARCHAR2(50) := 'UserAdmin';

/* const: OpShowUsers_RoleSNm
  Короткое наименование роли "AccessOperator: просмотр операторов, ролей, групп".
*/
OpShowUsers_RoleSNm constant varchar2(50) := 'OpShowUsers';

/* const: Module_Name
  Название модуля, к которому относится пакет.
*/
Module_Name constant varchar2(30) := 'AccessOperator';



/* group: Коды типов действий */


/* const: CreateOperator_ActTpCd
  Код типа действия "Создание оператора".
*/
CreateOperator_ActTpCd constant varchar2(20) := 'CREATEOPERATOR';

/* const: CreateOperator_ActTpCd
  Код типа действия "Выдача роли оператору".
*/
CreateOperatorRole_ActTpCd constant varchar2(20) := 'CREATEOPERATORROLE';

/* const: UpdateOperator_ActTpCd
  Код типа действия "Изменение роли оператора".
*/
UpdateOperatorRole_ActTpCd constant varchar2(20) := 'UPDATEOPERATORROLE';

/* const: DeleteOperatorRole_ActTpCd
  Код типа действия "Удаление роли у оператора".
*/
DeleteOperatorRole_ActTpCd constant varchar2(20) := 'DELETEOPERATORROLE';

/* const: CreateOperatorGroup_ActTpCd
  Код типа действия "Выдача группы оператору".
*/
CreateOperatorGroup_ActTpCd constant varchar2(20) := 'CREATEOPERATORGROUP';

/* const: UpdateOperatorGroup_ActTpCd
  Код типа действия "Изменение группы оператора".
*/
UpdateOperatorGroup_ActTpCd constant varchar2(20) := 'UPDATEOPERATORGROUP';

/* const: DeleteOperatorGroup_ActTpCd
  Код типа действия "Удаление группы у оператора".
*/
DeleteOperatorGroup_ActTpCd constant varchar2(20) := 'DELETEOPERATORGROUP';

/* const: CreateGroupRole_ActTpCd
  Код типа действия "Добавление роли в группу".
*/
CreateGroupRole_ActTpCd constant varchar2(20) := 'CREATEGROUPROLE';

/* const: DeleteGroupRole_ActTpCd
  Код типа действия "Удаление роли из группы".
*/
DeleteGroupRole_ActTpCd constant varchar2(20) := 'DELETEGROUPROLE';

/* const: ChangePassword_ActTpCd
  Код типа действия "Изменение пароля".
*/
ChangePassword_ActTpCd constant varchar2(20) := 'CHANGEPASSWORD';

/* const: BlockOperator_ActTpCd
  Код типа действия "Блокирование оператора".
*/
BlockOperator_ActTpCd constant varchar2(20) := 'BLOCKOPERATOR';

/* const: UnblockOperator_ActTpCd
  Код типа действия "Разблокировка оператора".
*/
UnblockOperator_ActTpCd constant varchar2(20) := 'UNBLOCKOPERATOR';

/* const: AutoBlockOperator_ActTpCd
  Код типа действия "Автоблокировка оператора".
*/
AutoBlockOperator_ActTpCd constant varchar2(20) := 'AUTOBLOCKOPERATOR';

/* const: ChangePersonalData_ActTpCd
  Код типа действия "Изменение персональных данных оператора".
*/
ChangePersonalData_ActTpCd constant varchar2(20) := 'CHANGEPERSONALDATA';



/* group: Функции */



/* group: Служебные функции */

/* pproc: addSqlCondition
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

  ( <body::addSqlCondition>)
*/
procedure addSqlCondition(
  searchCondition in out nocopy varchar2
  , fieldExpr varchar2
  , operation varchar2
  , isNullValue boolean
  , parameterExpr varchar2 := null
);



/* group: Функции для работы с операторами */

/* pfunc: createOperator
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

  ( <body::createOperator>)
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
return integer;

/* pproc: updateOperator
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

  ( <body::updateOperator>)
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
);

/* pproc: deleteOperator
   Процедура удаления пользователя

   Входные параметры:
     operatorId          - ИД оператора
     operatorIdIns       - ИД оператора дл проверки прав
     operatorComment     - Комментарии
     computerName        - Имя компьютера, с которого производится действие
     ipAddress           - IP адрес компьютера, с которого производится действие

  Выходные параметры отсутствуют.

  ( <body::deleteOperator>)
*/
procedure deleteOperator(
  operatorId integer
  , operatorIdIns integer
  , operatorComment varchar2 default null
  , computerName varchar2 default null
  , ipAddress varchar2 default null
);

/* pfunc: findOperator
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

  ( <body::findOperator>)
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
return sys_refcursor;

/* pproc: restoreOperator
   Процедура восстановления удаленного пользователя RestoreOperator

   Входные параметры:
     operatorId                  - Пользователь, которого необходимо восстановить
     restoreOperatorId           - Пользователь, который восстанавливает запись
     computerName                - Имя компьютера, с которого производится действие
     ipAddress                   - IP адрес компьютера, с которого производится действие

   Выходные параметры отсутствуют.

  ( <body::restoreOperator>)
*/
procedure restoreOperator(
  operatorId integer
  , restoreOperatorId integer
  , computerName varchar2 default null
  , ipAddress varchar2 default null
);

/* pfunc: createOperatorHash
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

  ( <body::createOperatorHash>)
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
return integer;

/* pfunc: getOperatorManuallyChanged
   Функция получения признака ручного изменения пользователя.

   Входные параметры:
     operatorId                     - Идентификатор пользователя

   Возврат:
     is_manually_changed            - Флаг вручную измененных данных по пользователю

  ( <body::getOperatorManuallyChanged>)
*/
function getOperatorManuallyChanged(
  operatorId integer
)
return integer;

/* pproc: restoreOperator
   Процедура восстановления удаленного пользователя

   Входные параметры:
     operatorId          - ID оператора для восстановления
     operatorIdIns	     - Пользователь, восстанавливающий оператора
     computerName        - Имя компьютера, с которого производится действие
     ipAddress           - IP адрес компьютера, с которого производится действие

   Выходные параметры отсутствуют

  ( <body::restoreOperator>)
*/
procedure restoreOperator(
  operatorId integer
  , operatorIdIns integer
  , computerName varchar2 default null
  , ipAddress varchar2 default null
);



/* group: Функции для работы с ролями */

/* pfunc: createRole
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

  ( <body::createRole>)
*/
function createRole(
  roleName varchar2
  , roleNameEn varchar2
  , shortName varchar2
  , description varchar2
  , isUnused number default 0
  , operatorId integer
)
return integer;

/* pproc: updateRole
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

  ( <body::updateRole>)
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
);

/* pproc: deleteRole
  Процедура удаления роли.

  Входные параметры:
    roleId                                 - ID роли
    operatorId                             - ИД оператора
    computerName                           - Имя компьютера, с которого производится действие
    ipAddress                              - IP адрес компьютера, с которого производится действие

  Выходные параметры отсутствуют.

  ( <body::deleteRole>)
*/
procedure deleteRole(
  roleId integer
  , operatorId integer
  , computerName varchar2 default null
  , ipAddress varchar2 default null
);

/* pfunc: mergeRole
  Добавление или обновление роли.

  Параметры:
  roleShortName               - короткое наименование роли
  roleName                    - наименование роли
  roleNameEn                  - наименование роли на английском
  description                 - описание роли

  Возврат:
  - была ли роль изменена ( добавлена или обновлена);

  ( <body::mergeRole>)
*/
function mergeRole(
  roleShortName varchar2
  , roleName varchar2
  , roleNameEn varchar2
  , description varchar2
)
return integer;

/* pfunc: findRole
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

  ( <body::findRole>)
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
return sys_refcursor;



/* group: Функции для работы с группами */

/* pfunc: createGroup
  Функция создания группы.

  Входные параметры:
    groupName                              - Наименование группы на языке по умолчанию
    groupNameEn                            - Наименование группы на английском языке
    description                            - описание
    isUnused                               - признак неиспользуемой роли
    operatorId                             - Пользователь, создавший запись

  Возврат:
    group_id                               - ИД группы

  ( <body::createGroup>)
*/
function createGroup(
  groupName varchar2
  , groupNameEn varchar2
  , description varchar2 default null
  , isUnused integer default 0
  , operatorId integer
)
return integer;

/* pproc: updateGroup
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

  ( <body::updateGroup>)
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
);

/* pproc: deleteGroup
  Процедура удаления группы.

  Входные параметры:
    groupId                                - ИД группы
    operatorId                             - ИД оператора
    computerName                           - Имя компьютера, с которого производится действие
    ipAddress                              - IP адрес компьютера, с которого производится действие

  Выходные параметры отсутствуют.

  ( <body::deleteGroup>)
*/
procedure deleteGroup(
  groupId integer
  , operatorId integer
  , computerName varchar2 default null
  , ipAddress varchar2 default null
);

/* pfunc: findGroup
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

  ( <body::findGroup>)
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
return sys_refcursor;



/* group: Функции для работы с ролями оператора */

/* pproc: createOperatorRole
  Процедура создания связи пользователя и роли.

  Входные параметры:
    operatorId                             - ИД оператора
    roleId                                 - ИД роли
    userAccessFlag                         - право на использование группы
    grantOptionFlag                        - право на выдачу группы другим операторам
    operatorIdIns                          - ИД текущего оператора
    computerName                           - Имя компьютера, с которого производится действие
    ipAddress                              - IP адрес компьютера, с которого производится действие

  Выходные параметры отсутсвуют.

  ( <body::createOperatorRole>)
*/
procedure createOperatorRole(
  operatorId integer
  , roleId integer
  , userAccessFlag integer default null
  , grantOptionFlag integer default null
  , operatorIdIns	integer
  , computerName varchar2 default null
  , ipAddress varchar2 default null
);

/* pproc: updateOperatorRole
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
);

/* pproc: deleteOperatorRole
  Процедура удаления роли у оператора.

  Входные параметры:
    operatorId                             - ИД оператора
    roleId                                 - ИД роли
    operatorIdIns                          - ИД текущего оператора
    computerName                           - Имя компьютера, с которого производится действие
    ipAddress                              - IP адрес компьютера, с которого производится действие

  Выходные параметры отсутсвуют.

  ( <body::deleteOperatorRole>)
*/
procedure deleteOperatorRole(
  operatorId integer
  , roleId integer
  , operatorIdIns	integer
  , computerName varchar2 default null
  , ipAddress varchar2 default null
);

/* pfunc: findOperatorRole
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

  ( <body::findOperatorRole>)
*/
function findOperatorRole(
  operatorId integer default null
  , roleId integer default null
  , rowCount integer default null
  , operatorIdIns integer
)
return sys_refcursor;



/* group: Функции для работы с группами оператора */

/* pproc: createOperatorGroup
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

  ( <body::createOperatorGroup>)
*/
procedure createOperatorGroup(
  operatorId integer
  , groupId integer
  , userAccessFlag integer default null
  , grantOptionFlag integer default null
  , operatorIdIns integer
  , computerName varchar2 default null
  , ipAddress varchar2 default null
);

/* pproc: updateOperatorGroup
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
);

/* pproc: deleteOperatorGroup
  Процедура удаления группы у оператора.

  Входные параметры:
    operatorID                             - ID оператора
    groupID                                - ID группы
    operatorIDIns                          - ID оператора, выполняющего процедуру
    computerName                           - Имя компьютера, с которого производится действие
    ipAddress                              - IP адрес компьютера, с которого производится действие

  Выходные параметры отсутствуют.

  ( <body::deleteOperatorGroup>)
*/
procedure deleteOperatorGroup(
  operatorId integer
  , groupId integer
  , operatorIdIns integer
  , computerName varchar2 default null
  , ipAddress varchar2 default null
);

/* pfunc: findOperatorGroup
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

  ( <body::findOperatorGroup>)
*/
function findOperatorGroup(
  operatorId integer default null
  , groupId integer default null
  , isActualOnly integer default null
  , rowCount integer default null
  , operatorIdIns	integer
)
return sys_refcursor;



/* group: функции для работы со связями роль-группа*/

/* pproc: createGroupRole
  Процедура добавления роли в группу.

  Входные параметры:
    groupID                                - ID группы
    roleID                                 - ID роли
    operatorID                             - ID оператора
    computerName                           - Имя компьютера, с которого производится действие
    ipAddress                              - IP адрес компьютера, с которого производится действие

  Выходные параметры отсутствуют.

  ( <body::createGroupRole>)
*/
procedure createGroupRole(
  groupId integer
  , roleId integer
  , operatorId integer
  , computerName varchar2 default null
  , ipAddress varchar2 default null
);

/* pproc: deleteGroupRole
  Процедура удаления роли из группы.

  Входные параметры:
    groupID                                - ID группы
    roleID                                 - ID роли
    operatorID                             - ID оператора
    computerName                           - Имя компьютера, с которого производится действие
    ipAddress                              - IP адрес компьютера, с которого производится действие

  Выходные параметры отсутствуют.

  ( <body::deleteGroupRole>)
*/
procedure deleteGroupRole(
  groupId integer
  , roleId integer
  , operatorId integer
  , computerName varchar2 default null
  , ipAddress varchar2 default null
);

/* pfunc: findGroupRole
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

  ( <body::findGroupRole>)
*/
function findGroupRole(
  groupId integer default null
  , roleId integer default null
  , rowCount integer default null
  , operatorId integer
)
return sys_refcursor;

/* pfunc: operatorLoginReport
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

  ( <body::operatorLoginReport>)
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
return sys_refcursor;

/* pfunc: autoUnlockOperator
   Функция автоматической разбокировки операторов.

   Входные параметры отсутствуют.

   Возврат:
     operator_unlocked_count      - Количество разблокированных операторов

  ( <body::autoUnlockOperator>)
*/
function autoUnlockOperator
return integer;



/* group: Функции для работы с группами операторов */

/* pfunc: createLoginAttemptGroup
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

  ( <body::createLoginAttemptGroup>)
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
return integer;

/* pproc: updateLoginAttemptGroup
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

  ( <body::updateLoginAttemptGroup>)
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
);

/* pproc: deleteLoginAttemptGroup
   Процедура удаления группы параметров блокировки.

   Входные параметры:
     loginAttemptGroupId          - ИД записи
     operatorId                   - ИД оператора

   Выходные параметры отсутствуют.

  ( <body::deleteLoginAttemptGroup>)
*/
procedure deleteLoginAttemptGroup(
  loginAttemptGroupId integer
  , operatorId integer
);

/* pfunc: findLoginAttemptGroup
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

  ( <body::findLoginAttemptGroup>)
*/
function findLoginAttemptGroup(
  loginAttemptGroupId integer default null
  , loginAttemptGroupName varchar2 default null
  , isDefault number default null
  , lockTypeCode varchar2 default null
  , maxRowCount number default null
  , operatorId integer default null
)
return sys_refcursor;

/* pfunc: getLoginAttemptGroup
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

  ( <body::getLoginAttemptGroup>)
*/
function getLoginAttemptGroup(
  lockTypeCode varchar2 default null
)
return sys_refcursor;

/* pproc: changeLoginAttemptGroup
   Процедура массовой смена группы параметров блокировки.

   Входные параметры:
     oldLoginAttemptGroupId       - Идентификатор группы, с которой
                                    осуществляется перенос
     newLoginAttemptGroupId       - Идентификатор группы, на которую
                                    осуществляется перенос
     operatorId                   - ИД оператора

   Выходные параметры отсутствуют.

  ( <body::changeLoginAttemptGroup>)
*/
procedure changeLoginAttemptGroup(
  oldLoginAttemptGroupId integer
  , newLoginAttemptGroupId integer
  , operatorId integer
);



/* group: Функции по выдачу админских прав */

/* pproc: setAdminGroup
  Функция выдает администраторские права оператору на группу

  Параметры:
  targetOperatorId            - идентификатор, которому выдаются права
  groupId                     - идентификатор группы
  operatorId                  - идентификатор пользователя

  ( <body::setAdminGroup>)
*/
procedure setAdminGroup(
  targetOperatorId            integer
, groupId                     integer
, operatorId                  integer
);

/* pproc: setAdminRole
  Функция выдает администраторские права оператору на роль

  Параметры:
  targetOperatorId            - идентификатор, которому выдаются права
  roleId                      - идентификатор роли
  operatorId                  - идентификатор пользователя

  ( <body::setAdminRole>)
*/
procedure setAdminRole(
  targetOperatorId            integer
, roleId                      integer
, operatorId                  integer
);

end pkg_AccessOperator;
/
