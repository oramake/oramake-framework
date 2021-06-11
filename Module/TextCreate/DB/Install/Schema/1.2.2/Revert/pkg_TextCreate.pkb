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
  ����������� clob. ���������������� � <NewText>
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

/* proc: NewText
  �������������� ����� ����� ��� ������������
  
  �����������:
    - ���������� dbms_lob.createtemporary
      ��� ������������� clob
    - ��������� clob �� ������
    - �������������� ���������� <currentClobLength>,
      <maxBufferLength>
    - ������� <buffer>
*/
procedure NewText 
is
begin
  if destinationClob is not null then
    logger.Debug( 'destinationClob.is_open=' || 
      to_char( dbms_lob.isopen( destinationClob))
    );
  end if;
  dbms_lob.createtemporary( destinationClob, true);
                                       -- ��������� clob
                                       -- ��� ������
  dbms_lob.open( destinationClob, dbms_lob.lob_readwrite);
  currentClobLength := 0;
  buffer := null;
                                       -- ��� �����������
                                       -- ������������ ������
                                       -- ������ ���� �� ������
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
end NewText;

/* proc: Append
  ���������� ������ � �����
  
  ���������:
    str - ������, ��� null ���������� ���������� ������
    
  ���������:
    - ���� �� ������ ���������� �� ��� ������ <NewText>, �� ����
      ����� �� ��� ������������������ �����, �� ������������
      ����������
*/  
procedure Append( 
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


/* func: GetClob
  �������� �������������� ����� � ���� clob

  ���������:
    filename                 - �������� ����� ������ ������
  
  �������:
    - <destinationClob>
  
  ���������:
    - ���������� ����� � <destinationClob> � ������� Append('')
    - ��������� <destinationClob>,
      �������������� ��������, ������ �� �� 
*/
function GetClob
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
end GetClob;

/* proc: Append(destClob)
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
procedure Append(
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
                                       -- ���������� ������ ����������
                                       -- � lob
  cycleCount integer;  
begin
  if str is null and currentBufferSize > 0 then
                                       -- ���� ���� ��� ���� ������
                                       -- ����� ������ 
    dbms_lob.writeappend( 
      destClob
      , currentBufferSize
      , stringBuffer 
    );        
    clobLength := clobLength + currentBufferSize;
    stringBuffer := null;
  elsif strLength + currentBufferSize > maxBufferSize  then
    cycleCount := trunc(( strLength + currentBufferSize)/ maxBufferLength);                                        
                                       -- �������� �� ������ ������� 
                                       -- maxBufferLength
                                       -- ������������� 
                                       -- stringBuffer || str
    for i in 1..cycleCount loop 
      if i = 1 and currentBufferSize > 0 then 
                                       -- �� ������ ��������
                                       -- ��������� �����
        stringBuffer := 
           stringBuffer 
           || substr( str, 1, maxBufferSize - currentBufferSize);
        dbms_lob.writeappend( 
          destClob
          , maxBufferSize
          , stringBuffer
        );        
      else
                                       -- �� ��������� ���������
                                       -- ��� �� ������ ����������� 
                                       -- ������
                                       -- ������ ����� ������������� 
                                       -- ��� �������, ���� ����� ������ 
                                       -- ��������� ����.
                                       -- ������ ������
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
end Append;
/* func: GetZip
  �������� �������������� zip-�����

  ���������:
    filename                 - �������� ����� ������ ������
  
  �������:
    - blob � zip-�������
  
  ���������:
      �������� GetClob, �.�. �������������� ����������� ��� ��������.
*/
function GetZip(filename varchar2)
return blob
is
  destinationBlob blob         := null;
  sourceClob      clob         := null;
  vin             pls_integer  := 1;
  vout            pls_integer  := 1;
  lang            pls_integer  := dbms_lob.default_lang_ctx;
  warning         pls_integer  := dbms_lob.no_warning;
begin
   
   sourceClob := GetClob;
   if (sourceClob is not null) then
     dbms_lob.createtemporary(destinationBlob, true, dbms_lob.session);
 
      dbms_lob.convertToBlob(dest_lob     => destinationBlob
                              , src_clob     => sourceClob
                              , amount       => dbms_lob.getlength(sourceClob)
                              , dest_offset  => vin
                              , src_offset   => vout
                              , blob_csid    => dbms_lob.default_csid
                              , lang_context => lang
                              , warning      => warning
                            ); 
     destinationBlob := pkg_TextCreateJava.blobCompress(sourceBlob     => destinationBlob
                                                      , sourceFileName => filename);
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
end GetZip;

end pkg_TextCreate;
/
