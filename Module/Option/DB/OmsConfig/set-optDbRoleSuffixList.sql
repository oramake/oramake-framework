-- script: ModuleConfig/Option/set-optDbRoleSuffixList.sql
-- Определяет суффиксы для ролей, с помощью которых выдаются права на все
-- параметры, созданные в определенной промышленной БД ( настройки могут
-- модифицироваться в пользовательской версии).
--
-- Возврат:
-- bind-переменная optDbRoleSuffixList типа refcursor с открытым курсором,
-- содержащим настройки ( по одной записи для каждой БД ( схемы БД)).
--
-- Колонки курсора:
-- production_db_name         - Имя промышленной БД ( возможно с указанием
--                              схемы)
-- local_role_suffix          - Суфикс ролей, выдающих права на все параметры,
--                              созданные в данной БД ( данной схеме БД)
--                              ( см.
--                              <pkg_OptionMain.LocalRoleSuffix_OptionSName>)
--
--

var optDbRoleSuffixList refcursor

begin
  open :optDbRoleSuffixList for
select
  a.production_db_name
  , coalesce(
      a.local_role_suffix
      -- определяем значение по умолчанию
      , a.production_db_name
    )
    as local_role_suffix
from
  (
  select
    trim( pkg_Common.getStringByDelimiter( t.column_value, ':', 1))
      as production_db_name
    , trim( pkg_Common.getStringByDelimiter( t.column_value, ':', 2))
      as local_role_suffix
  from
    table( cmn_string_table_t(
      -- Настройки в формате
      -- "<production_db_name>[@schemaName][:<local_role_suffix>]",
      --
      -- Замечания:
      --  - если указано имя схемы ( schemaName), то настройка применяется
      --    только для указанной схемы и имеет приоритет над настройкой для
      --    той же БД без указания схемы;
      --  - если local_role_suffix не задан, то ему будет назначено значение
      --    по-умолчанию ( см. выше);
      'ProdDb: Prod'
      , 'tst_om_main@ProdDb: ProdMain'
      , 'ProdDb2'
      --
    )) t
  ) a
;
end;
/
