-- view: v_tp_task_type
-- ���� ������� ( ������������ �������������).
create or replace force view v_tp_task_type
as
select
  -- SVN root: Oracle/Module/TaskProcessor
  t.task_type_id
  , t.module_name
  , t.process_name
  , t.task_type_name_eng
  , t.task_type_name_rus
  , t.exec_command
  , t.file_name_pattern
  , t.access_role_short_name
  , t.task_keep_day
  , t.date_ins
  , t.operator_id
from
  tp_task_type t
/



comment on table v_tp_task_type is
  '���� ������� ( ������������ �������������) [ SVN root: Oracle/Module/TaskProcessor]'
/
comment on column v_tp_task_type.task_type_id is
  'Id ���� �������'
/
comment on column v_tp_task_type.module_name is
  '�������� ����������� ������'
/
comment on column v_tp_task_type.process_name is
  '�������� ����������� ��������, ��������������� ���� ��� �������'
/
comment on column v_tp_task_type.task_type_name_eng is
  '�������� ���� ������� ( ���.)'
/
comment on column v_tp_task_type.task_type_name_rus is
  '�������� ���� ������� ( ���.)'
/
comment on column v_tp_task_type.exec_command is
  '�������, ���������� ��� ��������� ( ���������� PL/SQL �����, �������� � �������������� ���������������� ����������)'
/
comment on column v_tp_task_type.file_name_pattern is
  '����� ����� ����� ( ��� like, ������������ ������ "\") � ������� ��� ��������� �������� ( ���� �������, �� ��� ���������� ������� ����� ��������� ���� � ���������� ������ ����� ���������, ����� ���� ��� ������� �� ������������)'
/
comment on column v_tp_task_type.access_role_short_name is
  '�������� ���� �� ������ AccessOperator, ����������� ��� ������� � �������� ����� ����'
/
comment on column v_tp_task_type.task_keep_day is
  '����� �������� ������� � ����, �� ��������� �������� �������������� �������������� ������� ������������� ��������� ( �� ��������� ������������)'
/
comment on column v_tp_task_type.date_ins is
  '���� ���������� ������'
/
comment on column v_tp_task_type.operator_id is
  'Id ���������, ����������� ������'
/
