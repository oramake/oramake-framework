create or replace package body pkg_LoggingTest is
/* package body: pkg_LoggingTest::body */



/* group: Переменные */

/* ivar: logger
  Логер пакета.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => pkg_Logging.Module_Name
  , objectName  => 'pkg_LoggingTest'
);



/* group: Функции */

/* func: updateJavaUtilLoggingLevel
  Обновляет уровень логирования в java.util.logging
*/
procedure updateJavaUtilLoggingLevel(
  loggingConfigText varchar2
  , isTraceEnabled number
)
is
language java name
  'LoggingTest.updateJavaUtilLoggingLevel(
     java.lang.String
     , java.math.BigDecimal
   )';

/* proc: testLogger
  Тестирование логирования с помощью типа <lg_logger_t>.

  Параметры:
  testCaseNumber              - Номер проверяемого тестового случая
                                ( по умолчанию без ограничений)
*/
procedure testLogger(
  testCaseNumber integer := null
)
is

  -- Порядковый номер очередного тестового случая
  checkCaseNumber integer := 0;

  -- Корневой логгер
  rootLogger lg_logger_t := lg_logger_t.getRootLogger();

  -- Используемый в тестах логгер
  testLogger lg_logger_t := lg_logger_t.getLogger(
    moduleName    => 'TestModule'
    , objectName  => 'pkg_TestModule'
  );



  /*
    Тестирование логирования в таблицу.
  */
  procedure testLogToTable
  is



    /*
      Проверяет тестовый случай.
    */
    procedure checkCase(
      caseDescription varchar2
      , levelCode varchar2 := null
      , messageText varchar2
      , setLevelCode varchar2 := null
      , errorMessageMask varchar2 := null
      , nextCaseUsedCount pls_integer := null
    )
    is

      -- Описание тестового случая
      cinfo varchar2(200) :=
        'CASE ' || to_char( checkCaseNumber + 1)
        || ' "' || caseDescription || '": '
      ;

      errorMessage varchar2(32000);

      prevLogId integer;

      oldLevelCode lg_level.level_code%type;
      oldRootLevelCode lg_level.level_code%type;

      -- Id созданного сообщения
      logId integer;

      -- Число добавленных сообщений
      logCount integer;

      lgr lg_log%rowtype;

    -- checkCase
    begin
      checkCaseNumber := checkCaseNumber + 1;
      if pkg_TestUtility.isTestFailed()
            or testCaseNumber is not null
              and testCaseNumber
                not between checkCaseNumber
                  and checkCaseNumber + coalesce( nextCaseUsedCount, 0)
          then
        return;
      end if;
      logger.info( '*** ' || cinfo);

      select
        coalesce( max( t.log_id), 0)
      into prevLogId
      from
        lg_log t
      ;
      if setLevelCode is not null then
        oldRootLevelCode := rootLogger.getLevel();
        oldLevelCode := testLogger.getLevel();
      end if;
      begin
        if setLevelCode is not null then
          rootLogger.setLevel( setLevelCode);
          testLogger.setLevel( setLevelCode);
        end if;
        testLogger.log(
          levelCode     => coalesce( levelCode, testLogger.getEffectiveLevel())
          , messageText => messageText
        );
        select
          max( t.log_id)
          , count(*)
        into logId, logCount
        from
          lg_log t
        where
          t.log_id > prevLogId
        ;
        if setLevelCode is not null then
          rootLogger.setLevel( oldRootLevelCode);
          testLogger.setLevel( oldLevelCode);
        end if;
        if errorMessageMask is not null then
          pkg_TestUtility.failTest(
            failMessageText   =>
              cinfo || 'Успешное выполнение вместо ошибки'
          );
        end if;
      exception when others then
        if setLevelCode is not null then
          rootLogger.setLevel( oldRootLevelCode);
          testLogger.setLevel( oldLevelCode);
        end if;
        if errorMessageMask is not null then
          errorMessage := logger.getErrorStack();
          if errorMessage not like errorMessageMask then
            pkg_TestUtility.compareChar(
              actualString        => errorMessage
              , expectedString    => errorMessageMask
              , failMessageText   =>
                  cinfo || 'Сообщение об ошибке не соответствует маске'
            );
          end if;
        else
          pkg_TestUtility.failTest(
            failMessageText   =>
              cinfo || 'Выполнение завершилось с ошибкой:'
              || chr(10) || logger.getErrorStack()
          );
        end if;
      end;

      -- Проверка успешного результата
      if errorMessageMask is null then
        pkg_TestUtility.compareChar(
          actualString        => logCount
          , expectedString    => 1
          , failMessageText   =>
              cinfo || 'Некорректное число добавленных сообщений'
              || ' ( prevLogId=' || prevLogId || ')'
        );

        if logId is not null then
          select
            t.*
          into lgr
          from
            lg_log t
          where
            t.log_id = logId
          ;
        end if;

        if levelCode is not null then
          pkg_TestUtility.compareChar(
            actualString        => lgr.message_type_code
            , expectedString    =>
                case levelCode
                  when pkg_Logging.Fatal_LevelCode then
                    pkg_LoggingInternal.Error_MessageTypeCode
                  when pkg_Logging.Error_LevelCode then
                    pkg_LoggingInternal.Error_MessageTypeCode
                  when pkg_Logging.Warn_LevelCode then
                    pkg_LoggingInternal.Warning_MessageTypeCode
                  when pkg_Logging.Info_LevelCode then
                    pkg_LoggingInternal.Info_MessageTypeCode
                  when pkg_Logging.Debug_LevelCode then
                    pkg_LoggingInternal.Debug_MessageTypeCode
                  when pkg_Logging.Trace_LevelCode then
                    pkg_LoggingInternal.Debug_MessageTypeCode
                end
            , failMessageText   =>
                cinfo || 'Некорректное значение message_type_code'
          );
        end if;
        if length( messageText) <= 4000 then
          pkg_TestUtility.compareChar(
            actualString        => lgr.message_text
            , expectedString    => messageText
            , failMessageText   =>
                cinfo || 'Некорректное значение message_text'
          );
        end if;
      end if;
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.errorStack(
            'Ошибка при проверке тестового случая ('
            || ' caseNumber=' || checkCaseNumber
            || ', caseDescription="' || caseDescription || '"'
            || ').'
          )
        , true
      );
    end checkCase;



  -- testLogToTable
  begin
    pkg_TestUtility.beginTest( 'logger: log to table');

    -- Добавляем сообщения всех возможных уровней
    for rec in
          (
          select
            t.*
          from
            lg_level t
          where
            t.level_code not in (
              lg_logger_t.getAllLevelCode()
              , lg_logger_t.getOffLevelCode()
            )
          order by
            t.level_order
          )
        loop
      checkCase(
        'Сообщение уровня ' || rec.level_code
        , levelCode     => rec.level_code
        , setLevelCode  => rec.level_code
        , messageText   =>
            'Сообщение уровня "' || rec.level_description || '"'
            || ' ( код "' || rec.level_code || '")'
      );
    end loop;

    checkCase(
      'Сообщение длиной 32767 символов'
      , messageText   =>
          rpad( 'Сообщение длиной 32767 символов', 32767, '.')
    );

    pkg_TestUtility.endTest();
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при тестировании логирования в таблицу.'
        )
      , true
    );
  end testLogToTable;



-- testLogger
begin
  testLogToTable();
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при тестировании тестировании логирования через lg_logger_t ('
        || ' testCaseNumber=' || testCaseNumber
        || ').'
      )
    , true
  );
end testLogger;

end pkg_LoggingTest;
/
