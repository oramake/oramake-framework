-- Использование Warning и Error
declare
  testFlag boolean := false;
  
  logger lg_logger_t := lg_logger_t.getLogger(
    moduleName    => 'TestModule'
    , objectName  => 'Test'
  );

begin

  logger.info( 'working...');

  if testFlag = false then
      
    logger.warn( 'warning...');
      
  end if;
  
  raise_application_error(
    pkg_Error.ProcessError
    , 'exception'
  );
  
exception when others then
  
  logger.error('error...');

end;
/
