create or replace package pkg_AccessOperator is
/* package: pkg_AccessOperator
  ѕакет дл€ изменени€ данных модул€.

  SVN root: Oracle/Module/AccessOperator
*/



/* group: ‘ункции */

/* pfunc: mergeRole
  ƒобавление или обновление роли.

  ѕараметры:
  roleShortName               - короткое наименование роли
  roleName                    - наименование роли
  roleNameEn                  - наименование роли на английском
  description                 - описание роли

  ¬озврат:
  - была ли роль изменена ( добавлена или обновлена);

  ( <body::mergeRole>)
*/
function mergeRole(
  roleShortName varchar2
  , roleName varchar2
  , roleNameEn varchar2
  , description varchar2
)
return integer;

end pkg_AccessOperator;
/
