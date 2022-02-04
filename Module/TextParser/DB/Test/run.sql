-- script: Test/run.sql
-- Выполняет все тесты.
--

--@reconn

begin
--  lg_logger_t.getLogger('TextParser').setLevel( 'TRACE');
  pkg_TextParserTest.testCsvIterator();
end;
/
