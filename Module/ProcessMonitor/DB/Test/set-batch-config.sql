begin
  begin pkg_Operator.SetCurrentUserID(9);end;
  pkg_ProcessMonitor.SetBatchConfig( 
    batchShortName => 'TestBatch'
    , warningTimePercent => 0
    , warningTimeHour => 0
    , abortTimeHour => 0
    , orakillWaitTimeHour => 0
    , traceTimeHour => 0
    , sqlTraceLevel => 12
    , isFinalTraceSending => 1
  );     
end;

begin
  begin pkg_Operator.SetCurrentUserID(9);end;
  pkg_ProcessMonitor.DeleteBatchConfig( 
    batchShortName => 'TestBatch'
  );     
end;

select * from prm_batch_config
