-- script: Show/batch.sql
-- Показывает пакеты.
--
-- Параметры:
-- batchPattern               - Маска краткого имени пакетного задания
--                              (like по полю batch_short_name)
--

define batchPattern = "&1"



select
  *
from
  v_sch_batch b
where
  b.batch_short_name like '&batchPattern' escape '\'
order by
  b.batch_short_name
/



undefine batchPattern
