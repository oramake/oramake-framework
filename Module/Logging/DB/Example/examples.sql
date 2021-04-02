/* Лог в одну строчку
*/
begin
  pkg_logging.logMessage('Hellow World');
end;



/* Посмотреть лог в той же сессии
Ещё можно увидеть его в выводе output
*/
select
  vl.*
from 
  v_lg_current_log vl
order by
  vl.date_ins
;



/* Установка уровня и логирование действий
*/
declare

  procedure f1( step integer)
  is

    logger lg_logger_t := lg_logger_t.getLogger(
      moduleName    => 'TestModule'
      , objectName  => 'f1'
    );

  begin
    logger.debug( 'f1(' || step || '): start...');

    logger.info( 'f1(' || step || '): working...');

    logger.trace( 'f1(' || step || '): finished');
  end f1;

begin

  -- Отключение вывода отладочных сообщений (включено в тестовых БД по
  -- умолчанию)
  lg_logger_t.getRootLogger().setLevel( lg_logger_t.getInfoLevelCode());
  f1( 1);

  -- Включение вывода отладочных сообщений для модуля TestModule
  lg_logger_t.getLogger('TestModule')
    .setLevel( lg_logger_t.getDebugLevelCode())
  ;
  f1( 2);

  -- Включение вывода трассировочных сообщений для модуля TestModule
  lg_logger_t.getLogger('TestModule')
    .setLevel( lg_logger_t.getTraceLevelCode())
  ;
  -- Вывод всех сообщений только через dbms_output
  pkg_Logging.setDestination( pkg_Logging.DbmsOutput_DestinationCode);
  f1( 3);

  -- Восстанавливаем назначение вывода по умолчанию
  pkg_Logging.setDestination( null);
end;



/* Появилась возможность добавлять в лог данные типа clob ( textData)
*/
declare

  procedure f( step integer)
  is
    
    testText clob := 'test';
  
    logger lg_logger_t := lg_logger_t.getLogger(
      moduleName    => 'TestModule'
      , objectName  => 'f'
    );

  begin
    logger.debug( 'f(' || step || '): start...');

    logger.info( messageText => 'f(' || step || '): working...'
      , textData => testText);

  end f;

begin
  
  f( 1);

end;



/*Логирование предупреждений и ошибок без необходимости создания исключения
(С исключениями можно поступать аналогично, но error не возвращает строку для исключения)
*/
declare

  procedure f( step integer)
  is
    
    testFlag boolean := false;
  
    logger lg_logger_t := lg_logger_t.getLogger(
      moduleName    => 'TestModule'
      , objectName  => 'f'
    );

  begin
    logger.debug( 'f(' || step || '): start...');

    logger.info( 'f(' || step || '): working...');

    if testFlag = false then
      
      logger.warn( 'f(' || step || '): have warning...');
      
    end if;
  end f;

begin

  f( 1);

end;



/*
*/
declare

  procedure f( step integer)
  is
    
    testFlag boolean := false;
  
    logger lg_logger_t := lg_logger_t.getLogger(
      moduleName    => 'TestModule'
      , objectName  => 'f'
    );

  begin
    logger.debug( 'f(' || step || '): start...');

    logger.info( 'f(' || step || '): working...');

    if logger.isDebugEnabled() then
      
      -- Можно применять для включения каких-либо действий если работает какой-либо уровень логирования
      dbms_output.put_line('Debug Enabled');
    
    end if;
  end f;

begin

  f( 1);

end;



/*Логирование стека ошибок
*/

/*Примеры логирования стека ошибок
*/

declare
  lg lg_logger_t := lg_logger_t.getLogger(
    moduleName => 'Test'
    , objectName => 'TestBlock'
  );

  procedure internal
  is
  begin
    raise_application_error(
      pkg_Error.ProcessError
      , 'Произошла ошибка' || lpad( '!', 1000, '_')
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , lg.errorStack( 'Ошибка "Internal"' || lpad( '!', 1000, '_'))
      , true
    );
  end internal;

begin
  internal();
exception when others then
  pkg_Common.outputMessage(
    lg.getErrorStack()
  );
end;
/

declare
  lg lg_logger_t := lg_logger_t.getLogger(
    moduleName => 'Test'
    , objectName => 'TestBlock'
  );

  procedure internal
  is
  begin
    raise_application_error(
      pkg_Error.ProcessError
      , 'Произошла ошибка' || lpad( '!', 1000, '_')
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , lg.errorStack( 'Ошибка "Internal_"' || lpad( '!', 1000, '_'))
      , true
    );
  end internal;

  procedure internal2
  is
    errorMessage varchar2( 32267);
  begin
    begin
      internal();
    exception when others then
      errorMessage := lg.getErrorStack();
    end;

    -- Нужны промежуточные результаты стека в errorMessage
    raise_application_error(
      pkg_Error.ProcessError
      , 'Произошла ошибка обработки' || lpad( '!', 100, '_')
          || '"' || errorMessage || '"'
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , lg.errorStack( 'Ошибка "Internal_2"' || lpad( '!', 1000, '_'))
      , true
    );
  end internal2;

begin
  internal2();
exception when others then
  pkg_Common.outputMessage(
    lg.getErrorStack()
  );
end;
/

