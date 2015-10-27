-- view: v_prm_session_action
-- ������������� �� ��������� ������������������ ������ 
-- 
create or replace view v_prm_session_action
as
select
  /* SVN root: Oracle/Module/ProcessMonitor */
  r.registered_session_id
  , sid
  , serial#
  , a.session_action_code
  , a.email_recipient
  , a.email_subject
  , exists_session
  , planned_time
  , execution_time
from
  v_prm_session_existence r
inner join
  prm_session_action a
on
  a.registered_session_id = r.registered_session_id
/  
comment on table v_prm_session_action
is
'������������� �� ��������� ������������������ ������
[ SVN root: Oracle/Module/ProcessMonitor ]'
/
comment on column v_prm_session_action.registered_session_id
is 'Id ������������������ ������'
/
comment on column v_prm_session_action.sid is
'sid ������'
/
comment on column v_prm_session_action.serial# is
'serial# ������'
/
comment on column v_prm_session_action.session_action_code is
'��� ��������'
/
comment on column v_prm_session_action.email_recipient is
'���������� email-���������'
/
comment on column v_prm_session_action.email_subject is
'���� email-���������'
/
comment on column v_prm_session_action.exists_session is
'���� ������������� ������ Oracle'
/
comment on column v_prm_session_action.planned_time is
'��������������� ����� ���������� ��������'
/
comment on column v_prm_session_action.execution_time is
'�������� ����� ���������� ��������'
/
