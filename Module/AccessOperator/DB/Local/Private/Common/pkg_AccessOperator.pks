create or replace package pkg_AccessOperator is
/* package: pkg_AccessOperator
  ���������� ����� ������ Operator.

  SVN root: Module/AccessOperator
*/

/* const: ROLEADMIN_ROLEID
 ID ���� "������������� ���� �������" */
ROLEADMIN_ROLEID CONSTANT INTEGER := 5;

/* const: ROLEADMIN_ROLE
��� ���� "������������� ���� �������" */
ROLEADMIN_ROLE CONSTANT VARCHAR2(50) := 'RoleAdmin';

/* const: USERADMIN_ROLEID
ID ���� "������������� �������������" */
USERADMIN_ROLEID CONSTANT INTEGER := 1;

/* const: USERADMIN_ROLE
��� ���� "������������� �������������" */
USERADMIN_ROLE CONSTANT VARCHAR2(50) := 'UserAdmin';

/* const: OpShowUsers_RoleSNm
  �������� ������������ ���� "AccessOperator: �������� ����������, �����, �����".
*/
OpShowUsers_RoleSNm constant varchar2(50) := 'OpShowUsers';

/* const: Module_Name
  �������� ������, � �������� ��������� �����.
*/
Module_Name constant varchar2(30) := 'AccessOperator';



/* group: ���� ����� �������� */


/* const: CreateOperator_ActTpCd
  ��� ���� �������� "�������� ���������".
*/
CreateOperator_ActTpCd constant varchar2(20) := 'CREATEOPERATOR';

/* const: CreateOperator_ActTpCd
  ��� ���� �������� "������ ���� ���������".
*/
CreateOperatorRole_ActTpCd constant varchar2(20) := 'CREATEOPERATORROLE';

/* const: UpdateOperator_ActTpCd
  ��� ���� �������� "��������� ���� ���������".
*/
UpdateOperatorRole_ActTpCd constant varchar2(20) := 'UPDATEOPERATORROLE';

/* const: DeleteOperatorRole_ActTpCd
  ��� ���� �������� "�������� ���� � ���������".
*/
DeleteOperatorRole_ActTpCd constant varchar2(20) := 'DELETEOPERATORROLE';

/* const: CreateOperatorGroup_ActTpCd
  ��� ���� �������� "������ ������ ���������".
*/
CreateOperatorGroup_ActTpCd constant varchar2(20) := 'CREATEOPERATORGROUP';

/* const: UpdateOperatorGroup_ActTpCd
  ��� ���� �������� "��������� ������ ���������".
*/
UpdateOperatorGroup_ActTpCd constant varchar2(20) := 'UPDATEOPERATORGROUP';

/* const: DeleteOperatorGroup_ActTpCd
  ��� ���� �������� "�������� ������ � ���������".
*/
DeleteOperatorGroup_ActTpCd constant varchar2(20) := 'DELETEOPERATORGROUP';

/* const: CreateGroupRole_ActTpCd
  ��� ���� �������� "���������� ���� � ������".
*/
CreateGroupRole_ActTpCd constant varchar2(20) := 'CREATEGROUPROLE';

/* const: DeleteGroupRole_ActTpCd
  ��� ���� �������� "�������� ���� �� ������".
*/
DeleteGroupRole_ActTpCd constant varchar2(20) := 'DELETEGROUPROLE';

/* const: ChangePassword_ActTpCd
  ��� ���� �������� "��������� ������".
*/
ChangePassword_ActTpCd constant varchar2(20) := 'CHANGEPASSWORD';

/* const: BlockOperator_ActTpCd
  ��� ���� �������� "������������ ���������".
*/
BlockOperator_ActTpCd constant varchar2(20) := 'BLOCKOPERATOR';

/* const: UnblockOperator_ActTpCd
  ��� ���� �������� "������������� ���������".
*/
UnblockOperator_ActTpCd constant varchar2(20) := 'UNBLOCKOPERATOR';

/* const: AutoBlockOperator_ActTpCd
  ��� ���� �������� "�������������� ���������".
*/
AutoBlockOperator_ActTpCd constant varchar2(20) := 'AUTOBLOCKOPERATOR';

/* const: ChangePersonalData_ActTpCd
  ��� ���� �������� "��������� ������������ ������ ���������".
*/
ChangePersonalData_ActTpCd constant varchar2(20) := 'CHANGEPERSONALDATA';



/* group: ������� */



/* group: ��������� ������� */

/* pproc: addSqlCondition
  ��������� ������� � ���������� � ������ SQL-�������.
  � ������, ���� ����������� �������� ��������� �� null ( isNullValue false),
  ������� ����������� � ���� �������� �������� ��������� ��� ����� � ����������,
  � ��������� ������ ����������� ������������ �������� ������� � ����������.

  ��������� ����� ������������ ���������� ����� � ������� ���������� ���
  ���������� ������������� SQL ��� ���, ��� ���������� ����� ����������
  ����� ���� �� ������ ( ����� �������� null). ����� �������������� ������
  ����� ������� � ����������� �� ������� ����������� �������� ����������,
  ��� ��������� ������������ ������ ����� ���������� �������.

  ���������:
  searchCondition             - ����� � SQL-��������� ������, � �������
                                ����������� ������� ( ������������� ����� � SQL
                                ����� "where")
  fieldExpr                   - ��������� ��� ����� ������� ( ����������� �
                                ����� ����� �������� ���������)
  operation                   - �������� ��������� ( "=", ">=" � �.�.)
  isNullValue                 - ������� �������� null � ������� ��������
                                ���������
  parameterExpr               - ��������� ��� ���������� ( ����������� � ������
                                ����� �������� ���������, � ������ ����������
                                ":" ��� ����������� � ������ ������, ��
                                ��������� ������� �� fieldExpr � ���������
                                ������ � ����������� ":")

  ���������:
  - � ������ �������������� �������� � fieldExpr ( �� ������
    "[<alias>.]<fieldName>"), �������� parameterExpr ������ ���� ���� ������;

  ( <body::addSqlCondition>)
*/
procedure addSqlCondition(
  searchCondition in out nocopy varchar2
  , fieldExpr varchar2
  , operation varchar2
  , isNullValue boolean
  , parameterExpr varchar2 := null
);



/* group: ������� ��� ������ � ����������� */

/* pfunc: createOperator
  ������� �������� ������������

  ������� ���������:
    operatorName                - ������������ ������������ �� ����� �� ���������
    operatorNameEn              - ������������ ������������ �� ���������� �����
    login                       - �����
    password                    - ������
    changePassword              - ������� ������������� ��������� ������
                                  �������������:
                                  1 � ������������ ���������� �������� ������;
                                  0 � ������������ ��� ������������� ������ ������.
    operatorIdIns               - ������������, ��������� ������
    operatorComment             - ���������� � ������
    loginAttemptGroupId         - ������ ���������� ����������
    computerName                - ��� ����������, � �������� ������������ ��������
    ipAddress                   - IP ����� ����������, � �������� ������������ ��������
   �������:
     operator_id                - ID ���������� ���������

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
  ��������� ���������� ������������ UpdateOperator

  ������� ���������:
    operatorId                  - ID ��������� ��� ���������
    operatorName                - ������������ ������������ �� ����� �� ���������
    operatorNameEn              - ������������ ������������ �� ���������� �����
    login                       - �����
    password                    - ������
    changePassword              - ������� ������������� ��������� ������
                                  �������������:
                                  1 � ������������ ���������� �������� ������;
                                  0 � ������������ ��� ������������� ������ ������.
    operatorIdIns               - ������������, ��������� ������
    operatorComment             - ���������� ���������
    loginAttemptGroupId         - ������ ���������� ����������
    computerName                - ��� ����������, � �������� ������������ ��������
    ipAddress                   - IP ����� ����������, � �������� ������������ ��������

   �������� ��������� �����������.

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
   ��������� �������� ������������

   ������� ���������:
     operatorId          - �� ���������
     operatorIdIns       - �� ��������� �� �������� ����
     operatorComment     - �����������
     computerName        - ��� ����������, � �������� ������������ ��������
     ipAddress           - IP ����� ����������, � �������� ������������ ��������

  �������� ��������� �����������.

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
   ������� ������ ������������.

   ������� ���������:
     operatorId                     - ������������� ������������
     login                          - ����� ������������
     operatorName                   - ������������ ������������ �� �����
                                      �� ���������
     operatorNameEn                 - ������������ ������������ ��
                                      ���������� �����
     loginAttemptGroupId            - ������ ���������� ����������
     deleted                        - ������� ����������� ��������� �������:
                                      0 � �� ���������� ���������;
                                      1 � ���������� ���������.
     rowCount                       -  ������������ ����������
                                      ������������ �������
     operatorIdIns                  - ������������, �������������� �����

   ������� (� ���� �������):
     operator_id                    - ������������� ������������
     login                          - ����� ������������
     operator_name                  - ������������ ������������ �� �����
                                      �� ���������
     operator_name_en               - ������������ ������������ �� ���������� �����
     date_begin                     - ���� ������ �������� ������
     date_finish                    - ���� ��������� �������� ������
     change_password                - ������� ������������� ����� ������:
                                      0 � ������ ������ �� �����;
                                      1 � ���������� ������� ������.
     date_ins                       - ���� �������� ������
     operator_id_ins                - ������������, ��������� ������
     operator_name_ins              - ������������ �� ����� �� ���������,
                                      ��������� ������
     operator_name_ins_en           - ������������ �� ���������� �����,
                                      ��������� ������
     operator_comment               - �����������, ������� ����������
     curr_login_attempt_count       - ������� ���������� ���������� ������� �����
     login_attempt_group_id         - ������ ���������� ����������
     login_attempt_group_name       - ������������ ������ ���������� ����������
     is_default                     - ������� �� ���������
     lock_type_code                 - ��� ����������
     max_login_attempt_count        - ����������� ���������� ����������
                                      ������� ����� � �������
     locking_time                   - ����� ���������� � ��������
     lock_type_name                 - ������������ ����
     block_wait_period              - ���������� ���� �������� ���������� ���������
                                      ����� ���������� ����������

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
   ��������� �������������� ���������� ������������ RestoreOperator

   ������� ���������:
     operatorId                  - ������������, �������� ���������� ������������
     restoreOperatorId           - ������������, ������� ��������������� ������
     computerName                - ��� ����������, � �������� ������������ ��������
     ipAddress                   - IP ����� ����������, � �������� ������������ ��������

   �������� ��������� �����������.

  ( <body::restoreOperator>)
*/
procedure restoreOperator(
  operatorId integer
  , restoreOperatorId integer
  , computerName varchar2 default null
  , ipAddress varchar2 default null
);

/* pfunc: createOperatorHash
  ������� ������ ��������� � ���������� ��� ID.

  ������� ���������:
    operatorName               - ��� ���������
    operatorNameEn             - ��� ��������� (�� ����������)
    login                      - �����
    passwordHash               - Hash ������
    changepassword             - ���� ����� ������ ���������
    operatorIDIns              - ID ���������, ������������ ���������
    computerName               - ��� ����������, � �������� ������������ ��������
    ipAddress                  - IP ����� ����������, � �������� ������������ ��������

   �������:
     operator_id               - ID ���������� ���������

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
   ������� ��������� �������� ������� ��������� ������������.

   ������� ���������:
     operatorId                     - ������������� ������������

   �������:
     is_manually_changed            - ���� ������� ���������� ������ �� ������������

  ( <body::getOperatorManuallyChanged>)
*/
function getOperatorManuallyChanged(
  operatorId integer
)
return integer;

/* pproc: restoreOperator
   ��������� �������������� ���������� ������������

   ������� ���������:
     operatorId          - ID ��������� ��� ��������������
     operatorIdIns	     - ������������, ����������������� ���������
     computerName        - ��� ����������, � �������� ������������ ��������
     ipAddress           - IP ����� ����������, � �������� ������������ ��������

   �������� ��������� �����������

  ( <body::restoreOperator>)
*/
procedure restoreOperator(
  operatorId integer
  , operatorIdIns integer
  , computerName varchar2 default null
  , ipAddress varchar2 default null
);



/* group: ������� ��� ������ � ������ */

/* pfunc: createRole
  ������� �������� ����.

  ������� ���������:
    roleName                               - ������������ ���� �� ����� �� ���������
    roleNameEn                             - ������������ ���� �� ���������� �����
    shortName                              - ������� ������������ ����
    description                            - �������� ���� �� ����� �� ���������
    isUnused                               - ������� �������������� ����
    operatorId                             - �� ���������

  �������:
    role_id                                - ������������� ��������� ������ ����

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
  ��������� �������������� ����.

  ������� ���������:
    roleId                                 - ID ����
    roleName                               - ������������ ���� �� ����� �� ���������
    roleNameEn                             - ������������ ���� �� ���������� �����
    shortName                              - ������� ������������ ����
    description                            - �������� ���� �� ����� �� ���������
    isUnused                               - ������� �������������� ����
    computerName                           - ��� ����������, � �������� ������������ ��������
    ipAddress                              - IP ����� ����������, � �������� ������������ ��������
    operatorId                             - ������������, ��������� ������

  �������� ��������� �����������.

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
  ��������� �������� ����.

  ������� ���������:
    roleId                                 - ID ����
    operatorId                             - �� ���������
    computerName                           - ��� ����������, � �������� ������������ ��������
    ipAddress                              - IP ����� ����������, � �������� ������������ ��������

  �������� ��������� �����������.

  ( <body::deleteRole>)
*/
procedure deleteRole(
  roleId integer
  , operatorId integer
  , computerName varchar2 default null
  , ipAddress varchar2 default null
);

/* pfunc: mergeRole
  ���������� ��� ���������� ����.

  ���������:
  roleShortName               - �������� ������������ ����
  roleName                    - ������������ ����
  roleNameEn                  - ������������ ���� �� ����������
  description                 - �������� ����

  �������:
  - ���� �� ���� �������� ( ��������� ��� ���������);

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
  ������� ������ ����.

  ������� ���������:
    roleId	                               - ������������� ����
    roleName	                             - ������������ ���� �� ����� �� ���������
    roleNameEn	                           - ������������ ���� �� ���������� �����
    shortName	                             - ������� ������������ ����
    description	                           - �������� ���� �� ����� �� ���������
    isUnused                               - ������� �������������� ����
    rowCount	                             - ������������ ���������� ������������ �������
    operatorId	                           - ������������, �������������� �����

  ������� (� ���� �������):
    role_id	                               - ������������� ����
    short_name	                           - ������� ������������ ����
    role_name	                             - ������������ ���� �� ����� �� ���������
    role_name_en	                         - ������������ ���� �� ���������� �����
    description	                           - �������� ���� �� ����� �� ���������
    date_ins	                             - ���� �������� ������
    operator_id	                           - ������������, ��������� ������
    operator_name	                         - ������������ �� ����� �� ���������, ��������� ������
    operator_name_en	                     - ������������ �� ���������� �����, ��������� ������
    is_unused                              - ������� �������������� ����

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



/* group: ������� ��� ������ � �������� */

/* pfunc: createGroup
  ������� �������� ������.

  ������� ���������:
    groupName                              - ������������ ������ �� ����� �� ���������
    groupNameEn                            - ������������ ������ �� ���������� �����
    description                            - ��������
    isUnused                               - ������� �������������� ����
    operatorId                             - ������������, ��������� ������

  �������:
    group_id                               - �� ������

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
  ��������� �������������� ������.

  ������� ���������:
    groupId                                - ID ������
    groupName                              - ������������ ������ �� ����� �� ���������
    groupNameEn                            - ������������ ������ �� ���������� �����
    description                            - ��������
    isUnused                               - ������� �������������� ����
    computerName                           - ��� ����������, � �������� ������������ ��������
    ipAddress                              - IP ����� ����������, � �������� ������������ ��������
    operatorId                             - ������������, ��������� ������

  �������� ��������� �����������.

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
  ��������� �������� ������.

  ������� ���������:
    groupId                                - �� ������
    operatorId                             - �� ���������
    computerName                           - ��� ����������, � �������� ������������ ��������
    ipAddress                              - IP ����� ����������, � �������� ������������ ��������

  �������� ��������� �����������.

  ( <body::deleteGroup>)
*/
procedure deleteGroup(
  groupId integer
  , operatorId integer
  , computerName varchar2 default null
  , ipAddress varchar2 default null
);

/* pfunc: findGroup
  ������� ������ �����.

  ������� ���������:
    groupId                                - �� ������
    groupId                                - ������������� ������
    groupName                              - ������������ ������ �� ����� �� ���������
    groupNameEn                            - ������������ ������ �� ���������� �����
    isGrantOnly                            - ������� ���������� ������ grant-������:
                                             ���� 1, �� ���������� ������ grant-������;
                                             ���� 0  ��� null, �� ���������� ��� ������.
    description                            - ��������
    isUnused                               - ������� �������������� ������
    rowCount                               - ������������ ���������� ������������ �������
    operatorId                             - ������������, �������������� �����

  ������� (� ���� �������):
    group_id                               - ������������� ������
    group_name                             - ������������ ������ �� ����� �� ���������
    group_name_en                          - ������������ ������ �� ���������� �����
    date_ins                               - ���� �������� ������
    operator_id                            - ������������, ��������� ������
    operator_name                          - ������������ �� ����� �� ���������, ��������� ������
    operator_name_en                       - ������������ �� ���������� �����, ��������� ������
    description                            - �������� ������
    is_unused                              - ������� �������������� ������

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



/* group: ������� ��� ������ � ������ ��������� */

/* pproc: createOperatorRole
  ��������� �������� ����� ������������ � ����.

  ������� ���������:
    operatorId                             - �� ���������
    roleId                                 - �� ����
    userAccessFlag                         - ����� �� ������������� ������
    grantOptionFlag                        - ����� �� ������ ������ ������ ����������
    operatorIdIns                          - �� �������� ���������
    computerName                           - ��� ����������, � �������� ������������ ��������
    ipAddress                              - IP ����� ����������, � �������� ������������ ��������

  �������� ��������� ����������.

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
  ��������� �������������� ����� ������������ � ����.

  ������� ���������:
    operatorId                             - �� ���������
    roleId                                 - �� ����
    userAccessFlag                         - ����� �� ������������� ������
    grantOptionFlag                        - ����� �� ������ ������ ������ ����������
    operatorIdIns                          - �� �������� ���������
    computerName                           - ��� ����������, � �������� ������������ ��������
    ipAddress                              - IP ����� ����������, � �������� ������������ ��������

  �������� ��������� ����������.

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
  ��������� �������� ���� � ���������.

  ������� ���������:
    operatorId                             - �� ���������
    roleId                                 - �� ����
    operatorIdIns                          - �� �������� ���������
    computerName                           - ��� ����������, � �������� ������������ ��������
    ipAddress                              - IP ����� ����������, � �������� ������������ ��������

  �������� ��������� ����������.

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
  ������� ������ ����� ������������ � ���� FindOperatorRole

  ������� ���������:
    operatorId                 - ������������� ������������
    roleId                     - ������������� ����
    rowCount                   - ������������ ���������� ������������ �������
    operatorIdIns              - ������������, �������������� �����

  ������� (� ���� �������):
    operator_id                - ������������� ������������
      role_id                  - ������������� ����
      short_name               - ������� ������������ ����
      role_name                - ������������ ���� �� ����� �� ���������
      role_name_en             - ������������ ���� �� ���������� �����
      description              - �������� ���� �� ����� �� ���������
      date_ins                 - ���� �������� ������
      operator_id_ins          - ������������, ��������� ������
      operator_name_ins        - ������������ �� ����� �� ���������, ��������� ������
      operator_name_ins_en     - ������������ �� ���������� �����, ��������� ������
      user_access_flag         - ������� ������� � ����
      grant_option_flag        - ������� ������ ���� � ����

  ( <body::findOperatorRole>)
*/
function findOperatorRole(
  operatorId integer default null
  , roleId integer default null
  , rowCount integer default null
  , operatorIdIns integer
)
return sys_refcursor;



/* group: ������� ��� ������ � �������� ��������� */

/* pproc: createOperatorGroup
  ��������� ���������� ������ ���������.

  ������� ���������:
    operatorID                             - ID ���������
    groupID                                - ID ������
    userAccessFlag                         - ����� �� ������������� ������
    grantOptionFlag                        - ����� �� ������ ������ ������ ����������
    operatorIDIns                          - ID ���������, ������������ ���������
    computerName                           - ��� ����������, � �������� ������������ ��������
    ipAddress                              - IP ����� ����������, � �������� ������������ ��������

  �������� ��������� �����������.

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
  ��������� �������������� ����� ������ � ���������.

  ������� ���������:
    operatorID                             - ID ���������
    groupID                                - ID ������
    userAccessFlag                         - ����� �� ������������� ������
    grantOptionFlag                        - ����� �� ������ ������ ������ ����������
    operatorIDIns                          - ID ���������, ������������ ���������
    computerName                           - ��� ����������, � �������� ������������ ��������
    ipAddress                              - IP ����� ����������, � �������� ������������ ��������

  �������� ��������� �����������.

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
  ��������� �������� ������ � ���������.

  ������� ���������:
    operatorID                             - ID ���������
    groupID                                - ID ������
    operatorIDIns                          - ID ���������, ������������ ���������
    computerName                           - ��� ����������, � �������� ������������ ��������
    ipAddress                              - IP ����� ����������, � �������� ������������ ��������

  �������� ��������� �����������.

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
  ������� ������ ����� ����������.

  ������� ���������:
    operatorID                             - ID ���������
    groupId                                - ������������� ������
    isActualOnly                           - ������� ������ ������ ����������������� ����������
    rowCount                               - ������������ ���������� ������������ �������
    operatorIdIns                          - ������������, �������������� �����

  ������� (� ���� �������):
    operator_id                            - ������������� ������������
    login                                  - ����� ���������
    operator_name                          - ��� ���������
    group_id                               - ������������� ������
    group_name                             - ������������ ������ �� ����� �� ���������
    group_name_en                          - ������������ ������ �� ���������� �����
    date_ins                               - ���� �������� ������
    operator_id_ins                        - ������������, ��������� ������
    operator_name_ins                      - ������������ �� ����� �� ���������, ��������� ������
    operator_name_ins_en                   - ������������ �� ���������� �����, ��������� ������
    user_access_flag                       - ������� ��������� � ������
    grant_option_flag                      - ������� ������ ���� �� ������

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



/* group: ������� ��� ������ �� ������� ����-������*/

/* pproc: createGroupRole
  ��������� ���������� ���� � ������.

  ������� ���������:
    groupID                                - ID ������
    roleID                                 - ID ����
    operatorID                             - ID ���������
    computerName                           - ��� ����������, � �������� ������������ ��������
    ipAddress                              - IP ����� ����������, � �������� ������������ ��������

  �������� ��������� �����������.

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
  ��������� �������� ���� �� ������.

  ������� ���������:
    groupID                                - ID ������
    roleID                                 - ID ����
    operatorID                             - ID ���������
    computerName                           - ��� ����������, � �������� ������������ ��������
    ipAddress                              - IP ����� ����������, � �������� ������������ ��������

  �������� ��������� �����������.

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
  ������� ������ ����� ������ � ���� FindGroupRole

  ������� ���������:
    groupId	-	������������� ������
    roleId	-	������������� ����
    rowCount	-	������������ ���������� ������������ �������
    operatorId	-	������������, �������������� �����

  �������� ���������(� ���� �������):
    group_id	-	������������� ������
    role_id	-	������������� ����
    short_name	-	������� ������������ ����
    role_name	-	������������ ���� �� ����� �� ���������
    role_name_en	-	������������ ���� �� ���������� �����
    description	-	�������� ���� �� ����� �� ���������
    date_ins	-	���� �������� ������
    operator_id	-	������������, ��������� ������
    operator_name	-	������������ �� ����� �� ���������, ��������� ������
    operator_name_en	-	������������ �� ���������� �����, ��������� ������

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
  ����� �� �������.

  ������� ���������:
    operatorDateInsFrom             - ���� �������� ��������� �
    operatorDateInsTo               - ���� �������� ��������� ��
    AccessOperatorId                - ID ���������
    AccessOperatorName              - ��� ���������
    operatorBlockEnsign             - ������� ����������
    groupId                         - ID ������
    groupDateInsFrom                - ���� ���������� � ����� �
    groupDateInsTo                  - ���� ���������� � ������ ��
    roleId                          - ID ����
    roleDateInsFrom                 - ���� ���������� ���� �
    roleDateInsTo                   - ���� ���������� ���� ��
    rowCount                        - ����� �����

  �������( � ���� �������):
    operator_id                     - ID ���������
    operator_name                   - ��� ���������
    employee_name                   - ��� � ����������� �����������
    login                           - �����
    branch_name                     - �������� �������
    operator_block_ensign           - ������� ����������
    date_ins                        - ���� �������� ��������
    operator_name_ins               - ��� ���������
    date_finish                     - ���� ��������� �������� ������ � ���������
    group_id                        - ID ������
    group_name                      - �������� ������
    group_date_ins                  - ���� ���������� ��������� � �����
    group_operator_name_ins         - ��� ��������� ������� ������� � ������
    role_id                         - ID ����
    role_name                       - �������� ����
    role_date_ins                   - ���� ���������� ���� ���������
    role_operator_name_ins          - ��� ��������� ������� ����� ����

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
   ������� �������������� ������������ ����������.

   ������� ��������� �����������.

   �������:
     operator_unlocked_count      - ���������� ���������������� ����������

  ( <body::autoUnlockOperator>)
*/
function autoUnlockOperator
return integer;



/* group: ������� ��� ������ � �������� ���������� */

/* pfunc: createLoginAttemptGroup
   ������� �������� ������ ���������� ����������.

   ������� ���������:
     loginAttemptGroupName        - ������������ ������
     isDefault                    - ������� �� ���������
     lockTypeCode                 - ��� ����������
     maxLoginAttemptCount         - ����������� ���������� ����������
                                    ������� ����� � �������
     lockingTime                  - ����� ���������� � ��������
     usedForCl                    - ������������ ��� CL
     blockWaitPeriod              - ���������� ����, ���������� ���������� ���������
                                    ��� ���������� ����������
     operatorId                   - ������������, ��������� ������

   �������:
     login_attempt_group_id       - ������������� ��������� ������

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
   ��������� �������������� ������ ���������� ����������.

   ������� ���������:
     loginAttemptGroupId          - �� ������
     loginAttemptGroupName        - ������������ ������
     isDefault                    - ������� �� ���������
     lockTypeCode                 - ��� ����������
     maxLoginAttemptCount         - ����������� ���������� ����������
                                    ������� ����� � �������
     lockingTime                  - ����� ���������� � ��������
     usedForCl                    - ������������ ��� CL
     blockWaitPeriod              - ���������� ����, ���������� ���������� ���������
                                    ��� ���������� ����������
     operatorId                   - ������������,��������� ������

   �������� ��������� �����������.

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
   ��������� �������� ������ ���������� ����������.

   ������� ���������:
     loginAttemptGroupId          - �� ������
     operatorId                   - �� ���������

   �������� ��������� �����������.

  ( <body::deleteLoginAttemptGroup>)
*/
procedure deleteLoginAttemptGroup(
  loginAttemptGroupId integer
  , operatorId integer
);

/* pfunc: findLoginAttemptGroup
   ������� ������ ������ ���������� ����������.

   ������� ���������:
     loginAttemptGroupId          - �� ������
     loginAttemptGroupName        - ������������ ������
     isDefault                    - ������� �� ���������
     lockTypeCode                 - ��� ����������
     maxRowCount                  - ���������� ������� � �������
     operatorId                   - ������������,��������� ������

   ������� (� ���� �������):
     login_attempt_group_id       - ������������� ������
     login_attempt_group_name     - ������������ ������
     is_default                   - ������� �� ���������
     lock_type_code               - ��� ����������
     lock_type_name               - ������������ ����
     max_login_attempt_count      - ����������� ���������� ����������
                                    ������� ����� � �������
     locking_time                 - ����� ���������� � ��������
     used_for_cl                  - ������� ������������� ��� CL
     block_wait_period            - ���������� ����, ���������� ���������� ���������
                                    ��� ���������� ����������

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
   ������� ��������� ������ ������ ���������� ����������.

   ������� ���������:
     lockTypeCode                 - ��� ����������

   ������� (� ���� �������):
     login_attempt_group_id       - ������������� ������
     login_attempt_group_name     - ������������ ������
     is_default                   - ������� �� ���������
     lock_type_code               - ��� ����������
     lock_type_name               - ������������ ����
     max_login_attempt_count      - ����������� ���������� ����������
                                    ������� ����� � �������
     locking_time                 - ����� ���������� � ��������
     block_wait_period            - ���������� ����, ���������� ���������� ���������
                                    ��� ���������� ����������

  ( <body::getLoginAttemptGroup>)
*/
function getLoginAttemptGroup(
  lockTypeCode varchar2 default null
)
return sys_refcursor;

/* pproc: changeLoginAttemptGroup
   ��������� �������� ����� ������ ���������� ����������.

   ������� ���������:
     oldLoginAttemptGroupId       - ������������� ������, � �������
                                    �������������� �������
     newLoginAttemptGroupId       - ������������� ������, �� �������
                                    �������������� �������
     operatorId                   - �� ���������

   �������� ��������� �����������.

  ( <body::changeLoginAttemptGroup>)
*/
procedure changeLoginAttemptGroup(
  oldLoginAttemptGroupId integer
  , newLoginAttemptGroupId integer
  , operatorId integer
);



/* group: ������� �� ������ ��������� ���� */

/* pproc: setAdminGroup
  ������� ������ ����������������� ����� ��������� �� ������

  ���������:
  targetOperatorId            - �������������, �������� �������� �����
  groupId                     - ������������� ������
  operatorId                  - ������������� ������������

  ( <body::setAdminGroup>)
*/
procedure setAdminGroup(
  targetOperatorId            integer
, groupId                     integer
, operatorId                  integer
);

/* pproc: setAdminRole
  ������� ������ ����������������� ����� ��������� �� ����

  ���������:
  targetOperatorId            - �������������, �������� �������� �����
  roleId                      - ������������� ����
  operatorId                  - ������������� ������������

  ( <body::setAdminRole>)
*/
procedure setAdminRole(
  targetOperatorId            integer
, roleId                      integer
, operatorId                  integer
);

end pkg_AccessOperator;
/
