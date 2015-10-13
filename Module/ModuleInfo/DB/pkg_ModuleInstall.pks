create or replace package pkg_ModuleInstall is
/* package: pkg_ModuleInstall
  �������, ������������ �� ����� ��������� ������.

  SVN root: Oracle/Module/ModuleInfo
*/



/* group: ������� */



/* group: ��������������� ������� */



/* group: ��������� ������ */

/* pfunc: startInstallFile
  ��������� ������ ��������� �����.
  ���������� ����� ���������� ����� � ��� �� ������.

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
  installVersion              - ��������������� ������ ������
  hostProcessStartTime        - ����� ������ ���������� ��������, � �������
                                ����������� �������� ( ����������� ���������
                                ����� �� �����)
  hostProcessId               - ������������� �������� �� �����, � �������
                                ����������� ��������
  actionGoalList              - ���� ���������� �������� �� ��������� ������
                                ( ������ � ��������� � �������� �����������)
  actionOptionList            - ��������� �������� �� ��������� ������
                                ( ������ � ��������� � �������� �����������)
  svnPath                     - ���� � Subversion, �� �������� ���� ��������
                                ����� ������ ( ������� � ����� �����������,
                                null � ������ ���������� ����������)
  svnVersionInfo              - ���������� � ������ ������ ������ �� Subversion
                                ( � ������� ������ ������� svnversion,
                                null � ������ ���������� ����������)
  filePath                    - ���� � ���������������� �����
  fileModuleSvnRoot           - ���� � ��������� �������� ������, � ��������
                                ��������� ��������������� ����, � Subversion
                                ( ������ ���������� ��������� moduleSvnRoot,
                                �� ��������� ���������, ��� ���� ��������� �
                                ���������������� ������)
  fileModuleInitialSvnPath    - �������������� ���� � ��������� ��������
                                ������, � �������� ��������� ���������������
                                ����, � Subversion ( ������ ����������
                                ��������� moduleInitialSvnPath, �� ���������
                                ���������, ��� ���� ��������� �
                                ���������������� ������)
  fileModulePartNumber        - ����� ����� ������, � ������� ��������� ����
                                ( �� ��������� �� ���������� ��� �������
                                ������ � <mod_source_file>, � ��� �����
                                ������ ������������ ����� �������� �����)
  fileObjectName              - ��� ������� � ��, �������� ������������� ����
                                ( �� ��������� �� ������������� �������)
  fileObjectType              - ��� ������� � ��, �������� ������������� ����
                                ( �� ��������� �� ������������� �������)

  �������:
  Id ��� ����������� ��������� ����� ( �������� install_file_id �� �������
  <mod_install_file>).

  ���������:
  - ������� ����������� � ���������� ����������;

  ( <body::startInstallFile>)
*/
function startInstallFile(
  moduleSvnRoot varchar2
  , moduleInitialSvnPath varchar2
  , moduleVersion varchar2
  , installVersion varchar2 := null
  , hostProcessStartTime timestamp with time zone
  , hostProcessId integer
  , actionGoalList varchar2
  , actionOptionList varchar2
  , svnPath varchar2 := null
  , svnVersionInfo varchar2 := null
  , filePath varchar2
  , fileModuleSvnRoot varchar2 := null
  , fileModuleInitialSvnPath varchar2 := null
  , fileModulePartNumber integer := null
  , fileObjectName varchar2 := null
  , fileObjectType varchar2 := null
)
return integer;

/* pproc: finishInstallFile
  ��������� ���������� ��������� �����.
  ���������� ����� ���������� ��������� ����� � ��� �� ������, ��� ����
  ����� ���������� ������ ���� ������� ��������� <startInstallFile>.

  ���������:
  installFileId               - Id ��������� ����� ( �� ��������� �������)

  ���������:
  - ��������� ����������� � ���������� ����������;

  ( <body::finishInstallFile>)
*/
procedure finishInstallFile(
  installFileId integer := null
);

/* pfunc: startInstallNestedFile
  ��������� ������ ��������� ���������� �����.
  �������������� � ��� �� ������ ������ ���� ������������� ������ ���������
  ����� �������� ������ � ������� ������ ������� <startInstallFile>.

  ���������:
  filePath                    - ���� � ������������ �����
  fileModuleSvnRoot           - ���� � ��������� �������� ������, � ��������
                                ��������� ����������� ����, � Subversion
                                ( ������ ���������� ��������� moduleSvnRoot,
                                �� ��������� ���������, ��� ���� ��������� �
                                ���������������� ������)
  fileModuleInitialSvnPath    - �������������� ���� � ��������� ��������
                                ������, � �������� ��������� �����������
                                ����, � Subversion ( ������ ����������
                                ��������� moduleInitialSvnPath, �� ���������
                                ���������, ��� ���� ��������� �
                                ���������������� ������)
  fileModulePartNumber        - ����� ����� ������, � ������� ��������� ����
                                ( �� ��������� �� ���������� ��� �������
                                ������ � <mod_source_file>, � ��� �����
                                ������ ������������ ����� �����
                                ���������������� ����� �������� ������ ����
                                �� ��������� � ���� �� ������, ����� �����
                                �������� �����)
  fileObjectName              - ��� ������� � ��, �������� ������������� ����
                                ( �� ��������� �� ������������� �������)
  fileObjectType              - ��� ������� � ��, �������� ������������� ����
                                ( �� ��������� �� ������������� �������)

  �������:
  Id ������, ����������� ������ ��������� ����� ( �������� install_file_id ��
  ������� <mod_install_file>).

  ���������:
  - ������� ����������� � ���������� ����������;

  ( <body::startInstallNestedFile>)
*/
function startInstallNestedFile(
  filePath varchar2
  , fileModuleSvnRoot varchar2 := null
  , fileModuleInitialSvnPath varchar2 := null
  , fileModulePartNumber integer := null
  , fileObjectName varchar2 := null
  , fileObjectType varchar2 := null
)
return integer;

/* pproc: finishInstallNestedFile
  ��������� ���������� ��������� ���������� �����.
  ���������� ����� ���������� ��������� ���������� ����� � ��� �� ������, ���
  ���� ����� ������� ���������� ���������� ����� ������ ���� ������� �������
  <startInstallNestedFile>.

  ���������:
  - ��������� ����������� � ���������� ����������;

  ( <body::finishInstallNestedFile>)
*/
procedure finishInstallNestedFile;



/* group: ��������� ��������� */

/* pfunc: createInstallResult
  ��������� ��������� ��������� ��� �������� �� ��������� ������.

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
  hostProcessStartTime        - ����� ������ ���������� ��������, � �������
                                ����������� �������� ( ����������� ���������
                                ����� �� �����)
  hostProcessId               - ������������� �������� �� �����, � �������
                                ����������� ��������
  moduleVersion               - ������ ������ ( ��������, "1.1.0")
  actionGoalList              - ���� ���������� �������� �� ��������� ������
                                ( ������ � ��������� � �������� �����������)
  actionOptionList            - ��������� �������� �� ��������� ������
                                ( ������ � ��������� � �������� �����������)
  svnPath                     - ���� � Subversion, �� �������� ���� ��������
                                ����� ������ ( ������� � ����� �����������,
                                null � ������ ���������� ����������)
  svnVersionInfo              - ���������� � ������ ������ ������ �� Subversion
                                ( � ������� ������ ������� svnversion,
                                null � ������ ���������� ����������)
  modulePartNumber            - ����� ��������������� ����� ������
                                ( �� ��������� ����� �������� �����)
  installVersion              - ��������������� ������
  installTypeCode             - ��� ���� ���������
  isFullInstall               - ���� ������ ��������� ( 1 ��� ������ ���������,
                                0 ��� ��������� ����������)
  isRevertInstall             - ���� ���������� ������ ��������� ������
                                ( 1 ������ ��������� ������, 0 ��������� ������
                                ( �� ���������))
  installUser                 - ��� ������������, ��� ������� �����������
                                ��������� ( �� ��������� �������)
  installDate                 - ���� ���������� ��������� ( �� ���������
                                �������)
  objectSchema                - �����, � ������� ����������� ������� ������
                                ����� ������ ( �� ��������� ��������� �
                                installUser, null ���� � ��� ������� sys ���
                                system)
  privsUser                   - ��� ������������ ��� ����, ��� �������
                                ����������� ��������� ���� ������� ( ��������
                                ������ ���� ������� ������ ��� ��������� ����
                                �������)
  installScript               - ��������� ������������ ������ ( �����
                                �������������, ���� ������������� �����������
                                �������, �������� run.sql)
  resultVersion               - ������, ������������ ���������� ����������
                                ���������, ������ ���� ����������� ������� ���
                                ������ ��������� ���������� ( �� ���������
                                installVersion � ������ ���������, null �
                                ������ ������ ������ ���������)

  �������:
  Id ����������� ������ ( ���� install_result_id ������� <mod_install_result>).

  ���������:
  - ������, ��������� � resultVersion, ���������� ������� �������������
    �������;

  ( <body::createInstallResult>)
*/
function createInstallResult(
  moduleSvnRoot varchar2
  , moduleInitialSvnPath varchar2
  , hostProcessStartTime timestamp with time zone
  , hostProcessId integer
  , moduleVersion varchar2
  , actionGoalList varchar2
  , actionOptionList varchar2
  , svnPath varchar2 := null
  , svnVersionInfo varchar2 := null
  , modulePartNumber integer
  , installVersion varchar2
  , installTypeCode varchar2
  , isFullInstall integer
  , isRevertInstall integer := null
  , installUser varchar2 := null
  , installDate date := null
  , objectSchema varchar2 := null
  , privsUser varchar2 := null
  , installScript varchar2 := null
  , resultVersion varchar2 := null
)
return integer;

end pkg_ModuleInstall;
/
