create or replace package body pkg_WebUtility is
/* package body: pkg_WebUtility::body */



/* group: Переменные */

/* ivar: logger
  Логер пакета.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => Module_Name
  , objectName  => 'pkg_WebUtility'
);



/* group: Функции */



/* group: Отправка внешних запросов по http */

/* proc: processHttpRequest
  Выполняет запрос по протоколу HTTP.

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
  requestText                 - Текст запроса
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
procedure processHttpRequest(
  statusCode out nocopy integer
  , reasonPhrase out nocopy varchar2
  , contentType out nocopy varchar2
  , entityBody out nocopy clob
  , execSecond out nocopy number
  , requestUrl varchar2
  , requestText clob
  , maxWaitSecond integer := null
  , headerText varchar2 := null
)
is

  -- HTTP-запрос
  req utl_http.req;

  -- Время начала выполнения HTTP-запроса
  startTime number;



  /*
     Отправляет HTTP-запрос
  */
  procedure writeRequest
  is

    len number := 1;

    maxVarchar2Length number := 32767;

    utf8RequestText clob;



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
      logger.trace(
        'HTTP header ' || fieldName || ': ' || fieldValue
      );
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

  -- writeRequest
  begin
    req:= utl_http.begin_request(
      url             => requestUrl
      , method        => 'POST'
      , http_version  => utl_http.HTTP_VERSION_1_1
    );
    begin
      if logger.isTraceEnabled() then
        logger.trace(
          'HTTP request: ' || requestUrl
        );
      end if;


      utl_http.set_body_charset( req, 'UTF-8');

      -- Конвертация в UTF-8
      utf8RequestText := convert( requestText, 'utf8');

      if headerText is null then
        setHeader( 'Content-Type', 'text/xml');
        -- Указываем длину тела запроса с учетом конвертации в UTF-8
        setHeader( 'Content-Length', dbms_lob.getLength( utf8RequestText));
      else
        setHeaderList();
      end if;

      -- Записываем тело запроса
      loop
        utl_http.write_text(
          req
        , substr( utf8RequestText, len, maxVarchar2Length)
        );
        len := len + maxVarchar2Length;
        exit when len > coalesce( dbms_lob.getLength( utf8RequestText), 0);
      end loop;
    exception when others then
      -- Закрываем запрос в случае ошибки
      utl_http.end_request( req);
      raise;
    end;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при отправке запроса.'
        )
      , true
    );
  end writeRequest;



  /*
    Читает ответ в CLOB и поля response.
  */
  procedure readResponse
  is

    -- Буфер для работы с CLOB
    buff varchar2(32767);
    Buff_Size constant integer := 32767;

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
    logger.trace( '*** HTTP response header: start');
    logger.trace(
      'HTTP: '|| resp.status_code || ' ' || resp.reason_phrase
    );
    for i in 1 .. utl_http.get_header_count( resp) loop
      utl_http.get_header( resp, i, headerName, headerValue);
      logger.trace( headerName || ': ' || headerValue);

      -- Сохраняем значения ключевых полей
      if headerName = 'Content-Type' then
        contentType := substr( headerValue, 1, 1024);
      end if;
    end loop;
    logger.trace( '*** HTTP response header: finish');

    -- Сохраняем тело ответа в CLOB
    dbms_lob.createTemporary(
      lob_loc     => entityBody
      , cache     => true
    );
    loop
      utl_http.read_text( resp, buff, Buff_Size);
      dbms_lob.writeAppend( entityBody, length( buff), buff);
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
            'Ошибка при получении ответа.'
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



-- processHttpRequest
begin

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
        'Ошибка при выполнении HTTP-запроса ('
        || ' maxWaitSecond=' || maxWaitSecond
        || ').'
      )
    , true
  );
end processHttpRequest;

end pkg_WebUtility;
/
