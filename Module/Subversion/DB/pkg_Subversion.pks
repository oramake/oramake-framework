create or replace package pkg_Subversion is
/* package: pkg_Subversion
  ������������ ����� ������ Subversion.

  SVN root: Oracle/Module/Subversion
*/

/* const: Module_Name
  �������� ������, � �������� ��������� �����.
*/
Module_Name constant varchar2(30) := 'Subversion';



/* group: ������� */

/* pproc: openConnection
  ���������� � ������������.

  ���������:
  repositoryUrl               - URL ����������� ( �������������� ���������
                                svn, http, file)
  login                       - ����� ��� ������� � �����������
  password                    - ������ ��� ������� � �����������

  ( <body::openConnection>)
*/
procedure openConnection(
  repositoryUrl varchar2
  , login varchar2
  , password varchar2
);

/* pproc: closeConnection
  �������� ���������� � ������������.

  ( <body::closeConnection>)
*/
procedure closeConnection;

/* pproc: getSvnFile
  ��������� ������ �����.

  ���������:
  fileData                    - ������ ����� ( ���� lob null ��
                                ���������������� ��������� lob)
  fileSvnPath                 - ���� � ����� � svn �����������

  ( <body::getSvnFile>)
*/
procedure getSvnFile(
  fileData in out nocopy blob
  , fileSvnPath varchar2
);

/* pfunc: checkAccess
  �������� ������� � ����� � �����������.

  ���������:
  svnPath                     - ���� � svn-�����������

  �������:
  0                           - ���� ������� ���
  1                           - ���� ������ ����

  ( <body::checkAccess>)
*/
function checkAccess(
  svnPath varchar2
)
return integer;

/* pproc: getFileTree
  ��������� ������ ������ � ���������� � �������.

  dirSvnPath                  - ���� � ����� � SVN
  maxRecursiveLevel           - ����������� ������� �������� ( 1 - ������ �����
                                �� ���������� ��������, ��-��������� null ���
                                �����������)
  directoryRecordFlag         - ��������� �� ����������, ��-��������� null ���

  ( <body::getFileTree>)
*/
procedure getFileTree(
  dirSvnPath varchar2
  , maxRecursiveLevel integer := null
  , directoryRecordFlag boolean := null
);

end pkg_Subversion;
/
