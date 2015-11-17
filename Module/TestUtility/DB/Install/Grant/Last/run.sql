-- script: Install/Grant/Last/run.sql
-- Выдает необходимые права на использование объектов модуля
--
-- Параметры:
-- toUserName                  - имя пользователя, которому выдаются права
--
-- Замечания:
--  - скрипт запускается под пользователем, которому принадлежат объекты модуля;
--  - для выдачи прав public пользователь должен обладать правами
--    create public synonym
--

define toUserName = "&1"



grant
  execute
on
  pkg_TestUtility
to
  &toUserName
/

declare
  -- пользователь для выдачи прав
  toUserName varchar2(30) := lower( '&toUserName' );

  -- текст команды на выдачу прав
  grantText varchar2(100) := '
    create or replace $(synonymType) synonym $(synonymName)
    for pkg_TestUtility';

  -- тип синонима
  synonymType varchar2(30);
  -- наименование синонима
  synonymName varchar2(30);

begin

  if toUserName = 'public' then
    synonymType := 'public';
    synonymName := 'pkg_TestUtility';
  else
    synonymType := null;
    synonymName := '&toUserName..pkg_TestUtility';
  end if;

  execute immediate
    replace(
      replace( grantText, '$(synonymType)', synonymType )
      , '$(synonymName)', synonymName
      );

end;
/



undefine toUserName
