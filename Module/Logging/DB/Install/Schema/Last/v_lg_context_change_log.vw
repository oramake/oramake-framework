-- view: v_lg_context_change_log
-- ��� ��������� ��������� ����������.
--
create or replace force view
  v_lg_context_change_log
as
select
  -- SVN root: Oracle/Module/Logging
  lg.log_id
  , lg.sessionid
  , lg.log_time
  , lg.context_type_id
  , lg.context_value_id
  , lg.open_context_flag
  , coalesce( cc1.open_log_id, cc2.open_log_id) as open_log_id
  , coalesce( cc1.close_log_id, cc2.close_log_id) as close_log_id
  , coalesce( cc1.open_log_time_utc, cc2.open_log_time_utc)
    as open_log_time_utc
  , coalesce( cc1.close_log_time_utc, cc2.close_log_time_utc)
    as close_log_time_utc
  , coalesce( cc1.open_context_level, cc2.open_context_level)
    as open_context_level
  , coalesce( cc1.close_context_level, cc2.close_context_level)
    as close_context_level
  , coalesce( cc1.open_level_code, cc2.open_level_code)
    as open_level_code
  , coalesce( cc1.open_message_value, cc2.open_message_value)
    as open_message_value
  , coalesce( cc1.open_message_label, cc2.open_message_label)
    as open_message_label
  , coalesce( cc1.close_level_code, cc2.close_level_code)
    as close_level_code
  , coalesce( cc1.close_message_value, cc2.close_message_value)
    as close_message_value
  , coalesce( cc1.close_message_label    , cc2.close_message_label)
    as close_message_label
  , lg.level_code
  , lg.message_value
  , lg.message_label
  , lg.message_text
  , lg.context_level
  , lg.open_context_log_id
  , lg.open_context_log_time
  , lg.context_type_level
  , lg.module_name
  , lg.object_name
  , lg.module_id
  , lg.date_ins
  , lg.operator_id
from
  lg_log lg
  left join v_lg_context_change cc1
    on cc1.context_type_id = lg.context_type_id
      and cc1.context_value_id = lg.context_value_id
      and cc1.open_log_time_utc = sys_extract_utc( lg.open_context_log_time)
      and cc1.open_log_id = lg.open_context_log_id
  left join v_lg_context_change cc2
    on cc2.context_type_id = lg.context_type_id
      and cc2.context_value_id is null
        and lg.context_value_id is null
      and cc2.open_log_time_utc = sys_extract_utc( lg.open_context_log_time)
      and cc2.open_log_id = lg.open_context_log_id
where
  lg.context_type_id is not null
/



comment on table v_lg_context_change_log is
  '��� ��������� ��������� ���������� [SVN root: Oracle/Module/Logging]'
/
comment on column v_lg_context_change_log.log_id is
  'Id ������ ����'
/
comment on column v_lg_context_change_log.sessionid is
  '������������� ������ (�������� v$session.audsid ���� ���������� ������������� �������� ���� v$session.audsid ����� 0)'
/
comment on column v_lg_context_change_log.log_time is
  '����� ������������ ������ ����'
/
comment on column v_lg_context_change_log.context_type_id is
  'Id ���� ��������� ����������'
/
comment on column v_lg_context_change_log.context_value_id is
  '�������������, ��������� � ���������� ����������'
/
comment on column v_lg_context_change_log.open_context_flag is
  '�������� ����������: ���� �������� ��������� ���������� (1 - �������� ���������, 0 - �������� ���������, -1 - �������� � ����������� �������� ���������)'
/
comment on column v_lg_context_change_log.open_log_id is
  'Id ������ ���� �������� ���������'
/
comment on column v_lg_context_change_log.close_log_id is
  'Id ������ ���� �������� ��������� (null ���� �������� �� ��� ������)'
/
comment on column v_lg_context_change_log.open_log_time_utc is
  '����� �������� ��������� (�� UTC)'
/
comment on column v_lg_context_change_log.close_log_time_utc is
  '����� �������� ��������� (�� UTC, null ���� �������� �� ��� ������)'
/
comment on column v_lg_context_change_log.open_context_level is
  '������� ���������� ��������� ���������� ��� �������� (0 ��� ���������� ���������� ���������)'
/
comment on column v_lg_context_change_log.close_context_level is
  '������� ���������� ��������� ���������� ��� �������� (0 ��� ���������� ���������� ���������)'
/
comment on column v_lg_context_change_log.open_level_code is
  '��� ������ ����������� ��������� �� �������� ���������'
/
comment on column v_lg_context_change_log.open_message_value is
  '������������� ��������, ��������� � ���������� �� �������� ���������'
/
comment on column v_lg_context_change_log.open_message_label is
  '��������� ��������, ��������� � ���������� �� �������� ���������'
/
comment on column v_lg_context_change_log.close_level_code is
  '��� ������ ����������� ��������� �� �������� ���������'
/
comment on column v_lg_context_change_log.close_message_value is
  '������������� ��������, ��������� � ���������� �� �������� ���������'
/
comment on column v_lg_context_change_log.close_message_label is
  '��������� ��������, ��������� � ���������� �� �������� ���������'
/
comment on column v_lg_context_change_log.level_code is
  '��� ������ �����������'
/
comment on column v_lg_context_change_log.message_value is
  '������������� ��������, ��������� � ����������'
/
comment on column v_lg_context_change_log.message_label is
  '��������� ��������, ��������� � ����������'
/
comment on column v_lg_context_change_log.message_text is
  '����� ���������'
/
comment on column v_lg_context_change_log.context_level is
  '�������� ����������: ������� ���������� ��������� ���������� (0 ��� ���������� ���������� � ������� �������������� ���������)'
/
comment on column v_lg_context_change_log.open_context_log_id is
  '�������� ����������: Id ������ ���� �������� ������������/������������ ��������� (����� log_id ��� �������� ���������)'
/
comment on column v_lg_context_change_log.open_context_log_time is
  '�������� ����������: ����� ������������ ������ ���� �������� ������������/������������ ��������� (����� log_time ��� �������� ���������)'
/
comment on column v_lg_context_change_log.context_type_level is
  '������� ��������������� ���� ��������� ���������� (������� � 1, null ��� �������������� ���������)'
/
comment on column v_lg_context_change_log.module_name is
  '��� ������, ����������� ������'
/
comment on column v_lg_context_change_log.object_name is
  '��� ������� ������ (������, ����, �������), ����������� ������'
/
comment on column v_lg_context_change_log.module_id is
  'Id ������, ����������� ������ (���� ������� ����������)'
/
comment on column v_lg_context_change_log.date_ins is
  '���� ���������� ������ � �������'
/
comment on column v_lg_context_change_log.operator_id is
  'Id ��������� ( �� ������ AccessOperator)'
/
