-- script: Show/option.sql
-- Показывает используемые в текущей БД значения параметров пакетных заданий.
--
-- Параметры:
-- batchPattern               - маска для имени пакетов ( batch_short_name),
--

define batchPattern = "&1"



column object_type_short_name noprint

select
  ov.*
from
  v_opt_option_value ov
where
  ov.object_type_module_svn_root = 'Oracle/Module/Scheduler'
  and ov.object_type_short_name = 'batch'
  and ov.object_short_name like '&batchPattern'
order by
  ov.module_name
  , ov.object_short_name
  , ov.option_short_name
/

column object_type_short_name clear



undefine batchPattern
