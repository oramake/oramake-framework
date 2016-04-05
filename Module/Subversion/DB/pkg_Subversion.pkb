create or replace package body pkg_Subversion is
/* package body: pkg_Subversion::body */

/* ivar: logger
  ����� ������.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => pkg_Subversion.Module_Name
  , objectName  => 'pkg_Subversion'
);



/* group: ������� */

/* iproc: openConnectionJava
  ���������� � ������������.

  ���������:
  repositoryUrl               - URL ����������� ( �������������� ���������
                                svn, http, file)
  login                       - ����� ��� ������� � �����������
  password                    - ������ ��� ������� � �����������
*/
procedure openConnectionJava(
  repositoryUrl varchar2
  , login varchar2
  , password varchar2
)
is
language java name '
  Subversion.openConnection(
    java.lang.String
    , java.lang.String
    , java.lang.String
  )';

/* iproc: closeConnectionJava
  �������� ���������� � ������������.
*/
procedure closeConnectionJava
is
language java name '
  Subversion.closeConnection()';

/* ifunc: checkAccessJava
  �������� ������� � ����� � �����������.

  ���������:
  svnPath                     - ���� � svn-�����������

  �������:
  0                           - ���� ������� ���
  1                           - ���� ������ ����
*/
function checkAccessJava(
  svnPath varchar2
)
return number
is
language java name
  'Subversion.checkAccess(
     java.lang.String
   ) return java.math.BigDecimal';

/* iproc: getSvnFileJava
  ��������� ������ �����.

  ���������:
  fileData                    - ������ ����� ( ���� lob null ��
                                ���������������� ��������� lob)
  fileSvnPath                 - ���� � ����� � svn �����������
*/
procedure getSvnFileJava(
  fileData in out nocopy blob
  , fileSvnPath varchar2
)
is
language java name '
  Subversion.getSvnFile(
    oracle.sql.BLOB[]
    , java.lang.String
  )';

/* iproc: getFileTreeJava
  ��������� ������ ������ � ���������� � �������.

  dirSvnPath                  - ���� � ����� � SVN
  maxRecursiveLevel           - ����������� ������� �������� ( 1 - ������ �����
                                �� ���������� ��������, ��-��������� null ���
                                �����������)
  directoryRecordFlag         - ��������� �� ����������, ��-��������� null ���
*/
procedure getFileTreeJava(
  dirSvnPath varchar2
  , maxRecursiveLevel number
  , directoryRecordFlag number
)
is
language java name '
  Subversion.getFileTree(
    java.lang.String
    , java.math.BigDecimal
    , java.math.BigDecimal
  )';

/* proc: openConnection
  ���������� � ������������.

  ���������:
  repositoryUrl               - URL ����������� ( �������������� ���������
                                svn, http, file)
  login                       - ����� ��� ������� � �����������
  password                    - ������ ��� ������� � �����������
*/
procedure openConnection(
  repositoryUrl varchar2
  , login varchar2
  , password varchar2
)
is
begin
  openConnectionJava(
    repositoryUrl => repositoryUrl
    , login => login
    , password => password
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ �������� ���������� ('
        || ' repositoryUrl="' || repositoryUrl || '"'
        || ', login="' || login || '"'
        || ')'
      )
    , true
  );
end openConnection;

/* proc: closeConnection
  �������� ���������� � ������������.
*/
procedure closeConnection
is
-- closeConnection
begin
  closeConnectionJava();
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ �������� ���������� � ������������'
      )
    , true
  );
end closeConnection;

/* proc: getSvnFile
  ��������� ������ �����.

  ���������:
  fileData                    - ������ ����� ( ���� lob null ��
                                ���������������� ��������� lob)
  fileSvnPath                 - ���� � ����� � svn �����������
*/
procedure getSvnFile(
  fileData in out nocopy blob
  , fileSvnPath varchar2
)
is
-- getSvnFile
begin
  if fileData is null then
    dbms_lob.createTemporary( fileData, true);
  end if;
  getSvnFileJava(
    fileData => fileData
    , fileSvnPath => fileSvnPath
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� �������� ����� �� svn'
      )
    , true
  );
end getSvnFile;

/* func: checkAccess
  �������� ������� � ����� � �����������.

  ���������:
  svnPath                     - ���� � svn-�����������

  �������:
  0                           - ���� ������� ���
  1                           - ���� ������ ����
*/
function checkAccess(
  svnPath varchar2
)
return integer
is
-- checkAccess
begin
  return checkAccessJava( svnPath => svnPath);
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ �������� ������� � ����� � �����������'
      )
    , true
  );
end checkAccess;

/* proc: getFileTree
  ��������� ������ ������ � ���������� � �������.

  dirSvnPath                  - ���� � ����� � SVN
  maxRecursiveLevel           - ����������� ������� �������� ( 1 - ������ �����
                                �� ���������� ��������, ��-��������� null ���
                                �����������)
  directoryRecordFlag         - ��������� �� ����������, ��-��������� null ���
*/
procedure getFileTree(
  dirSvnPath varchar2
  , maxRecursiveLevel integer := null
  , directoryRecordFlag boolean := null
)
is
begin
  getFileTreeJava(
    dirSvnPath => dirSvnPath
    , maxRecursiveLevel => maxRecursiveLevel
    , directoryRecordFlag =>
      case when
        directoryRecordFlag
      then
        1
      when
        not directoryRecordFlag
      then
        0
      end
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��������� ������ ������ ('
        || ' dirSvnPath="' || dirSvnPath || '"'
        || ')'
      )
    , true
  );
end getFileTree;

end pkg_Subversion;
/
