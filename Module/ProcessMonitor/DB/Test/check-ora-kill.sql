begin
  pkg_ProcessMonitor.CheckOraKill;
end;

select * from v_prm_registered_session;



select * from v_prm_registered_session

select * from prm_session_action where registered_session_id = 2;

select * from v_prm_session_existence

select * from prm_session_action
select * from v$session;
select * from v_prm_session_action

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
  , sysdate
from
  v_prm_session_existence r
inner join
  prm_session_action a
on
  a.registered_session_id = r.registered_session_id
where
  a.execution_time is null
  and
  ( a.planned_time <= sysdate and exists_session = 1
    or a.planned_time is null and exists_session = 0
  );

select * from sch_batch where batch_short_name like 'Check%'

begin
  pkg_Scheduler.ActivateBatch( 364, 9);
  pkg_Scheduler.SETNEXTDATE( 364, 9);
  commit;
end;

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
from
  v_prm_session_existence r
inner join
  prm_session_action a
on
  a.registered_session_id = r.registered_session_id
where
  a.execution_time is null
  and
  ( a.planned_time <= sysdate and exists_session = 1
    or a.planned_time is null and exists_session = 0
  );
  
select * from sch_batch where batch_short_name like 'Check%'  
