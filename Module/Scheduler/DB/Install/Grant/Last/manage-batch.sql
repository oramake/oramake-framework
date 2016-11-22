-- script: Install/Grant/Last/manage-batch.sql
-- Выдает необходимые права для управления выполнением пакетных заданий.
--
-- Параметры:
-- toUserName                  - имя пользователя, которому выдаются права
--
-- Замечания:
--  - скрипт запускается под пользователем, которому принадлежат объекты модуля
--   ;
--

define toUserName = "&1"


prompt grant execute on pkg_Scheduler to &toUserName
grant
  execute
on
  pkg_Scheduler
to
  &toUserName
/


prompt create synonym &toUserName..pkg_Scheduler for pkg_Scheduler

create or replace synonym
  &toUserName..pkg_Scheduler
for
  pkg_Scheduler
/


prompt grant select on sch_batch to &toUserName

grant
  select
on
  sch_batch
to
  &toUserName
/

prompt create synonym &toUserName..sch_batch for sch_batch

create or replace synonym
  &toUserName..sch_batch
for
  sch_batch
/


prompt grant select on v_sch_batch_root_log to &toUserName

grant
  select
on
  v_sch_batch_root_log
to
  &toUserName
/


prompt create synonym &toUserName..v_sch_batch_root_log for v_sch_batch_root_log

create or replace synonym
  &toUserName..v_sch_batch_root_log
for
  v_sch_batch_root_log
/


undefine toUserName
