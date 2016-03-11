create or replace package body pkg_SubversionTest is
/* package body: pkg_SubversionTest::body */



/* group: ���������� */

/* ivar: logger
  ����� ������.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => pkg_Subversion.Module_Name
  , objectName  => 'pkg_SubversionTest'
);




/* group: ������� */

/* proc: openConnection
  �������� ���������� � ������������ � �������� ������������.
*/
procedure openConnection
is
-- openConnection
begin
  pkg_Subversion.openConnection(
    repositoryUrl => Test_RepositoryUrl
    , login => Test_Login
    , password => Test_Pasword
  );
end openConnection;

/* proc: closeConnection
  �������� ���������� � ������������ � �������� ������������.
*/
procedure closeConnection
is
-- closeConnection
begin
  pkg_Subversion.closeConnection();
end closeConnection;

/* proc: testGetList
  ������������ ��������� ������ ������.

  ��������:
  - ������� �������� ������ ������ � �������� DB/Test ������� ������
    � ������ ���������� ����� "pkg_SubversionTest.pkb" ���������, ��� ����
    ���������� �������;
*/
procedure testGetList
is
  -- ���� ��������� �����
  successFlag number(1,0) := 0;
-- testGetList
begin
  openConnection();
  pkg_TestUtility.beginTest( 'testGetList');
  pkg_Subversion.getFileTree(
    dirSvnPath => TestDir_SvnPath
    , maxRecursiveLevel => 1
  );
  select
    count(1)
  into
    successFlag
  from
    svn_file_tmp
  where
    file_name = 'pkg_SubversionTest.pkb'
  ;
  if successFlag = 0 then
    pkg_TestUtility.failTest( 'file not found');
  end if;
  pkg_TestUtility.endTest();
  closeConnection();
exception when others then
  closeConnection();
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ������������ ��������� ������ ������'
      )
    , true
  );
end testGetList;

/* proc: testGetFile
  ������������ ��������� �����.

  ��������:
  - ������� �������� ����� ����� ���� ������� ������ � �������� ����� �
    ������ ����������� ������; � ������ ���������� ���������, ��� ����
    ���������� �������;
*/
procedure testGetFile
is
  -- ����� ������
  packageBodyData blob;
  packageBodyText clob;
-- testGetFile
begin
  openConnection();
  pkg_TestUtility.beginTest( 'testGetFile');
  pkg_Subversion.getSvnFile(
    fileData => packageBodyData
    , fileSvnPath => TestDir_SvnPath || '/pkg_SubversionTest.pkb'
  );
  packageBodyText := pkg_TextCreate.convertToClob( packageBodyData);
  if ( instr( coalesce( packageBodyText, ' '), '������� ������') = 0) then
    pkg_TestUtility.failTest( 'the string not found');
  end if;
  pkg_TestUtility.endTest();
  closeConnection();
exception when others then
  closeConnection();
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ������������ ��������� �����'
      )
    , true
  );
end testGetFile;

end pkg_SubversionTest;
/
