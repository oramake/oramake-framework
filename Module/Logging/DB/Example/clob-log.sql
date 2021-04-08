-- Использование типа Clob в логах
declare

  testText clob := 'test';
  
  logger lg_logger_t := lg_logger_t.getLogger(
    moduleName    => 'TestModule'
    , objectName  => 'Test'
  );
begin

  logger.info( messageText => 'working...'
    , textData => testText);

end;
/