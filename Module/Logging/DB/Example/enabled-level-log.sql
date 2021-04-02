-- Узанть логиуется ли сообщение данного уровня
declare

  logger lg_logger_t := lg_logger_t.getLogger(
    moduleName    => 'TestModule'
    , objectName  => 'Test'
  );

begin
  logger.debug( 'start...');

  logger.info( 'working...');

  if logger.isDebugEnabled() then

    dbms_output.put_line('Debug Enabled');
  
  else
  
    dbms_output.put_line('Debug not Enabled');
  
  end if;
  
  if logger.isTraceEnabled() then

    dbms_output.put_line('Trace Enabled');
  
  else
  
    dbms_output.put_line('Trace not Enabled');
  
  end if;
  
end;
/
