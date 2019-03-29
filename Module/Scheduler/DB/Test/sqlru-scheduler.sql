drop sequence TEST_CORA_48;
CREATE SEQUENCE TEST_CORA_48
  START WITH 0
  MAXVALUE 999999999
  MINVALUE 0
  CYCLE
  NOCACHE
  NOORDER;


BEGIN
  SYS.DBMS_SCHEDULER.DROP_JOB( 'CREATE_PFP_MONTH_INVOICES');
END;


bEGIN
  SYS.DBMS_SCHEDULER.CREATE_JOB
    (
       job_name        => 'CREATE_PFP_MONTH_INVOICES'
    ,repeat_interval => 'sysdate+1000000'
      ,job_class       => 'DBMS_JOB$'
      ,job_type        => 'PLSQL_BLOCK'
      ,job_action      => 'next_date := SYSDATE + TEST_CORA_48.NEXTVAL / 60 / 60 /24;'
      , enabled => true
       , auto_drop => false
    );
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'CREATE_PFP_MONTH_INVOICES'
     ,attribute => 'RESTARTABLE'
     ,value     => TRUE);
/*  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'CREATE_PFP_MONTH_INVOICES'
     ,attribute => 'LOGGING_LEVEL'
     ,value     => SYS.DBMS_SCHEDULER.LOGGING_RUNS); */
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL
    ( name      => 'CREATE_PFP_MONTH_INVOICES'
     ,attribute => 'MAX_FAILURES');
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL
    ( name      => 'CREATE_PFP_MONTH_INVOICES'
     ,attribute => 'MAX_RUNS');
  BEGIN
    SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
      ( name      => 'CREATE_PFP_MONTH_INVOICES'
       ,attribute => 'STOP_ON_WINDOW_CLOSE'
       ,value     => FALSE);
  EXCEPTION
    -- could fail if program is of type EXECUTABLE...
    WHEN OTHERS THEN
      NULL;
  END;
/*  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'CREATE_PFP_MONTH_INVOICES'
     ,attribute => 'JOB_PRIORITY'
     ,value     => 1);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL
    ( name      => 'CREATE_PFP_MONTH_INVOICES'
     ,attribute => 'SCHEDULE_LIMIT');
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'CREATE_PFP_MONTH_INVOICES'
     ,attribute => 'AUTO_DROP'
     ,value     => FALSE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'CREATE_PFP_MONTH_INVOICES'
     ,attribute => 'RAISE_EVENTS'
     ,value     => SYS.DBMS_SCHEDULER.JOB_STARTED + SYS.DBMS_SCHEDULER.JOB_SUCCEEDED + SYS.DBMS_SCHEDULER.JOB_FAILED + SYS.DBMS_SCHEDULER.JOB_BROKEN + SYS.DBMS_SCHEDULER.JOB_COMPLETED + SYS.DBMS_SCHEDULER.JOB_STOPPED + SYS.DBMS_SCHEDULER.JOB_SCH_LIM_REACHED + SYS.DBMS_SCHEDULER.JOB_DISABLED + SYS.DBMS_SCHEDULER.JOB_CHAIN_STALLED); */
 /* SYS.DBMS_SCHEDULER.ENABLE
    (name                  => 'CREATE_PFP_MONTH_INVOICES'); */
END;
/

select next_run_date from user_scheduler_jobs where job_name='CREATE_PFP_MONTH_INVOICES';


select TEST_CORA_48.nextval from dual


begin
  pkg_TaskHandler.sendStopCommand();
end;


select sysdate + 1000000 from dual

