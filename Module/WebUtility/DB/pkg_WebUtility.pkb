create or replace package body pkg_WebUtility is
/* package body: pkg_WebUtility::body */



/* group: Variables */

/* ivar: logger
  Logger of package.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => Module_Name
  , objectName  => 'pkg_WebUtility'
);

/* ivar: ntlmToken
  ntlmToken for all requests.
*/
ntlmToken varchar2(1024);

/* group: Functions */



/* group: Execute of HTTP requests */

/* ifunc: getTextLength
  Returns length of text in bytes after conversion to specified character set.

  Parameters:
  textData                    - Text data
  destCharset                 - Name of the character set to which textData is
                                converted

  Returns:
  length of text in bytes (null if textData is null, length(textData) if
  destCharset is null).
*/
function getTextLength(
  textData clob
  , destCharset varchar2
)
return integer
is

  blobLength integer;

  tmpBlob blob;
  destCsid integer;

  amount integer := dbms_lob.getLength( textData);
  src_offset integer := 1;
  dest_offset integer := 1;
  def_lang_context integer := dbms_lob.DEFAULT_LANG_CTX;
  wrn integer;

begin
  if amount > 0 and destCharset is not null then
    dbms_lob.createTemporary(
      lob_loc     => tmpBlob
      , cache     => true
      , dur       => dbms_lob.call
    );
    destCsid := nls_charset_id( destCharset);
    dbms_lob.convertToBlob(
      dest_lob          => tmpBlob
      , src_clob        => textData
      , amount          => amount
      , dest_offset     => dest_offset
      , src_offset      => src_offset
      , blob_csid       => destCsid
      , lang_context    => def_lang_context
      , warning         => wrn
    );
    blobLength := dbms_lob.getLength( tmpBlob);
    dbms_lob.freeTemporary( tmpBlob);
  else
    blobLength := amount;
  end if;
  return blobLength;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Error while getting length of text in specified character set ('
        || ' destCharset="' || destCharset || '"'
        || ').'
      )
    , true
  );
end getTextLength;

/* proc: execHttpRequest
  Execute of HTTP request.

  Parameters:
  statusCode                  - Request result code (HTTP Status-Code)
                                (out)
  reasonPhrase                - Description of the query result
                                (HTTP Reason-Phrase)
                                (out, maximum 256 chars)
  contentType                 - Type of response (HTTP Content-Type)
                                (out, maximum 1024 chars)
  entityBody                  - Response to request (HTTP entity-body)
                                (out)
  execSecond                  - Request execution time
                                (in seconds, -1 if it was not possible to
                                  measure)
                                (out)
  responseHeaderList          - Response headers (out)
  requestUrl                  - Request URL
  requestText                 - Request text
                                (default is absent)
  parameterList               - Request parameters
                                (default is absent)
  httpMethod                  - HTTP method for request
                                (default POST if requestText or parameterList
                                  is not empty oterwise GET)
  disableChunkedEncFlag       - Disable use chunked transfer encoding when
                                sending request
                                (1 yes, 0 no (is default))
  headerList                  - Request headers
                                (defaut is absent, but some headers can be
                                  added by default, see the remarks below)
  partList                    - Request parts
                                (defaut is absent, only for multipart request,
                                 RFC 2045)
  bodyCharset                 - Character set of request body
                                (default is UTF-8)
  maxWaitSecond               - Maximum response time on request
                                (in seconds, default 60 seconds)

  Remarks:
  - headers in headerList with null value are not sent;
  - by default, request uses chunked transfer-encoding and sends
    "Transfer-Encoding: chunked" header ( this will be disabled if
    disableChunkedEncFlag=1 or you use <ContentLength_HttpHeader> or
    <TransferEncoding_HttpHeader> in headerList);
  - by default, request sends <ContentType_HttpHeader> header with value
    <WwwForm_ContentType> if it is POST request with parameters,
    with value <Xml_ContentType> if request text starts with "<?xml ",
    with value <Json_ContentType> if request text starts with "[" or "{"
    ( this will be disabled if you use <ContentType_HttpHeader> in
    headerList);
  - data is automatically converted from the database character set to the
    request body character set;
*/
procedure execHttpRequest(
  statusCode out nocopy integer
  , reasonPhrase out nocopy varchar2
  , contentType out nocopy varchar2
  , entityBody out nocopy clob
  , execSecond out nocopy number
  , responseHeaderList out nocopy wbu_header_list_t
  , requestUrl varchar2
  , requestText clob := null
  , parameterList wbu_parameter_list_t := null
  , httpMethod varchar2 := null
  , disableChunkedEncFlag integer := null
  , headerList wbu_header_list_t := null
  , partList wbu_part_list_t := null
  , bodyCharset varchar2 := null
  , maxWaitSecond integer := null
)
is

  -- Number of parameters
  nParameter pls_integer :=
    case when parameterList is not null
      then parameterList.count()
      else 0
    end
  ;

  -- Number of parts
  nPart pls_integer :=
    case when partList is not null
      then partList.count()
      else 0
    end
  ;

  -- Time out value for reading the HTTP response
  -- (60 seconds is default in utl_http)
  transferTimeout integer := coalesce( maxWaitSecond, 60);

  -- HTTP request
  req utl_http.req;

  -- Time to start the HTTP request
  startTime number;

  -- Buffer for work with CLOB
  Buffer_Size constant pls_integer := 32767;
  buffer varchar2(32767);



  /*
     Write request.
  */
  procedure writeRequest
  is

    -- Character set of the request body (used)
    usedBodyCharset varchar2(100);

    -- Data of request parameters (joined)
    parameterData clob;

    -- Data of multipart request
    multipartData clob;
    boundary varchar2(256) := '7e315618717a8';

    -- HTTP method of current request
    reqMethod varchar2(100);

    -- Availability of appropriate headers in headerList
    isContentLengthUsed boolean := false;
    isContentTypeUsed boolean := false;
    isTransferEncodingUsed boolean := false;



    /*
      Prepare data of parameters into parameterData variable.
    */
    procedure prepareParameterData(
      maxLength integer
    )
    is

      -- utl_url.escape can increase the length of the string by 6 times
      -- ( 3 times due to escaping and 2 times due to encoding of character
      -- sets)
      Escape_Factor constant pls_integer := 6;

      i pls_integer := parameterList.first();

      len integer;
      offset integer;
      amount integer;

    begin
      dbms_lob.createTemporary(
        lob_loc     => parameterData
        , cache     => true
        , dur       => dbms_lob.session
      );
      while i is not null loop
        len := coalesce( length( parameterList( i).parameter_value), 0);
        if logger.isTraceEnabled() then
          logger.trace(
            'parameter #' || i || ': name="'
              || parameterList( i).parameter_name || '"'
            || ', length(value)=' || len
            || ', value'
              || case when len > 3800  then
                  '(first 3800 chars)'
                end
              || '="' || substr( parameterList( i).parameter_value, 1, 3800)
              || '"'
          );
        end if;
        if parameterList( i).parameter_name is not null then
          buffer :=
            case when i > 1  then '&' end
            || utl_url.escape(
                url => parameterList( i).parameter_name
                , escape_reserved_chars => true
                , url_charset => usedBodyCharset
              )
            || '='
          ;
          dbms_lob.writeAppend( parameterData, length( buffer), buffer);
          offset := 1;
          amount := floor( Buffer_Size / Escape_Factor);
          loop
            exit when offset > len;
            dbms_lob.read(
              parameterList( i).parameter_value
              , amount, offset, buffer
            );
            offset := offset + amount;
            buffer := utl_url.escape(
              url => buffer
              , escape_reserved_chars => true
              , url_charset => usedBodyCharset
            );
            dbms_lob.writeAppend( parameterData, length( buffer), buffer);
          end loop;
        elsif len > 0 then
          raise_application_error(
            pkg_Error.IllegalArgument
            , 'Value of parameter without a name is specified ('
              || 'parameter index: ' || i
              || ').'
          );
        end if;
        i := parameterList.next( i);
      end loop;
      if length( parameterData) > maxLength then
        raise_application_error(
          pkg_Error.IllegalArgument
          , 'Maximum allowed length of parameters exceeded ('
            || 'max length: ' || maxLength
            || ', actual length: ' || length( parameterData)
            || ').'
        );
      end if;
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.errorStack(
            'Error while preparing data of parameters ('
            || 'maxLength=' || maxLength
            || ').'
          )
        , true
      );
    end prepareParameterData;



    /*
      Add request header.
    */
    procedure addHeader(
      headerName varchar2
      , headerValue varchar2
    )
    is
    begin
      utl_http.set_header(
        req
        , headerName
        , headerValue
      );
      logger.trace( headerName || ': ' || headerValue);
    end addHeader;



    /*
      Add headers from headerList.
    */
    procedure processHeaderList
    is

      i pls_integer := headerList.first();

    begin
      while i is not null loop
        case headerList( i).header_name
          when ContentLength_HttpHeader then
            isContentLengthUsed := true;
          when ContentType_HttpHeader then
            isContentTypeUsed := true;
          when TransferEncoding_HttpHeader then
            isTransferEncodingUsed := true;
          else
            null;
        end case;
        if headerList( i).header_value is not null then
          if headerList( i).header_name is not null then
            addHeader(
              headerList( i).header_name
              , headerList( i).header_value
            );
          else
            raise_application_error(
              pkg_Error.IllegalArgument
              , 'Value of header without a name is specified ('
                || 'header index: ' || i
                || ').'
            );
          end if;
        end if;
        i := headerList.next( i);
      end loop;
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.errorStack(
            'Error while adding headers from headerList.'
          )
        , true
      );
    end processHeaderList;

    /*
      Process request part list
    */
    procedure preparePartData
    is
      i pls_integer := partList.first();
      /*
        Add request part
      */
      procedure addPart(
        boundary                varchar2
        , partName              varchar2
        , fileName              varchar2
        , contentTransferEncode varchar2
        , partContent           clob
      )
      is
      begin
        dbms_lob.append(
          multipartData
          , '--' || boundary
            || chr(13) || chr(10)
        );
        dbms_lob.append(
          multipartData
          , 'Content-Disposition: form-data; name="' || partName || '"'
            || case
                 when fileName is not null then
                   '; filename="' || fileName || '"'
               end
            || chr(13) || chr(10)
        );
        if contentTransferEncode is not null then
          dbms_lob.append(
            multipartData
            , 'Content-Transfer-Encoding: ' || contentTransferEncode || '"'
              || chr(13) || chr(10)
          );
        end if;
        dbms_lob.append(
          multipartData
          , chr(13) || chr(10)
            || partContent
            || chr(13) || chr(10)
        );
      exception when others then
        raise_application_error(
          pkg_Error.ErrorStackInfo
          , logger.ErrorStack(
              'Error while adding part('
              || 'partName="' || partName || '"'
              || ', fileName="' || fileName || '"'
              || ', contentTransferEncode="' || contentTransferEncode || '"'
              || ').'
            )
          , true
        );
      end addPart;

    -- preparePartData
    begin
      dbms_lob.createtemporary(multipartData, true);
      while i is not null loop
        addPart(
          boundary                => boundary
          , partName              => partList(i).part_name
          , fileName              => partList(i).file_name
          , contentTransferEncode => partList(i).content_transfer_encode
          , partContent           => partList(i).part_content
        );
        i := partList.next( i);
      end loop;
      dbms_lob.append(
        multipartData
        , '--' || boundary || '--'
          || chr(13) || chr(10));
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.errorStack(
            'Error while adding parts from partList.'
          )
        , true
      );
    end preparePartData;


    /*
      Write body of request.
    */
    procedure writeBody(
      bodyText clob
    )
    is

      len integer := coalesce( length( bodyText), 0);
      offset integer := 1;

      tmpClob clob;

    begin
      -- Text data is automatically converted in UTL_HTTP from the database
      -- character set to the request body character set
      utl_http.set_body_charset( req, usedBodyCharset);
      logger.trace(
        'message body: source length=' || length( bodyText)
        || ', set body charset: ' || usedBodyCharset
      );
      if ntlmToken is not null then
        addHeader(Authorization_HttpHeader, ntlmToken);
      end if;

      if len > 0 then
        if not isContentTypeUsed then
          if reqMethod = Post_HttpMethod and nParameter > 0 then
            addHeader( ContentType_HttpHeader, WwwForm_ContentType);
          elsif substr( requestText, 1, 6) = '<?xml ' then
            addHeader( ContentType_HttpHeader, Xml_ContentType);
          elsif substr( requestText, 1, 1) in ( '{', '[') then
            addHeader( ContentType_HttpHeader, Json_ContentType);
          end if;
        end if;
        if coalesce( disableChunkedEncFlag, 0) != 1
              and not ( isContentLengthUsed or isTransferEncodingUsed)
            then
          -- UTL_HTTP will performs chunked transfer-encoding on the request
          -- body
          addHeader( TransferEncoding_HttpHeader, 'chunked');
        elsif not isContentLengthUsed then
          addHeader(
            ContentLength_HttpHeader
            , getTextLength(
                textData        => bodyText
                , destCharset   =>
                    utl_i18n.map_charset(
                      usedBodyCharset
                      , utl_i18n.GENERIC_CONTEXT
                      , utl_i18n.IANA_TO_ORACLE
                    )
              )
          );
        end if;
        if nPart > 0 then
          addHeader( ContentType_HttpHeader, 'multipart/form-data; boundary="' || boundary || '"');
        end if;
      end if;
      logger.trace( '* HTTP request header: finish');

      if len > 0 then
        logger.trace( '* HTTP message body: start');
        loop
          buffer := substr( bodyText, offset, Buffer_Size);
          utl_http.write_text( req, buffer);
          logger.trace( buffer);
          offset := offset + Buffer_Size;
          exit when offset > len;
        end loop;
        logger.trace( '* HTTP message body: finish');
      end if;
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.errorStack(
            'Error while write body of request.'
          )
        , true
      );
    end writeBody;



  -- writeRequest
  begin
    usedBodyCharset := substr( coalesce( bodyCharset, Utf8_Charset), 1, 100);
    reqMethod := coalesce(
      httpMethod
      , case when
          requestText is not null or nParameter > 0
        then
          Post_HttpMethod
        else
          Get_HttpMethod
        end
    );
    if nParameter > 0 then
      prepareParameterData(
        maxLength =>
          case when reqMethod = Get_HttpMethod then
            32767 - 1 - length( requestUrl)
          end
      );
    end if;
    if nPart > 0 then
      preparePartData();
    end if;
    req := utl_http.begin_request(
      url             =>
          requestUrl
          || case when
              reqMethod = Get_HttpMethod and nParameter > 0
            then
              '?' || cast( parameterData as varchar2)
            end
      , method        => reqMethod
      , http_version  => utl_http.HTTP_VERSION_1_1
    );
    begin
      if logger.isTraceEnabled() then
        logger.trace( req.method || ' ' || req.url || ' ' || req.http_version);
        logger.trace( '* HTTP request header: start');
      end if;

      if headerList is not null then
        processHeaderList();
      end if;

      writeBody(
        case
          when
              reqMethod = Post_HttpMethod and nPart > 0
            then
              multipartData
          when
              reqMethod = Post_HttpMethod and nParameter > 0
            then
              parameterData
          else
              requestText
        end
      );

      if parameterData is not null then
        dbms_lob.freeTemporary( parameterData);
      end if;
      if multipartData is not null then
        dbms_lob.freeTemporary( multipartData);
      end if;
    exception when others then
      -- Close the request in case of an error
      utl_http.end_request( req);
      raise;
    end;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Error while sending request.'
        )
      , true
    );
  end writeRequest;



  /*
    Read response.
  */
  procedure readResponse
  is

    resp utl_http.resp;

    nHeader integer;
    headerName  varchar2(256);
    headerValue varchar2(1024);

  begin
    resp := utl_http.get_response( req);
    statusCode := resp.status_code;
    reasonPhrase := resp.reason_phrase;

    logger.trace( '* HTTP response header: start');
    logger.trace(
      'HTTP: '|| resp.status_code || ' ' || resp.reason_phrase
    );
    responseHeaderList := wbu_header_list_t();
    for i in 1 .. utl_http.get_header_count( resp) loop
      utl_http.get_header( resp, i, headerName, headerValue);
      logger.trace( headerName || ': ' || headerValue);
      responseHeaderList.Extend();
      responseHeaderList(i) := wbu_header_t(headerName, headerValue);

      if headerName = ContentType_HttpHeader then
        contentType := substr( headerValue, 1, 1024);
      end if;
    end loop;
    logger.trace( '* HTTP response header: finish');

    dbms_lob.createTemporary(
      lob_loc     => entityBody
      , cache     => true
    );
    loop
      utl_http.read_text( resp, buffer, Buffer_Size);
      if length( entityBody) = 0 then
        logger.trace( '* HTTP response body: start');
      end if;
      logger.trace( buffer);
      dbms_lob.writeAppend( entityBody, length( buffer), buffer);
    end loop;
  exception
    when utl_http.end_of_body then
      -- ignore the pseudo error of data exhaustion for reading
      utl_http.end_response( resp);
      logger.clearErrorStack();
      logger.trace(
        '* HTTP response body: finish'
        || ' (length=' || length( entityBody) || ')'
      );
    when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.errorStack(
            'Error while getting response ('
            || ' transferTimeout=' || transferTimeout
            || ').'
          )
        , true
      );
  end readResponse;



  /*
    Returns elapsed time in seconds.
  */
  function timeDiff(
    newTime number
    , oldTime number
  )
  return number
  is
  begin
    return
      case when newTime >= oldTime then
        newTime - oldTime
      end
    ;
  end timeDiff;



-- execHttpRequest
begin
  if nParameter > 0 and requestText is not null then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Simultaneous use of request text and parameters is incorrect.'
    );
  end if;
  if nPart > 0 and requestText is not null then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Simultaneous use of request text and partList is incorrect.'
    );
  end if;
  if nPart > 0 and  nParameter > 0 then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Simultaneous use of parameters and partList is incorrect.'
    );
  end if;

  logger.trace( '*** HTTP request: ' || requestUrl);
  if not pkg_WebUtilityBase.getTestResponse(
          statusCode      => statusCode
          , reasonPhrase  => reasonPhrase
          , contentType   => contentType
          , entityBody    => entityBody
          , execSecond    => execSecond
        )
      then

    utl_http.set_transfer_timeout( transferTimeout);

    startTime := dbms_utility.get_time() / 100;
    execSecond := -1;

    writeRequest();
    readResponse();

    execSecond := coalesce(
      timeDiff(
        newTime   => dbms_utility.get_time() / 100
      , oldTime   => startTime
      )
      , -1
    );
  else
    logger.debug( 'Test response data was set (without sending HTTP request).');
    logger.trace( 'statusCode         : ' || statusCode);
    logger.trace( 'reasonPhrase       : ' || reasonPhrase);
    logger.trace( 'contentType        : ' || contentType);
    logger.trace( 'length(entityBody) : ' || length( entityBody));
    logger.trace( 'execSecond         : ' || execSecond);
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Error while executing HTTP request.'
      )
    , true
  );
end execHttpRequest;

/* proc: execHttpRequest(without responseHeaderList)
  Execute of HTTP request.

  Parameters:
  statusCode                  - Request result code (HTTP Status-Code)
                                (out)
  reasonPhrase                - Description of the query result
                                (HTTP Reason-Phrase)
                                (out, maximum 256 chars)
  contentType                 - Type of response (HTTP Content-Type)
                                (out, maximum 1024 chars)
  entityBody                  - Response to request (HTTP entity-body)
                                (out)
  execSecond                  - Request execution time
                                (in seconds, -1 if it was not possible to
                                  measure)
                                (out)
  requestUrl                  - Request URL
  requestText                 - Request text
                                (default is absent)
  parameterList               - Request parameters
                                (default is absent)
  httpMethod                  - HTTP method for request
                                (default POST if requestText or parameterList
                                  is not empty oterwise GET)
  disableChunkedEncFlag       - Disable use chunked transfer encoding when
                                sending request
                                (1 yes, 0 no (is default))
  headerList                  - Request headers
                                (defaut is absent, but some headers can be
                                  added by default, see the remarks below)
  partList                    - Request parts
                                (defaut is absent, only for multipart request,
                                 RFC 2045)
  bodyCharset                 - Character set of request body
                                (default is UTF-8)
  maxWaitSecond               - Maximum response time on request
                                (in seconds, default 60 seconds)

  Remarks:
  - headers in headerList with null value are not sent;
  - by default, request uses chunked transfer-encoding and sends
    "Transfer-Encoding: chunked" header ( this will be disabled if
    disableChunkedEncFlag=1 or you use <ContentLength_HttpHeader> or
    <TransferEncoding_HttpHeader> in headerList);
  - by default, request sends <ContentType_HttpHeader> header with value
    <WwwForm_ContentType> if it is POST request with parameters,
    with value <Xml_ContentType> if request text starts with "<?xml ",
    with value <Json_ContentType> if request text starts with "[" or "{"
    ( this will be disabled if you use <ContentType_HttpHeader> in
    headerList);
  - data is automatically converted from the database character set to the
    request body character set;
*/
procedure execHttpRequest(
  statusCode out nocopy integer
  , reasonPhrase out nocopy varchar2
  , contentType out nocopy varchar2
  , entityBody out nocopy clob
  , execSecond out nocopy number
  , requestUrl varchar2
  , requestText clob := null
  , parameterList wbu_parameter_list_t := null
  , httpMethod varchar2 := null
  , disableChunkedEncFlag integer := null
  , headerList wbu_header_list_t := null
  , partList wbu_part_list_t := null
  , bodyCharset varchar2 := null
  , maxWaitSecond integer := null
)
is
  responseHeaderList wbu_header_list_t;
begin
  execHttpRequest(
    statusCode                => statusCode
    , reasonPhrase            => reasonPhrase
    , contentType             => contentType
    , entityBody              => entityBody
    , execSecond              => execSecond
    , responseHeaderList      => responseHeaderList
    , requestUrl              => requestUrl
    , requestText             => requestText
    , parameterList           => parameterList
    , httpMethod              => httpMethod
    , disableChunkedEncFlag   => disableChunkedEncFlag
    , headerList              => headerList
    , partList                => partList
    , bodyCharset             => bodyCharset
    , maxWaitSecond           => maxWaitSecond
  );
end execHttpRequest;

/* proc: checkResponseError
  Raises an exception when the Web server returns a status code other than
  successful code (HTTP 200).

  Parameters:
  statusCode                  - Request result code (HTTP Status-Code)
  reasonPhrase                - Description of the query result
                                (HTTP Reason-Phrase)
  entityBody                  - Response to request (HTTP entity-body)
  soapRequestFlag             - SOAP request was sent
                                (1 yes, 0 no (by default))

  Remarks:
  - in the case of specifying soapRequestFlag = 1, an attempt is made to
    obtain error information according to the format of the SOAP response
    (from the tag Fault);
*/
procedure checkResponseError(
  statusCode integer
  , reasonPhrase varchar2
  , entityBody clob
  , soapRequestFlag integer := null
)
is



  /*
    Attempts to return additional error information from the SOAP response.
  */
  function getSoapErrorInfo
  return varchar2
  is

    -- Response in XML format (null in case of parsing error)
    responseXml xmltype;

    faultXml xmltype;
    faultCode xmltype;
    faultString xmltype;

  begin
    begin
      responseXml := xmltype( entityBody);
    exception when others then
      logger.trace(
        'getSoapErrorInfo: ignored XML parse error:'
        || chr(10) || logger.getErrorStack( isStackPreserved => 1)
      );
      -- Ignore the error and clear errors stack
      logger.clearErrorStack();
    end;
    if responseXml is not null then
      faultXml := responseXml.extract(
        '/Envelope/Body/Fault/node()'
        , 'xmlns="' || responseXml.getNamespace() || '"'
      );
    end if;
    if faultXml is not null then
      faultCode := faultXml.extract( '/faultcode/text()');
      faultString := faultXml.extract( '/faultstring/text()');
    end if;
    return
      case when faultXml is not null then
        substr( trim(
          dbms_xmlgen.convert(
            case when faultCode is not null then
              'faultcode: ' || faultCode.getStringVal()
              || case when faultString is not null then
                  ', ' || chr(10) || 'faultstring: '
                  || faultString.getStringVal()
                end
            else
              'SOAP Fault: ' || faultXml.getStringVal()
            end
            , dbms_xmlgen.ENTITY_DECODE
          )
        ), 1, 500)
      end
    ;
  end getSoapErrorInfo;



-- checkResponseError
begin
  if statusCode not in (
    utl_http.HTTP_OK
    , utl_http.HTTP_CREATED
  ) then
    raise_application_error(
      pkg_Error.ProcessError
      , 'HTTP error ' || to_char( statusCode)
        || ': ' || reasonPhrase
        || case when entityBody is not null then
            chr(10)
            || coalesce(
                case when soapRequestFlag = 1 then
                    getSoapErrorInfo()
                  end
                , substr( entityBody, 1, 500)
                  || case when length( entityBody) > 500 then
                      chr(10) || '...'
                    end
              )
          end
    );
  end if;
end checkResponseError;

/* func: getResponseXml
  Attempts to return response in XML format.

  Parameters:
  entityBody                  - Response text
  contentType                 - Type of response (HTTP Content-Type)
                                (default is unknown)

  Return:
  response in XML format.
*/
function getResponseXml(
  entityBody clob
  , contentType varchar2 := null
)
return xmltype
is

  -- Response in XML format
  responseXml xmltype;

begin
  return xmltype( entityBody);
exception when others then
  if contentType = Xml_ContentType or contentType like Xml_ContentType || ';%'
      then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Error parsing response as text in XML format ('
          || ' response length=' || length( entityBody)
          || ', substr(response,1,200)="'
            || chr(10) || substr( entityBody, 1, 200) || chr(10)
            || '"'
          || ').'
        )
      , true
    );
  else
    logger.clearErrorStack();
    raise_application_error(
      pkg_Error.ProcessError
      , 'Response was not in XML format ('
        || ' response length=' || length( entityBody)
        || ', content_type="' || contentType || '"'
        || ').'
    );
  end if;
end getResponseXml;

/* func: getResponseXml(CHECK)
  Check HTTP response and attempts to return response in XML format.

  Parameters:
  statusCode                  - Request result code (HTTP Status-Code)
  reasonPhrase                - Description of the query result
                                (HTTP Reason-Phrase)
  contentType                 - Type of response (HTTP Content-Type)
                                (default is unknown)
  entityBody                  - Response to request (HTTP entity-body)
  soapRequestFlag             - SOAP request was sent
                                (1 yes (by default), 0 no)

  Return:
  response in XML format.

  Remarks:
  - it is wrapper for <checkResponseError> and <getResponseXml> functions;
*/
function getResponseXml(
  statusCode integer
  , reasonPhrase varchar2
  , contentType varchar2 := null
  , entityBody clob
  , soapRequestFlag integer := null
)
return xmltype
is
begin
  checkResponseError(
    statusCode        => statusCode
    , reasonPhrase    => reasonPhrase
    , entityBody      => entityBody
    , soapRequestFlag => coalesce( soapRequestFlag, 1)
  );
  return
    getResponseXml(
      entityBody    => entityBody
      , contentType => contentType
    )
  ;
end getResponseXml;

/* func: getHttpResponse
  Returns data received by using an HTTP request at a given URL.

  Parameters:
  requestUrl                  - URL for request
  requestText                 - Request text
                                ( default is absent)
  parameterList               - Request parameters
                                ( default is absent)
  httpMethod                  - HTTP method for request
                                ( default POST if requestText not empty
                                  oterwise GET)
  disableChunkedEncFlag       - Disable use chunked transfer encoding when
                                sending request
                                (1 yes, 0 no (is default))
  headerList                  - Request headers
                                (defaut is absent, but some headers can be
                                  added by default, see the remarks below)
  bodyCharset                 - Character set of request body
                                (default is UTF-8)
  maxWaitSecond               - Maximum response time on request
                                (in seconds, default 60 seconds)

  Return:
  text data, returned from the HTTP request.
*/
function getHttpResponse(
  requestUrl varchar2
  , requestText clob := null
  , parameterList wbu_parameter_list_t := null
  , httpMethod varchar2 := null
  , disableChunkedEncFlag integer := null
  , headerList wbu_header_list_t := null
  , bodyCharset varchar2 := null
  , maxWaitSecond integer := null
)
return clob
is

  -- Response data
  statusCode integer;
  reasonPhrase varchar2(1024);
  contentType varchar2(1024);
  entityBody clob;

  execSecond number;

-- getHttpResponse
begin
  execHttpRequest(
    statusCode                => statusCode
    , reasonPhrase            => reasonPhrase
    , contentType             => contentType
    , entityBody              => entityBody
    , execSecond              => execSecond
    , requestUrl              => requestUrl
    , requestText             => requestText
    , parameterList           => parameterList
    , httpMethod              => httpMethod
    , disableChunkedEncFlag   => disableChunkedEncFlag
    , headerList              => headerList
    , bodyCharset             => bodyCharset
    , maxWaitSecond           => maxWaitSecond
  );
  checkResponseError(
    statusCode        => statusCode
    , reasonPhrase    => reasonPhrase
    , entityBody      => entityBody
  );
  return entityBody;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Error while returning data of HTTP request ('
        || 'requestUrl="' || requestUrl || '"'
        || ', httpMethod="' || httpMethod || '"'
        || ').'
      )
    , true
  );
end getHttpResponse;



/* group: Execute of SOAP HTTP requests  */

/* proc: execSoapRequest
  Execute of SOAP HTTP request.

  Parameters:
  statusCode                  - Request result code (HTTP Status-Code)
                                (out)
  reasonPhrase                - Description of the query result
                                (HTTP Reason-Phrase)
                                (out, maximum 256 chars)
  contentType                 - Type of response (HTTP Content-Type)
                                (out, maximum 1024 chars)
  entityBody                  - Response to request (HTTP entity-body)
                                (out)
  requestUrl                  - URL of web service
  soapAction                  - Action for request
  soapMessage                 - Text of SOAP message to web service
  disableChunkedEncFlag       - Disable use chunked transfer encoding when
                                sending request
                                (1 yes, 0 no (is default))
  maxWaitSecond               - Maximum response time on request
                                (in seconds, default 60 seconds)

  Remarks:
  - it is wrapper for <execHttpRequest>;
*/
procedure execSoapRequest(
  statusCode out nocopy integer
  , reasonPhrase out nocopy varchar2
  , contentType out nocopy varchar2
  , entityBody out nocopy clob
  , requestUrl varchar2
  , soapAction varchar2
  , soapMessage clob
  , disableChunkedEncFlag integer := null
  , maxWaitSecond integer := null
)
is

  execSecond number;

begin
  execHttpRequest(
    statusCode                => statusCode
    , reasonPhrase            => reasonPhrase
    , contentType             => contentType
    , entityBody              => entityBody
    , execSecond              => execSecond
    , requestUrl              => requestUrl
    , requestText             => soapMessage
    , parameterList           => null
    , disableChunkedEncFlag   => disableChunkedEncFlag
    , headerList              =>
        wbu_header_list_t(
          wbu_header_t( ContentType_HttpHeader, SoapMessage_ContentType)
          , wbu_header_t( SoapAction_HttpHeader, soapAction)
        )
    , maxWaitSecond       => maxWaitSecond
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Error while executing SOAP HTTP request ('
        || 'requestUrl="' || requestUrl || '"'
        || ', soapAction="' || soapAction || '"'
        || ').'
      )
    , true
  );
end execSoapRequest;

/* ifunc: getSoapResponse(INTERNAL)
  Returns SOAP message, received by using HTTP request.

  Parameters:
  requestUrl                  - URL of web service
  requestText                 - Request text
  parameterList               - Request parameters
  disableChunkedEncFlag       - Disable use chunked transfer encoding when
                                sending request
  headerList                  - Request headers
  maxWaitSecond               - Maximum response time on request

  Return:
  XML with SOAP message, received from web service.
*/
function getSoapResponse(
  requestUrl varchar2
  , requestText clob
  , parameterList wbu_parameter_list_t
  , disableChunkedEncFlag integer
  , headerList wbu_header_list_t
  , maxWaitSecond integer
)
return xmltype
is

  -- Response data
  statusCode integer;
  reasonPhrase varchar2(1024);
  contentType varchar2(1024);
  entityBody clob;

  execSecond number;

-- getSoapResponse
begin
  execHttpRequest(
    statusCode                => statusCode
    , reasonPhrase            => reasonPhrase
    , contentType             => contentType
    , entityBody              => entityBody
    , execSecond              => execSecond
    , requestUrl              => requestUrl
    , requestText             => requestText
    , parameterList           => parameterList
    , httpMethod              => Post_HttpMethod
    , disableChunkedEncFlag   => disableChunkedEncFlag
    , headerList              => headerList
    , maxWaitSecond           => maxWaitSecond
  );
  checkResponseError(
    statusCode        => statusCode
    , reasonPhrase    => reasonPhrase
    , entityBody      => entityBody
    , soapRequestFlag => 1
  );
  return
    getResponseXml(
      entityBody      => entityBody
      , contentType   => contentType
    )
  ;
end getSoapResponse;

/* func: getSoapResponse
  Returns SOAP message, received by using HTTP request to web service.

  Parameters:
  requestUrl                  - URL of web service
  soapAction                  - Action for request
  soapMessage                 - Text of SOAP message to web service
  disableChunkedEncFlag       - Disable use chunked transfer encoding when
                                sending request
                                (1 yes, 0 no (is default))
  maxWaitSecond               - Maximum response time on request
                                (in seconds, default 60 seconds)

  Return:
  XML with SOAP message, received from web service.
*/
function getSoapResponse(
  requestUrl varchar2
  , soapAction varchar2
  , soapMessage clob
  , disableChunkedEncFlag integer := null
  , maxWaitSecond integer := null
)
return xmltype
is
begin
  return
    getSoapResponse(
      requestUrl                => requestUrl
      , requestText             => soapMessage
      , parameterList           => null
      , disableChunkedEncFlag   => disableChunkedEncFlag
      , headerList              =>
          wbu_header_list_t(
            wbu_header_t( ContentType_HttpHeader, SoapMessage_ContentType)
            , wbu_header_t( SoapAction_HttpHeader, soapAction)
          )
      , maxWaitSecond       => maxWaitSecond
    )
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Error while returning data from SOAP web service ('
        || 'requestUrl="' || requestUrl || '"'
        || ', soapAction="' || soapAction || '"'
        || ').'
      )
    , true
  );
end getSoapResponse;

/* func: getSoapResponse( PARAMETERS)
  Returns SOAP message, received by using HTTP POST-request with parameters.

  Parameters:
  requestUrl                  - URL of web service
  parameterList               - Request parameters
  disableChunkedEncFlag       - Disable use chunked transfer encoding when
                                sending request
                                (1 yes, 0 no (is default))
  headerList                  - Request headers
                                (defaut is absent, but some headers can be
                                  added by default, see the remarks below)
  maxWaitSecond               - Maximum response time on request
                                (in seconds, default 60 seconds)

  Return:
  XML with SOAP message, received by request.
*/
function getSoapResponse(
  requestUrl varchar2
  , parameterList wbu_parameter_list_t
  , disableChunkedEncFlag integer := null
  , headerList wbu_header_list_t := null
  , maxWaitSecond integer := null
)
return xmltype
is
begin
  return
    getSoapResponse(
      requestUrl                => requestUrl
      , requestText             => null
      , parameterList           => parameterList
      , disableChunkedEncFlag   => disableChunkedEncFlag
      , headerList              => headerList
      , maxWaitSecond           => maxWaitSecond
    )
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Error while returning SOAP message, received by request ('
        || 'requestUrl="' || requestUrl || '"'
        || ').'
      )
    , true
  );
end getSoapResponse;



/* group: Authentification  */

/* proc: login
  Perform authentification request

  Parameters:
  requestUrl                  - URL of web service
  username                    - The username for the authentication
  password                    - The password for the HTTP authentication
  domain                      - The user domain for the authentication
  walletPath                  - Path to wallet (must have for https)
  walletPassword              - Password for wallet (must have for https)
  proxyServer                 - Name of proxy server
  scheme                      - The HTTP authentication scheme.
                                Either 'NTLM' for the Microsoft NTLM,
                                'Basic' for the HTTP basic,
                                'Digest' for the HTTP digest,
                                'AWS' for Amazon AWS version 2 authentication scheme, or
                                'AWS4-HMAC-SHA256' for AWS version 4 authentication scheme.
                                Default is 'Basic'.
*/
procedure login(
  requestUrl                varchar2
  , username                varchar2
  , password                varchar2
  , domain                  varchar2 default null
  , walletPath              varchar2 default null
  , walletPassword          varchar2 default null
  , proxyServer             varchar2 default null
  , scheme                  varchar2 default null
)
is
  req utl_http.req;
  resp utl_http.resp;
  statusCode integer;
  reasonPhrase varchar2(1024);
begin
  -- support for HTTPS
  if instr(lower(requestUrl),'https') = 1 then
    utl_http.set_wallet (walletPath, walletPassword);
  end if;

  -- support for proxy server
  if proxyServer is not null then
    utl_http.set_proxy (proxyServer);
  end if;

  -- NTLM authentication
  if scheme = NTLM_scheme then
    ntlmToken := pkg_WebUtilityNtlm.ntlmLogin(
        requestUrl       => requestUrl
        , username       => username
        , password       => password
        , domain         => domain
    );
  else
  -- others authentications
    req := utl_http.begin_request(requestUrl);
    utl_http.set_authentication(
      r => req
      , username => userName
      , password => password
      , scheme => coalesce(scheme, Basic_Scheme)
    );
    resp := utl_http.get_response(req);
    statusCode := resp.status_code;
    reasonPhrase := resp.reason_phrase;
    if statusCode != utl_http.HTTP_OK then
      raise_application_error(
        pkg_Error.ProcessError
        , 'Server return an error:'
          || to_char(statusCode)
          || ' ' || reasonPhrase
          || '.'
      );
    end if;
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Error while user authentification ('
        || 'requestUrl="' || requestUrl || '"'
        || ', username="' || username || '"'
        || ', password="' || password || '"'
        || ', domain="' || domain || '"'
        || ', walletPath="' || walletPath || '"'
        || ', walletPassword="' || walletPassword || '"'
        || ', proxyServer="' || proxyServer || '"'
        || ', scheme="' || scheme || '"'
        || ').'
      )
    , true
  );
end login;

end pkg_WebUtility;
/
