create or replace package pkg_FileHandler is
/* package: pkg_FileHandler
  ������������ ����� ������ FileHandler.

  SVN root: Oracle/Module/FileHandler
*/

/* const: Module_Name
  �������� ������ File ��� �������� ������������� � �������
  pkg_FileUtility
*/
Module_Name constant varchar2(30) := 'File';

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

/* pfunc: GetFilePath
  ���������� ���� � �����, �������������� �� ���� ���������� ������
  ( <body::GetFilePath>).
*/
function GetFilePath(
  parent in varchar2
  , child in varchar2
)
return varchar2;
/* pproc: FileList
  ��������� ������ ������ �������� �� ��������� ������� tmp_file_name
  ( <body::FileList>).
*/
procedure FileList(
  fromPath varchar2
  , fileMask varchar2 := null
  , maxCount integer := null
  , useCache boolean := null
);

/* pfunc: SubdirList
  �������� ������ ������������ ��������
  ( <body::SubdirList>).
*/
function SubdirList(
  fromPath varchar2
)
return integer;

/* pproc: FileCopy
  �������� ����
  ( <body::FileCopy>).
*/
procedure FileCopy(
  fromPath varchar2
  , toPath varchar2
  , overwrite integer := 0
  , waitForRequest integer := null
);
/* pproc: FileDelete
  ������� ���� ��� ������ �������
  ( <body::FileDelete>).
*/
procedure FileDelete(
  fromPath varchar2
  , waitForRequest integer := null
);
/* group: �������� ������ */

/* pproc: LoadBlobFromFile
  ��������� ���� � BLOB
  ( <body::LoadBlobFromFile>).
*/
procedure LoadBlobFromFile(
  dstLob in out nocopy blob
  , fromPath varchar2
  , useCache boolean := null
);
/* pproc: LoadClobFromFile
  ��������� ���� � CLOB
  ( <body::LoadClobFromFile>).
*/
procedure LoadClobFromFile(
  dstLob in out nocopy clob
  , fromPath varchar2
  , useCache boolean := null
);
/* pproc: LoadTxt
  ��������� ��������� ���� � ������� doc_input_document
  ( <body::LoadTxt>).
*/
procedure LoadTxt(
  fromPath varchar2
  , byLine integer
  , useCache boolean := null
);
/* group: �������� ������ */

/* pproc: AppendUnloadData
  ��������� ������ ��� �������� ( � ������������)
  ( <body::AppendUnloadData>).
*/
procedure AppendUnloadData(
  str varchar2 := null
);
/* pproc: DeleteUnloadData
  ������� �� ���������� ������� doc_output_document
  ( <body::DeleteUnloadData>).
*/
procedure DeleteUnloadData;
/* pproc: UnloadTxt
  ��������� ��������� ���� �� ������� doc_output_document
  ( <body::UnloadTxt>).
*/
procedure UnloadTxt(
  toPath varchar2
  , writeMode integer := Mode_Write
  , charEncoding varchar2 := null
  , isGzipped integer := null
  , waitForRequest integer := null
);

/* group: ���������� ������ */

/* pfunc: ExecCommand
  ��������� ������� �� �� �������
  ( <body::ExecCommand>).
*/
function ExecCommand(
  command in varchar2
  , output in out nocopy clob
  , error in out nocopy clob
)
return integer;
/* pfunc: ExecCommand( CMD, ERR)
  ��������� ������� �� �� �������
  ( <body::ExecCommand( CMD, ERR)>).
*/
function ExecCommand(
  command in varchar2
  , error in out nocopy clob
)
return integer;
/* pproc: ExecCommand( CMD, OUT)
  ��������� ������� �� �� ������� � ��������� �� ��� ����������
  ( <body::ExecCommand( CMD, OUT)>).
*/
procedure ExecCommand(
  command in varchar2
  , output in out nocopy clob
);
/* pproc: ExecCommand( CMD)
  ��������� ������� �� �� ������� � ��������� �� ��� ����������
  ( <body::ExecCommand( CMD)>).
*/
procedure ExecCommand(
  command in varchar2
);

end pkg_FileHandler;
/