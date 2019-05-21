alter table
  sch_batch
add (
   active_flag                  number(1,0) default 0
);

update
  sch_batch
set
  active_flag =
  case when
    oracle_job_id is not null
  then
    1
  else
    0
  end
  , oracle_job_id = null
/
alter table sch_batch modify active_flag not null
/

comment on column sch_batch.active_flag is
  'Флаг активности пакетного задания (1 - активированное, 0 - неактивированное)'
/
comment on column sch_batch.oracle_job_id is
  'Deprecated. Delete after changing OraMakeSystem'
/



