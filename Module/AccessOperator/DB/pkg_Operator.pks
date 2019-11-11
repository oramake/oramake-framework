create or replace package pkg_Operator is
/* package: pkg_Operator
  Интерфейсный пакет модуля Operator.

  SVN root: Module/AccessOperator
*/



/* group: Константы */

/* const: Module_Name
  Название модуля, к которому относится пакет.
*/
Module_Name constant varchar2(30) := 'AccessOperator';



/* group: Коды парольных политик */

/* const: NumUL_PasswordPolicyCode
  Парольная политика "цифры + буквы в верхнем регистре + буквы в нижнем регистре".
*/
NumUL_PasswordPolicyCode constant varchar2(10) := 'NUM_U_L';

/* const: NumULSp_PasswordPolicyCode
  Парольная политика "цифры + буквы в верхнем регистре + буквы в нижнем регистре + спецсимволы".
*/
NumULSp_PasswordPolicyCode constant varchar2(10) := 'NUM_U_L_SP';



/* group: Роли для работы с модулем */

/* const: ROLEADMIN_ROLEID
 ID роли "Администратор прав доступа" */
ROLEADMIN_ROLEID CONSTANT INTEGER := 5;

/* const: ROLEADMIN_ROLE
Имя роли "Администратор прав доступа" */
ROLEADMIN_ROLE CONSTANT VARCHAR2(50) := 'RoleAdmin';

/* const: RoleShowDSLoyalInBranch
ID роли "Администратор пользователей" */
USERADMIN_ROLEID CONSTANT INTEGER := 1;

/* const: USERADMIN_ROLE
Имя роли "Администратор пользователей" */
USERADMIN_ROLE CONSTANT VARCHAR2(50) := 'UserAdmin';

/* const: OpLoginAttmptGrpAdmin_RoleName
   Имя роли "Администратор настроек параметров блокировок"
*/
OpLoginAttmptGrpAdmin_RoleName constant varchar2(50) := 'OpLoginAttemptGroupAdmin';



/* group: Типы блокировок */

/* const: Permanent_LockTypeCode
   Тип блокировки "Постоянная"
*/
Permanent_LockTypeCode constant varchar2(20) := 'PERMANENT';

/* const: Unused_LockTypeCode
   Тип блокировки "Не используется"
*/
Unused_LockTypeCode constant varchar2(20) := 'UNUSED';

/* const: Temporal_LockTypeCode
   Тип блокировки "Временная"
*/
Temporal_LockTypeCode constant varchar2(20) := 'TEMPORAL';



/* group: Опции для работы с модулем
  Параметры хранятся в модуле Option ( Oracle/Module/Option).
*/

/* const: HashSalt_OptSName
  Короткое название параметра для хранения
  "соли" хэша пароля.
*/
HashSalt_OptSName constant varchar2(50) := 'HashSalt';



/* group: Функции */

/* pfunc: getHash
  Возвращает hex-строку с MD5 контрольной суммой.

  Параметры:

  inputString                 - исходная строка для расчета контрольной суммы;

  Возврат:
  - возвращает hex-строку с MD5 контрольной суммой;

  ( <body::getHash>)
*/
function getHash(
  inputString varchar2
)
return varchar2;

/* pfunc: getHashSalt
  Функция хэширования пароля с "солью".

  Входные параметры:
    password                              - пароль

  Возврат:
    hashSalt                              - Хэш пароля с "солью"

  ( <body::getHashSalt>)
*/
function getHashSalt(
  password varchar2
)
return varchar2;



/* group: Регистрация */

/* pfunc: login
  Регистрирует оператора в базе по логину и
  паролю/хэшу пароля и возвращает имя оператора.

  Входные параметры:
    operatorLogin               - логин оператора
    password                    - пароль

  Возврат:
    current_operator_name       - ФИО текущего оператора

  ( <body::login>)
*/
function login(
  operatorLogin varchar2
  , password varchar2
  , passwordHash varchar2 default null
)
return varchar2;

/* pfunc: login
  Регистрирует оператора в базе и возвращает имя оператора.

  Параметры:
  operatorLogin               - логин оператора;

  Выходные параметры:

 CurrentOperatorName - ;
)

  ( <body::login>)
*/
function login( operatorLogin varchar2)
return varchar2;

/* pproc: login
  Регистрирует оператора в базе ( без проверки пароля).

  Параметры:
  operatorLogin               - логин оператора

  ( <body::login>)
*/
procedure login(
  operatorLogin varchar2
);

/* pproc: setCurrentUserId
  Регистрирует оператора в базе ( без проверки пароля).

  Параметры:
  operatorId                  - Id оператора;

  ( <body::setCurrentUserId>)
*/
procedure setCurrentUserId( operatorId integer);

/* pproc: remoteLogin
  Регистрирует текущего оператора в удаленной БД.

  Параметры:
  dbLink                      - имя линка к удаленной БД;

  ( <body::remoteLogin>)
*/
procedure remoteLogin(
  dbLink varchar2
);

/* pproc: logoff
  Отменяет текущую регистрацию;

  ( <body::logoff>)
*/
procedure logoff;

/* pfunc: getCurrentUserId
   Возвращает ID текущего оператора.

   Входные параметры:
     isRaiseException - флаг выбрасывания исключения в случае,
                        если текущий оператор не определен
                        0 - флаг не активен
                        1 - флаг активен

   Возврат:
     oprator_id       - ИД текущего оператора


  ( <body::getCurrentUserId>)
*/
function getCurrentUserId(
  isRaiseException integer default 1
)
return integer;

/* pfunc: getCurrentUserName
   Возвращает имя текущего оператора.

   Входные параметры:
     isRaiseException - флаг выставления исключения в случае,
                        если текущий оператор не определен
                        0 - флаг не активен
                        1 - флаг активен

   Возврат:
     oprator_name     - Имя текущего оператора


  ( <body::getCurrentUserName>)
*/
function getCurrentUserName(
  isRaiseException integer default 1
)
return varchar2;



/* group: Проверка */

/* pfunc: isRole(operatorId,DEPRECATED)
  Проверяет наличие роли у оператора.

  Параметры:
  operatorId                  - id оператора
  roleId                      - id роли

  Возвращаемые значения:
  1 - роль установлена;
  0 - роль не установлена;

  Замечание:
  - устаревшая функция. Не использовать.

  ( <body::isRole(operatorId,DEPRECATED)>)
*/
function isRole(
  operatorId integer
, roleId     integer
)
return integer;

/* pfunc: isRole(operatorId)
  Проверяет наличие роли у оператора.

  Параметры:

  operatorId                  - id оператора
  roleShortName               - короткое наименование роли

  Возвращаемые значения:
  1 - роль установлена;
  0 - роль не установлена;

  ( <body::isRole(operatorId)>)
*/
function isRole(
  operatorId integer
  , roleShortName varchar2
)
return integer;

/* pfunc: isRole
  Проверяет наличие роли у текущего оператора.

  Параметры:
  roleShortName               - имя роли;

  Возвращаемые значения:
  1 - роль установлена;
  0 - роль не установлена;

  ( <body::isRole>)
*/
function isRole(
  roleShortName varchar2
)
return integer;

/* pproc: isRole(operatorId,DEPRECATED)
  Проверяет наличие роли у оператора и в случае ее отсутствия выбрасывает
  исключение.

  Параметр:

  operatorID                  - ID оператора;
  roleID                      - ID роли;

  Замечание:
  - устаревшая функция. Не использовать.

  ( <body::isRole(operatorId,DEPRECATED)>)
*/
procedure isRole
 (OPERATORID INTEGER
 ,ROLEID INTEGER
 );

/* pproc: isRole(operatorId)
  Проверяет наличие роли у оператора и в случае ее отсутствия выбрасывает
  исключение.

  Параметр:

  operatorId                  - id оператора;
  roleShortName               - имя роли;

  ( <body::isRole(operatorId)>)
*/
procedure isRole(
  operatorId integer
  , roleShortName varchar2
);

/* pproc: isRole
  Проверяет наличие роли у текущего оператора и в случае отсутствия
  регистрации или роли выбрасывает исключение.

  Параметр:
  roleShortName               - имя роли

  ( <body::isRole>)
*/
procedure isRole(
  roleShortName varchar2
);

/* pproc: isUserAdmin
  Проверяет права на администрирование операторов и в случае их отсутствия
  выбрасывает исключение.

  Входные параметры:

  operatorID                  - ID оператора, выполняющего действие;
  targetOperatorID            - ID оператора, над которым выполняется действие;
  roleID                      - ID выдаваемой/забираемой роли;
  groupID                     - ID выдаваемой/забираемой группы;


  ( <body::isUserAdmin>)
*/
procedure isUserAdmin
 (OPERATORID INTEGER
 ,TARGETOPERATORID INTEGER := null
 ,ROLEID INTEGER := null
 ,GROUPID INTEGER := null
 );



/* group: Изменение пароля (перенести в pkg_AccessOperator) */

/* pproc: checkPassword
  Процедура проверки пароля.

  Входные параметры:
    operatorId          - Пользователь, которого необходимо восстановить
    password            - Текущий пароль
    newPassword         - Новый пароль
    newPasswordConfirm  - Новый пароль ( подтверждение)
    operatorIdIns       - Идентификатор оператора
    passwordPolicyCode  - Код парольной политики (
                          NUM_U_L - цифры + буквы в верхнем регистре + буквы в нижнем регистре
                          NUM_U_L_SP - цифры + буквы в верхнем регистре + буквы в нижнем регистре
                            + спецсимволы
                          ). По умолчанию "NUM_U_L_SP".

  ( <body::checkPassword>)
*/
procedure checkPassword(
  operatorId integer
  , password varchar2 default null
  , newPassword varchar2
  , newPasswordConfirm varchar2 default null
  , operatorIdIns integer default null
  , passwordPolicyCode varchar2 default null
);

/* pproc: changePasswordHash
Меняет пароль у оператора.

Параметры:

operatorID                  - ID оператора;
passwordHash                - Hash пароль;
operatorIDIns               - ID оператора, выполняющего процедуру;

  ( <body::changePasswordHash>)
*/
procedure changePasswordHash (operatorid integer
                             ,passwordHash varchar2
                             ,operatoridins integer
                             );

/* pproc: changePasswordHash
Меняет пароль у оператора.

Параметры:

operatorID                  - ID оператора;
passwordHash                    - Hash пароль;
newPasswordHash             - Hash новый пароль;
newPasswordConfirmHash      - подтверждение пароля;
(<body::changePasswordHash>)

  ( <body::changePasswordHash>)
*/
procedure changePasswordHash
 (operatorid integer
 ,passwordHash varchar2
 ,newPasswordHash varchar2
 ,newPasswordConfirmHash varchar2
 );

/* pproc: changePassword
Меняет пароль у оператора.

Параметры:

operatorID                  - ID оператора;
password                    - пароль;
operatorIDIns               - ID оператора, выполняющего процедуру;


  ( <body::changePassword>)
*/
procedure changePassword
 (OPERATORID INTEGER
 ,PASSWORD VARCHAR2
 ,OPERATORIDINS INTEGER
 );

/* pproc: changePassword
Меняет пароль у оператора.

Параметры:

operatorID                  - ID оператора;
password                    - пароль;
newPassword                 - новый пароль;
newPasswordConfirm          - подтверждение пароля;


  ( <body::changePassword>)
*/
PROCEDURE changePassword
 (OPERATORID INTEGER
 ,PASSWORD VARCHAR2
 ,NEWPASSWORD VARCHAR2
 ,NEWPASSWORDCONFIRM VARCHAR2
 );

/* pproc: changePassword
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

  ( <body::changePassword>)
*/
PROCEDURE changePassword(
  OPERATORID INTEGER
  , PASSWORD VARCHAR2
  , NEWPASSWORD VARCHAR2
  , NEWPASSWORDCONFIRM VARCHAR2
  , passwordPolicyCode varchar2
);

/* pfunc: getOperatorName
  Функция поиска имени оператора.

  Входные параметры:
    operatorId                  - ID оператора

  Возврат:
    operator_name               - Имя оператора

  ( <body::getOperatorName>)
*/
function getOperatorName(
  operatorId integer
)
return varchar2;

/* pfunc: isChangePassword
  Флаг необходимости принудительной смены пароля.

  Входные параметры:
    operatorId                  - ID оператора

  Возврат:
    result                      - 0 - Не меняем
                                  1 - Меняем

  ( <body::isChangePassword>)
*/
function isChangePassword(
  operatorId integer
)
return number;



/* group: Функции для формирования различных списков ролей и групп */

/* pfunc: getRoles
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


  ( <body::getRoles>)
*/
FUNCTION getRoles(login  varchar2 )
return sys_refcursor;

/* pfunc: getRoles
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


  ( <body::getRoles>)
*/
FUNCTION getRoles(operatorId  integer )
return sys_refcursor;

 /* pfunc: getRolesShortName
     Функция возвращает short_name роли

Входные параметры:

  login - логин

Выходные параметры(в виде курсора):

   short_name - short_name роли;


  ( <body::getRolesShortName>)
*/
FUNCTION getRolesShortName
 (
  login        varchar2 := null
 )
return sys_refcursor;

 /* pfunc: getRolesShortName
     Функция возвращает short_name роли

Входные параметры:

  operatorID - operatorID

Выходные параметры(в виде курсора):

   short_name - short_name роли;

(<body::getRolesShortName>)

  ( <body::getRolesShortName>)
*/
FUNCTION getRolesShortName
 (
  operatorID      integer := null
 )
return sys_refcursor;

/* pfunc: getOperator
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

  ( <body::getOperator>)
*/
function getOperator(
  operatorName varchar2 default null
  , operatorName_en varchar2 default null
  , maxRowCount integer := null
  , rowCount integer default 25
)
return sys_refcursor;

/* pfunc: getNoOperatorRole
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

  ( <body::getNoOperatorRole>)
*/
function getNoOperatorRole(
  operatorId integer
  , operatorIdIns	integer
)
return sys_refcursor;

/* pfunc: getNoOperatorGroup
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

  ( <body::getNoOperatorGroup>)
*/
function getNoOperatorGroup(
  operatorId integer
  , operatorIdIns integer
)
return sys_refcursor;

/* pfunc: getNoGroupRole
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

  ( <body::getNoGroupRole>)
*/
function getNoGroupRole(
  groupId integer
  , operatorId integer
)
return sys_refcursor;

/* pfunc: getRole
  Функция формирования списка ролей.

  Входные параметры:
    roleName                         - Слово для поиска роли

  Возврат (в виде курсора):
    role_id                          - ИД роли
    role_name                        - Наименование роли

  ( <body::getRole>)
*/
function getRole(
  roleName varchar2
)
return sys_refcursor;

/* pfunc: getGroup
  Функция формирования списка групп.

  Входные параметры:
    groupName                        - Слово для поиска группы

  Возврат (в виде курсора):
    group_id                         - ИД роли
    group_name                       - Наименование роли

  ( <body::getGroup>)
*/
function getGroup(
  groupName varchar2
)
return sys_refcursor;

/* pfunc: getOperatorIDByLogin
   Функция возвращает ID оператора по логину

   Входные параметры:
   login - логин оператора

   Выходные параметры:
    ID оператора

  ( <body::getOperatorIDByLogin>)
*/
function getOperatorIDByLogin(login varchar2 )
return integer;

/* pfunc: GetRoleID
   Функция возвращает ID роли по краткому наименованию

  ( <body::GetRoleID>)
*/
function GetRoleID(roleName	varchar2)
return integer;

/* pfunc: GetGroupID
   Функция возвращает ID группы по краткому наименованию

  ( <body::GetGroupID>)
*/
function GetGroupID(groupName	varchar2)
return integer;



/* group: Функции для работы с блокировками */

/* pfunc: getLockType
   Функция формирования списка типов блокировок.

   Входные параметры отсутствуют.

   Возврат (в виде курсора):
     lock_type_code               - Код типа блокировки
     lock_type_name               - Наименование типа

  ( <body::getLockType>)
*/
function getLockType
return sys_refcursor;

end pkg_Operator;
/
