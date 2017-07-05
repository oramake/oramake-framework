create or replace package pkg_FileOrigin is
/* package: pkg_FileOrigin
  ������������ ����� ������ File
*/



/* group: ��������� */

/* const: Module_Name
  �������� ������, � �������� ��������� �����.
*/
Module_Name constant varchar2(30) := 'File';

/* const: Temporary_File_Dir
  ������� ��� ��������� ������ �� �������.
*/
Temporary_File_Dir constant varchar2(255) := 'C:\TEMP';



/* group: ������ �������� ����� */

/* const: Mode_Read
  ����� ������.
*/
Mode_Read constant integer := 0;

/* const: Mode_Append
  ����� ����������.
*/
Mode_Append constant integer := 1;

/* const: Mode_Write
  ����� ������.
*/
Mode_Write constant integer := 2;

/* const: Mode_Rewrite
  ����� ����������.
*/
Mode_Rewrite constant integer := 3;

/* group: ��������� */

/* const: Encoding_Utf8
  ��������� "UTF8"
*/
Encoding_Utf8 constant varchar2( 10 ) := 'UTF-8';

/* const: Encoding_Utf8Bom
  ��������� "UTF8" � �������� BOM.
*/
Encoding_Utf8Bom constant varchar2( 10 ) := 'UTF-8-BOM';

/* const: Encoding_Unicode
  ��������� "Encoding_Unicode"
*/
Encoding_Unicode constant varchar2( 10 ) := 'Unicode';

/* const: Encoding_Cp866
  ��������� "Encoding_Cp866"
*/
Encoding_Cp866 constant varchar2( 10 ) := 'Cp866';



/* group: ������� */



/* group: �������� �������� */

/* pfunc: getFilePath
  ���������� ���� � �����, �������������� �� ���� ���������� ������.

  ���������:
  parent                      - ��������� ����� ����
  child                       - �������� ����� ����

  ( <body::getFilePath>)
*/
function getFilePath(
  parent in varchar2
  , child in varchar2
)
return varchar2;

/* pproc: fileList
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

  ( <body::fileList>)
*/
procedure fileList(
  fromPath varchar2
  , fileMask varchar2 := null
  , maxCount integer := null
);

/* pfunc: fileList( EXCEPTION)
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

  ( <body::fileList( EXCEPTION)>)
*/
function fileList(
  fromPath varchar2
  , fileMask varchar2 := null
  , maxCount integer := null
  , riseException integer := 1
)
return integer;

/* pfunc: subdirList
  �������� ������ ������������ �������� � ��������� ��� � ��������� �������
  tmp_file_name.

  ���������:
  fromPath                    - ���� � ��������

  �������:
  - ����� ������������;

  ���������:
  - ��� ��������� ���������� � ������������ ������ ���� ����� ������� �� ������
    Java ( ��. <dirJava>);

  ( <body::subdirList>)
*/
function subdirList(
  fromPath varchar2
)
return integer;

/* pfunc: checkExists
  ��������� ������������� ����� ��� ��������

  ���������:
  fromPath                    - ���� � ����� ��� ��������

  ���������:
  - ��� ��������� ���������� � ������������ ������ ���� ����� ������� �� ������
    Java ( ��. <checkExistsJava>);

  ( <body::checkExists>)
*/
function checkExists(
  fromPath varchar2
)
return boolean;

/* pproc: fileCopy
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

  ( <body::fileCopy>)
*/
procedure fileCopy(
  fromPath varchar2
  , toPath varchar2
  , overwrite integer := null
);

/* pfunc: fileCopy( EXCEPTION)
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

  ( <body::fileCopy( EXCEPTION)>)
*/
function fileCopy(
  fromPath varchar2
  , toPath varchar2
  , overwrite integer := null
  , riseException integer := null
)
return integer;

/* pproc: fileMove
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

  ( <body::fileMove>)
*/
procedure fileMove(
  fromPath varchar2
  , toPath varchar2
  , overwrite integer := null
);

/* pfunc: fileMove( EXCEPTION)
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

  ( <body::fileMove( EXCEPTION)>)
*/
function fileMove(
  fromPath varchar2
  , toPath varchar2
  , overwrite integer := null
  , riseException integer := null
)
return integer;

/* pproc: fileDelete
  ������� ���� ��� ������ �������.

  ���������:
  fromPath                    - ��������� ����

  ���������:
  - ��� ��������� ���������� � ������������ ������ ���� ����� ������� �� ������
    Java ( ��. <fileDeleteJava>);

  ( <body::fileDelete>)
*/
procedure fileDelete(
  fromPath varchar2
);

/* pfunc: fileDelete( EXCEPTION)
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

  ( <body::fileDelete( EXCEPTION)>)
*/
function fileDelete(
  fromPath varchar2
  , riseException integer := 1
)
return integer;

/* pproc: makeDirectory
  �������� ����������.

  ���������:
  dirPath                     - ���� � ����������
  raiseExceptionFlag          - ���� ��������� ���������� � ������
                                ������������� ���������� ��� ����������
                                ������������ ���������� ( ��-���������, false,
                                �� ���� ��������� ��� ������������� ����������,
                                ���� ��� ��������, � ��� ������������� ������
                                �� ���������)

  ( <body::makeDirectory>)
*/
procedure makeDirectory(
  dirPath varchar2
  , raiseExceptionFlag boolean := null
);



/* group: �������� ������ */

/* pproc: loadBlobFromFile
  ��������� ���� � BLOB.

  ���������:
  dstLob                      - LOB ��� �������� ������ ( �������)
  fromPath                    - ���� � �����

  ���������:
  - ��� �������� null � �������� dstLob, �������� ��������� LOB;
  - ��� ��������� ���������� � ������������ ������ ���� ����� ������� ��
    ������ Java ( ��. <loadBlobFromFileJava>);

  ( <body::loadBlobFromFile>)
*/
procedure loadBlobFromFile(
  dstLob in out nocopy blob
  , fromPath varchar2
);

/* pproc: loadClobFromFile
  ��������� ���� � CLOB.

  ���������:
  dstLob                      - LOB ��� �������� ������ ( �������)
  fromPath                    - ���� � �����
  charEncoding                - ��������� ��� �������� �����
                                ( ��-��������� ������������ ��������� ����)

  ���������:
  - ��� �������� null � �������� dstLob, �������� ��������� LOB;
  - ��� ��������� ���������� � ������������ ������ ���� ����� ������� ��
    ������ Java ( ��. <loadClobFromFileJava>);

  ( <body::loadClobFromFile>)
*/
procedure loadClobFromFile(
  dstLob          in out nocopy clob
, fromPath        varchar2
, charEncoding    varchar2
);

/* pproc: loadTxt
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

  ( <body::loadTxt>)
*/
procedure loadTxt(
  fromPath varchar2
  , byLine integer
);

/* pfunc: loadTxt( EXCEPTION)
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

  ( <body::loadTxt( EXCEPTION)>)
*/
function loadTxt(
  fromPath varchar2
  , byLine integer
  , riseException integer := 1
)
return integer;



/* group: �������� ������ */

 /* pproc: unloadBlobToFile
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

  ( <body::unloadBlobToFile>)
*/
procedure unloadBlobToFile(
  binaryData in blob
  , toPath varchar2
  , writeMode number := null
  , isGzipped number := null
);

/* pproc: unloadClobToFile
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

  ( <body::unloadClobToFile>)
*/
procedure unloadClobToFile(
  fileText      in clob
, toPath        varchar2
, writeMode     number := null
, charEncoding  varchar2 := null
, isGzipped     number := null
);

/* pproc: appendUnloadData
  ��������� ������ ��� �������� ( � ������������).

  ���������:
  str                         - ����������� ������

  ���������:
  - ���������� ������ ������ �������� ������ ����������� ������ � ��������
    CLOB;
  - ����� ���������� ���������� ������ ����� ������� ��������� ��� ���������,
    ����� ������� ����� ������ � �������� CLOB;

  ( <body::appendUnloadData>)
*/
procedure appendUnloadData(
  str varchar2 := null
);

/* pproc: deleteUnloadData
  ������� �� ���������� ������� doc_output_document.

  ( <body::deleteUnloadData>)
*/
procedure deleteUnloadData;

/* pproc: unloadTxt
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

  ( <body::unloadTxt>)
*/
procedure unloadTxt(
  toPath        varchar2
, writeMode     integer := Mode_Write
, charEncoding  varchar2 := null
, isGzipped     integer := null
);



/* group: ���������� ������ */

/* pfunc: execCommand
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

  ( <body::execCommand>)
*/
function execCommand(
  command in varchar2
  , output in out nocopy clob
  , error in out nocopy clob
)
return integer;

/* pfunc: execCommand( CMD, ERR)
  ��������� ������� �� �� �������.

  ���������:
  command                     - ��������� ������ ��� ����������
  error                       - ������ ( stderr, �������)

  �������:
  - ��� ���������� �������.

  ���������:
  - ��� ��������� ���������� � ������������ ������ ���� ����� ������� �� ������
    Java ( ��. <execCommandJava>);

  ( <body::execCommand( CMD, ERR)>)
*/
function execCommand(
  command in varchar2
  , error in out nocopy clob
)
return integer;

/* pproc: execCommand( CMD, OUT)
  ��������� ������� �� �� �������.

  ���������:
  command                     - ��������� ������ ��� ����������
  output                      - ����� ������� ( stdout, �������)

  ���������:
  - � ������, ���� ��� ���������� ������� ���������, ������������� ����������
    ( ����� pkg_Error.InvalidExitValue);
  - ��� ��������� ���������� � ������������ ������ ���� ����� ������� �� ������
    Java ( ��. <execCommandJava>);

  ( <body::execCommand( CMD, OUT)>)
*/
procedure execCommand(
  command in varchar2
  , output in out nocopy clob
);

/* pproc: execCommand( CMD)
  ��������� ������� �� �� �������.

  ���������:
  command                     - ��������� ������ ��� ����������

  ���������:
  - � ������, ���� ��� ���������� ������� ���������, ������������� ����������
    ( ����� pkg_Error.InvalidExitValue);
  - ��� ��������� ���������� � ������������ ������ ���� ����� ������� �� ������
    Java ( ��. <execCommandJava>);

  ( <body::execCommand( CMD)>)
*/
procedure execCommand(
  command in varchar2
);

end pkg_FileOrigin;
/
