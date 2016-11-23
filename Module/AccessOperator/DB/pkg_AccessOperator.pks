create or replace package pkg_AccessOperator is
/* package: pkg_AccessOperator
  ����� ��� ��������� ������ ������.

  SVN root: Oracle/Module/AccessOperator
*/



/* group: ������� */



/* group: ���� */

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



/* group: ������������ */

/* pfunc: createOperator
  �������� ������������.

  ������� ���������:
    operatorName                - ������������ ������������ �� ����� �� ���������
    operatorNameEn              - ������������ ������������ �� ���������� �����
    login                       - �����
    password                    - ������
    operatorIdIns               - ������������, ��������� ������
                                  ���������� �������� � ����������
    operatorComment             - ����������� ���������

   �������:
     operator_id                - ID ���������� ���������

  ( <body::createOperator>)
*/
function createOperator(
  operatorName      varchar2
  , operatorNameEn  varchar2
  , login           varchar2
  , password        varchar2
  , operatorIdIns   integer
  , operatorComment varchar2 := null
)
return integer;

/* pproc: updateOperator
  ���������� ������������.

  ������� ���������:
    operatorId                  - ID ��������� ��� ���������
    operatorName                - ������������ ������������ �� ����� �� ���������
    operatorNameEn              - ������������ ������������ �� ���������� �����
    login                       - �����
    password                    - ������
    operatorIdIns               - ������������, ��������� ������
    operatorComment             - ����������� ���������

   �������� ��������� �����������.

  ( <body::updateOperator>)
*/
procedure updateOperator(
  operatorId        integer
  , operatorName    varchar2
  , operatorNameEn  varchar2
  , login           varchar2
  , password        varchar2
  , operatorIdIns   integer
  , operatorComment varchar2 := null
);

/* pproc: deleteOperator
   �������� ������������.

   ������� ���������:
     operatorId          - �� ���������
     operatorIdIns       - �� ��������� �� �������� ����
     operatorComment     - �����������

  �������� ��������� �����������.

  ( <body::deleteOperator>)
*/
procedure deleteOperator(
  operatorId        integer
  , operatorIdIns   integer
  , operatorComment varchar2 := null
);



/* group: ������ ��������� */

/* pproc: createOperatorGroup
  ��������� ���������� ������ ���������.

  ������� ���������:
    operatorId                             - ID ���������
    groupId                                - ID ������
    operatorIdIns                          - ID ���������, ������������ ���������

  �������� ��������� �����������.

  ( <body::createOperatorGroup>)
*/
procedure createOperatorGroup(
  operatorId integer
  , groupId integer
  , operatorIdIns integer
);

/* pproc: deleteOperatorGroup
  ��������� �������� ������ � ���������.

  ������� ���������:
    operatorID                             - ID ���������
    groupID                                - ID ������
    operatorIDIns                          - ID ���������, ������������ ���������

  �������� ��������� �����������.

  ( <body::deleteOperatorGroup>)
*/
procedure deleteOperatorGroup(
  operatorId integer
  , groupId integer
  , operatorIdIns integer
);

end pkg_AccessOperator;
/
