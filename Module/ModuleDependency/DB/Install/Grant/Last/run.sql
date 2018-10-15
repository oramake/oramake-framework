-- script: Install/Grant/Last/run.sql
-- Выдача прав на объекты модуля
--
-- Параметры:
--   - toUserName - пользователь, которому нужно дать права и создать синонимы
--                  на объекты текущей схемы

define toUserName = "&1"


grant select, insert, update, delete on md_object_dependency to &toUserName
/
create or replace synonym &toUserName..md_object_dependency for md_object_dependency 
/

undefine toUserName
