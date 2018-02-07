-- script: Install/Grant/Last/run.sql
-- Выдает права на использование модуля.
--
-- Параметры:
-- toUserName                  - имя пользователя, которому выдаются права
--
-- Замечания:
--  - скрипт запускается под пользователем, которому принадлежат объекты модуля
--   ;
--

define toUserName = "&1"



grant
  execute
on
  pkg_FormatData
to
  &toUserName
/

create or replace synonym
  &toUserName..pkg_FormatData
for
  pkg_FormatData
/

grant select on v_fd_first_name_alias to &toUserName
/
create or replace synonym
  &toUserName..v_fd_first_name_alias
for
  v_fd_first_name_alias
/

grant select on v_fd_middle_name_alias to &toUserName
/
create or replace synonym
  &toUserName..v_fd_middle_name_alias
for
  v_fd_middle_name_alias
/

grant select on v_fd_no_value_alias to &toUserName
/
create or replace synonym
  &toUserName..v_fd_no_value_alias
for
  v_fd_no_value_alias
/



undefine toUserName
