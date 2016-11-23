create or replace package pkg_Operator is
/* package: pkg_Operator
  Интерфейсный пакет модуля Operator.

  SVN root: RusFinanceInfo/Module/AccessOperator
*/

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


/* func: GETHASH
  Возвращает hex-строку с MD5 контрольной суммой.

  Параметры:

  inputString                 - исходная строка для расчета контрольной суммы;

  выходные параметры:

  Возвращает hex-строку с MD5 контрольной суммой.

 ( <body::GETHASH>).
*/
FUNCTION GETHASH
 (INPUTSTRING VARCHAR2
 )
 RETURN VARCHAR2;

/* func: LOGIN
  Регистрирует оператора в базе и возвращает имя оператора.

 Параметры:

 operatorLogin               - логин оператора;
 password                    - пароль;

 Выходные параметры:

 currentOperatorNameRus - ;

(<body::LOGIN>)
*/
FUNCTION LOGIN
 (OPERATORLOGIN VARCHAR2
 ,PASSWORD VARCHAR2
 )
 RETURN VARCHAR2;

/* func: LOGIN
  Регистрирует оператора в базе и возвращает имя оператора.

 Параметры:

 operatorLogin               - логин оператора

 Выходные параметры:

 currentOperatorNameRus - ;

(<body::LOGIN>)
*/
FUNCTION LOGIN
 (OPERATORLOGIN VARCHAR2
 )
 RETURN VARCHAR2;

/* func: LOGIN
  Регистрирует оператора в базе ( без проверки пароля) и возвращает имя
  оператора в случае наличия у него указанной роли, иначе выбрасывает
  исключение.

  Параметры:

 operatorLogin               - логин оператора;
 roleID                      - ID роли;

 Выходные параметры:

 currentOperatorNameRus - ;

(<body::LOGIN>)
*/
FUNCTION LOGIN
 (OPERATORLOGIN VARCHAR2
 ,ROLEID INTEGER
 )
 RETURN VARCHAR2;

/* proc: LOGIN
  Регистрирует оператора в базе ( без проверки пароля).

  Параметры:

  operatorLogin               - логин оператора;

(<body::LOGIN>)
*/
PROCEDURE LOGIN
 (OPERATORLOGIN VARCHAR2
 );

/* proc: SETCURRENTUSERID
  Регистрирует оператора в базе ( без проверки пароля).

  Параметры:

 operatorID                  - ID оператора;

(<body::SETCURRENTUSERID>)
*/
PROCEDURE SETCURRENTUSERID
 (OPERATORID INTEGER
 );

/* proc: REMOTELOGIN
   Регистрирует текущего оператора в удаленной БД.

  Параметры:

  dbLink                      - имя линка к удаленной БД;

(<body::REMOTELOGIN>)
*/
PROCEDURE REMOTELOGIN
 (DBLINK VARCHAR2
 );

/* proc: LOGOFF
   Отменяет текущую регистрацию
(<body::LOGOFF>)
*/
PROCEDURE LOGOFF;

/* func: GETCURRENTUSERID
   Возвращает ID текущего оператора ( при отсутствии регистрации - выбрасывает
исключение).
(<body::GETCURRENTUSERID>)
*/
FUNCTION GETCURRENTUSERID
 RETURN INTEGER;

/* func: GETCURRENTUSERNAME
Возвращает имя текущего оператора ( при отсутствии регистрации - выбрасывает
исключение).
(<body::GETCURRENTUSERNAME>)
*/
FUNCTION GETCURRENTUSERNAME
 RETURN VARCHAR2;

/* func: ISROLE
  Проверяет наличие роли у оператора.

  Параметры:

  operatorID                  - ID оператора;
  roleID                      - ID роли;

 Возвращаемые значения:

 1 - роль установлена;
 0 - роль не установлена;
(<body::ISROLE>)
*/
FUNCTION ISROLE
 (OPERATORID INTEGER
 ,ROLEID INTEGER
 )
 RETURN INTEGER;

/* func: ISROLE
  Проверяет наличие роли у оператора.

  Параметры:

  operatorID                  - ID оператора;
  roleShortName                      - имя роли;

 Возвращаемые значения:
 1 - роль установлена;
 0 - роль не установлена;
(<body::ISROLE>)
*/
FUNCTION ISROLE
 (OPERATORID INTEGER
 ,ROLESHORTNAME VARCHAR2
 )
 RETURN INTEGER;

/* func: ISROLE
  Проверяет наличие роли у текущего оператора.

  Параметры:

  roleID                      - ID роли;

 Возвращаемые значения:

 1 - роль установлена;
 0 - роль не установлена;
(<body::ISROLE>)
*/
FUNCTION ISROLE
 (ROLEID INTEGER
 )
 RETURN INTEGER;

/* func: ISROLE
  Проверяет наличие роли у текущего оператора.

  Параметры:

  roleShortName               - имя роли;

 Возвращаемые значения:

 1 - роль установлена;
 0 - роль не установлена;
(<body::ISROLE>)
*/
FUNCTION ISROLE
 (ROLESHORTNAME VARCHAR2
 )
 RETURN INTEGER;

/* proc: ISROLE
 Проверяет наличие роли у оператора и в случае ее отсутствия выбрасывает
 исключение.

 Параметр:

 operatorID                  - ID оператора;
 roleID                      - ID роли;
(<body::ISROLE>)
*/
PROCEDURE ISROLE
 (OPERATORID INTEGER
 ,ROLEID INTEGER
 );

/* proc: ISROLE
 Проверяет наличие роли у оператора и в случае ее отсутствия выбрасывает
 исключение.

 Параметр:

 operatorID                  - ID оператора;
 roleShortName               - имя роли;
(<body::ISROLE>)
*/
PROCEDURE ISROLE
 (OPERATORID INTEGER
 ,ROLESHORTNAME VARCHAR2
 );

/* proc: ISROLE
Проверяет наличие роли у текущего оператора и в случае отсутствия регистрации
или роли выбрасывает исключение.

Параметр:

roleID                      - ID роли;
(<body::ISROLE>)
*/
PROCEDURE ISROLE
 (ROLEID INTEGER
 );

/* proc: ISROLE
Проверяет наличие роли у текущего оператора и в случае отсутствия регистрации
или роли выбрасывает исключение.

Параметр:
roleShortName               - имя роли;
(<body::ISROLE>)
*/
PROCEDURE ISROLE
 (ROLESHORTNAME VARCHAR2
 );

/* proc: CREATEROLE
Создает роль.

Параметры:

roleID                      - ID роли;
roleNameRus                 - название роли ( рус.);
roleNameEng                 - название роли ( анг.);
shortName                   - короткое название роли;
description                 - описание;
operatorID                  - ID оператора, выполняющего процедуру;
(<body::CREATEROLE>)
*/
PROCEDURE CREATEROLE
 (ROLEID INTEGER
 ,ROLENAMERUS VARCHAR2
 ,ROLENAMEENG VARCHAR2
 ,SHORTNAME VARCHAR2
 ,DESCRIPTION VARCHAR2 := null
 ,OPERATORID INTEGER
 );

/* func: CREATEROLE
Создает роль.

Параметры:

roleNameRus                 - название роли ( рус.);
roleNameEng                 - название роли ( анг.);
shortName                   - короткое название роли;
description                 - описание;
operatorID                  - ID оператора, выполняющего процедуру;

Выходные параметры:
 ID созданной записи

(<body::CREATEROLE>)
*/
function CREATEROLE
 ( ROLENAMERUS VARCHAR2
 ,ROLENAMEENG VARCHAR2
 ,SHORTNAME VARCHAR2
 ,DESCRIPTION VARCHAR2 := null
 ,OPERATORID INTEGER
 )
 return integer;

/* proc: UPDATEROLE
Изменяет роль.

Параметры:

roleID                      - ID роли;
roleNameRus                 - название роли ( рус.);
roleNameEng                 - название роли ( анг.);
shortName                   - короткое название роли;
description                 - описание;
operatorID                  - ID оператора, выполняющего процедуру;
(<body::UPDATEROLE>)
*/
PROCEDURE UPDATEROLE
 (ROLEID INTEGER
 ,ROLENAMERUS VARCHAR2
 ,ROLENAMEENG VARCHAR2
 ,SHORTNAME VARCHAR2
 ,DESCRIPTION VARCHAR2
 ,OPERATORID INTEGER
 );

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
(<body::CREATEGROUP>)
*/
FUNCTION CREATEGROUP
 (GROUPNAMERUS VARCHAR2
 ,GROUPNAMEENG VARCHAR2
 ,ISGRANTONLY INTEGER := null
 ,OPERATORID INTEGER
 )
 RETURN INTEGER;

/* proc: UPDATEGROUP
Изменяет группу.

Параметры:

groupID                     - ID группы;
groupNameRus                - название группы ( рус.);
groupNameEng                - название группы ( анг.);
isGrantOnly                 - если 1, то группа предоставляет право только;
                              выдавать данные ей роли другим операторам;
operatorID                  - ID оператора, выполняющего процедуру;
(<body::UPDATEGROUP>)
*/
PROCEDURE UPDATEGROUP
 (GROUPID INTEGER
 ,GROUPNAMERUS VARCHAR2
 ,GROUPNAMEENG VARCHAR2
 ,ISGRANTONLY INTEGER
 ,OPERATORID INTEGER
 );


/* proc: CREATEGROUPROLE
Включает роль в группу.

Параметры:

groupID                     - ID группы;
roleID                      - ID роли;
operatorID                  - ID оператора, выполняющего процедуру;
(<body::CREATEGROUPROLE>)
*/
PROCEDURE CREATEGROUPROLE
 (GROUPID INTEGER
 ,ROLEID INTEGER
 ,OPERATORID INTEGER
 );

/* proc: DELETEGROUPROLE
Удаляет роль из группы.

Параметры:

groupID                     - ID группы
roleID                      - ID роли
operatorID                  - ID оператора, выполняющего процедуру
(<body::DELETEGROUPROLE>)
*/
PROCEDURE DELETEGROUPROLE
 (GROUPID INTEGER
 ,ROLEID INTEGER
 ,OPERATORID INTEGER
 );

/* proc: CREATEGRANTGROUP
Добавляет право на выдачу группы.

Параметры:

groupID                     - ID группы, которой выдается право выдачи;
grantGroupID                - ID выдаваемой группы;
operatorID                  - ID оператора, выполняющего процедуру;
(<body::CREATEGRANTGROUP>)
*/
PROCEDURE CREATEGRANTGROUP
 (GROUPID INTEGER
 ,GRANTGROUPID INTEGER
 ,OPERATORID INTEGER
 );

/* proc: DELETEGRANTGROUP
Удаляет право на выдачу группы.

Параметры:

groupID                     - ID группы, у которой удаляет право выдачи;
grantGroupID                - ID выдаваемой группы;
operatorID                  - ID оператора, выполняющего процедуру;
(<body::DELETEGRANTGROUP>)
*/
PROCEDURE DELETEGRANTGROUP
 (GROUPID INTEGER
 ,GRANTGROUPID INTEGER
 ,OPERATORID INTEGER
 );

/* func: CREATEOPERATOR
Создает нового оператора и возвращает его ID.

Параметры:

operatorNameRus                - имя оператора;
operatorNameEng             - имя оператора (на английском);
login                       - логин;
password                    - пароль;
changepassword              - флаг смены пароля оператора;
operatorIDIns               - ID оператора, выполняющего процедуру;
(<body::CREATEOPERATOR>)
*/
FUNCTION CREATEOPERATOR
 (OPERATORNAMERUS VARCHAR2
 ,OPERATORNAMEENG VARCHAR2
 ,LOGIN VARCHAR2
 ,PASSWORD VARCHAR2
 ,CHANGEPASSWORD INTEGER
 ,OPERATORIDINS INTEGER
 )
 RETURN INTEGER;

/* func: CreateOperatorHash
Создает нового оператора и возвращает его ID.

Параметры:

operatorName             - имя оператора;
operatorNameEn            - имя оператора (на английском);
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
 RETURN INTEGER;

/* proc: UPDATEOPERATOR
Изменяет данные оператора.

Параметры:

operatorID                  - id оператора;
operatorNameRus             - имя оператора;
operatorNameEng             - имя оператора (на английском);
login                       - логин;
changePassword              - флаг смены пароля;
operatorIDIns               - ID оператора, выполняющего процедуру;
(<body::UPDATEOPERATOR>)
*/
PROCEDURE UPDATEOPERATOR
 (OPERATORID INTEGER
 ,OPERATORNAMERUS VARCHAR2
 ,OPERATORNAMEENG VARCHAR2
 ,LOGIN VARCHAR2
 ,CHANGEPASSWORD INTEGER
 ,OPERATORIDINS INTEGER
 );

/* proc: CHANGEPASSWORD
Меняет пароль у оператора.

Параметры:

operatorID                  - ID оператора;
password                    - пароль;
operatorIDIns               - ID оператора, выполняющего процедуру;
(<body::CHANGEPASSWORD>)
*/
PROCEDURE CHANGEPASSWORD
 (OPERATORID INTEGER
 ,PASSWORD VARCHAR2
 ,OPERATORIDINS INTEGER
 );

/* proc: ChangePasswordHash
Меняет пароль у оператора.

Параметры:

operatorID                  - ID оператора;
passwordHash                - Hash пароль;
operatorIDIns               - ID оператора, выполняющего процедуру;
(<body::ChangePasswordHash>)
*/
procedure ChangePasswordHash (operatorid integer
                             ,passwordHash varchar2
                             ,operatoridins integer
                             );

/* proc: CHANGEPASSWORD
Меняет пароль у оператора.

Параметры:

operatorID                  - ID оператора;
password                    - пароль;
newPassword                 - новый пароль;
newPasswordConfirm          - подтверждение пароля;
(<body::CHANGEPASSWORD>)
*/
PROCEDURE CHANGEPASSWORD
 (OPERATORID INTEGER
 ,PASSWORD VARCHAR2
 ,NEWPASSWORD VARCHAR2
 ,NEWPASSWORDCONFIRM VARCHAR2
 );

/* proc: changePasswordHash
Меняет пароль у оператора.

Параметры:

operatorID                  - ID оператора;
passwordHash                    - Hash пароль;
newPasswordHash             - Hash новый пароль;
newPasswordConfirmHash      - подтверждение пароля;
(<body::changePasswordHash>)
*/
procedure changePasswordHash (operatorid integer
                             ,passwordHash varchar2
                             ,newPasswordHash varchar2
                             ,newPasswordConfirmHash varchar2
                             );

/* proc: DELETEOPERATORROLE
Отбирает роль у оператора.

Параметры:

operatorID                  - ID оператора;
roleID                      - ID роли;
operatorIDIns               - ID оператора, выполняющего процедуру;
(<body::DELETEOPERATORROLE>)
*/
PROCEDURE DELETEOPERATORROLE
 (OPERATORID INTEGER
 ,ROLEID INTEGER
 ,OPERATORIDINS INTEGER
 );

/* proc: CREATEOPERATORGROUP
Включает оператора в группу.

Параметры:

operatorID                  - ID оператора;
groupID                     - ID группы;
operatorIDIns               - ID оператора, выполняющего процедуру;
(<body::CREATEOPERATORGROUP>)
*/
PROCEDURE CREATEOPERATORGROUP
 (OPERATORID INTEGER
 ,GROUPID INTEGER
 ,OPERATORIDINS INTEGER
 );

/* proc: DELETEOPERATORGROUP
Удаляет оператора из группы.

Параметры:

operatorID                  - ID оператора;
groupID                     - ID группы;
operatorIDIns               - ID оператора, выполняющего процедуру;
(<body::DELETEOPERATORGROUP>)
*/
PROCEDURE DELETEOPERATORGROUP
 (OPERATORID INTEGER
 ,GROUPID INTEGER
 ,OPERATORIDINS INTEGER
 );

/* func: GETOPERATORNAME
Возвращает имя оператора

Параметры:
operatorID                  - ID оператора

Выходные параметры:

Имя оператора
(<body::GETOPERATORNAME>)
*/
FUNCTION GETOPERATORNAME
 (OPERATORID INTEGER
 )
 RETURN VARCHAR2;

/* func: ISCHANGEPASSWORD
Флаг необходимости принудительной смены пароля
0-НЕ меняем
1-Меняем

Параметры:

operatorID                  - ID оператора

(<body::ISCHANGEPASSWORD>)
*/
FUNCTION ISCHANGEPASSWORD
 (OPERATORID INTEGER := null
 )
 RETURN number;

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

(<body::getRoles>)
*/
FUNCTION getRoles
 (
  login        varchar2
 )
return sys_refcursor;

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

(<body::getRoles>)
*/
FUNCTION getRoles
 (
  operatorId        integer
 )
return sys_refcursor;

 /* func: getRolesShortName
     Функция возвращает short_name роли

Входные параметры:

  login - логин

Выходные параметры(в виде курсора):

   short_name - short_name роли;

(<body::getRolesShortName>)
*/
FUNCTION getRolesShortName
 (
  login        varchar2 := null
 )
return sys_refcursor;

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
return sys_refcursor;


 /* pfunc: getOperator
     Функция возвращает

Входные параметры:

    operatorName - Имя оператора(рус)
    operatorName_en - Имя оператора(Англ.)

Выходные параметры(в виде курсора):

   operator_id - ID оператора;
   Operator_Name - ФИО оператора;
   Operator_Name_en - ФИО оператора (END);
   maxRowCount                - максимальное количество записей

(<body::getOperator>)
*/
FUNCTION getOperator
 (
  operatorName        varchar2 := null
 , operatorName_en    varchar2 := null
 , maxRowCount        integer  := null
 )
return sys_refcursor;

/* proc: RestoreOperator
   Процедура восстановления удаленного пользователя RestoreOperator

(<body::RestoreOperator>)
*/
procedure RestoreOperator( operatorId	integer,
                           restoreOperatorId	integer);

/* func: CreateOperator
   Функция создания пользователя CreateOperator
(<body::CreateOperator>)
*/
function CreateOperator(operatorName	  varchar2,
                        operatorNameEn	varchar2,
                        login	          varchar2,
                        password	      varchar2,
                        changePassword	integer,
                        operatorIdIns	  integer)
return integer;

/* proc: UpdateOperator
   Процедура обновления пользователя UpdateOperator
(<body::UpdateOperator>)
*/
procedure UpdateOperator( operatorId	    integer,
                          operatorName	  varchar2,
                          operatorNameEn	varchar2,
                          login	          varchar2,
                          password	      varchar2,
                          changePassword	integer,
                          operatorIdIns	  integer);

/* proc: DeleteOperator
   Процедура удаления пользователя DeleteOperator
(<body::DeleteOperator>)
*/
procedure DeleteOperator( operatorId	integer,
                          operatorIdIns	integer);

/* func: FindOperator
   Функция поиска пользователя FindOperator
(<body::FindOperator>)
*/
function FindOperator(  operatorId	   integer,
                        login	         varchar2,
                        operatorName	 varchar2,
                        operatorNameEn	varchar2,
                        deleted	        integer,
                        rowCount	      integer,
                        operatorIdIns	  integer)
return sys_refcursor;

/* proc: RestoreOperator
   Процедура восстановления удаленного пользователя
(<body::RestoreOperator>)
*/
procedure RestoreOperator( operatorId	integer,
                          operatorIdIns	integer);

/* func: CreateRole
   Функция создания роли CreateRole
(<body::CreateRole>)
*/
function CreateRole( roleName	    varchar2,
                     roleNameEn	  varchar2,
                     shortName	  varchar2,
                     description	varchar2,
                     operatorId	  integer)
return integer;

/* proc: UpdateRole
   Процедура обновления роли UpdateRole
(<body::UpdateRole>)
*/
procedure UpdateRole( roleId	     integer,
                      roleName	   varchar2,
                      roleNameEn	 varchar2,
                      shortName	   varchar2,
                      description	 varchar2,
                      operatorId	 integer);
/* proc: DeleteRole
   Процедура удаления роли DeleteRole
(<body::DeleteRole>)
*/
procedure DeleteRole( roleId	integer,
                      operatorId	integer);

/* func: FindRole
   Функция поиска роли FindRole
(<body::FindRole>)
*/
function FindRole(  roleId	     integer,
                    roleName	   varchar2,
                    roleNameEn	 varchar2,
                    shortName	   varchar2,
                    description	 varchar2,
                    rowCount	   integer,
                    operatorId	 integer)
return sys_refcursor;

/* func: CreateGroup
   Функция создания группы CreateGroup
(<body::CreateGroup>)
*/
function CreateGroup( groupName	  varchar2,
                      groupNameEn	varchar2,
                      isGrantOnly	number,
                      operatorId	integer)
return integer;

/* proc: UpdateGroup
   Процедура обновления группы UpdateGroup
(<body::UpdateGroup>)
*/
procedure UpdateGroup(  groupId	    integer,
                        groupName	  varchar2,
                        groupNameEn	varchar2,
                        isGrantOnly	number,
                        operatorId	integer);
/* proc: DeleteGroup
   Процедура удаления группы DeleteGroup
(<body::DeleteGroup>)
*/
procedure DeleteGroup(  groupId	    integer,
                        operatorId	integer);

/* func: FindGroup
   Функция поиска группы FindGroup
(<body::FindGroup>)
*/
function FindGroup( groupId	     integer,
                    groupName	   varchar2,
                    groupNameEn	 varchar2,
                    isGrantOnly	 number,
                    rowCount	   integer,
                    operatorId	 integer)
return sys_refcursor;

/* proc: CreateOperatorRole
   Процедура создания связи пользователя и роли CreateOperatorRole
(<body::CreateOperatorRole>)
*/
procedure CreateOperatorRole( operatorId	  integer,
                              roleId	      integer,
                              operatorIdIns	integer);
/* func: FindOperatorRole
   Функция поиска связи пользователя и роли FindOperatorRole
(<body::FindOperatorRole>)
*/
function FindOperatorRole(  operatorId	integer,
                            roleId	    integer,
                            rowCount	  integer,
                            operatorIdIns	integer)
return sys_refcursor;

/* func: GetNoOperatorRole
   Функция отображения ролей напрямую не принадлежащих пользователю GetNoOperatorRole
(<body::GetNoOperatorRole>)
*/
function GetNoOperatorRole( operatorId	integer,
                            operatorIdIns	integer)
return sys_refcursor;

/* func: FindOperatorGroup
   Функция поиска связи пользователя и группы FindOperatorGroup
(<body::FindOperatorGroup>)
*/
function FindOperatorGroup( operatorId	  integer,
                            groupId	      integer,
                            rowCount	    integer,
                            operatorIdIns	integer)
return sys_refcursor;

/* func: GetNoOperatorGroup
   Функция отображения групп напрямую не принадлежащих пользователю GetNoOperatorGroup
(<body::GetNoOperatorGroup>)
*/
function GetNoOperatorGroup(  operatorId	    integer,
                              operatorIdIns	integer)
return sys_refcursor;

/* func: FindGroupRole
   Функция поиска связи группы и роли FindGroupRole
(<body::FindGroupRole>)
*/
function FindGroupRole( groupId	     integer,
                        roleId	     integer,
                        rowCount	   integer,
                        operatorId	 integer)
return sys_refcursor;

/* func: GetNoGroupRole
   Функция отображения ролей напрямую не принадлежащих группе GetNoGroupRole
(<body::GetNoGroupRole>)
*/
function GetNoGroupRole( groupId	integer,
                         operatorId	integer)
return sys_refcursor;

/* func: FindGrantGroup
   Функция поиска связи grant-группы и группы FindGrantGroup
(<body::FindGrantGroup>)
*/
function FindGrantGroup(  groupId	      integer,
                          grantGroupId	integer,
                          rowCount	    integer,
                          operatorId	  integer)
return sys_refcursor;

/* func: GetNoGrantGroup
   Функция отображения групп напрямую не принадлежащих grant-группе GetNoGrantGroup
(<body::GetNoGrantGroup>)
*/
function GetNoGrantGroup( groupId	integer,
                          operatorId	integer)
return sys_refcursor;

end pkg_Operator;
/
