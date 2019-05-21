-- view: v_sch_batch_operation
-- �������� �� ���������� � ���������� �������� �������.
--
create or replace force view
  v_sch_batch_operation
as
select
  cc.open_log_id as start_log_id
  , cc.context_value_id as batch_id
  , cc.open_message_label as batch_operation_label
  , case
      when
          cc.open_message_label in (
            'ABORT' -- pkg_SchedulerMain.Abort_BatchMsgLabel
            , 'DEACTIVATE' -- pkg_SchedulerMain.Deactivate_BatchMsgLabel
          )
        then
          cc.open_message_value
      when
          cc.open_message_label = 'EXEC' -- pkg_SchedulerMain.Exec_BatchMsgLabel
        then
          cc.sessionid
      when
          -- pkg_SchedulerMain.StopHandler_BatchMsgLabel
          cc.open_message_label = 'STOP_HANDLER'
        then
          -- sessionid ��� ���������� ����� ������ (���� �� ������)
          coalesce( cc.close_message_value, cc.open_message_value)
    end
    as batch_sessionid
  , cc.context_type_level as execution_level
  , cc.open_log_time_utc as start_time_utc
  , cc.close_log_time_utc as finish_time_utc
  , cc.sessionid
  , cc.close_log_id as finish_log_id
  , case when
      cc.close_level_code != 'ERROR'
    then
      case when
        cc.open_message_label in (
          'ACTIVATE_ALL'      -- pkg_SchedulerMain.ActivateAll_BatchMsgLabel
          , 'DEACTIVATE_ALL'  -- pkg_SchedulerMain.DeactivateAll_BatchMsgLabel
        )
        -- pkg_Logging.Info_LevelCode
      then
        cc.close_message_value
      else
        1
      end
    end
    as processed_count
  , case when
      -- pkg_SchedulerMain.Exec_BatchMsgLabel
      cc.open_message_label = 'EXEC'
      -- pkg_Logging.Info_LevelCode
      and cc.close_level_code = 'INFO'
    then
      cc.close_message_value
    end
    as result_id
  , cc.context_type_id as batch_context_type_id
from
  v_lg_context_change cc
where
  cc.context_type_id =
    (
    select
      ct.context_type_id
    from
      v_mod_module md
      inner join lg_context_type ct
        on ct.module_id = md.module_id
    where
      -- pkg_SchedulerMain.Module_SvnRoot
      md.svn_root = 'Oracle/Module/Scheduler'
      -- pkg_SchedulerMain.Batch_CtxTpSName
      and ct.context_type_short_name = 'BATCH'
    )
/



comment on table v_sch_batch_operation is
  '�������� �� ���������� � ���������� �������� ������� [SVN root: Oracle/Module/Scheduler]'
/
comment on column v_sch_batch_operation.start_log_id is
  'Id ������ ���� ������ ���������� ��������'
/
comment on column v_sch_batch_operation.batch_id is
  'Id ��������� �������'
/
comment on column v_sch_batch_operation.batch_operation_label is
  '����� �������� ("ABORT" - ���������� ����������; "ACTIVATE" - ���������; "ACTIVATE_ALL" - �������� ���������; "DEACTIVATE" - �����������; "DEACTIVATE_ALL" - �������� �����������; "EXEC" - ����������; "SET_NEXT_DATE" - ��������� ���� ���������� �������; "STOP_HANDLER" - �������� ������� ��������� �����������)'
/
comment on column v_sch_batch_operation.batch_sessionid is
  '������������� ������ ��������� �������, � ������� ������� �������� (�������� v$session.audsid)'
/
comment on column v_sch_batch_operation.execution_level is
  '������� ����������� �������� (1 ��� �������� �������� ������)'
/
comment on column v_sch_batch_operation.start_time_utc is
  '����� ������ ���������� �������� (�� UTC)'
/
comment on column v_sch_batch_operation.finish_time_utc is
  '����� ���������� ���������� �������� (�� UTC)'
/
comment on column v_sch_batch_operation.sessionid is
  '������������� ������, � ������� ����������� �������� (�������� v$session.audsid)'
/
comment on column v_sch_batch_operation.finish_log_id is
  'Id ������ ���� ���������� ���������� ��������'
/
comment on column v_sch_batch_operation.processed_count is
  '����� ������������ �������� ������� (null � ������ ������ ��� ����������)'
/
comment on column v_sch_batch_operation.result_id is
  'Id ���������� ���������� ��������� ������� (� ������ �������� �� ���������� ��������� �������)'
/
comment on column v_sch_batch_operation.batch_context_type_id is
  'Id ���� ��������� ���������� ��� ����������� �������� ��� ��������� ��������� (���������� �������� ��� ���� ������� �������������, ��������� ��� ����������� ������������� � ��������)'
/

