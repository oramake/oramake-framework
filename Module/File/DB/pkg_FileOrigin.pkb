create or replace package body pkg_FileOrigin is
/* package body: pkg_FileOrigin::body */



/* group: ��������� */

/* iconst: File_Path_Separator
  ������-����������� ��� ��������� ���� ��.
*/
File_Path_Separator constant varchar2(1) := '\';

/* iconst: UnloadDataBuf_Size
  ������ ������ ��� ����������� ������.
*/
UnloadDataBuf_Size constant integer := 32767;

/* iconst: UnloadDataLob_MaxLength
  ������������ ����� ����������� ������, ������������ � ���� CLOB.
*/
UnloadDataLob_MaxLength constant integer := 1000000000;



/* group: ������ ������ ����� � Java-���������� */

/* iconst: WriteModeCode_New
  ����� ������ ����� "�����".
*/
WriteModeCode_New constant varchar2(10) := 'NEW';

/* iconst: WriteModeCode_Rewrite
  ����� ������ ����� "����������".
*/
WriteModeCode_Rewrite constant varchar2(10) := 'REWRITE';

/* iconst: WriteModeCode_Append
  ����� ������ ����� "����������".
*/
WriteModeCode_Append constant varchar2(10) := 'APPEND';



/* group: ���������� */

/* ivar: UnloadDataLob
  CLOB ��� ����������� ������.
*/
UnloadDataLob clob := null;

/* ivar: UnloadDataBuf
  ����� ��� ����������� ������.
*/
UnloadDataBuf varchar2(32767) := null;

/* ivar: UnloadWriteSize
  ����� ��������, ������������ � CLOB �� ���� ���.
*/
UnloadWriteSize integer := null;

/* ivar: UnloadDataLobLength
  ����� ��������, ���������� � CLOB.
*/
UnloadDataLobLength integer;

/* ivar: logger
  ������������ ������ � ������ Logging
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName => Module_Name
  , objectName => 'pkg_FileOrigin'
);



/* group: ������� */



/* group: �������� �������� */

/* func: getFilePath
  ���������� ���� � �����, �������������� �� ���� ���������� ������.

  ���������:
  parent                      - ��������� ����� ����
  child                       - �������� ����� ����
*/
function getFilePath(
  parent in varchar2
  , child in varchar2
)
return varchar2
is

  pathSeparator varchar2(1);  --������-����������� ��������� ����
  path varchar2(2048);        --�������������� ����

begin
  path := parent || child;    --��������� ���� ��� ����������� �����������
  pathSeparator :=            --���������� ������-����������� � ����
    case
      when instr( path, '/') > 0 then '/'
      when instr( path, '\') > 0 then '\'
      else File_Path_Separator
    end;
                              --��������� ���� � ������������
  path := parent || pathSeparator || child;
  return ( path);
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , '������ ��� ������������ ���� � ����� ('
      || ' parent="' || parent || '"'
      || ', child="' || child || '"'
      || ').'
    , true
  );
end getFilePath;

/* ifunc: dirJava
  ��������� ������ ��������� �������� �� ��������� ������� tmp_file_name.
  ������������ ����� ������� ��� ��������������� Java-�������.

  ���������:
  fromPath                    - ���� � ��������
  entryType                   - ��� ������������ ��������� �������� ( 1 �����,
                                2 ��������)
  fileMask                    - ����� ��� ������. ������������� ����������
                                ������������� � sql-��������� like escape '\'
  maxCount                    - ������������ ���������� ������ � ������

  ���������:
  - ��� ��������� ���������� � ������������ ������ ���� ����� �� ������
    ��������, � ����� ���� ��� ���������, �� ������ Java
*/
function dirJava(
  fromPath varchar2
  , entryType number
  , fileMask varchar2
  , maxCount number
)
return number
is
language java name
  'pkg_File.dir(
     java.lang.String
     , java.math.BigDecimal
     , java.lang.String
     , java.math.BigDecimal
   ) return java.math.BigDecimal';

/* proc: fileList
  �������� ������ ������ �������� � �������� ��� � ��������� �������
  tmp_file_name.

  ���������:
  fromPath                    - ���� � ��������
  fileMask                    - ����� ��� ������. ������������� ����������
                                ������������� � sql-��������� like escape '\'
  maxCount                    - ������������ ���������� ������ � ������

  ���������:
  - ��� ��������� ���������� � ������������ ������ ���� ����� ������� �� ������
    Java ( ��. <dirJava>);
*/
procedure fileList(
  fromPath varchar2
  , fileMask varchar2 := null
  , maxCount integer := null
)
is
                                        --����� ��������� ���������
  nFound integer;

--fileList
begin
                                        --������� ������� � ������������
  delete from tmp_file_name;
  nFound := dirJava(
    FromPath
    , 1
    , fileMask
    , maxCount
  );
  logger.Trace('nFound=' || to_char( nFound));
end fileList;

/* func: fileList( EXCEPTION)
  �������� ������ ������ �������� �� ����� � �������� ��� � ��������� �������
  tmp_file_name.

  ���������:
  fromPath                    - ���� � ��������
  riseException               - ���� ��������� ���������� ��� ������
                                ( 0 ������������ ������, 1 �����������
                                ����������, �� ��������� 1)
  fileMask                    - ����� ��� ������. ������������� ����������
                                ������������� � sql-��������� like escape '\'
  maxCount                    - ������������ ���������� ������ � ������

  ������������ ��������:
  1     - ��� �������� ����������
  0     - ��� ������ ( ���� �� ���������� riseException)

  ���������:
  - ��� ��������� ���������� � ������������ ������ ���� ����� ������� �� ������
    Java ( ��. <dirJava>);
*/
function fileList(
  fromPath varchar2
  , fileMask varchar2 := null
  , maxCount integer := null
  , riseException integer := 1
)
return integer
is

                                        --��������� ����������
  isOk integer := 1;

--fileList
begin
  begin
    fileList( FromPath, fileMask, maxCount );
  exception when others then            --����������� ���������� ����
                                        --������������� ��������� ���������
    if RiseException = 1 then
      raise;
    else
      isOk := 0;
    end if;
  end;
  return ( isOk);                       --���������� ��������� ����������
end fileList;

/* func: subdirList
  �������� ������ ������������ �������� � ��������� ��� � ��������� �������
  tmp_file_name.

  ���������:
  fromPath                    - ���� � ��������

  �������:
  - ����� ������������;

  ���������:
  - ��� ��������� ���������� � ������������ ������ ���� ����� ������� �� ������
    Java ( ��. <dirJava>);
*/
function subdirList(
  fromPath varchar2
)
return integer
is

                                        --����� ��������� ���������
  nFound integer;

--subdirList
begin
                                        --������� ������� � ������������
  delete from tmp_file_name;
  nFound := dirJava( FromPath, 2, null, null);
  return ( nFound);
end subdirList;

/* ifunc: checkExistsJava
  ��������� ������������� ����� ��� ��������

  ���������:
  fromPath                    - ���� � ����� ��� ��������

  ���������:
  - ��� ��������� ���������� � ������������ ������ ���� ����� �� ������
    ��������, � ����� ���� ��� ���������, �� ������ Java
*/
function checkExistsJava(
  fromPath varchar2
)
return number
is
language java name
  'pkg_File.exists(
     java.lang.String
   ) return java.math.BigDecimal';

/* func: checkExists
  ��������� ������������� ����� ��� ��������

  ���������:
  fromPath                    - ���� � ����� ��� ��������

  ���������:
  - ��� ��������� ���������� � ������������ ������ ���� ����� ������� �� ������
    Java ( ��. <checkExistsJava>);
*/
function checkExists(
  fromPath varchar2
)
return boolean
is
                                       -- ��������� ������
  nExists integer;
begin
  nExists := checkExistsJava( fromPath => fromPath);
  return
    case when
      nExists = 1
    then
      true
    else
      false
    end;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� �������� ������������� ����� ('
        || ' fromPath="' || fromPath || '"'
        || ').'
      )
    , true
  );
end checkExists;

/* iproc: fileCopyJava
  �������� ����.
  ������������ ����� ������ ��� ��������������� Java-�������.

  ���������:
  fromPath                    - ������ ��� �����-�������� (������� + ���)
  toPath                      - ���� � ���������� (������ ��� ����� ��� ������
                                �������), ���� ������ ������ �������, ����� ���
                                ������ ����� ����� ��������� � ������ ���������
                                �����
  overwrite                   - ���� ���������� ������������� �����
  tempFileDir                 - ������� ��� ��������� ������

  ���������:
  - ��� ��������� ���������� � ������������ ������ ���� ����� �� ������/������
    ��������������� ������ ( ��� ����� ��������� ��������������� ���������),
    �� ������ Java;
*/
procedure fileCopyJava(
  fromPath varchar2
  , toPath varchar2
  , overwrite number
  , tempFileDir varchar2
)
is
language java name 'pkg_File.fileCopy(java.lang.String,java.lang.String,java.math.BigDecimal,java.lang.String)';

/* proc: fileCopy
  �������� ����.

  ���������:
  fromPath                    - ������ ��� �����-�������� (������� + ���)
  toPath                      - ���� � ���������� (������ ��� ����� ��� ������
                                �������), ���� ������ ������ �������, ����� ���
                                ������ ����� ����� ��������� � ������ ���������
                                �����
  overwrite                   - ���� ���������� ������������� �����
                                ( 1 ��������������, 0 �� �������������� �
                                  ����������� ������ ( �� ���������))
*/
procedure fileCopy(
  fromPath varchar2
  , toPath varchar2
  , overwrite integer := null
)
is
begin
  begin
    fileCopyJava(
      fromPath
      , toPath
      , case when overwrite = 1 then 1 else 0 end
      , Temporary_File_Dir
    );
  exception when others then
    if sqlcode = pkg_Error.UncaughtJavaException and
        sqlerrm like '%java.lang.IllegalArgumentException: Destination file'
          || '%already exist'
        then
      raise_application_error(
        pkg_Error.FileAlreadyExists
        , '���� ��� ����������.'
        , true
      );
    else
      raise;
    end if;
  end;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , '������ ��� ����������� ����� ('
      || ' fromPath="' || fromPath || '"'
      || ', toPath="' || toPath || '"'
      || ', overwrite=' || overwrite
      || ').'
    , true
  );
end fileCopy;

/* func: fileCopy( EXCEPTION)
  �������� ����.

  ���������:
  fromPath                    - ������ ��� �����-�������� (������� + ���)
  toPath                      - ���� � ���������� (������ ��� ����� ��� ������
                                �������), ���� ������ ������ �������, ����� ���
                                ������ ����� ����� ��������� � ������ ���������
                                �����
  overwrite                   - ���� ���������� ������������� �����
                                ( 1 ��������������, 0 �� �������������� �
                                  ����������� ������ ( �� ���������))
  riseException               - ���� ��������� ���������� ��� ������
                                ( 0 ������������ ������, 1 �����������
                                ���������� ( �� ���������))

  ������������ ��������:
  1     - ��� �������� ����������
  0     - ��� ������ ( ���� �� ���������� riseException)
*/
function fileCopy(
  fromPath varchar2
  , toPath varchar2
  , overwrite integer := null
  , riseException integer := null
)
return integer
is

  -- ��������� ����������
  isOk integer := 1;

begin
  begin
    fileCopy( fromPath, toPath, overwrite);
  exception when others then
    if riseException = 0 then
      isOk := 0;
    else
      raise;
    end if;
  end;
  return isOk;
end fileCopy;

/* iproc: fileMoveJava
  �������� ����.
  ������������ ����� ������ ��� ��������������� Java-�������.

  ���������:
  fromPath                    - ������ ��� �����-�������� (������� + ���)
  toPath                      - ���� � ���������� (������ ��� ����� ��� ������
                                �������), ���� ������ ������ �������, ����� ���
                                ������ ����� ����� ��������� � ������ ���������
                                �����
  overwrite                   - ���� ���������� ������������� �����
  tempFileDir                 - ������� ��� ��������� ������

  ���������:
  - ��� ��������� ���������� � ������������ ������ ���� ����� �� ������/������
    ��������������� ������ ( ��� ����� ��������� ��������������� ���������),
    �� ������ Java;
*/
procedure fileMoveJava(
  fromPath varchar2
  , toPath varchar2
  , overwrite number
  , tempFileDir varchar2
)
is
language java name 'pkg_File.fileMove(java.lang.String,java.lang.String,java.math.BigDecimal,java.lang.String)';

/* proc: fileMove
  �������� ����.

  ���������:
  fromPath                    - ������ ��� �����-�������� (������� + ���)
  toPath                      - ���� � ���������� (������ ��� ����� ��� ������
                                �������), ���� ������ ������ �������, ����� ���
                                ������ ����� ����� ��������� � ������ ���������
                                �����
  overwrite                   - ���� ���������� ������������� �����
                                ( 1 ��������������, 0 �� �������������� �
                                  ����������� ������ ( �� ���������))
*/
procedure fileMove(
  fromPath varchar2
  , toPath varchar2
  , overwrite integer := null
)
is
begin
  begin
    fileMoveJava(
      fromPath
      , toPath
      , case when overwrite = 1 then 1 else 0 end
      , Temporary_File_Dir
    );
  exception when others then
    if sqlcode = pkg_Error.UncaughtJavaException and
        sqlerrm like '%java.lang.IllegalArgumentException: Destination file'
          || '%already exist'
        then
      raise_application_error(
        pkg_Error.FileAlreadyExists
        , '���� ��� ����������.'
        , true
      );
    else
      raise;
    end if;
  end;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , '������ ��� ����������� ����� ('
      || ' fromPath="' || fromPath || '"'
      || ', toPath="' || toPath || '"'
      || ', overwrite=' || overwrite
      || ').'
    , true
  );
end fileMove;

/* func: fileMove( EXCEPTION)
  �������� ����.

  ���������:
  fromPath                    - ������ ��� �����-�������� (������� + ���)
  toPath                      - ���� � ���������� (������ ��� ����� ��� ������
                                �������), ���� ������ ������ �������, ����� ���
                                ������ ����� ����� ��������� � ������ ���������
                                �����
  overwrite                   - ���� ���������� ������������� �����
                                ( 1 ��������������, 0 �� �������������� �
                                  ����������� ������ ( �� ���������))
  riseException               - ���� ��������� ���������� ��� ������
                                ( 0 ������������ ������, 1 �����������
                                ���������� ( �� ���������))

  ������������ ��������:
  1     - ��� �������� ����������
  0     - ��� ������ ( ���� �� ���������� riseException)
*/
function fileMove(
  fromPath varchar2
  , toPath varchar2
  , overwrite integer := null
  , riseException integer := null
)
return integer
is

  -- ��������� ����������
  isOk integer := 1;

begin
  begin
    fileMove( fromPath, toPath, overwrite);
  exception when others then
    if riseException = 0 then
      isOk := 0;
    else
      raise;
    end if;
  end;
  return isOk;
end fileMove;

/* iproc: fileDeleteJava
  ������� ���� ��� ������ �������.
  ������������ ����� ������ ��� ��������������� Java-�������.

  ���������:
  fromPath                    - ��������� ����

  ���������:
  - ��� ��������� ���������� � ������������ ������ ���� ����� �� ������ �
    �������� ��������� ���������������� �������� ( ��� ��������� ����������
    �����) �� ������ Java;
*/
procedure fileDeleteJava(
  fromPath varchar2
)
is language java name 'pkg_File.fileDelete(java.lang.String)';

/* proc: fileDelete
  ������� ���� ��� ������ �������.

  ���������:
  fromPath                    - ��������� ����

  ���������:
  - ��� ��������� ���������� � ������������ ������ ���� ����� ������� �� ������
    Java ( ��. <fileDeleteJava>);
*/
procedure fileDelete(
  fromPath varchar2
)
is
begin
  fileDeleteJava( fromPath);
exception when others then              --����������� ����� � PL/SQL ������
  if SQLCODE = pkg_Error.UncaughtJavaException and
      SQLERRM like '%java.io.FileNotFoundException:%'
    then
    raise_application_error(
      pkg_Error.FileNotFound
      , '���� �� ������.'
      , true
    );
  else
    raise;
  end if;
end fileDelete;

/* func: fileDelete( EXCEPTION)
  ������� ���� ��� ������ �������.

  ���������:
  fromPath                    - ��������� ����
  riseException               - ���� ��������� ���������� ��� ������
                                ( 0 ������������ ������, 1 �����������
                                ����������, �� ��������� 1)

  ������������ ��������:
  1     - ��� �������� ����������
  0     - ��� ������ ( ���� �� ���������� riseException)

  ���������:
  - ��� ��������� ���������� � ������������ ������ ���� ����� ������� �� ������
    Java ( ��. <fileDeleteJava>);
*/
function fileDelete(
  fromPath varchar2
  , riseException integer := 1
)
return integer
is

                                        --��������� ����������
  isOk integer := 1;

begin
  begin
    fileDelete( FromPath);
  exception when others then            --����������� ���������� ����
                                        --������������� ��������� ���������
    if RiseException = 1 then
      raise;
    else
      isOk := 0;
    end if;
  end;
  return ( isOk);                       --���������� ��������� ����������
end fileDelete;

/* iproc: makeDirectoryJava
  ������ ����������.
  ������������ ����� ������ ��� ��������������� Java-�������.

  ���������:
  dirPath                     - ���� � ����������
  raiseExceptionFlag          - ���� ��������� ���������� � ������
                                ������������� ���������� ��� ����������
                                ������������ ����������
*/
procedure makeDirectoryJava(
  dirPath varchar2
  , raiseExceptionFlag number
)
is language java name
  'pkg_File.makeDirectory(
    java.lang.String
    , java.math.BigDecimal
  )';

/* proc: makeDirectory
  �������� ����������.

  ���������:
  dirPath                     - ���� � ����������
  raiseExceptionFlag          - ���� ��������� ���������� � ������
                                ������������� ���������� ��� ����������
                                ������������ ���������� ( ��-���������, false,
                                �� ���� ��������� ��� ������������� ����������,
                                ���� ��� ��������, � ��� ������������� ������
                                �� ���������)
*/
procedure makeDirectory(
  dirPath varchar2
  , raiseExceptionFlag boolean := null
)
is
-- makeDirectory
begin
  makeDirectoryJava(
    dirPath => dirPath
    , raiseExceptionFlag =>
        case when
          raiseExceptionFlag
        then
          1
        else
          0
        end
  );
  logger.trace( 'makeDirectory: "' || dirPath || '"');
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ �������� ���������� ('
        || 'dirPath="' || dirPath || '"'
        || ', raiseExceptionFlag=' ||
          case when
            raiseExceptionFlag
          then
            'true'
          else
            'false'
          end
        || ')'
      )
    , true
  );
end makeDirectory;



/* group: �������� ������ */

/* iproc: loadBlobFromFileJava
  ��������� ���� � BLOB.
  ������������ ����� ������ ��� ��������������� Java-�������.

  ���������:
  dstLob                      - LOB ��� �������� ������ ( �������)
  fromPath                    - ���� � �����

  ���������:
  - ��� ��������� ���������� � ������������ ������ ���� ����� �� ������
    ����� �� ������ Java;
*/
procedure loadBlobFromFileJava(
  dstLob in out nocopy blob
  , fromPath varchar2
)
is
language java name 'pkg_File.loadBlobFromFile(oracle.sql.BLOB[],java.lang.String)';

/* iproc: loadClobFromFileJava
  ��������� ���� � CLOB.
  ������������ ����� ������ ��� ��������������� Java-�������.

  ���������:
  dstLob                      - LOB ��� �������� ������ ( �������)
  fromPath                    - ���� � �����
  charEncoding                - ��������� ��� �������� ����� ( ��-���������
                                ������������ ��������� ����)

  ���������:
  - ��� ��������� ���������� � ������������ ������ ���� ����� �� ������
    ����� �� ������ Java;
*/
procedure loadClobFromFileJava(
  dstLob in out nocopy clob
  , fromPath varchar2
  , charEncoding varchar2
)
is
language java name '
  pkg_File.loadClobFromFile(
    oracle.sql.CLOB[]
    , java.lang.String
    , java.lang.String
  )';

/* proc: loadBlobFromFile
  ��������� ���� � BLOB.

  ���������:
  dstLob                      - LOB ��� �������� ������ ( �������)
  fromPath                    - ���� � �����

  ���������:
  - ��� �������� null � �������� dstLob, �������� ��������� LOB;
  - ��� ��������� ���������� � ������������ ������ ���� ����� ������� ��
    ������ Java ( ��. <loadBlobFromFileJava>);
*/
procedure loadBlobFromFile(
  dstLob in out nocopy blob
  , fromPath varchar2
)
is
begin
  if dstLob is null then
    dbms_lob.createtemporary( dstLob, true);
  end if;
  loadBlobFromFileJava(
    dstLob => dstLob
    , fromPath => fromPath
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� �������� ����� � BLOB ('
        || ' fromPath="' || fromPath || '"'
        || ').'
      )
    , true
  );
end loadBlobFromFile;

/* proc: loadClobFromFile
  ��������� ���� � CLOB.

  ���������:
  dstLob                      - LOB ��� �������� ������ ( �������)
  fromPath                    - ���� � �����
  charEncoding                - ��������� ��� �������� ����� ( ��-���������
                                ������������ ��������� ����)

  ���������:
  - ��� �������� null � �������� dstLob, �������� ��������� LOB;
  - ��� ��������� ���������� � ������������ ������ ���� ����� ������� ��
    ������ Java ( ��. <loadClobFromFileJava>);
*/
procedure loadClobFromFile(
  dstLob in out nocopy clob
  , fromPath varchar2
  , charEncoding varchar2 := null
)
is
begin
  if dstLob is null then
    dbms_lob.createtemporary( dstLob, true);
  end if;
  loadClobFromFileJava(
    dstLob => dstLob
    , fromPath => fromPath
    , charEncoding => charEncoding
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� �������� ����� � CLOB ('
        || ' fromPath="' || fromPath || '"'
        || ', charEncoding="' || charEncoding || '"'
        || ').'
      )
    , true
  );
end loadClobFromFile;

/* proc: loadTxt
  ��������� ��������� ���� � ������� doc_input_document.

  ���������:
  fromPath                    - ���� � �����
  byLine                      - ���� ���������� �������� ����� ( ��� ������
                                ������ ����� ��������� ������ � �������
                                doc_input_document)

  ���������:
  - ��� ��������� ���������� � ������������ ������ ���� ����� ������� �� ������
    Java ( ��. <loadClobFromFileJava>);
  - ���������� �������� �������� ������ �������������������;
*/
procedure loadTxt(
  fromPath varchar2
  , byLine integer
)
is


  dataLob CLOB;                         --LOB, � ������� ���������� ����������
                                        --ID ��������� � ������ �������� �������
  fullDocID doc_Input_Document.input_document_id%type;

  lineLob CLOB;                         --LOB ��������� ��� ������� ������ ���
                                        --���������� ���������� ������
  lineOffset integer;                   --������� �������� ��� ������ � ������

  readCount number;                     --����� ������� ��������� ������



  function NewDocument( pLob in out nocopy CLOB)
    return doc_Input_Document.input_document_id%type
  is
  --������� ����� �������� (��������� ������) � ������� doc_Input_Document
  --
  --���������:
  --pLob                      - LOB �������� ���������
  --
  --���������� ID ������������ ���������

                                        --ID ������������ ���������
    lDocID doc_Input_Document.input_document_id%type;
  begin
    if pLob is not null then            --��������� ������� LOB
      dbms_lob.close( pLob);
      pLob := null;
    end if;
    insert into doc_Input_Document      --������� ����� ��������
    (
      input_document
    )
    values
    (
      empty_clob()
    )
    returning input_document_id into lDocID;
    select                              --�������� LOB ������ ���������
      input_document
    into pLob
    from
      doc_Input_Document
    where
      input_document_id = lDocID
    ;
                                        --��������� LOB ��� ������
    dbms_lob.open( pLob, dbms_lob.lob_readwrite);
    return lDocID;
  end NewDocument;



  procedure WriteLines( pLineLob in out nocopy CLOB
                      , pSrcLob in out nocopy CLOB
                      , pCopyAmount in integer
                      , pLineOffset in out integer
                      )
  is
  --��������� ��������� ������ � ������� doc_Input_Document
  --
  --���������:
  --pLineLob                  - LOB ������� ������
  --pSrcLob                   - LOB � ������� ��� ������
  --pCopyAmount               - ����� ���������� ������
  --pLineOffset               - �������� ��� ������ � ����� ������� ������

    vSrcOffset integer := 1;            --�������� ��� ���������� ������
    vAmount integer;                    --����� ���������� ������
    endlOffset integer;                 --�������� ������� ����� ������
                                        --ID ��������� ��� ������ �������
                                        --�������� ���������
    lDocID doc_Input_Document.input_document_id%type;

  begin
    while vSrcOffset <= pCopyAmount loop
                                        --���������� �������� ����� ������
      endlOffset := dbms_lob.instr( pSrcLob, chr(10), vSrcOffset);
      if endlOffset > 0 then            --���������� ����� ���������� ������
        vAmount := endlOffset - vSrcOffset + 1;
      else
        vAmount := pCopyAmount - vSrcOffset + 1;
      end if;
      if pLineLob is null then          --������� ����� �������� ��� ������
        lDocID := NewDocument( pLineLob);
        pLineOffset := 1;
      end if;
      dbms_lob.copy(                    --�������� ������
        pLineLob
        , pSrcLob
        , vAmount
        , pLineOffset
        , vSrcOffset
      );
      if endlOffset > 0 then
        dbms_lob.close( pLineLob);      --��������� LOB, ���� ����������� ������
        pLineLob := null;
      else
                                        --������������ �������� � LOB
        pLineOffset := pLineOffset + vAmount;
      end if;
      vSrcOffset := vSrcOffset + vAmount;
    end loop;
  end WriteLines;



  procedure CloseLOB is
  --��������� �������� ���������������� LOB
  begin
    if dataLob is not null then
      if dbms_lob.IsTemporary( dataLob) != 0 then
        dbms_lob.FreeTemporary( dataLob);
      else
        dbms_lob.close( dataLob);
      end if;
      dataLob := null;
    end if;
    if lineLob is not null then
      dbms_lob.close( lineLob);
      lineLob := null;
    end if;
  end CloseLOB;



--loadTxt
begin
  begin
    if ByLine = 1 then
                                        --��������� LOB ��� ���������� ������
      dbms_lob.CreateTemporary( dataLob, true);
    else
      fullDocID := NewDocument( dataLob);
    end if;
    loadClobFromFileJava(             --��������� ������ �� �����
      dataLob
      , FromPath
      , null
    );
    readCount := dbms_lob.getLength( dataLob);
                                      --��������� ������ ���������
    if ByLine = 1 then
      WriteLines( lineLob, dataLob, readCount, lineOffset);
    end if;
    CloseLOB;
                                        --������� ������ � ������ LOB
    if fullDocID is not null and readCount = 0 then
      delete from
        doc_Input_Document
      where
        input_document_id = fullDocID
      ;
    end if;
  exception when others then            --��������� LOB � ������ ������
    CloseLOB;
    raise;
  end;
end loadTxt;

/* func: loadTxt( EXCEPTION)
  ��������� ��������� ���� � ������� doc_input_document.

  ���������:
  fromPath                    - ���� � �����
  byLine                      - ���� ���������� �������� �����
  riseException               - ���� ��������� ���������� ��� ������
                                ( 0 ������������ ������, 1 �����������
                                ����������, �� ��������� 1)

  ������������ ��������:
  1     - ��� �������� ����������
  0     - ��� ������ ( ���� �� ���������� riseException)

  ���������:
  - ��� ��������� ���������� � ������������ ������ ���� ����� ������� �� ������
    Java ( ��. <loadClobFromFileJava>);
  - ���������� �������� �������� ������ �������������������;
*/
function loadTxt(
  fromPath varchar2
  , byLine integer
  , riseException integer := 1
)
return integer
is

                                        --��������� ����������
  isOk integer := 1;
begin
  begin
    loadTxt( FromPath, ByLine);
  exception when others then            --����������� ���������� ����
                                        --������������� ��������� ���������
    if RiseException = 1 then
      raise;
    else
      isOk := 0;
    end if;
  end;
  return ( isOk);                       --���������� ��������� ����������
end loadTxt;



/* group: �������� ������ */

/* ifunc: convertWriteMode
  ����������� ����� writeMode �������� ������ �� ���������� ���
  ��� �������� Java-����������.

  ���������:
  writeMode                   - ����� ������ � ������������ ���� ( <Mode_Rewrite>
                                ������������, <Mode_Append> ����������), ��
                                ��������� <Mode_Write> ( �� ��������������)
*/
function convertWriteMode(
  writeMode number
)
return varchar2
is
-- convertWriteMode
begin
  return
    case when
      writeMode = Mode_Rewrite
    then
      WriteModeCode_Rewrite
    when
      writeMode = Mode_Append
    then
      WriteModeCode_Append
    else
      WriteModeCode_New
    end
  ;
end convertWriteMode;

/* iproc: unloadBlobToFileJava
  ��������� �������� ������ � ����.

  ���������:
  binaryData                  - ������ ��� ��������
  toPath                      - ���� ��� ������������ �����
  writeModeCode               - ����� ������ � ������������ ����
  isGzipped                   - ���� ������ � ������� GZIP

  ���������:
  - ��� ��������� ���������� � ������������ ������ ���� ����� �� ������/������
    ����� ( ��� ���� ��������� ��������) �� ������ Java;
*/
procedure unloadBlobToFileJava(
  binaryData in blob
  , toPath varchar2
  , writeModeCode varchar2
  , isGzipped number
)
is
language java name
  'pkg_File.unloadBlobToFile(
     oracle.sql.BLOB
     , java.lang.String
     , java.lang.String
     , java.math.BigDecimal
   )';

 /* proc: unloadBlobToFile
  ��������� �������� ������ � ����.

  ���������:
  binaryData                  - ������ ��� ��������
  toPath                      - ���� ��� ������������ �����
  writeMode                   - ����� ������ � ������������ ���� ( <Mode_Rewrite>
                                ������������, <Mode_Append> ����������), ��
                                ��������� <Mode_Write> ( �� ��������������)
  isGzipped                   - ���� ������ � ������� GZIP

  ���������:
  - ��� ��������� ���������� � ������������ ������ ���� ����� �� ������/������
    ����� ( ��� ���� ��������� ��������) �� ������ Java;
*/
procedure unloadBlobToFile(
  binaryData in blob
  , toPath varchar2
  , writeMode number := null
  , isGzipped number := null
)
is
begin
  unloadBlobToFileJava(
    binaryData => binaryData
    , toPath => toPath
    , writeModeCode => convertWriteMode( writeMode)
    , isGzipped => isGzipped
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ �������� �������� ������ � ���� ('
        || ' toPath="' || toPath || '"'
        || ', writeMode=' || to_char( writeMode)
        || ', isGzipped=' || to_char( isGzipped)
        || ').'
      )
    , true
  );
end unloadBlobToFile;

/* iproc: unloadClobToFileJava
  ��������� ��������� ������ � ����.

  ���������:
  fileText                    - ������ ��� ��������
  toPath                      - ���� ��� ������������ �����
  writeModeCod                - ����� ������ � ������������ ����
  charEncoding                - ��������� ��� �������� �����
                                ( ��-��������� ������������ ��������� ����)
  isGzipped                   - ���� ������ � ������� GZIP

  ���������:
  - ��� ��������� ���������� � ������������ ������ ���� ����� �� ������/������
    ����� ( ��� ���� ��������� ��������) �� ������ Java;
*/
procedure unloadClobToFileJava(
  fileText in clob
  , toPath varchar2
  , writeModeCode varchar2
  , charEncoding varchar2
  , isGzipped number
)
is
language java name
  'pkg_File.unloadClobToFile(
     oracle.sql.CLOB
     , java.lang.String
     , java.lang.String
     , java.lang.String
     , java.math.BigDecimal
   )';

/* proc: unloadClobToFile
  ��������� ��������� ������ � ����.

  ���������:
  fileText                    - ������ ��� ��������
  toPath                      - ���� ��� ������������ �����
  writeMode                   - ����� ������ � ������������ ���� ( <Mode_Rewrite>
                                ������������, <Mode_Append> ����������), ��
                                ��������� <Mode_Write> ( �� ��������������)
  charEncoding                - ��������� ��� �������� �����
                                ( ��-��������� ������������ ��������� ����)
  isGzipped                   - ���� ������ � ������� GZIP

  ���������:
  - ��� ��������� ���������� � ������������ ������ ���� ����� �� ������/������
    ����� ( ��� ���� ��������� ��������) �� ������ Java;
*/
procedure unloadClobToFile(
  fileText in clob
  , toPath varchar2
  , writeMode number := null
  , charEncoding varchar2 := null
  , isGzipped number := null
)
is
begin
  unloadClobToFileJava(
    fileText => fileText
    , toPath => toPath
    , writeModeCode => convertWriteMode( writeMode)
    , charEncoding => charEncoding
    , isGzipped => isGzipped
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ �������� ��������� ������ � ���� ('
        || ' toPath="' || toPath || '"'
        || ', writeMode=' || to_char( writeMode)
        || ', charEncoding="' || charEncoding || '"'
        || ', isGzipped=' || to_char( isGzipped)
        || ').'
      )
    , true
  );
end unloadClobToFile;

/* proc: appendUnloadData
  ��������� ������ ��� �������� ( � ������������).

  ���������:
  str                         - ����������� ������

  ���������:
  - ���������� ������ ������ �������� ������ ����������� ������ � ��������
    CLOB;
  - ����� ���������� ���������� ������ ����� ������� ��������� ��� ���������,
    ����� ������� ����� ������ � �������� CLOB;
*/
procedure appendUnloadData(
  str varchar2 := null
)
is

  len integer := nvl( length( str), 0);
  bufLen integer := nvl( length( unloadDataBuf), 0);
  addLen integer;



  procedure OpenLob is
  --������� LOB ��� ����������� ������.

                                        --ID ���������� ���������
    docID doc_output_document.output_document_id%type;

  --OpenLob
  begin
    insert into doc_output_document     --������� ����� ��������
    (
      output_document
    )
    values
    (
      empty_clob()
    )
    returning output_document_id into docID;
    select                              --�������� LOB ������ ���������
      output_document
    into unloadDataLob
    from
      doc_output_document
    where
      output_document_id = docID
    ;
                                        --��������� LOB ��� ������
    dbms_lob.open( unloadDataLob, dbms_lob.lob_readwrite);
                                        --���������� ����������� ������
                                        --��� ������ � LOB
    unloadWriteSize := UnloadDataBuf_Size
      - mod( UnloadDataBuf_Size, dbms_lob.getChunkSize( unloadDataLob));
    unloadDataLobLength := 0;
  end OpenLob;



  procedure CloseLob is
  --��������� LOB.
  begin
    dbms_lob.close( unloadDataLob);
    unloadDataLob := null;
    unloadDataLobLength := null;
  end CloseLob;



--appendUnloadData
begin
  if len > 0 or bufLen > 0 then
                                        --��������� LOB, ���� �����������
                                        --����������� �� ������������ �����
    if unloadDataLobLength > 0
        and unloadDataLobLength + coalesce( len, 0) + coalesce( bufLen, 0)
         > UnloadDataLob_MaxLength
        then
      CloseLob;
    end if;
                                        --��������� LOB, ���� ��� ��� ���
    if unloadDataLob is null then
      OpenLob;
    end if;
    if len > 0 and bufLen + len < unloadWriteSize then
                                        --��������� ������ � �����
      unloadDataBuf := unloadDataBuf || str;
    else
                                        --��������� � LOB ���������� ������
      addLen := least( unloadWriteSize - bufLen, len);
      if addLen > 0 then
        unloadDataBuf := unloadDataBuf || substr( str, 1, addLen);
        bufLen := bufLen + addLen;
      end if;
      dbms_lob.writeAppend(
        unloadDataLob
        , bufLen
        , unloadDataBuf
      );
      unloadDataBuf := substr( str, 1 + addLen);
      unloadDataLobLength := unloadDataLobLength + bufLen;
    end if;
  end if;
                                        --��������� LOB ���� ����� � null
  if str is null and unloadDataLob is not null then
    CloseLob;
  end if;
end appendUnloadData;

/* proc: deleteUnloadData
  ������� �� ���������� ������� doc_output_document.
*/
procedure deleteUnloadData
is
begin
  UnloadDataLob := null;
  delete from doc_output_document;
end deleteUnloadData;

/* iproc: unloadTxtJava
  ��������� ��������� ���� �� ������� doc_output_document.
  ������������ ����� ������ ��� ��������������� Java-�������.

  ���������:
  toPath                      - ���� ��� ������������ �����
  writeModeCode               - ����� ������ � ������������ ����
  charEncoding                - ��������� ��� �������� ����� ( ��-��������� ������������
                                ��������� ����)
  izGzipped                   - ������� �� � ������� GZIP (1-��,0-���)

  ���������:
  - ��� ��������� ���������� � ������������ ������ ���� ����� �� ������/������
    ����� ( ��� ���� ��������� ��������) �� ������ Java;
*/
procedure unloadTxtJava(
  toPath varchar2
  , writeModeCode varchar2
  , charEncoding varchar2
  , isGzipped number
)
is
language java name
  'pkg_File.unloadTxt(
     java.lang.String
     , java.lang.String
     , java.lang.String
     , java.math.BigDecimal
   )';

/* proc: unloadTxt
  ��������� ��������� ���� �� ������� doc_output_document.

  ���������:
  toPath                      - ���� ��� ������������ �����
  writeMode                   - ����� ������ � ������������ ���� ( <Mode_Rewrite>
                                ������������, <Mode_Append> ����������), ��
                                ��������� <Mode_Write> ( �� ��������������)
  charEncoding                - ��������� ��� �������� �����
                                ( ��-��������� ������������ ��������� ����)
  isGzipped                   - ���� ������ � ������� GZIP

  ���������:
  - ��� ��������� ���������� � ������������ ������ ���� ����� ������� �� ������
    Java ( ��. <unloadTxtJava>);
*/
procedure unloadTxt(
  toPath varchar2
  , writeMode integer := Mode_Write
  , charEncoding varchar2 := null
  , isGzipped integer := null
)
is

begin
                                        --���������� ��� � LOB ( ���� ����)
  appendUnloadData( null);
                                        --��������� ����
  unloadTxtJava(
    ToPath
    , convertWriteMode( writeMode)
    , charEncoding
    , isGzipped
  );
end unloadTxt;



/* group: ���������� ������ */

/* ifunc: execCommandJava
  ��������� ������� �� �� �������.
  ������������ ����� ������ ��� ��������������� Java-�������.

  ���������:
  command                     - ��������� ������ ��� ����������
  output                      - ����� ������� ( stdout, �������)
  error                       - ������ ( stderr, �������)

  �������:
  - ��� ���������� �������.

  ���������:
  - ��� ��������� ���������� � ������������ ������ ���� ����� �� ����������
    ��������� ( ��� �����) �������, � ����� ����� �� ������ � ������
    ������������ ������ �� ������ Java;
*/
function execCommandJava(
  command in varchar2
  , output in out nocopy clob
  , error in out nocopy clob
)
return number
is
language java name 'pkg_File.execCommand(java.lang.String,oracle.sql.CLOB[],oracle.sql.CLOB[]) return java.math.BigDecimal';

/* func: execCommand
  ��������� ������� �� �� �������.

  ���������:
  command                     - ��������� ������ ��� ����������
  output                      - ����� ������� ( stdout, �������)
  error                       - ������ ( stderr, �������)

  �������:
  - ��� ���������� �������.

  ���������:
  - ��� ��������� ���������� � ������������ ������ ���� ����� ������� �� ������
    Java ( ��. <execCommandJava>);
*/
function execCommand(
  command in varchar2
  , output in out nocopy clob
  , error in out nocopy clob
)
return integer
is

begin
  return ( execCommandJava( command, output, error));
end execCommand;

/* func: execCommand( CMD, ERR)
  ��������� ������� �� �� �������.

  ���������:
  command                     - ��������� ������ ��� ����������
  error                       - ������ ( stderr, �������)

  �������:
  - ��� ���������� �������.

  ���������:
  - ��� ��������� ���������� � ������������ ������ ���� ����� ������� �� ������
    Java ( ��. <execCommandJava>);
*/
function execCommand(
  command in varchar2
  , error in out nocopy clob
)
return integer
is

  output CLOB;

begin
  dbms_lob.createTemporary( output, true, dbms_lob.call);
  return ( execCommand( command, output, error));
end execCommand;

/* proc: execCommand( CMD, OUT)
  ��������� ������� �� �� �������.

  ���������:
  command                     - ��������� ������ ��� ����������
  output                      - ����� ������� ( stdout, �������)

  ���������:
  - � ������, ���� ��� ���������� ������� ���������, ������������� ����������
    ( ����� pkg_Error.InvalidExitValue);
  - ��� ��������� ���������� � ������������ ������ ���� ����� ������� �� ������
    Java ( ��. <execCommandJava>);
*/
procedure execCommand(
  command in varchar2
  , output in out nocopy clob
)
is

  exitCode number;
  error CLOB;

begin
  dbms_lob.createTemporary( error, true, dbms_lob.call);
  exitCode := execCommandJava( command, output, error);
  if nvl( exitCode, -1) != 0 then
    raise_application_error(
      pkg_Error.InvalidExitValue
      , substr(
        '���������� ������� ����������� � ������� (��� ' || exitCode || ').'
        || chr(10) || chr(10)
        || dbms_lob.substr( error, 4000)
        , 1, 4000)
    );
  end if;
end execCommand;

/* proc: execCommand( CMD)
  ��������� ������� �� �� �������.

  ���������:
  command                     - ��������� ������ ��� ����������

  ���������:
  - � ������, ���� ��� ���������� ������� ���������, ������������� ����������
    ( ����� pkg_Error.InvalidExitValue);
  - ��� ��������� ���������� � ������������ ������ ���� ����� ������� �� ������
    Java ( ��. <execCommandJava>);
*/
procedure execCommand(
  command in varchar2
)
is
  output CLOB;

begin
  dbms_lob.createTemporary( output, true, dbms_lob.call);
  execCommand( command, output);
end execCommand;

end pkg_FileOrigin;
/
