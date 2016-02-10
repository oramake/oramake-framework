-- script: Install/Schema/Last/Common/revert.sql
-- Отменяет установку модуля, удаляя общие объекты схемы.
--

-- Пакеты
drop trigger lg_after_server_error
/
