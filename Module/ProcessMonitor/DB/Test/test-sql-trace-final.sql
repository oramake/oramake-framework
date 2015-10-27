begin
  begin pkg_Operator.SetCurrentUserID(9);end;
  pkg_ProcessMonitor.SqlTraceOn( 
    isFinalTraceSending => 1
  );  
end;


select * from v_prm_registered_session
