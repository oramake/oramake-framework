-- script: Install/Grant/Last/run.sql
-- Выдает права на использование модуля всем пользователям.
-- Реализовано с помощью выдачи прав пользователю public и создания публичных
-- синонимов.
--
-- Замечания:
--  - для успешного выполнения скрипта требуются права на создание
--    публичных синонимов;



grant execute on dyn_cursor_cache_t to public
/
create or replace public synonym dyn_cursor_cache_t for dyn_cursor_cache_t
/

grant execute on dyn_dynamic_sql_t to public
/
create or replace public synonym dyn_dynamic_sql_t for dyn_dynamic_sql_t
/
