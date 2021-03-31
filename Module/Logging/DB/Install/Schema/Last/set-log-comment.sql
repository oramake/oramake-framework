-- script: Install/Schema/Last/set-log-comment.sql
-- ������������� ����������� � ����� �� ������� lg_log.
--
-- ���������:
-- tableName                  - ��� ������� ��� ������������� ���
--                              ��������������� �����
--

define tableName = "&1"



comment on column &tableName..log_id is
  'Id ������ ����'
/
comment on column &tableName..sessionid is
  '������������� ������ (�������� v$session.audsid)'
/
comment on column &tableName..level_code is
  '��� ������ �����������'
/
comment on column &tableName..message_value is
  '������������� ��������, ��������� � ����������'
/
comment on column &tableName..message_label is
  '��������� ��������, ��������� � ����������'
/
comment on column &tableName..message_text is
  '����� ��������� (������ 4000 �������� � ������ �������� ���������)'
/
comment on column &tableName..long_message_text_flag is
  '���� �������� (����� 4000 ��������) ��������� (1 ��, ����� null). ��� �������� ��������� � ���� message_text ����������� ������ ������ 4000 �������� ������ ��������, ������ ����� ��������� ����������� � ���� long_message_text ������� lg_log_data.'
/
comment on column &tableName..text_data_flag is
  '���� ������� ��������� ������, ��������� � ���������� (1 ��, ����� null). ��������� ������ ����������� � ���� text_data ������� lg_log_data.'
/
comment on column &tableName..context_level is
  '�������� ����������: ������� ���������� ��������� ���������� (null ��� ���������� ���������, 0 ��� ���������� ���������� � ������� �������������� ���������)'
/
comment on column &tableName..context_type_id is
  '�������� ����������: Id ���� ������������/������������ ��������� ���������� (null ���� �������� �� �������)'
/
comment on column &tableName..context_value_id is
  '�������� ����������: �������������, ��������� � �����������/����������� ���������� ���������� (null ���� �������� �� �������)'
/
comment on column &tableName..open_context_log_id is
  '�������� ����������: Id ������ ���� �������� ������������/������������ ��������� (null ���� �������� �� �������, ����� log_id ��� �������� ���������)'
/
comment on column &tableName..open_context_log_time is
  '�������� ����������: ����� ������������ ������ ���� �������� ������������/������������ ��������� (null ���� �������� �� �������, ����� log_time ��� �������� ���������)'
/
comment on column &tableName..open_context_flag is
  '�������� ����������: ���� �������� ��������� ���������� (1 - �������� ���������, 0 - �������� ���������, -1 - �������� � ����������� �������� ���������, null - �������� �� �������)'
/
comment on column &tableName..context_type_level is
  '�������� ����������: ������� ��������������� ������������/������������ ���� ��������� ���������� (������� � 1, null ���� �������� �� ������� ��� �� �������� ���������)'
/
comment on column &tableName..module_name is
  '��� ������, ����������� ������'
/
comment on column &tableName..object_name is
  '��� ������� ������ (������, ����, �������), ����������� ������'
/
comment on column &tableName..module_id is
  'Id ������, ����������� ������ (���� ������� ����������)'
/
comment on column &tableName..log_time is
  '����� ������������ ������ ����'
/
comment on column &tableName..date_ins is
  '���� ���������� ������ � �������'
/
comment on column &tableName..operator_id is
  'Id ��������� (�� ������ AccessOperator)'
/
