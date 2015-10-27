-- view: v_prm_registered_session
-- ������ ������������� ����������������� ������ 
-- � ������, ��� ������� �� ��������� ��� �������
create or replace view v_prm_registered_session as 
select  
  /* SVN root: Oracle/Module/ProcessMonitor */
  registered_session_id
  , sid
  , serial#
  , spid 
  , sql_trace_level_set
  , sql_trace_date
from
  (
  select /*+index(s prm_reg_session_ux_exist)*/
    case is_finished when 0 then sid end as sid
    , case is_finished when 0 then serial# end as serial#
    , s.registered_session_id
    , s.sql_trace_level_set
    , s.spid
    , s.sql_trace_date
  from
    prm_registered_session s 
  ) s
where
  sid is not null
/  
comment on table v_prm_registered_session is
'������ ������������� ����������������� ������ 
� ������, ��� ������� �� ��������� ��� �������
[ SVN root: Oracle/Module/ProcessMonitor ]
'
/
comment on column v_prm_registered_session.registered_session_id is
'Id ������. ��������� ���� �������'
/
comment on column v_prm_registered_session.sid is
'sid ������ Oracle'
/
comment on column v_prm_registered_session.serial# is
'serial# ������ Oracle'
/
comment on column v_prm_registered_session.spid is
'spid ������ Oracle'
/
comment on column v_prm_registered_session.sql_trace_level_set is
'���������� ������� ����������� ��� ������'
/
comment on column v_prm_registered_session.sql_trace_date is
'����/����� ��������� �����������'
/
