create or replace package pkg_SubversionTest is
/* package: pkg_SubversionTest
  ����� ��� ������������ ������.

  SVN root: Oracle/Module/Subversion
*/



/* group: ��������� */

/* const: Test_Login
  ������������ � SVN ��� ������������ ������� � Subversion.
  ���������� ������ ������� �� ������ � <TestDir_SvnPath> � �����������
  <Test_RepositoryUrl>.
*/
Test_Login constant varchar2(10) := 'SvnTest';

/* const: Test_Pasword
  ������ ��� ������������ ������.
*/
Test_Pasword constant varchar2(10) := 'MZiijQ';

/* const: Test_RepositoryUrl
  URL ����������� ��� ������������.
*/
Test_RepositoryUrl constant varchar2(100) := 'svn://srvsvn/Oracle';

/* const: TestDir_SvnPath
  ������������� ���� � ���������� SVN.
*/
TestDir_SvnPath constant varchar2(100) := 'Module/Subversion/Trunk/DB/Test';



/* group: ������� */

/* pproc: openConnection
  �������� ���������� � ������������ � �������� ������������.

  ( <body::openConnection>)
*/
procedure openConnection;

/* pproc: closeConnection
  �������� ���������� � ������������ � �������� ������������.

  ( <body::closeConnection>)
*/
procedure closeConnection;

/* pproc: testGetFile
  ������������ ��������� �����.

  ��������:
  - ������� �������� ����� ����� ���� ������� ������ � �������� ����� �
    ������ ����������� ������; � ������ ���������� ���������, ��� ����
    ���������� �������;

  ( <body::testGetFile>)
*/
procedure testGetFile;

/* pproc: testGetList
  ������������ ��������� ������ ������.

  ��������:
  - ������� �������� ������ ������ � �������� DB/Test ������� ������
    � ������ ���������� ����� "pkg_SubversionTest.pkb" ���������, ��� ����
    ���������� �������;

  ( <body::testGetList>)
*/
procedure testGetList;

end pkg_SubversionTest;
/
