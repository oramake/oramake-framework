--script: Install/Grant/Last/all-to-public.sql
--Выдает права на использование модуля всем пользователям.
--Реализовано с помощью выдачи прав пользователю public и создания публичных
--синонимов.
--
--Замечания:
--  - для успешного выполнения скрипта требуются права на создание/удаление
--    публичных синонимов;
--



grant select on lg_destination to public
/
create or replace public synonym lg_destination for lg_destination
/

grant select on lg_level to public
/
create or replace public synonym lg_level for lg_level
/



grant execute on pkg_Logging to public
/
create or replace public synonym pkg_Logging for pkg_Logging
/
grant execute on pkg_LoggingErrorStack to public
/
create or replace public synonym pkg_LoggingErrorStack for pkg_LoggingErrorStack
/

grant execute on lg_logger_t to public
/
create or replace public synonym lg_logger_t for lg_logger_t
/
