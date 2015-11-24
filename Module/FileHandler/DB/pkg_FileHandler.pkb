create or replace package body pkg_FileHandler is
/* package body: pkg_FileHandler::body */

/* ivar: logger
  ������������ ������ � ������ Logging
*/
  logger lg_logger_t := lg_logger_t.GetLogger(
    moduleName => pkg_FileHandlerBase.Module_Name
    , objectName => 'pkg_FileHandler'
  );

/* group: ������� */

/* group: �������� �������� */

/* func: GetFilePath
  ���������� ���� � �����, �������������� �� ���� ���������� ������.

  ���������:
  parent                      - ��������� ����� ����
  child                       - �������� ����� ����
*/
function GetFilePath(
  parent in varchar2
  , child in varchar2
)
return varchar2
is
begin
  return pkg_FileOrigin.GetFilePath(
    parent => parent
    , child => child
  );
end GetFilePath;

/* func: FileListInternal
  �������� ������ ������( ������������) �������� �
  �������� ��� � ��������� ������� tmp_file_name.

  ���������:
  fromPath                    - ���� � ��������
  operationCode               - ��������
                                ( <pkg_FileHandlerBase.FileList_OperationCode>
                                  ��� <pkg_FileHandlerBase.DirList_OperationCode>
                                )
  fileMask                    - ����� ��� ������. ������������� ����������
                                ������������� � sql-��������� like escape '\'
  maxCount                    - ������������ ���������� ������ � ������
  useCache                    - ������������ �� ������ ���-����������

  �������:
    - ���������� ��������� ������ ( ������������ )
  ���������:
    - ��� ��������� ���������� � ������������ ������ ���� ����� ������� �� ������
      Java ( ��. <DirJava>);
*/
function FileListInternal(
  operationCode varchar2
  , fromPath varchar2
  , fileMask varchar2 := null
  , maxCount integer := null
  , useCache boolean := null
)
return integer
is
--FileList
                                       -- Id ���������� �������
                                       -- FileHandler
  requestId integer;
begin
  if operationCode not in (
    pkg_FileHandlerBase.FileList_OperationCode
    , pkg_FileHandlerBase.DirList_OperationCode
  )
  then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '�������� �������� operationCode="' || operationCode || '"'
    );
  end if;
                                       -- ������� ������� � ������������
  delete from tmp_file_name;
                                       -- ������ ������
  requestId :=
    pkg_FileHandlerRequest.CreateRequest(
      operationCode => FileListInternal.operationCode
      , fileFullPath => fromPath
      , fileMask => fileMask
      , maxListCount => maxCount
      , useCache => useCache
    );
                                       -- ��� ���������� �������
  pkg_FileHandlerRequest.WaitForRequest(
    requestId => requestId
  );
                                       -- ��������� ��������� �������
                                       -- �������������� �������
  insert into tmp_file_name(
    file_name
    , file_size
    , last_modification
  )
  select
    file_name
    , file_size
    , last_modification
  from
    flh_request_file_list
  where
    request_id = requestId;
  return SQL%ROWCOUNT;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack(
        '������ ��������� ������ ������ FileHandler('
        || ' fromPath="' || fromPath || '"'
        || ').'
      )
    , true
  );
end FileListInternal;

/* proc: FileList
  �������� ������ ������( ������������) �������� �
  �������� ��� � ��������� ������� tmp_file_name.

  ���������:
  fromPath                    - ���� � ��������
  fileMask                    - ����� ��� ������. ������������� ����������
                                ������������� � sql-��������� like escape '\'
  maxCount                    - ������������ ���������� ������ � ������
  useCache                    - ������������ �� ������ ���-����������

  ���������:
    - �������� <FileListInternal>
*/
procedure FileList(
  fromPath varchar2
  , fileMask varchar2 := null
  , maxCount integer := null
  , useCache boolean := null
)
is
begin
  logger.Debug( '���������� ������: ' ||
    to_char(
      FileListInternal(
        operationCode => pkg_FileHandlerBase.FileList_OperationCode
        , fromPath => fromPath
        , fileMask => fileMask
        , maxCount => maxCount
        , useCache => useCache
      )
    )
  );
end FileList;

/* func: SubdirList
  �������� ������ ������������ ��������

  ���������:
  fromPath                    - ���� � ��������

  �������:
  - ����� ������������;

  ���������:
  - �������� <FileListInternal>
*/
function SubdirList(
  fromPath varchar2
)
return integer
is
begin
  return FileListInternal(
    operationCode => pkg_FileHandlerBase.DirList_OperationCode
    , fromPath => fromPath
  );
end SubdirList;

/* proc: FileCopy
  �������� ����.

  ���������:
  fromPath                    - ������ ��� �����-�������� (������� + ���)
  toPath                      - ���� � ���������� (������ ��� ����� ��� ������
                                �������), ���� ������ ������ �������, ����� ���
                                ������ ����� ����� ��������� � ������ ���������
                                �����
  overwrite                   - ���� ���������� ������������� ����� ( ��
                                ��������� �� ������������ � ����������� ������)
  waitForRequest              - ���� "������� �� ��������� �������" ( ��-���������
                                ������� )

  ���������:
  - ��� ��������� ���������� � ������������ ������ ���� ����� ������� �� ������
    Java
*/
procedure FileCopy(
  fromPath varchar2
  , toPath varchar2
  , overwrite integer := 0
  , waitForRequest integer := null
)
is
                                       -- Id ���������� �������
                                       -- FileHandler
  requestId integer;
begin
                                       -- ������ ������
  requestId :=
    pkg_FileHandlerRequest.CreateRequest(
      operationCode => pkg_FileHandlerBase.Copy_OperationCode
      , fileFullPath => fromPath
      , fileDestPath => toPath
      , isOverwrite => overwrite
    );
  if coalesce( waitForRequest, 1 ) = 1  then
                                       -- ��� ���������� �������
    pkg_FileHandlerRequest.WaitForRequest(
      requestId => requestId
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack(
        '������ ����������� ����� FileHandler('
        || ' fromPath="' || fromPath || '"'
        || ', toPath="' || toPath || '"'
        || ', overwrite=' || to_char( overwrite)
        || ').'
      )
    , true
  );
end FileCopy;

/* proc: FileDelete
  ������� ���� ��� ������ �������.

  ���������:
  fromPath                    - ��������� ����
  waitForRequest              - ���� "������� �� ��������� �������" ( ��-���������
                                ������� )
  ���������:
  - ��� ��������� ���������� � ������������ ������ ���� ����� ������� �� ������
    Java
*/
procedure FileDelete(
  fromPath varchar2
  , waitForRequest integer := null
)
is
                                       -- Id ���������� �������
                                       -- FileHandler
  requestId integer;
begin
                                       -- ������ ������
  requestId :=
    pkg_FileHandlerRequest.CreateRequest(
      operationCode => pkg_FileHandlerBase.Delete_OperationCode
      , fileFullPath => fromPath
    );
  if coalesce( waitForRequest, 1 ) = 1  then
                                       -- ��� ���������� �������
    pkg_FileHandlerRequest.WaitForRequest(
      requestId => requestId
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( '������ �������� ����� FileHandler('
        || ' fromPath="' || fromPath || '"'
        || ').'
      )
    , true
  );
end FileDelete;

/* group: �������� ������ */

/* proc: LoadClobFromFile
  ��������� ���� � CLOB.

  ���������:
  dstLob                      - LOB ��� �������� ������ ( �������)
  fromPath                    - ���� � �����

  ���������:
  - ��� ��������� ���������� � ������������ ������ ���� ����� �� ������
    ����� �� ������ Java;
*/
procedure LoadClobFromFile(
  dstLob in out nocopy clob
  , fromPath varchar2
  , useCache boolean := null
)
is
                                       -- Id ���������� �������
                                       -- FileHandler
  requestId integer;
  savedClob clob;
                                       -- ����� ��������� clob
  lobLength integer;
begin
                                       -- ������ ������
  requestId :=
    pkg_FileHandlerRequest.CreateRequest(
      operationCode => pkg_FileHandlerBase.LoadText_OperationCode
      , fileFullPath => fromPath
      , useCache => useCache
    );
                                       -- ��� ���������� �������
  pkg_FileHandlerRequest.WaitForRequest(
    requestId => requestId
  );
                                       -- ���������� ��������� clob
                                       -- � ��������
  select
    t.text_data
  into
    savedClob
  from
    flh_request r
    , flh_text_data t
  where
    t.file_data_id = r.file_data_id
    and r.request_id = requestId;
                                       -- �������� ������
  if dbms_lob.isopen( dstLob ) = 0 then
    dbms_lob.open( dstLob, dbms_lob.lob_readwrite );
  end if;
  lobLength := dbms_lob.getlength( savedClob );
  if lobLength > 0 then
    dbms_lob.copy( dstLob, savedClob, lobLength );
  end if;
  dbms_lob.close( dstLob );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( '������ ���������� ���������� ����� FileHandler('
        || ' fromPath="' || fromPath || '"'
        || ').'
      )
    , true
  );
end LoadClobFromFile;

/* proc: LoadBlobFromFile
  ��������� ���� � BLOB.

  ���������:
  dstLob                      - LOB ��� �������� ������ ( �������)
  fromPath                    - ���� � �����

  ���������:
  - ��� ��������� ���������� � ������������ ������ ���� ����� �� ������
    ����� �� ������ Java;
*/
procedure LoadBlobFromFile(
  dstLob in out nocopy blob
  , fromPath varchar2
  , useCache boolean := null
)
is
                                       -- Id ���������� �������
                                       -- FileHandler
  requestId integer;
                                       -- ���������� � ���� blob
  savedBlob blob;
begin
                                       -- ������ ������
  requestId :=
    pkg_FileHandlerRequest.CreateRequest(
      operationCode => pkg_FileHandlerBase.LoadBinary_OperationCode
      , fileFullPath => fromPath
      , useCache => useCache
    );
                                       -- ��� ���������� �������
  pkg_FileHandlerRequest.WaitForRequest(
    requestId => requestId
  );
                                       -- ���������� ��������� blob
                                       -- � ��������
  select
    d.binary_data
  into
    savedBlob
  from
    flh_request r
    , flh_file_data d
  where
    d.file_data_id = r.file_data_id
    and r.request_id = requestId;
                                       -- �������� ������
  if dbms_lob.isopen( dstLob ) = 0 then
    dbms_lob.open( dstLob, dbms_lob.lob_readwrite );
  end if;
  dbms_lob.copy( dstLob, savedBlob, dbms_lob.getlength( savedBlob ) );
  dbms_lob.close( dstLob );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( '������ ���������� ��������� ����� FileHandler('
        || ' fromPath="' || fromPath || '"'
        || ').'
      )
    , true
  );
end LoadBlobFromFile;

/* proc: LoadTxt
  ��������� ��������� ���� � ������� doc_input_document.

  ���������:
  fromPath                    - ���� � �����
  byLine                      - ���� ���������� �������� ����� ( ��� ������
                                ������ ����� ��������� ������ � �������
                                doc_input_document)

  ���������:
  - ��� ��������� ���������� � ������������ ������ ���� ����� ������� �� ������
    Java ( ��. <LoadClobFromFile>);
  - ���������� �������� �������� ������ �������������������;
*/
procedure LoadTxt(
  fromPath varchar2
  , byLine integer
  , useCache boolean := null
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



--LoadTxt
begin
  begin
    if ByLine = 1 then
                                       -- ��������� LOB ��� ���������� ������
      dbms_lob.CreateTemporary( dataLob, true);
    else
      fullDocID := NewDocument( dataLob);
    end if;
    LoadClobFromFile(                  -- ��������� ������ �� �����
      dataLob
      , FromPath
      , useCache => useCache
    );
                                        --��������� LOB ��� ������
    dbms_lob.open( dataLob, dbms_lob.lob_readwrite);
    readCount := dbms_lob.getLength( dataLob);
    logger.Debug('readcount=' || to_char( readcount) );
                                       -- ��������� ������ ���������
    if ByLine = 1 then
      WriteLines( lineLob, dataLob, readCount, lineOffset);
    end if;
    CloseLOB;
                                       -- ������� ������ � ������ LOB
    if fullDocID is not null and readCount = 0 then
      delete from
        doc_Input_Document
      where
        input_document_id = fullDocID
      ;
    end if;
  exception when others then           -- ��������� LOB � ������ ������
    CloseLOB;
    raise;
  end;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( '������ ������ ����� � doc_input_document'
        || chr(10) || ', FileHandler('
        || ' fromPath="' || fromPath || '"'
        || ' byLine="' || to_char( byLine ) || '"'
        || ').'
      )
    , true
  );
end LoadTxt;

/* group: �������� ������ */

/* proc: AppendUnloadData
  ��������� ������ ��� �������� ( � ������������).

  ���������:
  str                         - ����������� ������

  ���������:
  - ���������� ������ ������ �������� ������ ����������� ������ � ��������
    CLOB;
  - ����� ���������� ���������� ������ ����� ������� ��������� ��� ���������,
    ����� ������� ����� ������ � �������� CLOB;
  - �������� ��������� <pkg_FileOrigin.AppendUnloadData>
*/
procedure AppendUnloadData(
  str varchar2 := null
)
is
begin
  pkg_FileOrigin.AppendUnloadData( str => str );
end AppendUnloadData;

/* proc: DeleteUnloadData
  ������� �� ���������� ������� doc_output_document.

  - �������� ��������� <pkg_FileOrigin.DeleteUnloadData>
*/
procedure DeleteUnloadData
is
begin
   pkg_FileOrigin.DeleteUnloadData;
end DeleteUnloadData;

/* proc: UnloadTxt
  ��������� ��������� ���� �� ������� doc_output_document.

  ���������:
  toPath                      - ���� ��� ������������ �����
  writeMode                   - ����� ������ � ������������ ���� ( Mode_Rewrite
                                ������������, Mode_Append ����������), ��
                                ��������� Mode_Write ( �� ��������������)
  charEncoding                - ��������� ��� �������� ����� ( ��-��������� ������������
                                ��������� ����)
  isGzipped                   - ���� ������ � ������� GZIP
  waitForRequest              - ���� "������� �� ��������� �������" ( ��-���������
                                ������� )

  ���������:
  - ��� ��������� ���������� � ������������ ������ ���� ����� ������� �� ������
    Java ( ��. <UnloadTxtJava>);
*/
procedure UnloadTxt(
  toPath varchar2
  , writeMode integer := Mode_Write
  , charEncoding varchar2 := null
  , isGzipped integer := null
  , waitForRequest integer := null
)
is
                                       -- Id ���������� �������
                                       -- FileHandler
  requestId integer;
                                       -- ��������� ������ ��� ��������
  colText pkg_FileHandlerBase.tabClob := pkg_FileHandlerBase.tabClob();
                                       -- ����� clob
  lobLength integer;
begin
                                       -- ���������� ��� � LOB ( ���� ����)
  AppendUnloadData( null);
                                       -- �������� clob'� � clob'� �������
  for recDocument in
    (
    select
      output_document as output_document
    from
      (
      select
        output_document
      from
        doc_output_document
      order by
        output_document_id
      )
   )
  loop
    colText.extend;
    dbms_lob.createtemporary( colText( colText.last ), true );
    dbms_lob.open( colText( colText.last ), dbms_lob.lob_readwrite );
    lobLength := dbms_lob.getlength( recDocument.output_document );
    if lobLength > 0 then 
      dbms_lob.copy(
        colText( colText.last )
        , recDocument.output_document
        , lobLength
      );
    end if;  
    dbms_lob.close( colText( colText.last ));
  end loop;
                                       -- ������ ������
  requestId :=
    pkg_FileHandlerRequest.CreateRequest(
      operationCode => pkg_FileHandlerBase.UnloadText_OperationCode
      , fileFullPath => toPath
      , writeMode => writeMode
      , charEncoding => charEncoding
      , isGzipped => isGzipped
      , colText => colText
    );
  if coalesce( waitForRequest, 1 ) = 1  then
                                       -- ��� ���������� �������
    pkg_FileHandlerRequest.WaitForRequest(
      requestId => requestId
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( '������ �������� �����, FileHandler('
        || ' toPath="' || toPath || '"'
        || ' writeMode="' || to_char( writeMode ) || '"'
        || ').'
      )
    , true
  );
end UnloadTxt;

/* group: ���������� ������ */

/* func: ExecCommand
  ��������� ������� �� �� �������.

  ���������:
  command                     - ��������� ������ ��� ����������
  output                      - ����� ������� ( stdout, �������)
  error                       - ������ ( stderr, �������)

  �������:
  - ��� ���������� �������.

  ���������:
  - ��� ��������� ���������� � ������������ ������ ���� ����� ������� �� ������
    Java ( ��. <ExecCommandJava>);
*/
function ExecCommand(
  command in varchar2
  , output in out nocopy clob
  , error in out nocopy clob
)
return integer
is
                                       -- ��� ���������� �������
  commandResult integer;
                                       -- Id ���������� �������
                                       -- FileHandler
  requestId integer;
begin
                                       -- ������ ������
  requestId :=
    pkg_FileHandlerRequest.CreateRequest(
      operationCode => pkg_FileHandlerBase.Command_OperationCode
      , commandText => command
    );
                                       -- ��� ���������� �������
  pkg_FileHandlerRequest.WaitForRequest(
    requestId => requestId
    , output => output
    , error => error
    , commandResult => commandResult
  );
  return commandResult;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( '������ ���������� �������, FileHandler('
        || ' command="' || command || '"'
        || ').'
      )
    , true
  );
end ExecCommand;
/* func: ExecCommand( CMD, ERR)
  ��������� ������� �� �� �������.

  ���������:
  command                     - ��������� ������ ��� ����������
  error                       - ������ ( stderr, �������)

  �������:
  - ��� ���������� �������.

  ���������:
  - ��� ��������� ���������� � ������������ ������ ���� ����� ������� �� ������
    Java ( ��. <ExecCommandJava>);
*/
function ExecCommand(
  command in varchar2
  , error in out nocopy clob
)
return integer
is

  output CLOB;

begin
  return ( ExecCommand( command, output, error));
end ExecCommand;
/* proc: ExecCommand( CMD, OUT)
  ��������� ������� �� �� �������.

  ���������:
  command                     - ��������� ������ ��� ����������
  output                      - ����� ������� ( stdout, �������)

  ���������:
  - � ������, ���� ��� ���������� ������� ���������, ������������� ����������
    ( ����� pkg_Error.InvalidExitValue);
  - ��� ��������� ���������� � ������������ ������ ���� ����� ������� �� ������
    Java ( ��. <ExecCommandJava>);
*/
procedure ExecCommand(
  command in varchar2
  , output in out nocopy clob
)
is

  exitCode number;
  error CLOB;

begin
  dbms_lob.createTemporary( error, true, dbms_lob.call);
  exitCode := ExecCommand( command, output, error);
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
end ExecCommand;
/* proc: ExecCommand( CMD)
  ��������� ������� �� �� �������.

  ���������:
  command                     - ��������� ������ ��� ����������

  ���������:
  - � ������, ���� ��� ���������� ������� ���������, ������������� ����������
    ( ����� pkg_Error.InvalidExitValue);
  - ��� ��������� ���������� � ������������ ������ ���� ����� ������� �� ������
    Java ( ��. <ExecCommandJava>);
*/
procedure ExecCommand(
  command in varchar2
)
is
  output CLOB;

begin
  ExecCommand( command, output);
  if output is not null then
    logger.Debug(
      'output="' || to_char( substr( output, 1, 30000 ) ) || '"'
    );
  end if;
end ExecCommand;

end pkg_FileHandler;
/