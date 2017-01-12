-- script: Install/Schema/Last/revert.sql
-- Отменяет установку модуля, удаляя созданные объекты схемы.


-- Пакеты

drop package pkg_DataSync
/


-- Типы

@oms-drop-type dsn_data_sync_source_t
@oms-drop-type dsn_data_sync_t
