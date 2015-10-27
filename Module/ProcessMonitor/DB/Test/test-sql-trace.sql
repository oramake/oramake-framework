begin
  begin pkg_Operator.SetCurrentUserID(9);end;
  pkg_ProcessMonitor.SqlTraceOn;
  pkg_processMonitor.SendTrace;
end;
