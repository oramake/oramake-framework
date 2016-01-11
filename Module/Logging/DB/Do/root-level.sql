-- script: Do/root-level.sql
-- Установка уровня логирования для корневого логера.
--
-- Параметры:
-- 1                          - уровень логирования

begin
  lg_logger_t.getRootLogger().setLevel( '&1');
end;
/

