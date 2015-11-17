-- script: Test/run.sql
-- Выполняет тестирование модуля.
-- Тестирование выполняется c помощью процедуры <pkg_FileTest.unitTest> для
-- файлов размером в 1 MB.
--
-- Используемые макромеременные:
-- loggingLevelCode           - уровень логирования ( по-умолчанию DEBUG)
-- httpInternetFileTest       - флаг тестирования выполнения операций по HTTP
--                              c файлами в Интернет ( 1 да, 0 нет ( по
--                              умолчанию))
--

@oms-default loggingLevelCode DEBUG
@oms-default httpInternetFileTest 0

set feedback off

exec lg_logger_t.getRootLogger().setLevel( '&loggingLevelCode');

set feedback on



@oms-run Test/AutoTest/unit.sql
@oms-run Test/AutoTest/fs-operation.sql
@oms-run Test/AutoTest/http-operation.sql
