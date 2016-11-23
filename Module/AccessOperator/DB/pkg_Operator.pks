create or replace package pkg_Operator is
/* package: pkg_Operator
  ������������ ����� ������ Operator.

  SVN root: RusFinanceInfo/Module/AccessOperator
*/

/* const: ROLEADMIN_ROLEID
 ID ���� "������������� ���� �������" */
ROLEADMIN_ROLEID CONSTANT INTEGER := 5;

/* const: ROLEADMIN_ROLE
��� ���� "������������� ���� �������" */
ROLEADMIN_ROLE CONSTANT VARCHAR2(50) := 'RoleAdmin';

/* const: RoleShowDSLoyalInBranch
ID ���� "������������� �������������" */
USERADMIN_ROLEID CONSTANT INTEGER := 1;

/* const: USERADMIN_ROLE
��� ���� "������������� �������������" */
USERADMIN_ROLE CONSTANT VARCHAR2(50) := 'UserAdmin';


/* func: GETHASH
  ���������� hex-������ � MD5 ����������� ������.

  ���������:

  inputString                 - �������� ������ ��� ������� ����������� �����;

  �������� ���������:

  ���������� hex-������ � MD5 ����������� ������.

 ( <body::GETHASH>).
*/
FUNCTION GETHASH
 (INPUTSTRING VARCHAR2
 )
 RETURN VARCHAR2;

/* func: LOGIN
  ������������ ��������� � ���� � ���������� ��� ���������.

 ���������:

 operatorLogin               - ����� ���������;
 password                    - ������;

 �������� ���������:

 currentOperatorNameRus - ;

(<body::LOGIN>)
*/
FUNCTION LOGIN
 (OPERATORLOGIN VARCHAR2
 ,PASSWORD VARCHAR2
 )
 RETURN VARCHAR2;

/* func: LOGIN
  ������������ ��������� � ���� � ���������� ��� ���������.

 ���������:

 operatorLogin               - ����� ���������

 �������� ���������:

 currentOperatorNameRus - ;

(<body::LOGIN>)
*/
FUNCTION LOGIN
 (OPERATORLOGIN VARCHAR2
 )
 RETURN VARCHAR2;

/* func: LOGIN
  ������������ ��������� � ���� ( ��� �������� ������) � ���������� ���
  ��������� � ������ ������� � ���� ��������� ����, ����� �����������
  ����������.

  ���������:

 operatorLogin               - ����� ���������;
 roleID                      - ID ����;

 �������� ���������:

 currentOperatorNameRus - ;

(<body::LOGIN>)
*/
FUNCTION LOGIN
 (OPERATORLOGIN VARCHAR2
 ,ROLEID INTEGER
 )
 RETURN VARCHAR2;

/* proc: LOGIN
  ������������ ��������� � ���� ( ��� �������� ������).

  ���������:

  operatorLogin               - ����� ���������;

(<body::LOGIN>)
*/
PROCEDURE LOGIN
 (OPERATORLOGIN VARCHAR2
 );

/* proc: SETCURRENTUSERID
  ������������ ��������� � ���� ( ��� �������� ������).

  ���������:

 operatorID                  - ID ���������;

(<body::SETCURRENTUSERID>)
*/
PROCEDURE SETCURRENTUSERID
 (OPERATORID INTEGER
 );

/* proc: REMOTELOGIN
   ������������ �������� ��������� � ��������� ��.

  ���������:

  dbLink                      - ��� ����� � ��������� ��;

(<body::REMOTELOGIN>)
*/
PROCEDURE REMOTELOGIN
 (DBLINK VARCHAR2
 );

/* proc: LOGOFF
   �������� ������� �����������
(<body::LOGOFF>)
*/
PROCEDURE LOGOFF;

/* func: GETCURRENTUSERID
   ���������� ID �������� ��������� ( ��� ���������� ����������� - �����������
����������).
(<body::GETCURRENTUSERID>)
*/
FUNCTION GETCURRENTUSERID
 RETURN INTEGER;

/* func: GETCURRENTUSERNAME
���������� ��� �������� ��������� ( ��� ���������� ����������� - �����������
����������).
(<body::GETCURRENTUSERNAME>)
*/
FUNCTION GETCURRENTUSERNAME
 RETURN VARCHAR2;

/* func: ISROLE
  ��������� ������� ���� � ���������.

  ���������:

  operatorID                  - ID ���������;
  roleID                      - ID ����;

 ������������ ��������:

 1 - ���� �����������;
 0 - ���� �� �����������;
(<body::ISROLE>)
*/
FUNCTION ISROLE
 (OPERATORID INTEGER
 ,ROLEID INTEGER
 )
 RETURN INTEGER;

/* func: ISROLE
  ��������� ������� ���� � ���������.

  ���������:

  operatorID                  - ID ���������;
  roleShortName                      - ��� ����;

 ������������ ��������:
 1 - ���� �����������;
 0 - ���� �� �����������;
(<body::ISROLE>)
*/
FUNCTION ISROLE
 (OPERATORID INTEGER
 ,ROLESHORTNAME VARCHAR2
 )
 RETURN INTEGER;

/* func: ISROLE
  ��������� ������� ���� � �������� ���������.

  ���������:

  roleID                      - ID ����;

 ������������ ��������:

 1 - ���� �����������;
 0 - ���� �� �����������;
(<body::ISROLE>)
*/
FUNCTION ISROLE
 (ROLEID INTEGER
 )
 RETURN INTEGER;

/* func: ISROLE
  ��������� ������� ���� � �������� ���������.

  ���������:

  roleShortName               - ��� ����;

 ������������ ��������:

 1 - ���� �����������;
 0 - ���� �� �����������;
(<body::ISROLE>)
*/
FUNCTION ISROLE
 (ROLESHORTNAME VARCHAR2
 )
 RETURN INTEGER;

/* proc: ISROLE
 ��������� ������� ���� � ��������� � � ������ �� ���������� �����������
 ����������.

 ��������:

 operatorID                  - ID ���������;
 roleID                      - ID ����;
(<body::ISROLE>)
*/
PROCEDURE ISROLE
 (OPERATORID INTEGER
 ,ROLEID INTEGER
 );

/* proc: ISROLE
 ��������� ������� ���� � ��������� � � ������ �� ���������� �����������
 ����������.

 ��������:

 operatorID                  - ID ���������;
 roleShortName               - ��� ����;
(<body::ISROLE>)
*/
PROCEDURE ISROLE
 (OPERATORID INTEGER
 ,ROLESHORTNAME VARCHAR2
 );

/* proc: ISROLE
��������� ������� ���� � �������� ��������� � � ������ ���������� �����������
��� ���� ����������� ����������.

��������:

roleID                      - ID ����;
(<body::ISROLE>)
*/
PROCEDURE ISROLE
 (ROLEID INTEGER
 );

/* proc: ISROLE
��������� ������� ���� � �������� ��������� � � ������ ���������� �����������
��� ���� ����������� ����������.

��������:
roleShortName               - ��� ����;
(<body::ISROLE>)
*/
PROCEDURE ISROLE
 (ROLESHORTNAME VARCHAR2
 );

/* proc: CREATEROLE
������� ����.

���������:

roleID                      - ID ����;
roleNameRus                 - �������� ���� ( ���.);
roleNameEng                 - �������� ���� ( ���.);
shortName                   - �������� �������� ����;
description                 - ��������;
operatorID                  - ID ���������, ������������ ���������;
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
������� ����.

���������:

roleNameRus                 - �������� ���� ( ���.);
roleNameEng                 - �������� ���� ( ���.);
shortName                   - �������� �������� ����;
description                 - ��������;
operatorID                  - ID ���������, ������������ ���������;

�������� ���������:
 ID ��������� ������

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
�������� ����.

���������:

roleID                      - ID ����;
roleNameRus                 - �������� ���� ( ���.);
roleNameEng                 - �������� ���� ( ���.);
shortName                   - �������� �������� ����;
description                 - ��������;
operatorID                  - ID ���������, ������������ ���������;
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
������� ������ � ���������� �� ID.

���������:

groupNameRus                - �������� ������ ( ���.);
groupNameEng                - �������� ������ ( ���.);
isGrantOnly                 - ���� 1, �� ������ ������������� ����� ������;
                              �������� ������ �� ���� ������ ����������;
operatorID                  - ID ���������, ������������ ��������;

�������� ���������:

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
�������� ������.

���������:

groupID                     - ID ������;
groupNameRus                - �������� ������ ( ���.);
groupNameEng                - �������� ������ ( ���.);
isGrantOnly                 - ���� 1, �� ������ ������������� ����� ������;
                              �������� ������ �� ���� ������ ����������;
operatorID                  - ID ���������, ������������ ���������;
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
�������� ���� � ������.

���������:

groupID                     - ID ������;
roleID                      - ID ����;
operatorID                  - ID ���������, ������������ ���������;
(<body::CREATEGROUPROLE>)
*/
PROCEDURE CREATEGROUPROLE
 (GROUPID INTEGER
 ,ROLEID INTEGER
 ,OPERATORID INTEGER
 );

/* proc: DELETEGROUPROLE
������� ���� �� ������.

���������:

groupID                     - ID ������
roleID                      - ID ����
operatorID                  - ID ���������, ������������ ���������
(<body::DELETEGROUPROLE>)
*/
PROCEDURE DELETEGROUPROLE
 (GROUPID INTEGER
 ,ROLEID INTEGER
 ,OPERATORID INTEGER
 );

/* proc: CREATEGRANTGROUP
��������� ����� �� ������ ������.

���������:

groupID                     - ID ������, ������� �������� ����� ������;
grantGroupID                - ID ���������� ������;
operatorID                  - ID ���������, ������������ ���������;
(<body::CREATEGRANTGROUP>)
*/
PROCEDURE CREATEGRANTGROUP
 (GROUPID INTEGER
 ,GRANTGROUPID INTEGER
 ,OPERATORID INTEGER
 );

/* proc: DELETEGRANTGROUP
������� ����� �� ������ ������.

���������:

groupID                     - ID ������, � ������� ������� ����� ������;
grantGroupID                - ID ���������� ������;
operatorID                  - ID ���������, ������������ ���������;
(<body::DELETEGRANTGROUP>)
*/
PROCEDURE DELETEGRANTGROUP
 (GROUPID INTEGER
 ,GRANTGROUPID INTEGER
 ,OPERATORID INTEGER
 );

/* func: CREATEOPERATOR
������� ������ ��������� � ���������� ��� ID.

���������:

operatorNameRus                - ��� ���������;
operatorNameEng             - ��� ��������� (�� ����������);
login                       - �����;
password                    - ������;
changepassword              - ���� ����� ������ ���������;
operatorIDIns               - ID ���������, ������������ ���������;
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
������� ������ ��������� � ���������� ��� ID.

���������:

operatorName             - ��� ���������;
operatorNameEn            - ��� ��������� (�� ����������);
login                       - �����;
passwordHash                - Hash ������;
changepassword              - ���� ����� ������ ���������;
operatorIDIns               - ID ���������, ������������ ���������;
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
�������� ������ ���������.

���������:

operatorID                  - id ���������;
operatorNameRus             - ��� ���������;
operatorNameEng             - ��� ��������� (�� ����������);
login                       - �����;
changePassword              - ���� ����� ������;
operatorIDIns               - ID ���������, ������������ ���������;
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
������ ������ � ���������.

���������:

operatorID                  - ID ���������;
password                    - ������;
operatorIDIns               - ID ���������, ������������ ���������;
(<body::CHANGEPASSWORD>)
*/
PROCEDURE CHANGEPASSWORD
 (OPERATORID INTEGER
 ,PASSWORD VARCHAR2
 ,OPERATORIDINS INTEGER
 );

/* proc: ChangePasswordHash
������ ������ � ���������.

���������:

operatorID                  - ID ���������;
passwordHash                - Hash ������;
operatorIDIns               - ID ���������, ������������ ���������;
(<body::ChangePasswordHash>)
*/
procedure ChangePasswordHash (operatorid integer
                             ,passwordHash varchar2
                             ,operatoridins integer
                             );

/* proc: CHANGEPASSWORD
������ ������ � ���������.

���������:

operatorID                  - ID ���������;
password                    - ������;
newPassword                 - ����� ������;
newPasswordConfirm          - ������������� ������;
(<body::CHANGEPASSWORD>)
*/
PROCEDURE CHANGEPASSWORD
 (OPERATORID INTEGER
 ,PASSWORD VARCHAR2
 ,NEWPASSWORD VARCHAR2
 ,NEWPASSWORDCONFIRM VARCHAR2
 );

/* proc: changePasswordHash
������ ������ � ���������.

���������:

operatorID                  - ID ���������;
passwordHash                    - Hash ������;
newPasswordHash             - Hash ����� ������;
newPasswordConfirmHash      - ������������� ������;
(<body::changePasswordHash>)
*/
procedure changePasswordHash (operatorid integer
                             ,passwordHash varchar2
                             ,newPasswordHash varchar2
                             ,newPasswordConfirmHash varchar2
                             );

/* proc: DELETEOPERATORROLE
�������� ���� � ���������.

���������:

operatorID                  - ID ���������;
roleID                      - ID ����;
operatorIDIns               - ID ���������, ������������ ���������;
(<body::DELETEOPERATORROLE>)
*/
PROCEDURE DELETEOPERATORROLE
 (OPERATORID INTEGER
 ,ROLEID INTEGER
 ,OPERATORIDINS INTEGER
 );

/* proc: CREATEOPERATORGROUP
�������� ��������� � ������.

���������:

operatorID                  - ID ���������;
groupID                     - ID ������;
operatorIDIns               - ID ���������, ������������ ���������;
(<body::CREATEOPERATORGROUP>)
*/
PROCEDURE CREATEOPERATORGROUP
 (OPERATORID INTEGER
 ,GROUPID INTEGER
 ,OPERATORIDINS INTEGER
 );

/* proc: DELETEOPERATORGROUP
������� ��������� �� ������.

���������:

operatorID                  - ID ���������;
groupID                     - ID ������;
operatorIDIns               - ID ���������, ������������ ���������;
(<body::DELETEOPERATORGROUP>)
*/
PROCEDURE DELETEOPERATORGROUP
 (OPERATORID INTEGER
 ,GROUPID INTEGER
 ,OPERATORIDINS INTEGER
 );

/* func: GETOPERATORNAME
���������� ��� ���������

���������:
operatorID                  - ID ���������

�������� ���������:

��� ���������
(<body::GETOPERATORNAME>)
*/
FUNCTION GETOPERATORNAME
 (OPERATORID INTEGER
 )
 RETURN VARCHAR2;

/* func: ISCHANGEPASSWORD
���� ������������� �������������� ����� ������
0-�� ������
1-������

���������:

operatorID                  - ID ���������

(<body::ISCHANGEPASSWORD>)
*/
FUNCTION ISCHANGEPASSWORD
 (OPERATORID INTEGER := null
 )
 RETURN number;

/* func: getRoles
     ������� ���������� ID ����

������� ���������:

  login - �����

�������� ���������(� ���� �������):


    role_id       -  ������������� ����
    short_name    -  ������� ������������ ����
    role_name     -  ������������ ���� �� ����� �� ���������
    role_name_en  -  ������������ ���� �� ���������� �����
    description   -  �������� ���� �� ����� �� ���������
    date_ins      -  ���� �������� ������
    operator_id   -  ������������, ��������� ������
    operator_name     -  ������������ �� ����� �� ���������, ��������� ������
    operator_name_en  -  ������������ �� ���������� �����, ��������� ������

(<body::getRoles>)
*/
FUNCTION getRoles
 (
  login        varchar2
 )
return sys_refcursor;

/* func: getRoles
     ������� ���������� ID ����

������� ���������:

 operatorId - �� ���������

�������� ���������(� ���� �������):

    role_id       -  ������������� ����
    short_name    -  ������� ������������ ����
    role_name     -  ������������ ���� �� ����� �� ���������
    role_name_en  -  ������������ ���� �� ���������� �����
    description   -  �������� ���� �� ����� �� ���������
    date_ins      -  ���� �������� ������
    operator_id   -  ������������, ��������� ������
    operator_name     -  ������������ �� ����� �� ���������, ��������� ������
    operator_name_en  -  ������������ �� ���������� �����, ��������� ������

(<body::getRoles>)
*/
FUNCTION getRoles
 (
  operatorId        integer
 )
return sys_refcursor;

 /* func: getRolesShortName
     ������� ���������� short_name ����

������� ���������:

  login - �����

�������� ���������(� ���� �������):

   short_name - short_name ����;

(<body::getRolesShortName>)
*/
FUNCTION getRolesShortName
 (
  login        varchar2 := null
 )
return sys_refcursor;

 /* func: getRolesShortName
     ������� ���������� short_name ����

������� ���������:

  operatorID - operatorID

�������� ���������(� ���� �������):

   short_name - short_name ����;

(<body::getRolesShortName>)
*/
FUNCTION getRolesShortName
 (
  operatorID      integer := null
 )
return sys_refcursor;


 /* pfunc: getOperator
     ������� ����������

������� ���������:

    operatorName - ��� ���������(���)
    operatorName_en - ��� ���������(����.)

�������� ���������(� ���� �������):

   operator_id - ID ���������;
   Operator_Name - ��� ���������;
   Operator_Name_en - ��� ��������� (END);
   maxRowCount                - ������������ ���������� �������

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
   ��������� �������������� ���������� ������������ RestoreOperator

(<body::RestoreOperator>)
*/
procedure RestoreOperator( operatorId	integer,
                           restoreOperatorId	integer);

/* func: CreateOperator
   ������� �������� ������������ CreateOperator
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
   ��������� ���������� ������������ UpdateOperator
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
   ��������� �������� ������������ DeleteOperator
(<body::DeleteOperator>)
*/
procedure DeleteOperator( operatorId	integer,
                          operatorIdIns	integer);

/* func: FindOperator
   ������� ������ ������������ FindOperator
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
   ��������� �������������� ���������� ������������
(<body::RestoreOperator>)
*/
procedure RestoreOperator( operatorId	integer,
                          operatorIdIns	integer);

/* func: CreateRole
   ������� �������� ���� CreateRole
(<body::CreateRole>)
*/
function CreateRole( roleName	    varchar2,
                     roleNameEn	  varchar2,
                     shortName	  varchar2,
                     description	varchar2,
                     operatorId	  integer)
return integer;

/* proc: UpdateRole
   ��������� ���������� ���� UpdateRole
(<body::UpdateRole>)
*/
procedure UpdateRole( roleId	     integer,
                      roleName	   varchar2,
                      roleNameEn	 varchar2,
                      shortName	   varchar2,
                      description	 varchar2,
                      operatorId	 integer);
/* proc: DeleteRole
   ��������� �������� ���� DeleteRole
(<body::DeleteRole>)
*/
procedure DeleteRole( roleId	integer,
                      operatorId	integer);

/* func: FindRole
   ������� ������ ���� FindRole
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
   ������� �������� ������ CreateGroup
(<body::CreateGroup>)
*/
function CreateGroup( groupName	  varchar2,
                      groupNameEn	varchar2,
                      isGrantOnly	number,
                      operatorId	integer)
return integer;

/* proc: UpdateGroup
   ��������� ���������� ������ UpdateGroup
(<body::UpdateGroup>)
*/
procedure UpdateGroup(  groupId	    integer,
                        groupName	  varchar2,
                        groupNameEn	varchar2,
                        isGrantOnly	number,
                        operatorId	integer);
/* proc: DeleteGroup
   ��������� �������� ������ DeleteGroup
(<body::DeleteGroup>)
*/
procedure DeleteGroup(  groupId	    integer,
                        operatorId	integer);

/* func: FindGroup
   ������� ������ ������ FindGroup
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
   ��������� �������� ����� ������������ � ���� CreateOperatorRole
(<body::CreateOperatorRole>)
*/
procedure CreateOperatorRole( operatorId	  integer,
                              roleId	      integer,
                              operatorIdIns	integer);
/* func: FindOperatorRole
   ������� ������ ����� ������������ � ���� FindOperatorRole
(<body::FindOperatorRole>)
*/
function FindOperatorRole(  operatorId	integer,
                            roleId	    integer,
                            rowCount	  integer,
                            operatorIdIns	integer)
return sys_refcursor;

/* func: GetNoOperatorRole
   ������� ����������� ����� �������� �� ������������� ������������ GetNoOperatorRole
(<body::GetNoOperatorRole>)
*/
function GetNoOperatorRole( operatorId	integer,
                            operatorIdIns	integer)
return sys_refcursor;

/* func: FindOperatorGroup
   ������� ������ ����� ������������ � ������ FindOperatorGroup
(<body::FindOperatorGroup>)
*/
function FindOperatorGroup( operatorId	  integer,
                            groupId	      integer,
                            rowCount	    integer,
                            operatorIdIns	integer)
return sys_refcursor;

/* func: GetNoOperatorGroup
   ������� ����������� ����� �������� �� ������������� ������������ GetNoOperatorGroup
(<body::GetNoOperatorGroup>)
*/
function GetNoOperatorGroup(  operatorId	    integer,
                              operatorIdIns	integer)
return sys_refcursor;

/* func: FindGroupRole
   ������� ������ ����� ������ � ���� FindGroupRole
(<body::FindGroupRole>)
*/
function FindGroupRole( groupId	     integer,
                        roleId	     integer,
                        rowCount	   integer,
                        operatorId	 integer)
return sys_refcursor;

/* func: GetNoGroupRole
   ������� ����������� ����� �������� �� ������������� ������ GetNoGroupRole
(<body::GetNoGroupRole>)
*/
function GetNoGroupRole( groupId	integer,
                         operatorId	integer)
return sys_refcursor;

/* func: FindGrantGroup
   ������� ������ ����� grant-������ � ������ FindGrantGroup
(<body::FindGrantGroup>)
*/
function FindGrantGroup(  groupId	      integer,
                          grantGroupId	integer,
                          rowCount	    integer,
                          operatorId	  integer)
return sys_refcursor;

/* func: GetNoGrantGroup
   ������� ����������� ����� �������� �� ������������� grant-������ GetNoGrantGroup
(<body::GetNoGrantGroup>)
*/
function GetNoGrantGroup( groupId	integer,
                          operatorId	integer)
return sys_refcursor;

end pkg_Operator;
/
