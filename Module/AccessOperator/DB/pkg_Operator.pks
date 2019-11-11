create or replace package pkg_Operator is
/* package: pkg_Operator
  ������������ ����� ������ Operator.

  SVN root: Module/AccessOperator
*/



/* group: ��������� */

/* const: Module_Name
  �������� ������, � �������� ��������� �����.
*/
Module_Name constant varchar2(30) := 'AccessOperator';



/* group: ���� ��������� ������� */

/* const: NumUL_PasswordPolicyCode
  ��������� �������� "����� + ����� � ������� �������� + ����� � ������ ��������".
*/
NumUL_PasswordPolicyCode constant varchar2(10) := 'NUM_U_L';

/* const: NumULSp_PasswordPolicyCode
  ��������� �������� "����� + ����� � ������� �������� + ����� � ������ �������� + �����������".
*/
NumULSp_PasswordPolicyCode constant varchar2(10) := 'NUM_U_L_SP';



/* group: ���� ��� ������ � ������� */

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

/* const: OpLoginAttmptGrpAdmin_RoleName
   ��� ���� "������������� �������� ���������� ����������"
*/
OpLoginAttmptGrpAdmin_RoleName constant varchar2(50) := 'OpLoginAttemptGroupAdmin';



/* group: ���� ���������� */

/* const: Permanent_LockTypeCode
   ��� ���������� "����������"
*/
Permanent_LockTypeCode constant varchar2(20) := 'PERMANENT';

/* const: Unused_LockTypeCode
   ��� ���������� "�� ������������"
*/
Unused_LockTypeCode constant varchar2(20) := 'UNUSED';

/* const: Temporal_LockTypeCode
   ��� ���������� "���������"
*/
Temporal_LockTypeCode constant varchar2(20) := 'TEMPORAL';



/* group: ����� ��� ������ � �������
  ��������� �������� � ������ Option ( Oracle/Module/Option).
*/

/* const: HashSalt_OptSName
  �������� �������� ��������� ��� ��������
  "����" ���� ������.
*/
HashSalt_OptSName constant varchar2(50) := 'HashSalt';



/* group: ������� */

/* pfunc: getHash
  ���������� hex-������ � MD5 ����������� ������.

  ���������:

  inputString                 - �������� ������ ��� ������� ����������� �����;

  �������:
  - ���������� hex-������ � MD5 ����������� ������;

  ( <body::getHash>)
*/
function getHash(
  inputString varchar2
)
return varchar2;

/* pfunc: getHashSalt
  ������� ����������� ������ � "�����".

  ������� ���������:
    password                              - ������

  �������:
    hashSalt                              - ��� ������ � "�����"

  ( <body::getHashSalt>)
*/
function getHashSalt(
  password varchar2
)
return varchar2;



/* group: ����������� */

/* pfunc: login
  ������������ ��������� � ���� �� ������ �
  ������/���� ������ � ���������� ��� ���������.

  ������� ���������:
    operatorLogin               - ����� ���������
    password                    - ������

  �������:
    current_operator_name       - ��� �������� ���������

  ( <body::login>)
*/
function login(
  operatorLogin varchar2
  , password varchar2
  , passwordHash varchar2 default null
)
return varchar2;

/* pfunc: login
  ������������ ��������� � ���� � ���������� ��� ���������.

  ���������:
  operatorLogin               - ����� ���������;

  �������� ���������:

 CurrentOperatorName - ;
)

  ( <body::login>)
*/
function login( operatorLogin varchar2)
return varchar2;

/* pproc: login
  ������������ ��������� � ���� ( ��� �������� ������).

  ���������:
  operatorLogin               - ����� ���������

  ( <body::login>)
*/
procedure login(
  operatorLogin varchar2
);

/* pproc: setCurrentUserId
  ������������ ��������� � ���� ( ��� �������� ������).

  ���������:
  operatorId                  - Id ���������;

  ( <body::setCurrentUserId>)
*/
procedure setCurrentUserId( operatorId integer);

/* pproc: remoteLogin
  ������������ �������� ��������� � ��������� ��.

  ���������:
  dbLink                      - ��� ����� � ��������� ��;

  ( <body::remoteLogin>)
*/
procedure remoteLogin(
  dbLink varchar2
);

/* pproc: logoff
  �������� ������� �����������;

  ( <body::logoff>)
*/
procedure logoff;

/* pfunc: getCurrentUserId
   ���������� ID �������� ���������.

   ������� ���������:
     isRaiseException - ���� ������������ ���������� � ������,
                        ���� ������� �������� �� ���������
                        0 - ���� �� �������
                        1 - ���� �������

   �������:
     oprator_id       - �� �������� ���������


  ( <body::getCurrentUserId>)
*/
function getCurrentUserId(
  isRaiseException integer default 1
)
return integer;

/* pfunc: getCurrentUserName
   ���������� ��� �������� ���������.

   ������� ���������:
     isRaiseException - ���� ����������� ���������� � ������,
                        ���� ������� �������� �� ���������
                        0 - ���� �� �������
                        1 - ���� �������

   �������:
     oprator_name     - ��� �������� ���������


  ( <body::getCurrentUserName>)
*/
function getCurrentUserName(
  isRaiseException integer default 1
)
return varchar2;



/* group: �������� */

/* pfunc: isRole(operatorId,DEPRECATED)
  ��������� ������� ���� � ���������.

  ���������:
  operatorId                  - id ���������
  roleId                      - id ����

  ������������ ��������:
  1 - ���� �����������;
  0 - ���� �� �����������;

  ���������:
  - ���������� �������. �� ������������.

  ( <body::isRole(operatorId,DEPRECATED)>)
*/
function isRole(
  operatorId integer
, roleId     integer
)
return integer;

/* pfunc: isRole(operatorId)
  ��������� ������� ���� � ���������.

  ���������:

  operatorId                  - id ���������
  roleShortName               - �������� ������������ ����

  ������������ ��������:
  1 - ���� �����������;
  0 - ���� �� �����������;

  ( <body::isRole(operatorId)>)
*/
function isRole(
  operatorId integer
  , roleShortName varchar2
)
return integer;

/* pfunc: isRole
  ��������� ������� ���� � �������� ���������.

  ���������:
  roleShortName               - ��� ����;

  ������������ ��������:
  1 - ���� �����������;
  0 - ���� �� �����������;

  ( <body::isRole>)
*/
function isRole(
  roleShortName varchar2
)
return integer;

/* pproc: isRole(operatorId,DEPRECATED)
  ��������� ������� ���� � ��������� � � ������ �� ���������� �����������
  ����������.

  ��������:

  operatorID                  - ID ���������;
  roleID                      - ID ����;

  ���������:
  - ���������� �������. �� ������������.

  ( <body::isRole(operatorId,DEPRECATED)>)
*/
procedure isRole
 (OPERATORID INTEGER
 ,ROLEID INTEGER
 );

/* pproc: isRole(operatorId)
  ��������� ������� ���� � ��������� � � ������ �� ���������� �����������
  ����������.

  ��������:

  operatorId                  - id ���������;
  roleShortName               - ��� ����;

  ( <body::isRole(operatorId)>)
*/
procedure isRole(
  operatorId integer
  , roleShortName varchar2
);

/* pproc: isRole
  ��������� ������� ���� � �������� ��������� � � ������ ����������
  ����������� ��� ���� ����������� ����������.

  ��������:
  roleShortName               - ��� ����

  ( <body::isRole>)
*/
procedure isRole(
  roleShortName varchar2
);

/* pproc: isUserAdmin
  ��������� ����� �� ����������������� ���������� � � ������ �� ����������
  ����������� ����������.

  ������� ���������:

  operatorID                  - ID ���������, ������������ ��������;
  targetOperatorID            - ID ���������, ��� ������� ����������� ��������;
  roleID                      - ID ����������/���������� ����;
  groupID                     - ID ����������/���������� ������;


  ( <body::isUserAdmin>)
*/
procedure isUserAdmin
 (OPERATORID INTEGER
 ,TARGETOPERATORID INTEGER := null
 ,ROLEID INTEGER := null
 ,GROUPID INTEGER := null
 );



/* group: ��������� ������ (��������� � pkg_AccessOperator) */

/* pproc: checkPassword
  ��������� �������� ������.

  ������� ���������:
    operatorId          - ������������, �������� ���������� ������������
    password            - ������� ������
    newPassword         - ����� ������
    newPasswordConfirm  - ����� ������ ( �������������)
    operatorIdIns       - ������������� ���������
    passwordPolicyCode  - ��� ��������� �������� (
                          NUM_U_L - ����� + ����� � ������� �������� + ����� � ������ ��������
                          NUM_U_L_SP - ����� + ����� � ������� �������� + ����� � ������ ��������
                            + �����������
                          ). �� ��������� "NUM_U_L_SP".

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
������ ������ � ���������.

���������:

operatorID                  - ID ���������;
passwordHash                - Hash ������;
operatorIDIns               - ID ���������, ������������ ���������;

  ( <body::changePasswordHash>)
*/
procedure changePasswordHash (operatorid integer
                             ,passwordHash varchar2
                             ,operatoridins integer
                             );

/* pproc: changePasswordHash
������ ������ � ���������.

���������:

operatorID                  - ID ���������;
passwordHash                    - Hash ������;
newPasswordHash             - Hash ����� ������;
newPasswordConfirmHash      - ������������� ������;
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
������ ������ � ���������.

���������:

operatorID                  - ID ���������;
password                    - ������;
operatorIDIns               - ID ���������, ������������ ���������;


  ( <body::changePassword>)
*/
procedure changePassword
 (OPERATORID INTEGER
 ,PASSWORD VARCHAR2
 ,OPERATORIDINS INTEGER
 );

/* pproc: changePassword
������ ������ � ���������.

���������:

operatorID                  - ID ���������;
password                    - ������;
newPassword                 - ����� ������;
newPasswordConfirm          - ������������� ������;


  ( <body::changePassword>)
*/
PROCEDURE changePassword
 (OPERATORID INTEGER
 ,PASSWORD VARCHAR2
 ,NEWPASSWORD VARCHAR2
 ,NEWPASSWORDCONFIRM VARCHAR2
 );

/* pproc: changePassword
������ ������ � ���������.

���������:
operatorID                  - ID ���������;
password                    - ������;
newPassword                 - ����� ������;
newPasswordConfirm          - ������������� ������;
passwordPolicyCode  - ��� ��������� �������� (
                      NUM_U_L - ����� + ����� � ������� �������� + ����� � ������ ��������
                      NUM_U_L_SP - ����� + ����� � ������� �������� + ����� � ������ ��������
                        + �����������
                      ). �� ��������� "NUM_U_L_SP".

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
  ������� ������ ����� ���������.

  ������� ���������:
    operatorId                  - ID ���������

  �������:
    operator_name               - ��� ���������

  ( <body::getOperatorName>)
*/
function getOperatorName(
  operatorId integer
)
return varchar2;

/* pfunc: isChangePassword
  ���� ������������� �������������� ����� ������.

  ������� ���������:
    operatorId                  - ID ���������

  �������:
    result                      - 0 - �� ������
                                  1 - ������

  ( <body::isChangePassword>)
*/
function isChangePassword(
  operatorId integer
)
return number;



/* group: ������� ��� ������������ ��������� ������� ����� � ����� */

/* pfunc: getRoles
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


  ( <body::getRoles>)
*/
FUNCTION getRoles(login  varchar2 )
return sys_refcursor;

/* pfunc: getRoles
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


  ( <body::getRoles>)
*/
FUNCTION getRoles(operatorId  integer )
return sys_refcursor;

 /* pfunc: getRolesShortName
     ������� ���������� short_name ����

������� ���������:

  login - �����

�������� ���������(� ���� �������):

   short_name - short_name ����;


  ( <body::getRolesShortName>)
*/
FUNCTION getRolesShortName
 (
  login        varchar2 := null
 )
return sys_refcursor;

 /* pfunc: getRolesShortName
     ������� ���������� short_name ����

������� ���������:

  operatorID - operatorID

�������� ���������(� ���� �������):

   short_name - short_name ����;

(<body::getRolesShortName>)

  ( <body::getRolesShortName>)
*/
FUNCTION getRolesShortName
 (
  operatorID      integer := null
 )
return sys_refcursor;

/* pfunc: getOperator
  ������ �� ����������.

  ������� ���������:
  operatorName                - ��� ��������� (���.)
  operatorName_en             - ��� ��������� (����.)
  rowCount                    - ������������ ���������� ����� � ��������
                                �������. ���������� ����. ��������� ���
                                �������������.
  maxRowCount                 - ������������ ���������� ����� � ��������
                                �������. ��-��������� 25.

  ������� (� ���� �������):
  operator_id                 - id ���������
  operator_name               - ��� ���������
  operator_name_en            - ��� ��������� (����.)
  login                       - �����

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
  ������� ����������� ����� �������� �� ������������� ������������.

  ������� ���������:
    operatorId                              - ������������� ������������
    operatorIdIns                           - ������������, �������������� �����

  ������� (� ���� �������):
    role_id                                 -	������������� ����
    short_name                              - ������� ������������ ����
    role_name                               - ������������ ���� �� ����� �� ���������
    role_name_en                            - ������������ ���� �� ���������� �����
    description                             - �������� ���� �� ����� �� ���������
    date_ins                                - ���� �������� ������
    operator_id                             - ������������, ��������� ������
    operator_name                           - ������������ �� ����� �� ���������, ��������� ������
    operator_name_en                        - ������������ �� ���������� �����, ��������� ������

  ( <body::getNoOperatorRole>)
*/
function getNoOperatorRole(
  operatorId integer
  , operatorIdIns	integer
)
return sys_refcursor;

/* pfunc: getNoOperatorGroup
  ������� ����������� ����� �������� �� ������������� ������������.

  ������� ���������:
    operatorId                              -	������������� ������������
    operatorIdIns                           -	������������, �������������� �������

  ������� (� ���� �������):
    group_id                                - ������������� ������
    group_name                              - ������������ ������ �� ����� �� ���������
    group_name_en                           - ������������ ������ �� ���������� �����
    date_ins                                - ���� �������� ������
    operator_id                             - ������������, ��������� ������
    operator_name                           - ������������ �� ����� �� ���������, ��������� ������
    operator_name_en                        - ������������ �� ���������� �����, ��������� ������

  ( <body::getNoOperatorGroup>)
*/
function getNoOperatorGroup(
  operatorId integer
  , operatorIdIns integer
)
return sys_refcursor;

/* pfunc: getNoGroupRole
  ������� ����������� ����� �������� �� ������������� ������.

  ������� ���������:
    groupId                                 - ������������� ������
    operatorId                              - ������������, �������������� �������

  ������� (� ���� �������):
    role_id                                 - ������������� ����
    short_name                              - ������� ������������ ����
    role_name                               - ������������ ���� �� ����� �� ���������
    role_name_en                            - ������������ ���� �� ���������� �����
    description                             - �������� ���� �� ����� �� ���������
    date_ins                                - ���� �������� ������
    operator_id                             - ������������, ��������� ������
    operator_name                           - ������������ �� ����� �� ���������, ��������� ������
    operator_name_en                        - ������������ �� ���������� �����, ��������� ������

  ( <body::getNoGroupRole>)
*/
function getNoGroupRole(
  groupId integer
  , operatorId integer
)
return sys_refcursor;

/* pfunc: getRole
  ������� ������������ ������ �����.

  ������� ���������:
    roleName                         - ����� ��� ������ ����

  ������� (� ���� �������):
    role_id                          - �� ����
    role_name                        - ������������ ����

  ( <body::getRole>)
*/
function getRole(
  roleName varchar2
)
return sys_refcursor;

/* pfunc: getGroup
  ������� ������������ ������ �����.

  ������� ���������:
    groupName                        - ����� ��� ������ ������

  ������� (� ���� �������):
    group_id                         - �� ����
    group_name                       - ������������ ����

  ( <body::getGroup>)
*/
function getGroup(
  groupName varchar2
)
return sys_refcursor;

/* pfunc: getOperatorIDByLogin
   ������� ���������� ID ��������� �� ������

   ������� ���������:
   login - ����� ���������

   �������� ���������:
    ID ���������

  ( <body::getOperatorIDByLogin>)
*/
function getOperatorIDByLogin(login varchar2 )
return integer;

/* pfunc: GetRoleID
   ������� ���������� ID ���� �� �������� ������������

  ( <body::GetRoleID>)
*/
function GetRoleID(roleName	varchar2)
return integer;

/* pfunc: GetGroupID
   ������� ���������� ID ������ �� �������� ������������

  ( <body::GetGroupID>)
*/
function GetGroupID(groupName	varchar2)
return integer;



/* group: ������� ��� ������ � ������������ */

/* pfunc: getLockType
   ������� ������������ ������ ����� ����������.

   ������� ��������� �����������.

   ������� (� ���� �������):
     lock_type_code               - ��� ���� ����������
     lock_type_name               - ������������ ����

  ( <body::getLockType>)
*/
function getLockType
return sys_refcursor;

end pkg_Operator;
/
