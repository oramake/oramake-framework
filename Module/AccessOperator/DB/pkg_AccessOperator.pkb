create or replace package body pkg_AccessOperator is
/* package body: pkg_AccessOperator::body */



/* group: Переменные */

/* ivar: logger
  Логер пакета.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => pkg_Operator.Module_Name
  , objectName  => 'pkg_AccessOperator'
);



/* group: Функции */

/* func: mergeRole
  Добавление или обновление роли.

  Параметры:
  roleShortName               - короткое наименование роли
  roleName                    - наименование роли
  roleNameEn                  - наименование роли на английском
  description                 - описание роли

  Возврат:
  - была ли роль изменена ( добавлена или обновлена);
*/
function mergeRole(
  roleShortName varchar2
  , roleName varchar2
  , roleNameEn varchar2
  , description varchar2
)
return integer
is
  -- Количество изменённых записей
  changed integer;
-- mergeRole
begin
  merge into
    op_role r
  using
  (
  select
    roleShortName as role_short_name
    , roleName as role_name
    , roleNameEn as role_name_en
    , description
  from
    op_role
  minus
  select
    role_short_name
    , role_name
    , role_name_en
    , description
  from
    op_role
  ) s
  on (
    s.role_short_name = r.role_short_name
  )
  when not matched then insert (
    role_short_name
    , role_name
    , role_name_en
    , description
  )
  values (
    s.role_short_name
    , s.role_name
    , s.role_name_en
    , s.description
  )
  when matched then update set
    r.role_name       = s.role_name
    , r.role_name_en  = s.role_name_en
    , r.description   = s.description
  ;
  changed := sql%rowcount;
  return
    changed
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка добавления или обновления роли ('
        || 'roleShortName="' || roleShortName || '"'
        || ', roleName="' || roleName || '"'
        || ', roleNameEn="' || roleNameEn || '"'
        || ')'
      )
    , true
  );
end mergeRole;

end pkg_AccessOperator;
/
