--script: Show/run.sql
--���������� ����������� � ������ ������ ������.



select
  *
from
  v_sch_batch b
where
  b.sid is not null
order by
  b.this_date
/
