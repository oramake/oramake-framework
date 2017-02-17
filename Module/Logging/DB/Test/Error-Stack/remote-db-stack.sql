-- script: Test/Error-Stack/remote-db-stack.sql 
-- Пример использования логирования стека ошибок при работе по линку.
-- Перед выполнением на удалённой базе следует выполнить скрипт 
-- <Test/Error-Stack/error-stack.sql>.
declare
  lg lg_logger_t := lg_logger_t.GetLogger(
    moduleName => 'Test'
    , objectName => 'TestBlock'
  );
  dblink varchar2( 30) := '&dblink';

  procedure Internal
  is
    a integer;
  begin
    execute immediate 
'begin drop_me_tmp100@' || dblink || ';end;'   
    ;
  exception when others then
                                       -- Откатываем возможную созданную 
                                       -- распределённую транзакцию
    rollback;
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , lg.RemoteErrorStack( 
          'Ошибка "Internal_"' || lpad( '!', 10000, '_')
          , dblink
        )
      , true
    );    
  end Internal;
   
begin
  Internal;   
exception when others then
  pkg_Common.OutputMessage( 
    lg.GetErrorStack
  );      
end;  

