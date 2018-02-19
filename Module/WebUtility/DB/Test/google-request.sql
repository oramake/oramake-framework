set define off

declare
  statusCode integer;
  reasonPhrase varchar2( 256);
  contentType varchar2( 1024);
  entityBody clob;
  execSecond number;

begin
  lg_logger_t.getRootLogger().setLevel( lg_logger_t.getTraceLevelCode());
  -- Sending a test request to www.google.com
  pkg_WebUtility.execHttpRequest(
    statusCode    => statusCode
  , reasonPhrase  => reasonPhrase
  , contentType   => contentType
  , entityBody    => entityBody
  , execSecond    => execSecond
  , requestUrl    => 'http://www.google.ru/search?newwindow=1&q=test&oq=test'
  , requestText   => ''
  , headerList    => wbu_header_list_t(
      wbu_header_t( 'Upgrade-Insecure-Requests', '1')
      , wbu_header_t(
          'User-Agent'
          , 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.132 Safari/537.36'
        )
    )
  );
end;
/

set define on
