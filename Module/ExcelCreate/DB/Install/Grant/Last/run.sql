-- script: Install/Grant/Last/run.sql
-- Выдает права на использование модуля всем пользователям.
-- Реализовано с помощью выдачи прав пользователю public и создания публичных
-- синонимов.
--
-- Замечания:
--  - для успешного выполнения скрипта требуются права на создание
--    публичных синонимов;



grant execute on pkg_ExcelCreate to public
/
create or replace public synonym pkg_ExcelCreate for pkg_ExcelCreate
/
grant execute on pkg_ExcelCreateUtility to public
/
create or replace public synonym pkg_ExcelCreateUtility for pkg_ExcelCreateUtility
/
