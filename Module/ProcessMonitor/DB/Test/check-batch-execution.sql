
alter system set job_queue_processes = 20;

select * from sch_batch where batch_short_name like 'Test%'

select * from dba_jobs where what like '%pkg_Scheduler%'

select * from sch_batch_content where batch_id = 309
select * from sch_job where job_id = 2249
update
  sch_job
set 
  job_what = 'begin pkg_ProcessMonitor.BatchBegin;
  pkg_TaskHandler.SetAction( ''TestSleep'');
  loop dbms_lock.sleep(1);end loop;
end;'
where
  job_id = 2249;
  


begin
  begin pkg_Operator.SetCurrentUserID(9);end;
  pkg_ProcessMonitor.CheckBatchExecution( warningTimePercent => 100, warningTimeHour => 0.1, 
    abortTimeHour => 0.1, orakillWaitTimeHour => 10);
end;


select * from prm_session_action

update prm_session_action set planned_time = sysdate where session_action_id = 3;

begin
  pkg_ProcessMonitor.CheckOraKill;
end;



select * from sch_batch where batch_short_name like 'Check%'

begin
  pkg_Scheduler.SETNEXTDATE( 309, 9);
  commit;
end; 

begin
  pkg_Scheduler.ACTIVATEBATCH( 71,9);
  pkg_Scheduler.SETNEXTDATE( 71, 9);
  commit;
end;

select * from v_opt_option where option_short_name like 'CheckBatch%Test'

begin
  begin pkg_Operator.SetCurrentUserID(9);end;
  -- abort
  pkg_Option.SetInteger(688,10/60/60);
--  pkg_Option.SetInteger(690,1);
  -- warning 
  pkg_Option.SetInteger(690, 1/60/60);
  pkg_Option.SetInteger(692, 100);
  -- minWarning
  pkg_Option.SetInteger(2534, 0);
  -- orakill
  pkg_Option.SetInteger(2532, 10/60/60);
end;

insert into opt_option( option_name, option_short_name, is_global, operator_id, mask_id)
values( 'TestBatchSqlTraceLevelTest','TestBatchSqlTraceLevelTest',1,9,1);

select * from opt_option where option_short_name like 'TestBatch%'

insert into opt_option_value( option_id,integer_value,operator_id) 
values( 2525, 12, 9);

