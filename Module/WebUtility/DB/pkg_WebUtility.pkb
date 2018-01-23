create or replace package body pkg_WebUtility is
/* package body: pkg_WebUtility::body */



/* group: ���������� */

/* ivar: logger
  ����� ������.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => Module_Name
  , objectName  => 'pkg_WebUtility'
);



/* group: ������� */



/* group: �������� ������� �������� �� http */

/* proc: processHttpRequest
  ��������� ������ �� ��������� HTTP.

  ���������:
  statusCode                  - ��� ���������� ������� ( HTTP Status-Code)
                                ( �������)
  reasonPhrase                - �������� ���������� �������
                                ( HTTP Reason-Phrase)
                                ( �������, �������� 256 ��������)
  contentType                 - ��� ���� ������ ( HTTP Content-Type)
                                ( �������, �������� 1024 �������)
  entityBody                  - ���� ������ ( HTTP entity-body)
                                ( �������)
  execSecond                  - ����� ���������� �������
                                ( � ��������, -1 ���� �� ������� ��������)
                                ( �������)
  requestUrl                  - URL ��� ���������� �������
  requestText                 - ����� �������
  maxWaitSecond               - ������������ ����� �������� ������ �� �������
                                ( � ��������, �� ��������� 60 ������)
  headerText                  - ������ ���������� � �������
                                ( �� ��������� ���������� Content-Type
                                  � Content-Length)

  ���������:
  - ��������� ���������� � ���� ������
  (code)
  Host: ads.betweendigital.com
  Connection: keep-alive
  ...
  (end code)
  - ��� ��������� ���������� ������� ���������� ������ ����� ACL ������������,
    ����������� ���������
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

  -- HTTP-������
  req utl_http.req;

  -- ����� ������ ���������� HTTP-�������
  startTime number;



  /*
     ���������� HTTP-������
  */
  procedure writeRequest
  is

    len number := 1;

    maxVarchar2Length number := 32767;

    utf8RequestText clob;



    /*
      ��������� ���� ��������� �������.
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
      ��������� ������ ���������
    */
    procedure setHeaderList
    is
      -- ������������ ���������
      headerName varchar2( 1000);
      -- �������� ���������
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
          -- �� ������ ":"
          headerName :=
            trim(
              substr(
                header.column_value
              , 1
              , instr( header.column_value, ':') - 1)
            );
          -- ����� ������ ":"
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
            '������ ������� ������ ����������'
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

      -- ����������� � UTF-8
      utf8RequestText := convert( requestText, 'utf8');

      if headerText is null then
        setHeader( 'Content-Type', 'text/xml');
        -- ��������� ����� ���� ������� � ������ ����������� � UTF-8
        setHeader( 'Content-Length', dbms_lob.getLength( utf8RequestText));
      else
        setHeaderList();
      end if;

      -- ���������� ���� �������
      loop
        utl_http.write_text(
          req
        , substr( utf8RequestText, len, maxVarchar2Length)
        );
        len := len + maxVarchar2Length;
        exit when len > coalesce( dbms_lob.getLength( utf8RequestText), 0);
      end loop;
    exception when others then
      -- ��������� ������ � ������ ������
      utl_http.end_request( req);
      raise;
    end;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� �������� �������.'
        )
      , true
    );
  end writeRequest;



  /*
    ������ ����� � CLOB � ���� response.
  */
  procedure readResponse
  is

    -- ����� ��� ������ � CLOB
    buff varchar2(32767);
    Buff_Size constant integer := 32767;

    -- HTTP-�����
    resp utl_http.resp;

    nHeader integer;
    headerName  varchar2(256);
    headerValue varchar2(1024);

  begin
    resp := utl_http.get_response( req);
    statusCode := resp.status_code;
    reasonPhrase := resp.reason_phrase;

    -- ������������ ���� ��������� ������
    logger.trace( '*** HTTP response header: start');
    logger.trace(
      'HTTP: '|| resp.status_code || ' ' || resp.reason_phrase
    );
    for i in 1 .. utl_http.get_header_count( resp) loop
      utl_http.get_header( resp, i, headerName, headerValue);
      logger.trace( headerName || ': ' || headerValue);

      -- ��������� �������� �������� �����
      if headerName = 'Content-Type' then
        contentType := substr( headerValue, 1, 1024);
      end if;
    end loop;
    logger.trace( '*** HTTP response header: finish');

    -- ��������� ���� ������ � CLOB
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
      -- ���������� ������������ ���������� ������ ��� ������
      utl_http.end_response( resp);
      logger.clearErrorStack();
    when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.errorStack(
            '������ ��� ��������� ������.'
          )
        , true
      );
  end readResponse;



  /*
    ���������� ������������ ���������� ������� � ��������.
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

  -- ������������ ����� �������� ������ ( �� ��������� 60 ������, ���
  -- ������������� �������� �� ��������� � utl_http)
  utl_http.set_transfer_timeout( coalesce( maxWaitSecond, 60));

  startTime := dbms_utility.get_time() / 100;
  execSecond := -1;

  writeRequest();
  readResponse();

  -- ���������� ����� ����������
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
        '������ ��� ���������� HTTP-������� ('
        || ' maxWaitSecond=' || maxWaitSecond
        || ').'
      )
    , true
  );
end processHttpRequest;

end pkg_WebUtility;
/
