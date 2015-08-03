-- script: Install/Grant/Last/run.sql
-- Выдает права на использование модуля всем пользователям.
-- Реализовано с помощью выдачи прав пользователю public и создания публичных
-- синонимов.
-- 
-- Замечания:
--   - для успешного выполнения скрипта требуются права на создание
--     публичных синонимов;



grant select on cmn_sequence to public
/
create or replace public synonym cmn_sequence for cmn_sequence
/

grant select, insert, delete, update on cmn_string_uid_tmp to public
/
create or replace public synonym cmn_string_uid_tmp for cmn_string_uid_tmp
/



grant execute on cmn_string_table_t to public
/
create or replace public synonym cmn_string_table_t for cmn_string_table_t
/

grant execute on pkg_Common to public
/
create or replace public synonym pkg_Common for pkg_Common
/

grant execute on pkg_Error to public
/
create or replace public synonym pkg_Error for pkg_Error
/

grant execute on str_concat to public
/
create or replace public synonym str_concat for str_concat
/
