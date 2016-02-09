-- script: Install/Schema/Last/revert.sql
-- Отменяет установку модуля, удаляя созданные объекты схемы.


-- Пакеты

drop package pkg_Common
/
drop package pkg_Error
/


-- Процедуры

drop function str_concat
/



-- Таблицы

drop table cmn_database_config
/
drop table cmn_sequence
/
drop table cmn_string_uid_tmp
/


-- Типы

drop type str_concat_t
/
drop type cmn_string_table_t
/
