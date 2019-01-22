BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
   job_name             => 'test_scheduler_job',
   job_type             => 'PLSQL_BLOCK',
   job_action           => '
BEGIN
  insert into t(a) values(sysdate);
  commit;
END;',
   start_date           => sysdate,
--  repeat_interval      => 'FREQ=HOURLY',
--   end_date             => '12-JAN-2019 1.00.00AM US/Pacific',
   enabled              =>  TRUE,
   comments             => 'Test create job');
END;
/

