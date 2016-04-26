-- script: Test/run.sql
-- Выполняет тестирование модуля.
-- Тестирование выполняется c помощью процедуры <pkg_FileTest.unitTest> для
-- файлов размером в 1 MB.
--
-- Используемые макромеременные:
-- testDirectory              - директория для тестирования
-- loggingLevelCode           - уровень логирования ( по-умолчанию DEBUG)
-- httpInternetFileTest       - флаг тестирования выполнения операций по HTTP
--                              c файлами в Интернет ( 1 да, 0 нет ( по
--                              умолчанию))
--

@oms-default testDirectory ""
@oms-default loggingLevelCode DEBUG
@oms-default httpInternetFileTest 0

set feedback off

exec lg_logger_t.getRootLogger().setLevel( '&loggingLevelCode');

set feedback on


begin
  if '&testDirectory' is not null then
    pkg_Common.outputMessage( 'setting test directory');
    pkg_FileTest.setTestDirectory( '&testDirectory');
  end if;
end;
/

@oms-run Test/AutoTest/unit.sql
@oms-run Test/AutoTest/fs-operation.sql
@oms-run Test/AutoTest/http-operation.sql
