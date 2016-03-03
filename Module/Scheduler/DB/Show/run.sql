--script: Show/run.sql
--ѕоказывает выполн€емые в данный момент пакеты.



select
  *
from
  v_sch_batch b
where
  b.sid is not null
order by
  b.this_date
/
