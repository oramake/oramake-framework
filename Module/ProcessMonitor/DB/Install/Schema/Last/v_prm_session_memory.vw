-- view: v_prm_session_memory
-- Использование памяти сессиями Oracle.
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
  'Использование памяти сессиями Oracle [ SVN root: Oracle/Module/ProcessMonitor]'
/
comment on column v_prm_session_memory.sid is
  'Параметры сессии Oracle: sid'
/
comment on column v_prm_session_memory.serial# is
  'Параметры сессии Oracle: serial#'
/
comment on column v_prm_session_memory.pga_memory is
  'Максимальный размер используемой памяти PGA'
/
comment on column v_prm_session_memory.batch_short_name is
  'Короткое наименование батча'
/
comment on column v_prm_session_memory.username is
  'Поле username из v$session'
/
comment on column v_prm_session_memory.terminal is
  'Поле terminal из v$session'
/
comment on column v_prm_session_memory.program is
  'Поле program из v$session'
/
comment on column v_prm_session_memory.logon_time is
  'Поле logon_time из v$session'
/


