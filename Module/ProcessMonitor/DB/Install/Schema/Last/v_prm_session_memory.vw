-- view: v_prm_session_memory
-- ������������� ������ �������� Oracle.
--
create or replace force view
  v_prm_session_memory
as
select
  -- SVN root: Oracle/Module/ProcessMonitor
  s.sid
  , s.serial#
  , sst.value as pga_memory
  , b.batch_short_name
  , s.username
  , s.osuser
  , s.terminal
  , s.program
  , s.logon_time
from
  v$session s
inner join
  v$sesstat sst
on
  sst.sid = s.sid
inner join
  v$statname sn
on
  sn.statistic# = sst.statistic#
  and sn.name = 'session pga memory'
left join
  v_sch_batch b
on
  b.sid = s.sid
  and b.serial# = s.serial#
/


comment on table v_prm_session_memory is
  '������������� ������ �������� Oracle [ SVN root: Oracle/Module/ProcessMonitor]'
/
comment on column v_prm_session_memory.sid is
  '��������� ������ Oracle: sid'
/
comment on column v_prm_session_memory.serial# is
  '��������� ������ Oracle: serial#'
/
comment on column v_prm_session_memory.pga_memory is
  '������������ ������ ������������ ������ PGA'
/
comment on column v_prm_session_memory.batch_short_name is
  '�������� ������������ �����'
/
comment on column v_prm_session_memory.username is
  '���� username �� v$session'
/
comment on column v_prm_session_memory.terminal is
  '���� terminal �� v$session'
/
comment on column v_prm_session_memory.program is
  '���� program �� v$session'
/
comment on column v_prm_session_memory.logon_time is
  '���� logon_time �� v$session'
/


