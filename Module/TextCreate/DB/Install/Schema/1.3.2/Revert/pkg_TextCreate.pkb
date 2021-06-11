create or replace package body pkg_TextCreate is
/* package body: pkg_TextCreate::body */

/* iconst: Max_Varchar2_Length
  ������������ ������ ������ � Oracle
*/
  Max_Varchar2_Length integer := 32767;

/* ivar: buffer
  ��������� ����� ��� ����������
  � clob, ������������ ������ ��������
  ��������� <maxBufferLength>
*/
  buffer varchar2( 32767);

/* ivar: destinationClob
  ����������� clob. ���������������� � <newText>
*/
  destinationClob clob;

/* ivar: maxBufferLength
  ����������� ������� ���������� ������
  ��� ����������� ���������� � clob
*/
  maxBufferLength integer;

/* ivar: currentClobLength
  ������� ����� destinationClob.
  ���������� ������������ ��� �����������.
*/
  currentClobLength integer;


/* ivar: logger
  ������ ��� �����������
*/
  logger lg_logger_t := lg_logger_t.GetLogger(
    moduleName => Module_Name
    , objectName => 'pkg_TextCreate'
  );



/* group: ������� */



/* group: ������������ ��������� ������ */

/* proc: newText
  �������������� ����� ����� ��� ������������

  �����������:
    - ���������� dbms_lob.createtemporary
      ��� ������������� clob
    - ��������� clob �� ������
    - �������������� ���������� <currentClobLength>,
      <maxBufferLength>
    - ������� <buffer>
*/
procedure newText
is
begin
  if destinationClob is not null then
    logger.Debug( 'destinationClob.is_open=' ||
      to_char( dbms_lob.isopen( destinationClob))
    );
    -- ������������� ������� ��������� lob, �.�. Oracle
    -- ��� �� ������� � ��� ��������� ������ ������������
    -- ����������� lob'�� ����� �� ����������, ������ �����
    -- ����������� ����� ��������� lob
    destinationClob := null;
  end if;
  dbms_lob.createtemporary( destinationClob, true);

  -- ��������� clob ��� ������
  dbms_lob.open( destinationClob, dbms_lob.lob_readwrite);
  currentClobLength := 0;
  buffer := null;

  -- ��� ����������� ������������ ������ ������ ���� �� ������
  -- dbms_lob.getChunkSize
  maxBufferLength :=
    Max_Varchar2_Length
    - mod( Max_Varchar2_Length, dbms_lob.getChunkSize( destinationClob));
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack(
        '������ ������������� ������ ��� ������������ ('
        || 'currentClobLength=' || to_char( currentClobLength)
        || ', currentBufferSize=' || to_char( coalesce( length( buffer), 0))
        || ')'
      )
    , true
  );
end newText;

/* proc: append ( str )
  ���������� ������ � �����

  ���������:
    str - ������, ��� null ���������� ���������� ������

  ���������:
    - ���� �� ������ ���������� �� ��� ������ <NewText>, �� ����
      ����� �� ��� ������������������ �����, �� ������������
      ����������
*/
procedure append(
  str varchar2
)
is
begin
  if destinationClob is null then
    raise_application_error(
      pkg_Error.ProcessError
      , logger.ErrorStack(
         '����� �� ������������������. ������� ������� ������� NewText'
        )
    );
  end if;
  Append(
    destClob => destinationClob
    , clobLength => currentClobLength
    , stringBuffer => buffer
    , maxBufferSize => maxBufferLength
    , str => str
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack(
        '������ ���������� ������ ('
        || 'str="'
        ||
           case when length( str) <= 1000 then
             str || '"'
           else
             substr( str, 1, 1000-3) || '"' || '...'
           end
        || ')'
      )
    , true
  );
end Append;

/* proc: append ( clob )
   ���������� clob � �����

   ���������:
     �                         - ��������� ���������� � ���� clob

   ���������:
    - ���� �� ������ ���������� �� ��� ������ <newText>, �� ����
      ����� �� ��� ������������������ �����, �� ������������
      ����������
*/
procedure append (
  c in clob
  )
is
-- append
begin
  if destinationClob is null then
    raise_application_error(
        pkg_Error.ProcessError
      , logger.ErrorStack(
         '����� �� ������������������. ������� ������� ������� newText()'
        )
      );
  end if;
  append( '' );
  dbms_lob.append(
      dest_lob => destinationClob
    , src_lob  => c
    );

exception
  when others then
    raise_application_error(
        pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ���������� clob'
          )
      , true
      );

end append;

/* func: getClob
  �������� �������������� ����� � ���� clob

  ���������:
    filename                 - �������� ����� ������ ������

  �������:
    - <destinationClob>

  ���������:
    - ���������� ����� � <destinationClob> � ������� append('')
    - ��������� <destinationClob>,
      �������������� ��������, ������ �� ��
*/
function getClob
return clob
is
begin
  Append( '');
  if dbms_lob.isopen( destinationClob ) = 1 then
    dbms_lob.close( destinationClob);
  end if;
  return
    destinationClob;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack(
        '������ ��������� clob ('
        || 'currentClobLength=' || to_char( currentClobLength)
        || ', maxBufferLength=' || to_char( maxBufferLength)
        || ', buffer.length=' || to_char( length( buffer),0)
        || ')'
      )
    , true
  );
end getClob;

/* proc: append ( destClob )
  ���������� ������ � �����
  c �������������� ����������� ���������� ��������

  ���������:
    destClob                 - clob ��� ������������
    clobLength               - ������� ������ clob. ��������� ���
                               �����������
    stringBuffer             - ��������� �����
    maxBufferSize            - ������������ ������ ������
    str                      - ������ ��� ����������,
                               ��� null ( '') ���������� ���������� ������
                               � clob

  ���������:
    - destClob, clobLength, maxBufferSize ������ ����
      ����������������
*/
procedure append(
  destClob in out nocopy clob
  , clobLength in out nocopy integer
  , stringBuffer in out nocopy varchar2
  , maxBufferSize integer
  , str varchar2
)
is
  -- ����� ����������� ������
  strLength integer := coalesce( length( str), 0);

  -- ������� ����� ������
  currentBufferSize integer := coalesce(  length( buffer), 0);

  -- ���������� ������ ���������� � lob
  cycleCount integer;

begin
  if str is null and currentBufferSize > 0 then
    -- ���� ���� ��� ���� ������ ����� ������
    dbms_lob.writeappend(
      destClob
      , currentBufferSize
      , stringBuffer
    );
    clobLength := clobLength + currentBufferSize;
    stringBuffer := null;
  elsif strLength + currentBufferSize > maxBufferSize  then
    cycleCount := trunc(( strLength + currentBufferSize)/ maxBufferLength);
    -- �������� �� ������ ������� maxBufferLength �������������
    -- stringBuffer || str
    for i in 1..cycleCount loop
      if i = 1 and currentBufferSize > 0 then
        -- �� ������ �������� ��������� �����
        stringBuffer :=
           stringBuffer
           || substr( str, 1, maxBufferSize - currentBufferSize);
        dbms_lob.writeappend(
          destClob
          , maxBufferSize
          , stringBuffer
        );
      else
        -- �� ��������� ��������� ��� �� ������ ����������� ������
        -- ������ ����� ������������� ��� �������, ���� ����� ������
        -- ��������� ����. ������ ������
        dbms_lob.writeappend(
          destClob
          , maxBufferSize
          , substr(
              str
              , maxBufferSize*(i-1) - currentBufferSize + 1
              , maxBufferSize
            )
        );
      end if;
    end loop;
    stringBuffer := substr( str
      , maxBufferSize * cycleCount - currentBufferSize + 1
    );
    clobLength := clobLength + maxBufferSize*cycleCount;
  elsif length( str) > 0 then
    stringBuffer := stringBuffer || str;
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack(
        '������ ���������� ������ ('
        || 'clobLength=' || to_char( clobLength)
        || ', strLength=' || to_char( strLength)
        || ', currentBufferSize=' || to_char( currentBufferSize)
        || ', maxBufferSize=' || to_char( maxBufferSize)
        || ', cycleCount=' || to_char( cycleCount)
        || ', str="'
        ||
           case when length( str) <= 1000 then
             str || '"'
           else
             substr( str, 1, 1000-3) || '"' || '...'
           end
        || ')'
      )
    , true
  );
end append;

/* func: getZip
  �������� �������������� zip-�����

  ���������:
    filename                 - �������� ����� ������ ������

  �������:
    - blob � zip-�������

  ���������:
      �������� GetClob, �.�. �������������� ����������� ��� ��������.
*/
function getZip(filename varchar2)
return blob
is
  destinationBlob blob     := null;
  sourceClob      clob     := null;
  vin             integer  := 1;
  vout            integer  := 1;
  lang            integer  := dbms_lob.default_lang_ctx;
  warning         integer  := dbms_lob.no_warning;
begin
  sourceClob := getClob();
  if sourceClob is not null then
    destinationBlob :=
      pkg_TextCreateJava.blobCompress(
        sourceBlob  => convertToBlob( sourceClob)
        , sourceFileName => fileName
      );
   end if;
  return destinationBlob;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack(
        '������ ��������� zip.'
      )
    , true
  );
end getZip;



/* group: �������������� ��������� ������ */

/* func: convertToClob
  �������������� BLOB ( �������� ������� �������� ������) � CLOB ( ��������
  ������� ��������� ������). ��������������, ��� ������ � ��������� ��.

  ���������:
  binaryData                  - �������� ������ ��� ��������������
*/
function convertToClob(
  binaryData blob
)
return clob
is

  -- ��������� convertToClob
  destOffset integer := 1;
  srcOffset integer := 1;
  warning number;
  langContext number := dbms_lob.default_lang_ctx;
  resultText clob;

-- convertToClob
begin
  dbms_lob.createTemporary( resultText, true);
  dbms_lob.convertToClob(
    dest_lob => resultText
    , src_blob => binaryData
    , amount => dbms_lob.lobmaxsize
    , dest_offset => destOffset
    , src_offset => srcOffset
    , blob_csid => dbms_lob.default_csid
    , lang_context => langContext
    , warning => warning
  );
  if warning = dbms_lob.warn_inconvertible_char then
    logger.warn( '��� ����������� ������������ ������������� ������� ( �������� �� "?")');
  end if;
  return
    resultText
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ �������������� BLOB � CLOB'
      )
    , true
  );
end convertToClob;

/* func: convertToBlob
  �������������� �LOB ( �������� ������� ��������� ������) � BLOB ( ��������
  ������� �������� ������). ��������������, ��� ������ � ��������� ��.

  ���������:
  textData                    - ��������� ������ ��� ��������������
*/
function convertToBlob(
  textData clob
)
return blob
is
    -- ��������� convertToBlob
  destOffset integer := 1;
  srcOffset integer := 1;
  warning number;
  langContext number := dbms_lob.default_lang_ctx;

  -- �������������� �������� ������
  resultBlob blob;

-- convertToBlob
begin
  dbms_lob.createTemporary( resultBlob, true);
  dbms_lob.convertToBlob(
    dest_lob => resultBlob
    , src_clob => textData
    , amount => dbms_lob.lobmaxsize
    , dest_offset => destOffset
    , src_offset => srcOffset
    , blob_csid => dbms_lob.default_csid
    , lang_context => langContext
    , warning => warning
  );
  if warning = dbms_lob.warn_inconvertible_char then
    logger.warn( '��� ����������� ������������ ������������� ������� ( �������� �� "?")');
  end if;
  return
    resultBlob
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ �������������� CLOB � BLOB'
      )
    , true
  );
end convertToBlob;

end pkg_TextCreate;
/
