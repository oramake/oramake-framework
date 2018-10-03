create or replace package body pkg_LoggingTest is
/* package body: pkg_LoggingTest::body */



/* group: Константы */

/* iconst: None_Date
  Дата, указываемая в качестве значения параметра по умолчанию, позволяющая
  определить отсутствие явно заданного значения.
*/
None_Date constant date := DATE '1901-01-01';

/* iconst: None_String
  Строка, указываемая в качестве значения параметра по умолчанию, позволяющая
  определить отсутствие явно заданного значения.
*/
None_String constant varchar2(10) := '$(none)';

/* iconst: None_Integer
  Число, указываемая в качестве значения параметра по умолчанию, позволяющая
  определить отсутствие явно заданного значения.
*/
None_Integer constant integer := -9582095482058325832950482954832;



/* group: Переменные */

/* ivar: logger
  Логер пакета.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName          => pkg_Logging.Module_Name
  , objectName        => 'pkg_LoggingTest'
  , findModuleString  => pkg_Logging.Module_InitialPath
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
  rootLogger lg_logger_t;

  -- Логгер, используемый в тестах по умолчанию
  testLogger lg_logger_t;
  testModuleId integer;
  testModuleName lg_log.module_name%type;
  testObjectName lg_log.object_name%type;
  testModuleInitialPath lg_log.module_name%type;



  /*
    Подготавливает данные для теста.
  */
  procedure prepareTestData
  is



    /*
      Получает параметры тестового модуля.
    */
    procedure getTestModule
    is

      pragma autonomous_transaction;

    begin
      testModuleId := pkg_ModuleInfoTest.getTestModuleId(
        baseName => 'LoggingAutoTest'
      );
      select
        t.module_name
        , t.initial_svn_root || '@' || t.initial_svn_revision
      into testModuleName, testModuleInitialPath
      from
        v_mod_module t
      where
        t.module_id = testModuleId
      ;

      -- Фиксируем, т.к. если модуль был создан, то он будет невиден в
      -- при логировании (выполняемом в автономной транзакции)
      commit;
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.errorStack(
            'Ошибка при получении параметров тестового модуля.'
          )
        , true
      );
    end getTestModule;



  -- prepareTestData
  begin
    getTestModule();
    rootLogger := lg_logger_t.getRootLogger();
    testObjectName := 'pkg_TestPackage';
    testLogger := lg_logger_t.getLogger(
      moduleName    => testModuleName
      , objectName  => testObjectName
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при подготовке данных для теста.'
        )
      , true
    );
  end prepareTestData;



  /*
    Проверяет тестовый случай.
  */
  procedure checkCase(
    caseDescription varchar2
    , levelCode varchar2 := null
    , messageText varchar2 := null
    , moduleName varchar2 := None_String
    , objectName varchar2 := None_String
    , moduleId integer := None_Integer
    , usedLogger lg_logger_t := testLogger
    , setLevelCode varchar2 := lg_logger_t.getAllLevelCode()
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
      oldLevelCode := usedLogger.getLevel();
    end if;
    begin
      if setLevelCode is not null then
        usedLogger.setLevel( setLevelCode);
      end if;

      -- Исключаем одновременный вывод через dbms_output
      pkg_Logging.setDestination(
        destinationCode => pkg_Logging.Table_DestinationCode
      );

      usedLogger.log(
        levelCode     => coalesce( levelCode, lg_logger_t.getTraceLevelCode())
        , messageText =>
            coalesce(
              messageText
              , 'Сообщение для автотеста: ' || caseDescription
            )
      );

      -- Восстанавливаем значения по умолчанию
      pkg_Logging.setDestination( destinationCode => null);
      select
        max( t.log_id)
        , count(*)
      into logId, logCount
      from
        lg_log t
      where
        t.log_id > prevLogId
        and t.sessionid = sys_context('USERENV','SESSIONID')
        -- исключаем отладочные сообщения пакета pkg_LoggingInternal
        and not (
          nullif( 'Logging', t.module_name) is null
          and nullif( 'pkg_LoggingInternal', t.object_name) is null
        )
      ;
      if setLevelCode is not null then
        usedLogger.setLevel( oldLevelCode);
      end if;
      if errorMessageMask is not null then
        pkg_TestUtility.failTest(
          failMessageText   =>
            cinfo || 'Успешное выполнение вместо ошибки'
        );
      end if;
    exception when others then
      if setLevelCode is not null then
        usedLogger.setLevel( oldLevelCode);
      end if;
      pkg_Logging.setDestination( destinationCode => null);
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
          actualString        => lgr.level_code
          , expectedString    => levelCode
          , failMessageText   =>
              cinfo || 'Некорректное значение level_code'
        );
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
      if nullif( None_String, moduleName) is not null then
        pkg_TestUtility.compareChar(
          actualString        => lgr.module_name
          , expectedString    => moduleName
          , failMessageText   =>
              cinfo || 'Некорректное значение module_name'
        );
      end if;
      if nullif( None_String, objectName) is not null then
        pkg_TestUtility.compareChar(
          actualString        => lgr.object_name
          , expectedString    => objectName
          , failMessageText   =>
              cinfo || 'Некорректное значение object_name'
        );
      end if;
      if nullif( None_Integer, moduleId) is not null then
        pkg_TestUtility.compareChar(
          actualString        => lgr.module_id
          , expectedString    => moduleId
          , failMessageText   =>
              cinfo || 'Некорректное значение module_id'
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



  /*
    Проверка логирования в таблицу.
  */
  procedure checkLogToTable
  is
  begin

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

    checkCase(
      'Заполнение полей о модуле/объекте'
      , moduleName    => testModuleName
      , objectName    => testObjectName
      , moduleId      => testModuleId
    );

    checkCase(
      'Использование явно заданного moduleName'
      , usedLogger    =>
          lg_logger_t.getLogger(
            moduleName          => testModuleName || '_Expected'
            , objectName        => testObjectName
            , findModuleString  => testModuleName
          )
      , moduleName    => testModuleName || '_Expected'
      , objectName    => testObjectName
      , moduleId      => testModuleId
    );

    checkCase(
      'Заполнение полей о модуле/объекте: корневой логер'
      , usedLogger    => rootLogger
      , moduleName    => null
      , objectName    => null
      , moduleId      => null
    );

    checkCase(
      'Заполнение полей о модуле/объекте: неизвестный модуль'
      , usedLogger    =>
          lg_logger_t.getLogger(
            moduleName          => 'UnknownModule'
            , objectName        => 'pkg_UnknownPackage'
          )
      , moduleName    => 'UnknownModule'
      , objectName    => 'pkg_UnknownPackage'
      , moduleId      => null
    );

    checkCase(
      'Определение moduleId по findModuleString с initialPath'
      , usedLogger    =>
          lg_logger_t.getLogger(
            moduleName          =>
                -- Имя модуля должно быть уникально (иначе будет использован
                -- ранее созданный логер)
                'NewUnknownModule_9483'
            , objectName        => 'pkg_NewUnknownPackage'
            , findModuleString  => testModuleInitialPath
          )
      , moduleName    => 'NewUnknownModule_9483'
      , objectName    => 'pkg_NewUnknownPackage'
      , moduleId      => testModuleId
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при проверке логирования в таблицу.'
        )
      , true
    );
  end checkLogToTable;



  /*
    Проверка получения логера.
  */
  procedure checkGetLogger
  is
  begin
    checkCase(
      'Проверка getRootLogger()'
      , usedLogger    => lg_logger_t.getRootLogger()
      , moduleName    => ''
      , objectName    => ''
    );

    -- Используем уникальные префиксы чтобы обеспечить уникальность логеров
    -- (для исключения взаимного влияния тестовых случаев)

    checkCase(
      'Проверка getLogger( str)'
      , usedLogger    => lg_logger_t.getLogger( 's01.s2.s3.s4')
      , moduleName    => 's01'
      , objectName    => 's2.s3.s4'
    );
    checkCase(
      'Проверка getLogger( str1, str2)'
      , usedLogger    => lg_logger_t.getLogger( 's02.s2', 's3.s4')
      , moduleName    => 's02.s2'
      , objectName    => 's3.s4'
    );
    checkCase(
      'Проверка getLogger( loggerName)'
      , usedLogger    =>
          lg_logger_t.getLogger(
            loggerName      => 's03.s2.s3'
          )
      , moduleName    => 's03'
      , objectName    => 's2.s3'
    );
    checkCase(
      'Проверка getLogger( moduleName)'
      , usedLogger    =>
          lg_logger_t.getLogger(
            moduleName      => 's04.s2.s3'
          )
      , moduleName    => 's04.s2.s3'
      , objectName    => ''
    );
    checkCase(
      'Проверка getLogger( moduleName, objectName)'
      , usedLogger    =>
          lg_logger_t.getLogger(
            moduleName      => 's05.s2'
            , objectName    => 's3.s4'
          )
      , moduleName    => 's05.s2'
      , objectName    => 's3.s4'
    );
    checkCase(
      'Проверка getLogger( moduleName, packageName)'
      , usedLogger    =>
          lg_logger_t.getLogger(
            moduleName      => 's06.s2'
            , packageName   => 's7.s8'
          )
      , moduleName    => 's06.s2'
      , objectName    => 's7.s8'
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при проверке получения логера.'
        )
      , true
    );
  end checkGetLogger;



-- testLogger
begin
  prepareTestData();
  pkg_TestUtility.beginTest( 'logger');
  checkLogToTable();
  checkGetLogger();
  pkg_TestUtility.endTest();
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
