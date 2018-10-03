-- script: Test/Error-Stack/stack-example.sql
-- Примеры использования
-- логирования стека ошибок
declare
  lg lg_logger_t := lg_logger_t.getLogger(
    moduleName => 'Test'
    , objectName => 'TestBlock'
  );

  procedure Internal
  is
  begin
    raise_application_error(
      pkg_Error.ProcessError
      , lg.ErrorStack( 'Произошла ошибка' || lpad( '!', 10000, '_'))
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , lg.ErrorStack( 'Ошибка "Internal_"' || lpad( '!', 10000, '_'))
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
/

declare
  lg lg_logger_t := lg_logger_t.getLogger(
    moduleName => 'Test'
    , objectName => 'TestBlock'
  );

  procedure Internal
  is
  begin
    raise_application_error(
      pkg_Error.ProcessError
      , lg.ErrorStack( 'Произошла ошибка' || lpad( '!', 1000, '_'))
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , lg.ErrorStack( 'Ошибка "Internal_"' || lpad( '!', 1000, '_'))
      , true
    );
  end Internal;

  procedure Internal2
  is
    errorMessage varchar2( 32267);
  begin
    begin
      Internal;
    exception when others then
      errorMessage := lg.GetErrorStack();
    end;
                                       -- Нужны промежуточные результаты
                                       -- стека в errorMessage
    raise_application_error(
      pkg_Error.ProcessError
      , lg.ErrorStack(
          'Произошла ошибка обработки' || lpad( '!', 100, '_')
          || '"' || errorMessage || '"'
        )
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , lg.ErrorStack( 'Ошибка "Internal_2"' || lpad( '!', 1000, '_'))
      , true
    );
  end Internal2;

begin
  Internal2;
exception when others then
  pkg_Common.OutputMessage(
    lg.GetErrorStack
  );
end;
/
