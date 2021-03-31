-- view: v_lg_current_log
-- ��� ������ ����������� ������� ������� ������.
--
create or replace force view
  v_lg_current_log
as
select
  -- SVN root: Oracle/Module/Logging
  t.log_id
  , t.sessionid
  , t.level_code
  , t.message_value
  , t.message_label
  , t.message_text
  , t.long_message_text_flag
  , t.text_data_flag
  , t.context_level
  , t.context_type_id
  , t.context_value_id
  , t.open_context_log_id
  , t.open_context_log_time
  , t.open_context_flag
  , t.context_type_level
  , t.module_name
  , t.object_name
  , t.module_id
  , t.log_time
  , t.date_ins
  , t.operator_id
  , t.long_message_text
  , t.full_message_text
  , t.text_data
from
  v_lg_log t
where
  t.sessionid = sys_context('USERENV','SESSIONID')
/



comment on table v_lg_current_log is
  '��� ������ ����������� ������� ������� ������ [ SVN root: Oracle/Module/Logging]'
/
comment on column v_lg_current_log.long_message_text is
  '����� �������� ��������� (������ �� 4001 �� 32767 ��������)'
/
comment on column v_lg_current_log.full_message_text is
  '������ ����� ���������'
/
comment on column v_lg_current_log.text_data is
  '��������� ������, ��������� � ����������'
/
-- ������������� ����������� � �����
@oms-run Install/Schema/Last/set-log-comment.sql v_lg_current_log
