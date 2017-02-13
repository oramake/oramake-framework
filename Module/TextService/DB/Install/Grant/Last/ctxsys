-- script: Install/Grant/Last/run.sql
-- Выдача прав и создание синонимов на объекты модуля.
-- Выполняется под пользователем, где установлен модуль.
-- Параметры:
--
--	toUserName - пользователь, которому выдаются права

define toUserName = "&1"

grant execute on pkg_TextService to &toUserName
/

create or replace synonym &toUserName..pkg_TextService for pkg_TextService
/

grant execute on CTX_DDL to &toUserName
/

create or replace synonym &toUserName..CTX_DDL for CTX_DDL
/

undefine toUserName
