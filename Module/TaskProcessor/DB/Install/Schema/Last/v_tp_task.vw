-- view: v_tp_task
-- ������� ( ������������ �������������).
create or replace force view v_tp_task
as
select
  -- SVN root: Oracle/Module/TaskProcessor
  ts.task_id
  , ts.task_type_id
  , ts.task_status_code
  , ts.next_start_date
  , ts.sid
  , ts.serial#
  , ts.start_number
  , ts.start_date
  , ts.finish_date
  , case when ts.sid is not null then
      sysdate - ts.start_date
    else
      ts.finish_date - ts.start_date
    end
    * 86400
    as duration_second
  , ts.result_code
  , ts.exec_result
  , ts.error_code
  , ts.error_message
  , ts.manage_date
  , ts.manage_operator_id
  , ts.date_ins
  , ts.operator_id
from
  tp_task ts
/



comment on table v_tp_task is
  '������� ( ������������ �������������) [ SVN root: Oracle/Module/TaskProcessor]'
;
comment on column v_tp_task.task_id is
  'Id �������'
;
comment on column v_tp_task.task_type_id is
  'Id ���� �������'
;
comment on column v_tp_task.task_status_code is
  '��� ��������� �������'
;
comment on column v_tp_task.next_start_date is
  '���� ���������� ������� ( ���� ������� ����� � �������)'
;
comment on column v_tp_task.sid is
  'sid ������, � ������� ����������� ������� ( �� v$session)'
;
comment on column v_tp_task.serial# is
  'serial# ������, � ������� ����������� ������� ( �� v$session)'
;
comment on column v_tp_task.start_number is
  '����� �������, ������� � 1 ( ���������� ��� ��������, ���� ������� �����������)'
;
comment on column v_tp_task.start_date is
  '���� ������� ( ���������� ��� ��������, ���� ������� �����������)'
;
comment on column v_tp_task.finish_date is
  '���� ���������� ����������'
;
comment on column v_tp_task.duration_second is
  '������������ ���������� ( � ��������)'
;
comment on column v_tp_task.result_code is
  '��� ���������� ����������'
;
comment on column v_tp_task.exec_result is
  '��������� ����������, ������������ ���������� ������������'
;
comment on column v_tp_task.error_code is
  '��� ������ ����������'
;
comment on column v_tp_task.error_message is
  '��������� �� ������ ����������'
;
comment on column v_tp_task.manage_date is
  '���� �������� �� ���������� �������� ( ��������, ���������� �� ������, ��������� � �.�.)'
;
comment on column v_tp_task.manage_operator_id is
  'Id ���������, ������������ �������� �� ���������� ��������'
;
comment on column v_tp_task.date_ins is
  '���� ���������� ������'
;
comment on column v_tp_task.operator_id is
  'Id ���������, ����������� ������'
;
