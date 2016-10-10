create or replace package pkg_Operator is
/* package: pkg_Operator
  ������������ ����� ������ Operator.

  SVN root: Oracle/Module/AccessOperator
*/



/* group: ��������� */

/* const: Module_Name
  �������� ������, � �������� ��������� �����.
*/
Module_Name constant varchar2(30) := 'AccessOperator';

/* const: FullAccess_GroupId
  Id ������ "������ ������".
*/
FullAccess_GroupId constant integer := 1;



/* group: ������� */

/* pfunc: login
  ������������ ��������� � ����. ���������� �������. ������������ ���������
  <login(password)>. ��������� ��� �������� �������������.

  ���������:
  operatorLogin               - ����� ���������
  password                    - ������ ���������

  �������:
  - ����� ���������

  ( <body::login>)
*/
function login(
  operatorLogin varchar2
  , password varchar2 := null
)
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

/* pproc: login(password)
  ������������ ��������� � ����.

  ���������:
  operatorLogin               - ����� ���������
  password                    - ������ ���������

  ( <body::login(password)>)
*/
procedure login(
  operatorLogin varchar2
  , password varchar2
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
  ���������� ������������� �������� ���������.

  ������� ���������:
  isRaiseException            - ���� ������������ ���������� � ������, ����
                                ������� �������� �� ���������

  �������:
  oprator_id                  - ������������� �������� ���������

  ( <body::getCurrentUserId>)
*/
function getCurrentUserId(
  isRaiseException integer default null
)
return integer;

/* pfunc: getCurrentUserName
  ���������� ��� �������� ���������.

  ������� ���������:
  isRaiseException            - ���� ����������� ���������� � ������, ����
                                ������� �������� �� ���������;

  �������:
  - ��� �������� ���������;

  ( <body::getCurrentUserName>)
*/
function getCurrentUserName(
  isRaiseException integer default 1
)
return varchar2;

/* pfunc: getOperator
  ��������� ������ �� ����������. � ��������� ����� *�� �����������* (
  �������� ��������� ��� ������ �������).

  ���������:
  operatorName                - ��� ���������
                                ( ����� �� like ��� ����� ��������)
                                ( �� ��������� ��� �����������)
  maxRowCount                 - ������������ ����� ������������ ������� �������
                                ( �� ��������� ��� �����������)

  ������� ( ������):
  operator_id                 - Id ���������
  operator_name               - ��� ���������

  ( <body::getOperator>)
*/
function getOperator(
  operatorName varchar2 := null
  , maxRowCount integer := null
)
return sys_refcursor;

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

end pkg_Operator;
/
