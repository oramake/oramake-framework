create or replace package pkg_ModuleInfoInternal is
/* package: pkg_ModuleInfoInternal
  ���������� ������� ������.

  SVN root: Oracle/Module/ModuleInfo 
*/



/* group: ��������� */

/* const: Module_Name
  �������� ������, � �������� ��������� �����.
*/
Module_Name constant varchar2(30) := 'ModuleInfo';



/* group: ���� ������
  ����������� ��������� ������������ ��� ��������� ����������� �� ������
  pkg_Error ������ Common.
  �������� �������� ��������� � ���������������� ( �� ������ ����� �����)
  ����������� �� ������ pkg_Error.
*/

/* const: ErrorStackInfo_Error
  ��� ������, ������������ ��� ������ ���������� � ����� ������������� ������ 
  � ���� ������.
*/
ErrorStackInfo_Error constant integer := -20150;

/* const: IllegalArgument_Error
  ��� ������, ��������� ��������� ������������ ���������� ��� �������.
*/
IllegalArgument_Error constant integer := -20195;

/* const: ProcessEror
  ��� ������, ���������� ��� ���������� �������. 
*/
ProcessError_Error constant integer := -20185;



/* group: ������� */

/* pfunc: compareVersion
  ���������� ������ ������.

  ���������:
  version1                    - ������ ����� ������
  version2                    - ������ ����� ������

  �������:
  -  -1 ���� version1 < version2
  -   0 ���� version1 = version2
  -   1 ���� version1 > version2
  - null ���� version1 ��� version2 ����� �������� null

  ���������:
  - ������ ������, ������������ ���� �������� �����������, ��������� �������,
    ��������, "1.0" � "1.00" � "1.0.0" �����;

  ( <body::compareVersion>)
*/
function compareVersion(
  version1 varchar2
  , version2 varchar2
)
return integer;

/* pfunc: getCurrentOperatorId
  ���������� Id �������� ������������������� ��������� ��� ����������� ������
  AccessOperator.

  �������:
  Id �������� ��������� ���� null � ������ ������������� ������ AccessOperator.

  ���������:
  - � ������ ����������� ������ AccessOperator � ���������� ��������
    ������������������� ��������� ������������� ����������;

  ( <body::getCurrentOperatorId>)
*/
function getCurrentOperatorId
return integer;

/* pfunc: getModuleId
  ���������� Id ������.

  ���������:
  svnRoot                     - ���� � ��������� �������� ������ � Subversion
                                ( ������� � ����� �����������, ��������
                                "Oracle/Module/ModuleInfo")
  initialSvnPath              - �������������� ���� � ��������� ��������
                                ������ � Subversion ( ������� � �����
                                ����������� � ������ ����� ������, � �������
                                �� ��� ������, ��������
                                "Oracle/Module/ModuleInfo@711")
  isCreate                    - ������� ������ � ������ ���������� ����������
                                ( 1 ��, 0 ��� ( �� ���������))
  operatorId                  - Id ���������, ������������ ��������
                                ( �� ��������� �������)

  �������:
  Id ������ ( �������� module_id �� ������� <mod_module>) ���� null ����
  ������ �� ������� � �� ������ isCreate = 1.

  ���������:
  - ��� ������ ������ ������ ���� ������� �������� �� null �������� svnRoot
    ���� initialSvnPath, ��� ���� � ������ �������� initialSvnPath ��������
    svnRoot ������������, ������� �������� ��������� ���������� ��� ������
    �������������;

  ( <body::getModuleId>)
*/
function getModuleId(
  svnRoot varchar2
  , initialSvnPath varchar2
  , isCreate integer := null
  , operatorId integer := null
)
return integer;

end pkg_ModuleInfoInternal;
/
