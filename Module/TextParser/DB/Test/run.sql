-- script: Test/run.sql
-- ��������� ��� �����.
--

--@reconn

begin
--  lg_logger_t.getLogger('TextParser').setLevel( 'TRACE');
  pkg_TextParserTest.testCsvIterator();
end;
/
