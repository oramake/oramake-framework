alter table
  sch_batch
add (
   activated_flag                  number(1,0) default 0
);

update
  sch_batch
set
  activated_flag =
  case when
    oracle_job_id is not null
  then
    1
  else
    0
  end
/
alter table sch_batch modify activated_flag not null
/

alter table sch_batch add
  constraint sch_batch_ck_activated check (
    activated_flag in (0, 1)
  );


alter table sch_batch drop column oracle_job_id
/

alter table sch_batch add  (
  oracle_job_id                integer as (
       case when
         activated_flag = 1
       then
         batch_id
       end
     )
)
/


comment on column sch_batch.activated_flag is
  'Флаг активности пакетного задания (1 - активированное, 0 - неактивированное)'
/
comment on column sch_batch.oracle_job_id is
  'Deprecated. Delete after changing OraMakeSystem'
/



