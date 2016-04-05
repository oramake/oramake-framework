-- script: DB\Install\Grant\Last\run.sql
-- Выдает права на использование модуля.
--
-- Параметры:
-- toUserName                  - имя пользователя, которому выдаются права
--
-- Замечания:
--  - скрипт запускается под пользователем, которому принадлежат объекты модуля
--    ;
--

define toUserName = "&1"



grant
  select, delete
on
  svn_file_tmp
to
  &toUserName
/

create or replace synonym
  &toUserName..svn_file_tmp
for
  svn_file_tmp
/


grant
  execute
on
  pkg_Subversion
to
  &toUserName
/
create or replace synonym
  &toUserName..pkg_Subversion
for
  pkg_Subversion
/



undefine toUserName
