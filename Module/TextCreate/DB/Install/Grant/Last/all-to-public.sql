--script: Install/Grant/Last/all-to-public.sql
--Выдает права на использование модуля всем пользователям.
--Реализовано с помощью выдачи прав пользователю public и создания публичных
--синонимов.
--
--Замечания:
--  - для успешного выполнения скрипта требуются права на создание/удаление
--    публичных синонимов;

grant execute on pkg_TextCreate to public
/
create or replace public synonym pkg_TextCreate for pkg_TextCreate
/
