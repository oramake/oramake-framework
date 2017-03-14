create or replace package pkg_ModuleInfo is
/* package: pkg_ModuleInfo
  ������������ ����� ������ ModuleInfo.

  SVN root: Oracle/Module/ModuleInfo
*/



/* group: ��������� */



/* group: ���� ��������� */

/* const: Object_InstallTypeCode
  ��� ���� ��������� "��������� �������� ����� � ������".
*/
Object_InstallTypeCode constant varchar2(10) := 'OBJ';

/* const: Privs_InstallTypeCode
  ��� ���� ��������� "��������� ���� �������".
*/
Privs_InstallTypeCode constant varchar2(10) := 'PRI';



/* group: ������� */



/* group: ������ � �� */

/* pfunc: getModuleId
  ��������� id ������.


  ���������:
  findModuleString            - ������ ��� ������ ������ (
                                ����� ��������� � ����� �� ��� ���������
                                ������: ���������, ���� � ��������� ��������,
                                �������������� ���� � ��������� �������� �
                                Subversion)
  moduleName                  - �������� ������ ( �������� "ModuleInfo")
  svnRoot                     - ���� � ��������� �������� ������ � Subversion
                                ( ������� � ����� �����������, ��������
                                "Oracle/Module/ModuleInfo")
  initialSvnPath              - �������������� ���� � ��������� ��������
                                ������ � Subversion ( ������� � �����
                                ����������� � ������ ����� ������, � �������
                                �� ��� ������, ��������
                                "Oracle/Module/ModuleInfo@711")
  raiseExceptionFlag          - ����������� �� ���������� ���� ������ �� ������
                                ( ��-��������� 1-�����������);

  �������:
  Id ������ ( �������� module_id �� ������� <mod_module>) ���� null ����
  ������ �� ������� � raiseExceptionFlag = 0.

  ( <body::getModuleId>)
*/
function getModuleId(
  findModuleString varchar2 := null
  , moduleName varchar2 := null
  , svnRoot varchar2 := null
  , initialSvnPath varchar2 := null
  , raiseExceptionFlag number := null
)
return varchar2;

/* pfunc: getInstallModuleVersion
  ���������� ������������� � �� ������ ������.
  ��� ����������� ������ ����������� ������ ������ �������� ����� ��������
  ������ �������.

  ���������:
  svnRoot                     - ���� � ��������� �������� ������ � Subversion
                                ( ������� � ����� �����������, ��������
                                "Oracle/Module/ModuleInfo")
  initialSvnPath              - �������������� ���� � ��������� ��������
                                ������ � Subversion ( ������� � �����
                                ����������� � ������ ����� ������, � �������
                                �� ��� ������, ��������
                                "Oracle/Module/ModuleInfo@711")
  mainObjectSchema            - �����, � ������� ����������� ������� ��������
                                ����� ������ ( ���������� ��������� � ������
                                ������� ��������� � ������ �����)

  �������:
  ����� ������������� ������ ���� null ��� ���������� ������ �� ���������.

  ���������:
  - ������ ���� ������� ������� �� null �������� svnRoot ���� initialSvnPath,
    ��� ���� � ������ �������� initialSvnPath �������� svnRoot ������������;
  - ������� �������� ���������� �������������;

  ( <body::getInstallModuleVersion>)
*/
function getInstallModuleVersion(
  svnRoot varchar2 := null
  , initialSvnPath varchar2 := null
  , mainObjectSchema varchar2 := null
)
return varchar2;



/* group: ��������� ���������� */

/* pfunc: getAppInstallVersion
  ���������� ������������� ������ ����������.

  ���������:
  deploymentPath              - ���� ��� ������������� ����������
  svnRoot                     - ���� � ��������� �������� ������ � Subversion
                                ( ������� � ����� �����������, ��������
                                "Oracle/Module/ModuleInfo")
  initialSvnPath              - �������������� ���� � ��������� ��������
                                ������ � Subversion ( ������� � �����
                                ����������� � ������ ����� ������, � �������
                                �� ��� ������, ��������
                                "Oracle/Module/ModuleInfo@711")

  �������:
  ����� ������������� ������ ���� null ��� ���������� ������ �� ���������.

  ���������:
  - ������ ���� ������� ������� �� null �������� svnRoot ���� initialSvnPath,
    ��� ���� � ������ �������� initialSvnPath �������� svnRoot ������������;
  - ������� �������� ���������� �������������;

  ( <body::getAppInstallVersion>)
*/
function getAppInstallVersion(
  deploymentPath varchar2
  , svnRoot varchar2 := null
  , initialSvnPath varchar2 := null
)
return varchar2;

/* pfunc: startAppInstall
  ��������� ���������� � ������ ��������� ����������.
  ������� ������ ���������� ����� ������� ��������� ����������, ��� ���� �����
  ���������� ��������� ���������� ( � �������� ���� ���������� �����������)
  ������ ���� ������� ������� <finishAppInstall>.

  ���������:
  moduleSvnRoot               - ���� � ��������� �������� ����������������
                                ������ � Subversion ( ������� � �����
                                �����������, ��������
                                "Oracle/Module/ModuleInfo")
  moduleInitialSvnPath        - �������������� ���� � ��������� ��������
                                ���������������� ������ � Subversion ( �������
                                � ����� ����������� � ������ ����� ������, �
                                ������� �� ��� ������, ��������
                                "Oracle/Module/ModuleInfo@711")
  moduleVersion               - ������ ������ ( ��������, "1.1.0")
  deploymentPath              - ���� ��� ������������� ����������
  installVersion              - ��������������� ������ ����������
  svnPath                     - ���� � Subversion, �� �������� ���� ��������
                                ����� ������ ( ������� � ����� �����������,
                                null � ������ ���������� ����������)
  svnVersionInfo              - ���������� � ������ ������ ������ �� Subversion
                                ( � ������� ������ ������� svnversion,
                                null � ������ ���������� ����������)
  operatorId                  - Id ���������, ������������ ��������
                                ( �� ��������� �������)

  �������:
  Id ����������� ������ ( ���� app_install_result_id �������
  <mod_app_install_result>).

  ���������:
  - ��� ������ ������� ��������� ���������� � ������� ������������� �������
    ����������, �.�. ���������, ��� ����� ������������� ������ ����������
    ���������������� ����� ���������� ����� ������;

  ( <body::startAppInstall>)
*/
function startAppInstall(
  moduleSvnRoot varchar2
  , moduleInitialSvnPath varchar2
  , moduleVersion varchar2
  , deploymentPath varchar2
  , installVersion varchar2
  , svnPath varchar2 := null
  , svnVersionInfo varchar2 := null
  , operatorId integer := null
)
return integer;

/* pproc: finishAppInstall
  ��������� ���������� � ���������� ��������� ����������.

  ���������:
  appInstallResultId          - Id ������ � ������ ��������� ����������,
                                ������� ��� ��������� �������� <startAppInstall>
  statusCode                  - ��� ���������� ���������� ���������
                                ( 0 �������� ���������� ������, ��� ����
                                  ��������������� ������ ���������� �������)
  errorMessage                - ����� ��������� �� ������� ��� ����������
                                ���������
                                ( ����������� ������ 4000 ��������)
                                ( �� ��������� �����������)
  installDate                 - ���� ���������� ��������� ( �� ���������
                                �������)
  operatorId                  - Id ���������, ������������ ��������
                                ( �� ��������� �������)

  ���������:
  - �������� javaReturnCode �������� ���������� � �������� �������� ���
    ����������� �������������, ������ ���� ������� ������������ statusCode;

  ( <body::finishAppInstall>)
*/
procedure finishAppInstall(
  appInstallResultId integer
  , statusCode integer := null
  , errorMessage varchar2 := null
  , installDate date := null
  , operatorId integer := null
  , javaReturnCode integer := null
);

end pkg_ModuleInfo;
/
