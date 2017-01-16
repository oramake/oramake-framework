-- script: Install/Schema/Last/revert.sql
-- Отменяет установку модуля, удаляя созданные объекты схемы.


-- Пакеты

drop package pkg_DynamicSqlCache
/


-- Типы

@oms-drop-type dyn_cursor_cache_t
@oms-drop-type dyn_dynamic_sql_t
