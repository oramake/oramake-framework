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



/* group: Functions */



/* group: Execute of HTTP requests */

/* proc: execHttpRequest
  Execute of HTTP request.

  Параметры:
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
  maxWaitSecond               - Maximum response time on request
                                (in seconds, default 60 seconds)
  headerList                  - Request headers
                                (defaut is absent, but some headers can be
                                  added by default, see the remarks below)
  bodyCharset                 - Sets the character set of the request body when
                                the media type is text but the character set
                                is not specified in the Content-Type header
                                (default is UTF-8)

  Remarks:
  - headers in headerList with null value are not sent;
  - by default, request uses chunked transfer-encoding and sends
    "Transfer-Encoding: chunked" header ( this will be disabled if you use
    <ContentLength_HttpHeader> or <TransferEncoding_HttpHeader> in headerList);
  - by default, request sends <ContentType_HttpHeader> header with value
    "application/x-www-form-urlencoded" if it is POST request with parameters,
    with value "text/xml" if request text starts with "<?xml ",
    with value "application/json" header if request text starts with "[" or "{"
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
  , maxWaitSecond integer := null
  , headerList wbu_header_list_t := null
  , bodyCharset varchar2 := null
)
is

  -- Number of parameters
  nParameter pls_integer :=
    case when parameterList is not null
      then parameterList.count()
      else 0
    end
  ;

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

    -- Data of request parameters ( joined)
    parameterData clob;

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

      -- utl_url.escape can increase the length of the string 3 times
      Escape_Factor constant pls_integer := 3;

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
        if parameterList( i).parameter_name is not null then
          offset := 1;
          amount :=
            floor( Buffer_Size / Escape_Factor)
            - length( parameterList( i).parameter_name) - 2
          ;
          loop
            exit when offset > len;
            dbms_lob.read(
              parameterList( i).parameter_value
              , amount, offset, buffer
            );
            offset := offset + amount;
            buffer :=
              case when i > 1  then '&' end
              || utl_url.escape( parameterList( i).parameter_name, true)
              || '='
              || utl_url.escape( buffer, true)
            ;
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
      Write body of request.
    */
    procedure writeBody(
      bodyText clob
    )
    is

      len integer := coalesce( length( bodyText), 0);
      offset integer := 1;

    begin
      if len > 0 and not ( isContentLengthUsed or isTransferEncodingUsed) then
        -- UTL_HTTP will performs chunked transfer-encoding on the request body
        addHeader( TransferEncoding_HttpHeader, 'chunked');
      end if;
      logger.trace( '* HTTP request header: finish');

      if len > 0 then

        -- Text data is automatically converted in UTL_HTTP from the database
        -- character set to the request body character set
        utl_http.set_body_charset( req, coalesce( bodyCharset, 'UTF-8'));

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
    logger.trace( '*** HTTP request: ' || requestUrl);
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
      if not isContentTypeUsed then
        if reqMethod = Post_HttpMethod and nParameter > 0 then
          addHeader(
            ContentType_HttpHeader
            , 'application/x-www-form-urlencoded'
          );
        elsif substr( requestText, 1, 6) = '<?xml ' then
          addHeader( ContentType_HttpHeader, 'text/xml');
        elsif substr( requestText, 1, 1) in ( '{', '[') then
          addHeader( ContentType_HttpHeader, 'application/json');
        end if;
      end if;

      writeBody(
        case when
            reqMethod = Post_HttpMethod and nParameter > 0
          then parameterData
          else requestText
        end
      );
      if parameterData is not null then
        dbms_lob.freeTemporary( parameterData);
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
    for i in 1 .. utl_http.get_header_count( resp) loop
      utl_http.get_header( resp, i, headerName, headerValue);
      logger.trace( headerName || ': ' || headerValue);

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
            'Error while getting response.'
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

  -- Limit waiting time for response ( 60 seconds is default in utl_http)
  utl_http.set_transfer_timeout( coalesce( maxWaitSecond, 60));

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
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Error while executing HTTP request ('
        || ' maxWaitSecond=' || maxWaitSecond
        || ').'
      )
    , true
  );
end execHttpRequest;

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
  maxWaitSecond               - Maximum response time on request
                                (in seconds, default 60 seconds)
  headerList                  - Request headers
                                (defaut is absent, but some headers can be
                                  added by default, see the remarks below)
  bodyCharset                 - Sets the character set of the request body when
                                the media type is text but the character set
                                is not specified in the Content-Type header
                                (default is UTF-8)

  Return values:
  text data, returned from the HTTP request.
*/
function getHttpResponse(
  requestUrl varchar2
  , requestText clob := null
  , parameterList wbu_parameter_list_t := null
  , httpMethod varchar2 := null
  , maxWaitSecond integer := null
  , headerList wbu_header_list_t := null
  , bodyCharset varchar2 := null
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
    statusCode            => statusCode
    , reasonPhrase        => reasonPhrase
    , contentType         => contentType
    , entityBody          => entityBody
    , execSecond          => execSecond
    , requestUrl          => requestUrl
    , requestText         => requestText
    , parameterList       => parameterList
    , httpMethod          => httpMethod
    , maxWaitSecond       => maxWaitSecond
    , headerList          => headerList
    , bodyCharset         => bodyCharset
  );
  if statusCode <> utl_http.HTTP_OK then
    raise_application_error(
      pkg_Error.ProcessError
      , 'HTTP error ' || to_char( statusCode)
        || ': ' || reasonPhrase
        || chr(10) || substr( entityBody, 1, 500)
        || case when length( entityBody) > 500 then
            chr(10) || '...'
          end
    );
  end if;
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

end pkg_WebUtility;
/
