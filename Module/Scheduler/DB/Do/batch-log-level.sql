-- script: Do/batch-log-level.sql
-- Устанавливает уровень логирования для батча.
--
-- Параметры:
-- batchShortName             - имя батча
-- loggingLevelCode           - уровень логирования батча
--                              ( "" для использования уровня по-умолчанию)
--
-- Замечания:
-- - в случае успешного выполнения скрипта выполняется commit;
--

define batchShortName = "&1"
define loggingLevelCode = "&2"

declare

  batchShortName sch_batch.batch_short_name%type := '&batchShortName';
  loggingLevelCode varchar2(30) := '&loggingLevelCode';

begin
  sch_batch_option_t( batchShortName).addString(
    optionShortName     => 'LoggingLevelCode'
    , optionName        => 'Уровень логирования пакетного задания'
    , stringValue       => loggingLevelCode
    , changeValueFlag   => 1
  );
  commit;
end;
/

undefine batchShortName
undefine loggingLevelCode
