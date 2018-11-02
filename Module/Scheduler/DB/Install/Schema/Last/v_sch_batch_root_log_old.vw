-- view: v_sch_batch_root_log_old
-- Корневые записи лога по управлению и выполнению пакетных заданий (по данным
-- лога, созданным до обновления модуля Scheduler до версии 4.6.0).
--
create or replace force view v_sch_batch_root_log_old
(
  batch_id
  , log_id
  , message_type_code
  , message_text
  , date_ins
  , operator_id
)
as
Select
  /*+ index( lg SCH_LOG_IX_ROOT_BATCH_DATE_LOG) */
  lg.batch_id as batch_id
  , lg.log_id as log_id
  , lg.message_type_code as message_type_code
  , lg.message_text as message_text
  , lg.date_ins as date_ins
  , lg.operator_id as operator_id
from
  (
  select
    case when lg.parent_log_id is null
          and message_type_code in ( 'BSTART', 'BMANAGE')
          then
        lg.message_value
      end
      as batch_id
    , case when lg.parent_log_id is null
          and message_type_code in ( 'BSTART', 'BMANAGE')
          then
        lg.log_id
      end
      as log_id
    , case when lg.parent_log_id is null
          and message_type_code in ( 'BSTART', 'BMANAGE')
          then
        lg.date_ins
      end
      as date_ins
    , lg.message_type_code
    , lg.message_text
    , lg.operator_id
  from
    sch_log lg
  ) lg
where
  lg.batch_id is not null
/



comment on table v_sch_batch_root_log_old is
  'Корневые записи лога по управлению и выполнению пакетных заданий (по данным лога, созданным до обновления модуля Scheduler до версии 4.6.0) [ SVN root: Oracle/Module/Scheduler]'
/
