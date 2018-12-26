-- script: Install/Grant/1.1.0/run.sql
-- Выдает права на использование объекта <dyn_cursor_cache_t> всем
-- пользователям.

grant execute on dyn_cursor_cache_t to public
/
create or replace public synonym dyn_cursor_cache_t for dyn_cursor_cache_t
/
