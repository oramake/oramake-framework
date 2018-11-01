-- script: Install/Schema/Last/lg_log.comment.sql
-- ������������� ����������� ��� ������� <lg_log>.
--

comment on table lg_log is
  '��� ������ ����������� ������� [ SVN root: Oracle/Module/Logging]'
/
comment on column lg_log.log_id is
  'Id ������ ����'
/
comment on column lg_log.sessionid is
  '������������� ������ (�������� v$session.audsid ���� ���������� ������������� �������� ���� v$session.audsid ����� 0)'
/
comment on column lg_log.level_code is
  '��� ������ �����������'
/
comment on column lg_log.message_value is
  '������������� ��������, ��������� � ����������'
/
comment on column lg_log.message_label is
  '��������� ��������, ��������� � ����������'
/
comment on column lg_log.message_text is
  '����� ���������'
/
comment on column lg_log.context_level is
  '�������� ����������: ������� ���������� ��������� ���������� (null ��� ���������� ���������, 0 ��� ���������� ���������� � ������� �������������� ���������)'
/
comment on column lg_log.context_type_id is
  '�������� ����������: Id ���� ������������/������������ ��������� ���������� (null ���� �������� �� �������)'
/
comment on column lg_log.context_value_id is
  '�������� ����������: �������������, ��������� � �����������/����������� ���������� ���������� (null ���� �������� �� �������)'
/
comment on column lg_log.open_context_log_id is
  '�������� ����������: Id ������ ���� �������� ������������/������������ ��������� (null ���� �������� �� �������, ����� log_id ��� �������� ���������)'
/
comment on column lg_log.open_context_log_time is
  '�������� ����������: ����� ������������ ������ ���� �������� ������������/������������ ��������� (null ���� �������� �� �������, ����� log_time ��� �������� ���������)'
/
comment on column lg_log.open_context_flag is
  '�������� ����������: ���� �������� ��������� ���������� (1 - �������� ���������, 0 - �������� ���������, -1 - �������� � ����������� �������� ���������, null - �������� �� �������)'
/
comment on column lg_log.context_type_level is
  '�������� ����������: ������� ��������������� ������������/������������ ���� ��������� ���������� (������� � 1, null ���� �������� �� ������� ��� �� �������� ���������)'
/
comment on column lg_log.module_name is
  '��� ������, ����������� ������'
/
comment on column lg_log.object_name is
  '��� ������� ������ (������, ����, �������), ����������� ������'
/
comment on column lg_log.module_id is
  'Id ������, ����������� ������ (���� ������� ����������)'
/
comment on column lg_log.log_time is
  '����� ������������ ������ ����'
/
comment on column lg_log.date_ins is
  '���� ���������� ������ � �������'
/
comment on column lg_log.operator_id is
  'Id ��������� ( �� ������ AccessOperator)'
/
comment on column lg_log.parent_log_id is
  '���������� ����: Id ������������ ������ ����'
/
comment on column lg_log.message_type_code is
  '���������� ����: ��� ���� ���������'
/
