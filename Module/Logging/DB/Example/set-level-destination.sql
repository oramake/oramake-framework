-- Установка уровня и назначения логирования (пример)

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
/



prompt Rows in lg_log:

select
  lg.level_code
  , lg.message_text
from
  v_lg_current_log lg
where
  lg.module_name = 'TestModule'
order by
  lg.log_id
/
