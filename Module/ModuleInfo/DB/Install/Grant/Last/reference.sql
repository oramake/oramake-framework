-- script: Install/Grant/Last/reference.sql
-- Выдаёт права на создание ссылок на таблицы модуля.

define toUserName=&1

grant select, references on
  mod_module
to
  &toUserName
/

create or replace synonym &toUserName..mod_module for mod_module
/

undefine toUserName
