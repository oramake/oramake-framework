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



/* group: Функции */



/* group: Execute of HTTP requests */

/* proc: execHttpRequest
  Execute of HTTP request.

  Параметры:
  statusCode                  - Код результата запроса ( HTTP Status-Code)
                                ( возврат)
  reasonPhrase                - Описание результата запроса
                                ( HTTP Reason-Phrase)
                                ( возврат, максимум 256 символов)
  contentType                 - Тип тела ответа ( HTTP Content-Type)
                                ( возврат, максимум 1024 символа)
  entityBody                  - Тело ответа ( HTTP entity-body)
                                ( возврат)
  execSecond                  - время выполнения запроса
                                ( в секундах, -1 если не удалось измерить)
                                ( возврат)
  requestUrl                  - URL для выполнения запроса
  requestText                 - Request text
                                ( default is absent)
  parameterList               - Request parameters
                                ( default is absent)
  httpMethod                  - HTTP method for request
                                ( default POST if requestText or parameterList
                                  is not empty oterwise GET)
  maxWaitSecond               - Максимальное время ожидания ответа по запросу
                                ( в секундах, по умолчанию 60 секунд)
  headerText                  - список заголовков к запросу
                                ( по умолчанию передается Content-Type
                                  и Content-Length)

  Замечания:
  - заголовки передаются в виде текста
  (code)
  Host: ads.betweendigital.com
  Connection: keep-alive
  ...
  (end code)
  - для успешного выполнения запроса необходимо выдать права ACL пользователю,
    вызывающему процедуру
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
  , headerText varchar2 := null
)
is

  -- Number of parameters
  nParameter pls_integer :=
    case when parameterList is not null
      then parameterList.count()
      else 0
    end
  ;

  -- HTTP-запрос
  req utl_http.req;

  -- Время начала выполнения HTTP-запроса
  startTime number;

  -- Buffer for work with CLOB
  Buffer_Size constant pls_integer := 32767;
  buffer varchar2(32767);



  /*
     Отправляет HTTP-запрос
  */
  procedure writeRequest
  is

    -- Data of request parameters ( joined)
    parameterData clob;

    -- HTTP method of current request
    reqMethod varchar2(100);



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
      Добавляет поле заголовка запроса.
    */
    procedure setHeader(
      fieldName varchar2
      , fieldValue varchar2
    )
    is
    begin
      utl_http.set_header(
        req
        , fieldName
        , fieldValue
      );
      logger.trace( fieldName || ': ' || fieldValue);
    end setHeader;



    /*
      Разбирает список заголовов
    */
    procedure setHeaderList
    is
      -- Наименование заголовка
      headerName varchar2( 1000);
      -- Значение заголовка
      headerValue varchar2( 1000);
    begin
      for header in (
        select
          column_value
        from
          table( pkg_Common.split( headerText, chr(10)))
      )
      loop
        if instr( header.column_value, ':') > 0 then
          -- До первой ":"
          headerName :=
            trim(
              substr(
                header.column_value
              , 1
              , instr( header.column_value, ':') - 1)
            );
          -- После первой ":"
          headerValue :=
            trim(
              substr(
                header.column_value
              , instr( header.column_value, ':') + 1)
            );
          setHeader(
            headerName
          , headerValue
          );
        end if;
      end loop;
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.errorStack(
            'Ошибка разбора списка заголовков'
          )
        , true
      );
    end setHeaderList;



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
      if len > 0 then
        -- UTL_HTTP will performs chunked transfer-encoding on the request body
        setHeader( TransferEncoding_HttpHField, 'chunked');
      end if;
      logger.trace( '* HTTP request header: finish');

      if len > 0 then

        -- Text data is automatically converted in UTL_HTTP from the database
        -- character set to the request body character set
        utl_http.set_body_charset( req, 'UTF-8');

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

      if headerText is null then
        if reqMethod = Post_HttpMethod and nParameter > 0 then
          setHeader(
            ContentType_HttpHField
            , 'application/x-www-form-urlencoded'
          );
        elsif requestText is not null then
          setHeader( ContentType_HttpHField, 'text/xml');
        end if;
      else
        setHeaderList();
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
      -- Закрываем запрос в случае ошибки
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
    Читает ответ в CLOB и поля response.
  */
  procedure readResponse
  is

    -- HTTP-ответ
    resp utl_http.resp;

    nHeader integer;
    headerName  varchar2(256);
    headerValue varchar2(1024);

  begin
    resp := utl_http.get_response( req);
    statusCode := resp.status_code;
    reasonPhrase := resp.reason_phrase;

    -- Обрабатываем поля заголовка ответа
    logger.trace( '* HTTP response header: start');
    logger.trace(
      'HTTP: '|| resp.status_code || ' ' || resp.reason_phrase
    );
    for i in 1 .. utl_http.get_header_count( resp) loop
      utl_http.get_header( resp, i, headerName, headerValue);
      logger.trace( headerName || ': ' || headerValue);

      -- Сохраняем значения ключевых полей
      if headerName = ContentType_HttpHField then
        contentType := substr( headerValue, 1, 1024);
      end if;
    end loop;
    logger.trace( '* HTTP response header: finish');

    -- Сохраняем тело ответа в CLOB
    dbms_lob.createTemporary(
      lob_loc     => entityBody
      , cache     => true
    );
    loop
      utl_http.read_text( resp, buffer, Buffer_Size);
      dbms_lob.writeAppend( entityBody, length( buffer), buffer);
    end loop;
  exception
    when utl_http.end_of_body then
      -- Игнорируем псевдоошибку исчерпания данных для чтения
      utl_http.end_response( resp);
      logger.clearErrorStack();
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
    Возвращает длительность прошедшего времени в секундах.
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

  -- Ограничиваем время ожидания ответа ( по умолчанию 60 секунд, что
  -- соответствует значению по умолчанию в utl_http)
  utl_http.set_transfer_timeout( coalesce( maxWaitSecond, 60));

  startTime := dbms_utility.get_time() / 100;
  execSecond := -1;

  writeRequest();
  readResponse();

  -- Определяем время выполнения
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

  Return values:
  text data, returned from the HTTP request.
*/
function getHttpResponse(
  requestUrl varchar2
  , requestText clob := null
  , parameterList wbu_parameter_list_t := null
  , httpMethod varchar2 := null
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
    , maxWaitSecond       => null
    , headerText          => null
  );
  if logger.isTraceEnabled() and entityBody is not null then
    logger.trace(
      'HTTP entity ( length=' || length( entityBody) || '):'
      || chr(10) || substr( entityBody, 1, 3900)
      || case when length( entityBody) > 3900 then
          chr(10) || '...'
        end
    );
  end if;
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
