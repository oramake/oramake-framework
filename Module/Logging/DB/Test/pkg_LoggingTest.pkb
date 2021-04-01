create or replace package body pkg_LoggingTest is
/* package body: pkg_LoggingTest::body */



/* group: ��������� */

/* iconst: None_Date
  ����, ����������� � �������� �������� ��������� �� ���������, �����������
  ���������� ���������� ���� ��������� ��������.
*/
None_Date constant date := DATE '1901-01-01';

/* iconst: None_String
  ������, ����������� � �������� �������� ��������� �� ���������, �����������
  ���������� ���������� ���� ��������� ��������.
*/
None_String constant varchar2(10) := '$(none)';

/* iconst: None_Integer
  �����, ����������� � �������� �������� ��������� �� ���������, �����������
  ���������� ���������� ���� ��������� ��������.
*/
None_Integer constant integer := -9582095482058325832950482954832;



/* group: ���������� */

/* ivar: logger
  ����� ������.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName          => pkg_Logging.Module_Name
  , objectName        => 'pkg_LoggingTest'
  , findModuleString  => pkg_Logging.Module_InitialPath
);



/* group: ������� */

/* func: updateJavaUtilLoggingLevel
  ��������� ������� ����������� � java.util.logging
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

/* iproc: execLoggerMethod
  ��������� ������ ������� ������.

  ���������:
  usedLogger                  - ������ ��� ���������� �������
  execListCsv                 - CSV ����������� �������
*/
procedure execLoggerMethod(
  usedLogger lg_logger_t
  , execListCsv cmn_string_table_t
)
is

  ci tpr_csv_iterator_t;
  methodName varchar2(100);

  es1ct lg_context_type%rowtype;
  es1lg lg_log%rowtype;
  es1textData lg_log_data.text_data%type;

  /*
    ���������� �������� ���������� ���� � �������������� ��������.
  */
  function getStr(
    fieldName varchar2
    , isNotFoundRaised integer := null
  )
  return varchar2
  is
  begin
    return
      trim(
        ci.getString(
          fieldName           => fieldName
          , isNotFoundRaised  => isNotFoundRaised
        )
      )
    ;
  end getStr;



  /*
    ���������� �������� ��������� ����.
  */
  function getNum(
    fieldName varchar2
    , isNotFoundRaised integer := null
  )
  return number
  is
  begin
    return
      trim(
        ci.getNumber(
          fieldName           => fieldName
          , isNotFoundRaised  => isNotFoundRaised
        )
      )
    ;
  end getNum;



-- execLoggerMethod
begin
  for i in 1 .. execListCsv.count() loop
    ci := tpr_csv_iterator_t(
      textData              =>
          ltrim( execListCsv( i), ' ' || chr(13) || chr(10))
      , headerRecordNumber  => 1
      , skipRecordCount     => 2
    );
    while ci.next() loop
      methodName := substr( getStr( 'methodName'), 1, 100);
      case methodName
        -- ����������� ���������
        when 'log' then
          usedLogger.log(
            levelCode               => getStr( 'levelCode')
            , messageText           => getStr( 'messageText')
            , messageValue          => getNum( 'messageValue', 0)
            , messageLabel          => getStr( 'messageLabel', 0)
            , textData              => getStr( 'textData', 0)
            , contextTypeShortName  => getStr( 'contextTypeShortName', 0)
            , contextValueId        => getNum( 'contextValueId', 0)
            , openContextFlag       => getNum( 'openContextFlag', 0)
            , contextTypeModuleId   => getNum( 'contextTypeModuleId', 0)
          );
        when 'fatal' then
          usedLogger.fatal(
            messageText             => getStr( 'messageText')
            , messageValue          => getNum( 'messageValue', 0)
            , messageLabel          => getStr( 'messageLabel', 0)
            , textData              => getStr( 'textData', 0)
            , contextTypeShortName  => getStr( 'contextTypeShortName', 0)
            , contextValueId        => getNum( 'contextValueId', 0)
            , openContextFlag       => getNum( 'openContextFlag', 0)
            , contextTypeModuleId   => getNum( 'contextTypeModuleId', 0)
          );
        when 'error' then
          usedLogger.error(
            messageText             => getStr( 'messageText')
            , messageValue          => getNum( 'messageValue', 0)
            , messageLabel          => getStr( 'messageLabel', 0)
            , textData              => getStr( 'textData', 0)
            , contextTypeShortName  => getStr( 'contextTypeShortName', 0)
            , contextValueId        => getNum( 'contextValueId', 0)
            , openContextFlag       => getNum( 'openContextFlag', 0)
            , contextTypeModuleId   => getNum( 'contextTypeModuleId', 0)
          );
        when 'errorStack1' then
          es1lg.message_text            := getStr( 'messageText');
          es1lg.log_id                  := getNum( 'logMessageFlag', 0);
          es1ct.context_type_short_name := getStr( 'contextTypeShortName', 0);
          es1lg.context_value_id        := getNum( 'contextValueId', 0);
          es1ct.module_id               := getNum( 'contextTypeModuleId', 0);
          es1lg.level_code              := getStr( 'levelCode', 0);
          es1lg.message_value           := getNum( 'messageValue', 0);
          es1lg.message_label           := getStr( 'messageLabel', 0);
          es1textData                   := getStr( 'textData', 0);
        when 'errorStack2' then
          begin
            begin
              begin
                raise_application_error(
                  getNum( 'errorCode')
                  , getStr( 'errorMessage')
                );
              exception when others then
                raise_application_error(
                  pkg_Error.ErrorStackInfo
                  , usedLogger.errorStack(
                      es1lg.message_text
                      , logMessageFlag            => es1lg.log_id
                      , closeContextTypeShortName => es1ct.context_type_short_name
                      , contextValueId            => es1lg.context_value_id
                      , contextTypeModuleId       => es1ct.module_id
                      , levelCode                 => es1lg.level_code
                      , messageValue              => es1lg.message_value
                      , messageLabel              => es1lg.message_label
                      , textData                  => es1textData
                    )
                  , true
                );
              end;
            exception when others then
              raise_application_error(
                pkg_Error.ErrorStackInfo
                , usedLogger.errorStack(
                    getStr( 'messageText')
                    , logMessageFlag            => getNum( 'logMessageFlag', 0)
                    , closeContextTypeShortName => getStr( 'contextTypeShortName', 0)
                    , contextValueId            => getNum( 'contextValueId', 0)
                    , contextTypeModuleId       => getNum( 'contextTypeModuleId', 0)
                    , levelCode                 => getStr( 'levelCode', 0)
                    , messageValue              => getNum( 'messageValue', 0)
                    , messageLabel              => getStr( 'messageLabel', 0)
                  )
                , true
              );
            end;
          exception when others then
            logger.trace(
              'execLoggerMethod: errorStack2: usedLogger.getErrorStack:'
              || chr(10) || usedLogger.getErrorStack()
            );
          end;
        when 'warn' then
          usedLogger.warn(
            messageText             => getStr( 'messageText')
            , messageValue          => getNum( 'messageValue', 0)
            , messageLabel          => getStr( 'messageLabel', 0)
            , textData              => getStr( 'textData', 0)
            , contextTypeShortName  => getStr( 'contextTypeShortName', 0)
            , contextValueId        => getNum( 'contextValueId', 0)
            , openContextFlag       => getNum( 'openContextFlag', 0)
            , contextTypeModuleId   => getNum( 'contextTypeModuleId', 0)
          );
        when 'info' then
          usedLogger.info(
            messageText             => getStr( 'messageText')
            , messageValue          => getNum( 'messageValue', 0)
            , messageLabel          => getStr( 'messageLabel', 0)
            , textData              => getStr( 'textData', 0)
            , contextTypeShortName  => getStr( 'contextTypeShortName', 0)
            , contextValueId        => getNum( 'contextValueId', 0)
            , openContextFlag       => getNum( 'openContextFlag', 0)
            , contextTypeModuleId   => getNum( 'contextTypeModuleId', 0)
          );
        when 'debug' then
          usedLogger.debug(
            messageText             => getStr( 'messageText')
            , messageValue          => getNum( 'messageValue', 0)
            , messageLabel          => getStr( 'messageLabel', 0)
            , textData              => getStr( 'textData', 0)
            , contextTypeShortName  => getStr( 'contextTypeShortName', 0)
            , contextValueId        => getNum( 'contextValueId', 0)
            , openContextFlag       => getNum( 'openContextFlag', 0)
            , contextTypeModuleId   => getNum( 'contextTypeModuleId', 0)
          );
        when 'trace' then
          usedLogger.trace(
            messageText             => getStr( 'messageText')
            , messageValue          => getNum( 'messageValue', 0)
            , messageLabel          => getStr( 'messageLabel', 0)
            , textData              => getStr( 'textData', 0)
            , contextTypeShortName  => getStr( 'contextTypeShortName', 0)
            , contextValueId        => getNum( 'contextValueId', 0)
            , openContextFlag       => getNum( 'openContextFlag', 0)
            , contextTypeModuleId   => getNum( 'contextTypeModuleId', 0)
          );
        when 'trace2' then
          usedLogger.trace2(
            messageText             => getStr( 'messageText')
            , messageValue          => getNum( 'messageValue', 0)
            , messageLabel          => getStr( 'messageLabel', 0)
            , textData              => getStr( 'textData', 0)
            , contextTypeShortName  => getStr( 'contextTypeShortName', 0)
            , contextValueId        => getNum( 'contextValueId', 0)
            , openContextFlag       => getNum( 'openContextFlag', 0)
            , contextTypeModuleId   => getNum( 'contextTypeModuleId', 0)
          );
        when 'trace3' then
          usedLogger.trace3(
            messageText             => getStr( 'messageText')
            , messageValue          => getNum( 'messageValue', 0)
            , messageLabel          => getStr( 'messageLabel', 0)
            , textData              => getStr( 'textData', 0)
            , contextTypeShortName  => getStr( 'contextTypeShortName', 0)
            , contextValueId        => getNum( 'contextValueId', 0)
            , openContextFlag       => getNum( 'openContextFlag', 0)
            , contextTypeModuleId   => getNum( 'contextTypeModuleId', 0)
          );
        -- ���� ��������� ����������
        when 'mergeContextType' then
          usedLogger.mergeContextType(
            contextTypeShortName      => getStr( 'contextTypeShortName')
            , contextTypeName         => getStr( 'contextTypeName', 0)
            , nestedFlag              => getNum( 'nestedFlag', 0)
            , contextTypeDescription  => getStr( 'contextTypeDescription', 0)
            , temporaryFlag           => getNum( 'temporaryFlag', 0)
          );
        when 'deleteContextType' then
          usedLogger.deleteContextType(
            contextTypeShortName      => getStr( 'contextTypeShortName')
          );
        else
          -- ���������� �����������
          if methodName like '#%' or methodName like '--%' then
            null;
          else
            raise_application_error(
              pkg_Error.IllegalArgument
              , '������� ����������� ��� ������ ������ ��� ���������� ('
                || ' methodName="' || methodName || '"'
                || ').'
            );
          end if;
      end case;
    end loop;
  end loop;
end execLoggerMethod;

/* proc: testLogger
  ������������ ����������� � ������� ���� <lg_logger_t>.

  ���������:
  testCaseNumber              - ����� ������������ ��������� ������
                                ( �� ��������� ��� �����������)
*/
procedure testLogger(
  testCaseNumber integer := null
)
is

  -- ���������� ����� ���������� ��������� ������
  checkCaseNumber integer := 0;

  -- �������� �� ����� ���������� ���������
  isDebugEnabled boolean;

  -- �������� �����
  rootLogger lg_logger_t;

  -- ������, ������������ � ������ �� ���������
  testLogger lg_logger_t;
  testModuleId integer;
  testModuleName lg_log.module_name%type;
  testObjectName lg_log.object_name%type;
  testModuleInitialPath lg_log.module_name%type;



  /*
    �������������� ������ ��� �����.
  */
  procedure prepareTestData
  is



    /*
      �������� ��������� ��������� ������.
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

      -- ���������, �.�. ���� ������ ��� ������, �� �� ����� ������� �
      -- ��� ����������� (����������� � ���������� ����������)
      commit;
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.errorStack(
            '������ ��� ��������� ���������� ��������� ������.'
          )
        , true
      );
    end getTestModule;



  -- prepareTestData
  begin
    getTestModule();
    rootLogger := lg_logger_t.getRootLogger();
    isDebugEnabled := rootLogger.isDebugEnabled();
    testObjectName := 'pkg_TestPackage';
    testLogger := lg_logger_t.getLogger(
      moduleName    => testModuleName
      , objectName  => testObjectName
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ���������� ������ ��� �����.'
        )
      , true
    );
  end prepareTestData;



  /*
    ��������� �������� ������.
  */
  procedure checkCase(
    caseDescription varchar2
    , levelCode varchar2 := null
    , messageText varchar2 := null
    , textData clob := null
    , moduleName varchar2 := None_String
    , objectName varchar2 := None_String
    , moduleId integer := None_Integer
    , usedLogger lg_logger_t := testLogger
    , setLevelCode varchar2 := lg_logger_t.getAllLevelCode()
    , errorMessageMask varchar2 := null
    , nextCaseUsedCount pls_integer := null
  )
  is

    -- �������� ��������� ������
    cinfo varchar2(200) :=
      'CASE ' || to_char( checkCaseNumber + 1)
      || ' "' || caseDescription || '": '
    ;

    errorMessage varchar2(32000);

    prevLogId integer;

    oldLevelCode lg_level.level_code%type;
    oldRootLevelCode lg_level.level_code%type;

    -- Id ���������� ���������
    logId integer;

    -- ����� ����������� ���������
    logCount integer;

    lgr v_lg_log%rowtype;

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

      -- ��������� ������������� ����� ����� dbms_output
      pkg_Logging.setDestination(
        destinationCode => pkg_Logging.Table_DestinationCode
      );

      usedLogger.log(
        levelCode     => coalesce( levelCode, lg_logger_t.getTraceLevelCode())
        , messageText =>
            coalesce(
              messageText
              , '��������� ��� ���������: ' || caseDescription
            )
        , textData    => textData
      );

      -- ��������������� �������� �� ���������
      pkg_Logging.setDestination( destinationCode => null);
      select
        max( t.log_id)
        , count(*)
      into logId, logCount
      from
        v_lg_current_log t
      where
        t.log_id > prevLogId
        -- ��������� ���������� ��������� ������ pkg_LoggingInternal
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
            cinfo || '�������� ���������� ������ ������'
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
                cinfo || '��������� �� ������ �� ������������� �����'
          );
        end if;
      else
        pkg_TestUtility.failTest(
          failMessageText   =>
            cinfo || '���������� ����������� � �������:'
            || chr(10) || logger.getErrorStack()
        );
      end if;
    end;

    -- �������� ��������� ����������
    if errorMessageMask is null then
      pkg_TestUtility.compareChar(
        actualString        => logCount
        , expectedString    => 1
        , failMessageText   =>
            cinfo || '������������ ����� ����������� ���������'
            || ' ( prevLogId=' || prevLogId || ')'
      );

      if logId is not null then
        select
          t.*
        into lgr
        from
          v_lg_log t
        where
          t.log_id = logId
        ;
      end if;

      if levelCode is not null then
        pkg_TestUtility.compareChar(
          actualString        => lgr.level_code
          , expectedString    => levelCode
          , failMessageText   =>
              cinfo || '������������ �������� level_code'
        );
      end if;
      if messageText is not null then
        pkg_TestUtility.compareChar(
          actualString        => lgr.message_text
          , expectedString    => substr( messageText, 1, 4000)
          , failMessageText   =>
              cinfo || '������������ �������� message_text'
        );
        pkg_TestUtility.compareChar(
          actualString        => lgr.long_message_text
          , expectedString    =>
              case when length( messageText) > 4000 then messageText end
          , failMessageText   =>
              cinfo || '������������ �������� long_message_text'
        );
        pkg_TestUtility.compareChar(
          actualString        => lgr.full_message_text
          , expectedString    => messageText
          , failMessageText   =>
              cinfo || '������������ �������� full_message_text'
        );
      end if;
      pkg_TestUtility.compareChar(
        actualString        => lgr.long_message_text_flag
        , expectedString    => case when length( messageText) > 4000 then 1 end
        , failMessageText   =>
            cinfo || '������������ �������� long_message_text_flag'
      );
      pkg_TestUtility.compareChar(
        actualString        => length( lgr.text_data)
        , expectedString    => length( textData)
        , failMessageText   =>
            cinfo || '������������ ����� text_data'
      );
      if length( lgr.text_data) = length( textData) then
        for i in 0 .. ceil( length( textData) / 30000) - 1 loop
          pkg_TestUtility.compareChar(
            actualString        => substr( lgr.text_data, i*30000 + 1, 30000)
            , expectedString    => substr( textData     , i*30000 + 1, 30000)
            , failMessageText   =>
                cinfo || '������������ �������� text_data (����� #' || i || ')'
          );
        end loop;
      end if;
      pkg_TestUtility.compareChar(
        actualString        => lgr.text_data_flag
        , expectedString    => case when textData is not null then 1 end
        , failMessageText   =>
            cinfo || '������������ �������� text_data_flag'
      );
      if nullif( None_String, moduleName) is not null then
        pkg_TestUtility.compareChar(
          actualString        => lgr.module_name
          , expectedString    => moduleName
          , failMessageText   =>
              cinfo || '������������ �������� module_name'
        );
      end if;
      if nullif( None_String, objectName) is not null then
        pkg_TestUtility.compareChar(
          actualString        => lgr.object_name
          , expectedString    => objectName
          , failMessageText   =>
              cinfo || '������������ �������� object_name'
        );
      end if;
      if nullif( None_Integer, moduleId) is not null then
        pkg_TestUtility.compareChar(
          actualString        => lgr.module_id
          , expectedString    => moduleId
          , failMessageText   =>
              cinfo || '������������ �������� module_id'
        );
      end if;
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� �������� ��������� ������ ('
          || ' caseNumber=' || checkCaseNumber
          || ', caseDescription="' || caseDescription || '"'
          || ').'
        )
      , true
    );
  end checkCase;



  /*
    ��������� �������� ������ ������ � ����������.
  */
  procedure checkContextCase(
    caseDescription varchar2
    , usedLogger lg_logger_t := testLogger
    , setLevelCode varchar2 := lg_logger_t.getAllLevelCode()
    , execLoggerMethodCsv cmn_string_table_t
    , expectedLogCsv clob := null
    , errorMessageMask varchar2 := null
    , nextCaseUsedCount pls_integer := null
  )
  is

    -- �������� ��������� ������
    cinfo varchar2(200) :=
      'CASE ' || to_char( checkCaseNumber + 1)
      || ' "' || caseDescription || '": '
    ;

    errorMessage varchar2(32000);

    prevLogId integer;

    oldLevelCode lg_level.level_code%type;
    oldRootLevelCode lg_level.level_code%type;

    -- Id ���������� ���������
    logId integer;

    -- ����� ����������� ���������
    logCount integer;

    lgr lg_log%rowtype;

  -- checkContextCase
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

      -- ��������� ������������� ����� ����� dbms_output
      if not isDebugEnabled then
        pkg_Logging.setDestination(
          destinationCode => pkg_Logging.Table_DestinationCode
        );
      end if;

      if setLevelCode is not null then
        usedLogger.setLevel( setLevelCode);
      end if;

      execLoggerMethod(
        usedLogger      => usedLogger
        , execListCsv   => execLoggerMethodCsv
      );

      -- ��������������� �������� �� ���������
      select
        max( t.log_id)
        , count(*)
      into logId, logCount
      from
        v_lg_current_log t
      where
        t.log_id > prevLogId
        -- ��������� ���������� ��������� ������ pkg_LoggingInternal
        and not (
          nullif( 'Logging', t.module_name) is null
          and nullif( 'pkg_LoggingInternal', t.object_name) is null
        )
      ;
      if setLevelCode is not null then
        usedLogger.setLevel( oldLevelCode);
      end if;
      pkg_Logging.setDestination( destinationCode => null);
      if errorMessageMask is not null then
        pkg_TestUtility.failTest(
          failMessageText   =>
            cinfo || '�������� ���������� ������ ������'
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
                cinfo || '��������� �� ������ �� ������������� �����'
          );
        end if;
      else
        pkg_TestUtility.failTest(
          failMessageText   =>
            cinfo || '���������� ����������� � �������:'
            || chr(10) || logger.getErrorStack()
        );
      end if;
    end;

    -- �������� ��������� ����������
    if errorMessageMask is null then
      if expectedLogCsv is not null then
        pkg_TestUtility.compareQueryResult(
          tableName           => 'lg_log'
          , tableExpression   =>
'(select
  lg.*
  , ct.context_type_short_name
from
  v_lg_current_log lg
  left join lg_context_type ct
    on ct.context_type_id = lg.context_type_id
)
'
          , filterCondition   =>
'log_id > ' || coalesce( prevLogId, 0) || '
and log_id <= ' || coalesce( logId, 0) || '
-- ��������� ���������� ��������� ������ pkg_LoggingInternal
and not (
  nullif( ''Logging'', module_name) is null
  and nullif( ''pkg_LoggingInternal'', object_name) is null
)
'
          , orderByExpression => 'log_id'
          , idColumnName      => 'log_id'
          , expectedCsv       =>
              replace(
                expectedLogCsv
                , '$(CURRENT_SCHEMA)'
                , sys_context('USERENV','CURRENT_SCHEMA')
              )
          , failMessagePrefix => cinfo
        );
      end if;
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� �������� ��������� ������ ������ � ���������� ('
          || ' caseNumber=' || checkCaseNumber
          || ', caseDescription="' || caseDescription || '"'
          || ').'
        )
      , true
    );
  end checkContextCase;



  /*
    �������� ����������� � �������.
  */
  procedure checkLogToTable
  is
  begin

    -- ��������� ��������� ���� ��������� �������
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
        '��������� ������ ' || rec.level_code
        , levelCode     => rec.level_code
        , setLevelCode  => rec.level_code
        , messageText   =>
            '��������� ������ "' || rec.level_name || '"'
            || ' ( ��� "' || rec.level_code || '")'
      );
    end loop;

    checkCase(
      '��������� ������ 32767 ��������'
      , messageText   =>
          rpad( '��������� ������ 32767 ��������', 32767, '.')
    );

    checkCase(
      '��������� ������ ������ 60000 ��������'
      , messageText   =>
          '��������� ������ ������ 60000 ��������'
      , textData      =>
          rpad( '0', 30000-1, '.') || '1'
          || rpad( '2', 30000-1, '.') || '3'
    );

    checkCase(
      '���������� ����� � ������/�������'
      , moduleName    => testModuleName
      , objectName    => testObjectName
      , moduleId      => testModuleId
    );

    checkCase(
      '������������� ���� ��������� moduleName'
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
      '���������� ����� � ������/�������: �������� �����'
      , usedLogger    => rootLogger
      , moduleName    => null
      , objectName    => null
      , moduleId      => null
    );

    checkCase(
      '���������� ����� � ������/�������: ����������� ������'
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
      '����������� moduleId �� findModuleString � initialPath'
      , usedLogger    =>
          lg_logger_t.getLogger(
            moduleName          =>
                -- ��� ������ ������ ���� ��������� (����� ����� �����������
                -- ����� ��������� �����)
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
          '������ ��� �������� ����������� � �������.'
        )
      , true
    );
  end checkLogToTable;



  /*
    �������� ��������� ������.
  */
  procedure checkGetLogger
  is
  begin
    checkCase(
      '�������� getRootLogger()'
      , usedLogger    => lg_logger_t.getRootLogger()
      , moduleName    => ''
      , objectName    => ''
    );

    -- ���������� ���������� �������� ����� ���������� ������������ �������
    -- (��� ���������� ��������� ������� �������� �������)

    checkCase(
      '�������� getLogger( str)'
      , usedLogger    => lg_logger_t.getLogger( 's01.s2.s3.s4')
      , moduleName    => 's01'
      , objectName    => 's2.s3.s4'
    );
    checkCase(
      '�������� getLogger( str1, str2)'
      , usedLogger    => lg_logger_t.getLogger( 's02.s2', 's3.s4')
      , moduleName    => 's02.s2'
      , objectName    => 's3.s4'
    );
    checkCase(
      '�������� getLogger( loggerName)'
      , usedLogger    =>
          lg_logger_t.getLogger(
            loggerName      => 's03.s2.s3'
          )
      , moduleName    => 's03'
      , objectName    => 's2.s3'
    );
    checkCase(
      '�������� getLogger( moduleName)'
      , usedLogger    =>
          lg_logger_t.getLogger(
            moduleName      => 's04.s2.s3'
          )
      , moduleName    => 's04.s2.s3'
      , objectName    => ''
    );
    checkCase(
      '�������� getLogger( moduleName, objectName)'
      , usedLogger    =>
          lg_logger_t.getLogger(
            moduleName      => 's05.s2'
            , objectName    => 's3.s4'
          )
      , moduleName    => 's05.s2'
      , objectName    => 's3.s4'
    );
    checkCase(
      '�������� getLogger( moduleName, packageName)'
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
          '������ ��� �������� ��������� ������.'
        )
      , true
    );
  end checkGetLogger;



  /*
    �������� �������� � ����������.
  */
  procedure checkContext
  is

    fileRecCtxExecCsv varchar2(10000) :=
'
methodName          ; contextTypeShortName ; contextTypeName                       ; nestedFlag ; temporaryFlag  ; contextTypeDescription
------------------- ; -------------------- ; ------------------------------------- ; ---------- ; -------------- ; --------------------------------------------------------------------------------------------------------
mergeContextType    ; file                 ; ��������� �����                       ;          1 ;              1 ; � context_value_id ����������� Id ����� (�� ������� tst_file)
mergeContextType    ; record               ; ��������� ������ � ������� �� �����   ;          1 ;              1 ; � context_value_id ����������� ���������� ����� ������ ����� (������������ � ��������� ��������� �����)
'
    ;
    operEdtCtxExecCsv varchar2(10000) :=
'
methodName          ; contextTypeShortName ; contextTypeName                       ; nestedFlag ; temporaryFlag  ; contextTypeDescription
------------------- ; -------------------- ; ------------------------------------- ; ---------- ; -------------- ; --------------------------------------------------------------------------------------------------------
mergeContextType    ; operator             ; ����������� ���������                 ;          0 ;                ; � context_value_id ����������� Id ��������� (�� ������� tst_operator)
mergeContextType    ; edition              ; ������������ �� ������������ edition  ;          0 ;                ; � message_label ����������� ������������ edition
'
    ;
    fileRecLogExecCsv varchar2(10000) :=
'
methodName  ; messageText                       ; messageValue  ; messageLabel  ; contextTypeShortName    ; contextValueId   ; openContextFlag   ; contextTypeModuleId
----------- ; --------------------------------- ; ------------- ; ------------- ; ----------------------- ; ---------------- ; ----------------- ; -------------------
info        ; ������ ��������� ����� tmp1.txt   ;               ; PROCESS       ; file                    ;               15 ;                 1 ;
debug       ; ������ ��������� ������ #1        ;               ;               ; record                  ;                1 ;                 1 ;
debug       ; ��������� ������ ���������        ;               ;               ; record                  ;                1 ;                 0 ;
debug       ; ������ ��������� ������ #2        ;               ;               ; record                  ;                2 ;                 1 ;
warn        ; ������ ��������� �����            ;               ;               ;                         ;                  ;                   ;
debug       ; ��������� ������ ���������        ;               ;               ; record                  ;                2 ;                 0 ;
debug       ; ������ ��������� ������ #3        ;               ;               ; record                  ;                3 ;                 1 ;
error       ; ������ ��� ��������� ������       ;               ;               ; record                  ;                3 ;                 0 ;
debug       ; ������ ��������� ������ #4        ;               ;               ; record                  ;                4 ;                 1 ;
debug       ; ��������� ������ ���������        ;               ;               ; record                  ;                4 ;                 0 ;
debug       ; ������ ��������� ������ #5        ;               ;               ; record                  ;                5 ;                 1 ;
debug       ; ��������� ������ ���������        ;               ;               ; record                  ;                5 ;                 0 ;
info        ; ��������� ����� ���������.        ;               ;               ; file                    ;               15 ;                 0 ;
'
    ;
    execCsv varchar2(10000);

  begin
    checkContextCase(
      '����� mergeContextType ��� ��������� ������'
      , usedLogger          => rootLogger
      , execLoggerMethodCsv => cmn_string_table_t(
'
methodName          ; contextTypeShortName ; contextTypeName                       ; nestedFlag
------------------- ; -------------------- ; ------------------------------------- ; ----------
mergeContextType    ; file                 ; ��������� �����                       ;          1
'
        )
      , errorMessageMask    =>
          '%ORA-20195: ���������� ���������� Id ������ ��� ��������� ������.%'
    );
    checkContextCase(
      '��������� ��������: ������ ���'
      , execLoggerMethodCsv =>
          cmn_string_table_t( fileRecCtxExecCsv, fileRecLogExecCsv)
      , expectedLogCsv      =>
'
LEVEL_CODE  ; MESSAGE_TEXT                      ; MESSAGE_VALUE ; MESSAGE_LABEL ; CONTEXT_TYPE_SHORT_NAME ; CONTEXT_VALUE_ID ; OPEN_CONTEXT_FLAG ; OPEN_CONTEXT_LOG_ID ; CONTEXT_LEVEL ; CONTEXT_TYPE_LEVEL
----------- ; --------------------------------- ; ------------- ; ------------- ; ----------------------- ; ---------------- ; ----------------- ; ------------------- ; ------------- ; ------------------
INFO        ; ������ ��������� ����� tmp1.txt   ;               ; PROCESS       ; file                    ;               15 ;                 1 ;            $(rowId) ;             1 ;                  1
DEBUG       ; ������ ��������� ������ #1        ;               ;               ; record                  ;                1 ;                 1 ;            $(rowId) ;             2 ;                  1
DEBUG       ; ��������� ������ ���������        ;               ;               ; record                  ;                1 ;                 0 ;        $(rowId(-1)) ;             2 ;                  1
DEBUG       ; ������ ��������� ������ #2        ;               ;               ; record                  ;                2 ;                 1 ;            $(rowId) ;             2 ;                  1
WARN        ; ������ ��������� �����            ;               ;               ;                         ;                  ;                   ;                     ;             2 ;
DEBUG       ; ��������� ������ ���������        ;               ;               ; record                  ;                2 ;                 0 ;        $(rowId(-2)) ;             2 ;                  1
DEBUG       ; ������ ��������� ������ #3        ;               ;               ; record                  ;                3 ;                 1 ;            $(rowId) ;             2 ;                  1
ERROR       ; ������ ��� ��������� ������       ;               ;               ; record                  ;                3 ;                 0 ;        $(rowId(-1)) ;             2 ;                  1
DEBUG       ; ������ ��������� ������ #4        ;               ;               ; record                  ;                4 ;                 1 ;            $(rowId) ;             2 ;                  1
DEBUG       ; ��������� ������ ���������        ;               ;               ; record                  ;                4 ;                 0 ;        $(rowId(-1)) ;             2 ;                  1
DEBUG       ; ������ ��������� ������ #5        ;               ;               ; record                  ;                5 ;                 1 ;            $(rowId) ;             2 ;                  1
DEBUG       ; ��������� ������ ���������        ;               ;               ; record                  ;                5 ;                 0 ;        $(rowId(-1)) ;             2 ;                  1
INFO        ; ��������� ����� ���������.        ;               ;               ; file                    ;               15 ;                 0 ;         $(rowId(1)) ;             1 ;                  1
'
    );
    checkContextCase(
      '��������� ��������: ������� INFO'
      , setLevelCode        => 'INFO'
      , execLoggerMethodCsv =>
          cmn_string_table_t( fileRecCtxExecCsv, fileRecLogExecCsv)
      , expectedLogCsv      =>
'
LEVEL_CODE  ; MESSAGE_TEXT                      ; MESSAGE_VALUE ; MESSAGE_LABEL ; CONTEXT_TYPE_SHORT_NAME ; CONTEXT_VALUE_ID ; OPEN_CONTEXT_FLAG ; OPEN_CONTEXT_LOG_ID ; CONTEXT_LEVEL ; CONTEXT_TYPE_LEVEL
----------- ; --------------------------------- ; ------------- ; ------------- ; ----------------------- ; ---------------- ; ----------------- ; ------------------- ; ------------- ; ------------------
INFO        ; ������ ��������� ����� tmp1.txt   ;               ; PROCESS       ; file                    ;               15 ;                 1 ;            $(rowId) ;             1 ;                  1
DEBUG       ; ������ ��������� ������ #2        ;               ;               ; record                  ;                2 ;                 1 ;            $(rowId) ;             2 ;                  1
WARN        ; ������ ��������� �����            ;               ;               ;                         ;                  ;                   ;                     ;             2 ;
DEBUG       ; ��������� ������ ���������        ;               ;               ; record                  ;                2 ;                 0 ;        $(rowId(-2)) ;             2 ;                  1
DEBUG       ; ������ ��������� ������ #3        ;               ;               ; record                  ;                3 ;                 1 ;            $(rowId) ;             2 ;                  1
ERROR       ; ������ ��� ��������� ������       ;               ;               ; record                  ;                3 ;                 0 ;        $(rowId(-1)) ;             2 ;                  1
INFO        ; ��������� ����� ���������.        ;               ;               ; file                    ;               15 ;                 0 ;         $(rowId(1)) ;             1 ;                  1
'
    );
    checkContextCase(
      '��������� ��������: ������� ERROR'
      , setLevelCode        => 'ERROR'
      , execLoggerMethodCsv =>
          cmn_string_table_t( fileRecCtxExecCsv, fileRecLogExecCsv)
      , expectedLogCsv      =>
'
LEVEL_CODE  ; MESSAGE_TEXT                      ; MESSAGE_VALUE ; MESSAGE_LABEL ; CONTEXT_TYPE_SHORT_NAME ; CONTEXT_VALUE_ID ; OPEN_CONTEXT_FLAG ; OPEN_CONTEXT_LOG_ID ; CONTEXT_LEVEL ; CONTEXT_TYPE_LEVEL
----------- ; --------------------------------- ; ------------- ; ------------- ; ----------------------- ; ---------------- ; ----------------- ; ------------------- ; ------------- ; ------------------
INFO        ; ������ ��������� ����� tmp1.txt   ;               ; PROCESS       ; file                    ;               15 ;                 1 ;            $(rowId) ;             1 ;                  1
DEBUG       ; ������ ��������� ������ #3        ;               ;               ; record                  ;                3 ;                 1 ;            $(rowId) ;             2 ;                  1
ERROR       ; ������ ��� ��������� ������       ;               ;               ; record                  ;                3 ;                 0 ;        $(rowId(-1)) ;             2 ;                  1
INFO        ; ��������� ����� ���������.        ;               ;               ; file                    ;               15 ;                 0 ;         $(rowId(1)) ;             1 ;                  1
'
    );
    checkContextCase(
      '��������� ��������: ������� FATAL'
      , setLevelCode        => 'FATAL'
      , execLoggerMethodCsv =>
          cmn_string_table_t( fileRecCtxExecCsv, fileRecLogExecCsv)
      , expectedLogCsv      => ' '
    );
    checkContextCase(
      '��������� ��������: �������������� ��������'
      , setLevelCode        => 'WARN'
      , execLoggerMethodCsv =>
          cmn_string_table_t( fileRecCtxExecCsv,
'
methodName  ; messageText                       ; messageValue  ; messageLabel  ; contextTypeShortName    ; contextValueId   ; openContextFlag   ; contextTypeModuleId
----------- ; --------------------------------- ; ------------- ; ------------- ; ----------------------- ; ---------------- ; ----------------- ; -------------------
info        ; ������ ��������� ����� tmp1.txt   ;               ; PROCESS       ; file                    ;                1 ;                 1 ;
debug       ; ������ ��������� ������ #1        ;               ;               ; record                  ;                2 ;                 1 ;
debug       ; ������ ��������� ����� tmp1_1.txt ;               ; PROCESS       ; file                    ;                3 ;                 1 ;
debug       ; ������ ��������� ������ #1        ;               ;               ; record                  ;                4 ;                 1 ;
warn        ; ������ ��������� �����            ;               ;               ;                         ;                  ;                   ;
error       ; ��������� ����� ��������.         ;               ;               ; file                    ;                1 ;                 0 ;
'
          )
      , expectedLogCsv      =>
'
LEVEL_CODE  ; MESSAGE_TEXT                      ; MESSAGE_VALUE ; MESSAGE_LABEL ; CONTEXT_TYPE_SHORT_NAME ; CONTEXT_VALUE_ID ; OPEN_CONTEXT_FLAG ; OPEN_CONTEXT_LOG_ID ; CONTEXT_LEVEL ; CONTEXT_TYPE_LEVEL
----------- ; --------------------------------- ; ------------- ; ------------- ; ----------------------- ; ---------------- ; ----------------- ; ------------------- ; ------------- ; ------------------
INFO        ; ������ ��������� ����� tmp1.txt   ;               ; PROCESS       ; file                    ;                1 ;                 1 ;            $(rowId) ;             1 ;                  1
DEBUG       ; ������ ��������� ������ #1        ;               ;               ; record                  ;                2 ;                 1 ;            $(rowId) ;             2 ;                  1
DEBUG       ; ������ ��������� ����� tmp1_1.txt ;               ; PROCESS       ; file                    ;                3 ;                 1 ;            $(rowId) ;             3 ;                  2
DEBUG       ; ������ ��������� ������ #1        ;               ;               ; record                  ;                4 ;                 1 ;            $(rowId) ;             4 ;                  2
WARN        ; ������ ��������� �����            ;               ;               ;                         ;                  ;                   ;                     ;             4 ;
DEBUG       ; �������������� �������� ��������� ;               ;               ; record                  ;                4 ;                 0 ;         $(rowId(4)) ;             4 ;                  2
DEBUG       ; �������������� �������� ��������� ;               ;               ; file                    ;                3 ;                 0 ;         $(rowId(3)) ;             3 ;                  2
DEBUG       ; �������������� �������� ��������� ;               ;               ; record                  ;                2 ;                 0 ;         $(rowId(2)) ;             2 ;                  1
ERROR       ; ��������� ����� ��������.         ;               ;               ; file                    ;                1 ;                 0 ;         $(rowId(1)) ;             1 ;                  1
'
    );
    checkContextCase(
      'errorStack � ��������� ���������'
      , setLevelCode        => 'INFO'
      , execLoggerMethodCsv =>
          cmn_string_table_t( fileRecCtxExecCsv,
'
methodName  ; messageText                       ; levelCode  ; messageValue  ; messageLabel  ; contextTypeShortName    ; contextValueId   ; openContextFlag   ; logMessageFlag  ; errorCode  ; errorMessage
----------- ; --------------------------------- ; ---------- ; ------------- ; ------------- ; ----------------------- ; ---------------- ; ----------------- ; --------------- ; ---------- ; -------------------
info        ; ������ ��������� ����� tmp1.txt   ;            ;               ; tmp1.txt      ; file                    ;               11 ;                 1 ;                 ;            ;
debug       ; ������ ��������� ������ #1        ;            ;               ;               ; record                  ;                1 ;                 1 ;                 ;            ;
debug       ; ������ #1 ����������              ;            ;               ;               ; record                  ;                1 ;                 0 ;                 ;            ;
debug       ; ������ ��������� ������ #2        ;            ;               ;               ; record                  ;                2 ;                 1 ;                 ;            ;
errorStack1 ; ������ ��� ��������� ������ #2.   ;       INFO ;        -20015 ;     DUB_ERROR ; record                  ;                2 ;                   ;                 ;            ;
errorStack2 ; ������ ��� ��������� �����.       ;            ;             1 ;               ; file                    ;               11 ;                   ;               1 ;     -20015 ; ������ ��������� �����
'
          )
      , expectedLogCsv      =>
'
LEVEL_CODE  ; MESSAGE_TEXT                                                                                                                                                                                                                      ; MESSAGE_VALUE ; MESSAGE_LABEL ; CONTEXT_TYPE_SHORT_NAME ; CONTEXT_VALUE_ID ; OPEN_CONTEXT_FLAG ; OPEN_CONTEXT_LOG_ID ; CONTEXT_LEVEL ; CONTEXT_TYPE_LEVEL
----------- ; --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- ; ------------- ; ------------- ; ----------------------- ; ---------------- ; ----------------- ; ------------------- ; ------------- ; ------------------
INFO        ; ������ ��������� ����� tmp1.txt                                                                                                                                                                                                   ;               ; tmp1.txt      ; file                    ;               11 ;                 1 ;            $(rowId) ;             1 ;                  1
DEBUG       ; ������ ��������� ������ #2                                                                                                                                                                                                        ;               ;               ; record                  ;                2 ;                 1 ;            $(rowId) ;             2 ;                  1
INFO        ; �������� ��������� ���������� � ����� � �������: ������ ��� ��������� ������ #2. ORA-20015: ������ ��������� �����                                                                                                                ;        -20015 ; DUB_ERROR     ; record                  ;                2 ;                 0 ;         $(rowId(2)) ;             2 ;                  1
ERROR       ; ������ ��� ��������� �����. ORA-20150: ������ ��� ��������� ������ #2. ORA-06512: at "$(CURRENT_SCHEMA).PKG_LOGGINGTEST", line 187 ORA-20015: ������ ��������� ����� ORA-06512: at "$(CURRENT_SCHEMA).PKG_LOGGINGTEST", line 182  ;             1 ;               ; file                    ;               11 ;                 0 ;         $(rowId(1)) ;             1 ;                  1
'
    );


    -- ������������� � ��������� ��������
    execCsv :=
'
methodName  ; messageText                       ; messageValue  ; messageLabel  ; contextTypeShortName    ; contextValueId   ; openContextFlag   ; contextTypeModuleId
----------- ; --------------------------------- ; ------------- ; ------------- ; ----------------------- ; ---------------- ; ----------------- ; -------------------
debug       ; ����������� ��������� PupkinAV    ;               ; LOGIN         ; operator                ;             1511 ;                 1 ;
debug       ; ������������ �� edition           ;               ; Edition1      ; edition                 ;                  ;                 1 ;
debug       ; ����������� ��������� PetrovDE    ;               ; LOGIN         ; operator                ;             1611 ;                 1 ;
info        ; ������ ��������� ����� data1.zip  ;               ; PROCESS       ; file                    ;              201 ;                 1 ;
debug       ; ������ ��������� ����� tmp1.txt   ;               ; PROCESS       ; file                    ;                1 ;                 1 ;
trace       ; ������ ��������� ������ #1        ;               ;               ; record                  ;                1 ;                 1 ;
debug       ; ����������� ��������� IvanovII    ;               ; LOGIN         ; operator                ;             1711 ;                 1 ;
warn        ; ������ ��������� �����            ;               ;               ; record                  ;                1 ;                 0 ;
trace       ; ������ ��������� ������ #2        ;               ;               ; record                  ;                2 ;                 1 ;
error       ; ��������� ����� ��������.         ;             2 ;               ; file                    ;              201 ;                 0 ;
debug       ; ������ ����������� ���������      ;               ; LOGOFF        ; operator                ;                  ;                 0 ;
debug       ; ����� edition                     ;               ;               ; edition                 ;                  ;                 0 ;
'
    ;
    checkContextCase(
      '������������� � ��������� ��������'
      , execLoggerMethodCsv =>
          cmn_string_table_t( fileRecCtxExecCsv, operEdtCtxExecCsv, execCsv)
      , expectedLogCsv      =>
'
LEVEL_CODE  ; MESSAGE_TEXT                      ; MESSAGE_VALUE ; MESSAGE_LABEL ; CONTEXT_TYPE_SHORT_NAME ; CONTEXT_VALUE_ID ; OPEN_CONTEXT_FLAG ; OPEN_CONTEXT_LOG_ID ; CONTEXT_LEVEL ; CONTEXT_TYPE_LEVEL
----------- ; --------------------------------- ; ------------- ; ------------- ; ----------------------- ; ---------------- ; ----------------- ; ------------------- ; ------------- ; ------------------
DEBUG       ; ����������� ��������� PupkinAV    ;               ; LOGIN         ; operator                ;             1511 ;                 1 ;            $(rowId) ;             0 ;
DEBUG       ; ������������ �� edition           ;               ; Edition1      ; edition                 ;                  ;                 1 ;            $(rowId) ;             0 ;
DEBUG       ; �������������� �������� ��������� ;               ;               ; operator                ;             1511 ;                 0 ;         $(rowId(1)) ;             0 ;
DEBUG       ; ����������� ��������� PetrovDE    ;               ; LOGIN         ; operator                ;             1611 ;                 1 ;            $(rowId) ;             0 ;
INFO        ; ������ ��������� ����� data1.zip  ;               ; PROCESS       ; file                    ;              201 ;                 1 ;            $(rowId) ;             1 ;                  1
DEBUG       ; ������ ��������� ����� tmp1.txt   ;               ; PROCESS       ; file                    ;                1 ;                 1 ;            $(rowId) ;             2 ;                  2
TRACE       ; ������ ��������� ������ #1        ;               ;               ; record                  ;                1 ;                 1 ;            $(rowId) ;             3 ;                  1
DEBUG       ; �������������� �������� ��������� ;               ;               ; operator                ;             1611 ;                 0 ;         $(rowId(4)) ;             3 ;
DEBUG       ; ����������� ��������� IvanovII    ;               ; LOGIN         ; operator                ;             1711 ;                 1 ;            $(rowId) ;             3 ;
WARN        ; ������ ��������� �����            ;               ;               ; record                  ;                1 ;                 0 ;        $(rowId(-3)) ;             3 ;                  1
TRACE       ; ������ ��������� ������ #2        ;               ;               ; record                  ;                2 ;                 1 ;            $(rowId) ;             3 ;                  1
TRACE       ; �������������� �������� ��������� ;               ;               ; record                  ;                2 ;                 0 ;        $(rowId(-1)) ;             3 ;                  1
DEBUG       ; �������������� �������� ��������� ;               ;               ; file                    ;                1 ;                 0 ;         $(rowId(6)) ;             2 ;                  2
ERROR       ; ��������� ����� ��������.         ;             2 ;               ; file                    ;              201 ;                 0 ;         $(rowId(5)) ;             1 ;                  1
DEBUG       ; ������ ����������� ���������      ;               ; LOGOFF        ; operator                ;                  ;                 0 ;         $(rowId(9)) ;             0 ;
DEBUG       ; ����� edition                     ;               ;               ; edition                 ;                  ;                 0 ;         $(rowId(2)) ;             0 ;
'
    );
    checkContextCase(
      '������������� � ��������� ��������: ������� WARN'
      , setLevelCode        => 'WARN'
      , execLoggerMethodCsv =>
          cmn_string_table_t( fileRecCtxExecCsv, operEdtCtxExecCsv, execCsv)
      , expectedLogCsv      =>
'
LEVEL_CODE  ; MESSAGE_TEXT                      ; MESSAGE_VALUE ; MESSAGE_LABEL ; CONTEXT_TYPE_SHORT_NAME ; CONTEXT_VALUE_ID ; OPEN_CONTEXT_FLAG ; OPEN_CONTEXT_LOG_ID ; CONTEXT_LEVEL ; CONTEXT_TYPE_LEVEL
----------- ; --------------------------------- ; ------------- ; ------------- ; ----------------------- ; ---------------- ; ----------------- ; ------------------- ; ------------- ; ------------------
DEBUG       ; ������������ �� edition           ;               ; Edition1      ; edition                 ;                  ;                 1 ;            $(rowId) ;             0 ;
INFO        ; ������ ��������� ����� data1.zip  ;               ; PROCESS       ; file                    ;              201 ;                 1 ;            $(rowId) ;             1 ;                  1
DEBUG       ; ������ ��������� ����� tmp1.txt   ;               ; PROCESS       ; file                    ;                1 ;                 1 ;            $(rowId) ;             2 ;                  2
TRACE       ; ������ ��������� ������ #1        ;               ;               ; record                  ;                1 ;                 1 ;            $(rowId) ;             3 ;                  1
DEBUG       ; ����������� ��������� IvanovII    ;               ; LOGIN         ; operator                ;             1711 ;                 1 ;            $(rowId) ;             3 ;
WARN        ; ������ ��������� �����            ;               ;               ; record                  ;                1 ;                 0 ;        $(rowId(-2)) ;             3 ;                  1
TRACE       ; ������ ��������� ������ #2        ;               ;               ; record                  ;                2 ;                 1 ;            $(rowId) ;             3 ;                  1
TRACE       ; �������������� �������� ��������� ;               ;               ; record                  ;                2 ;                 0 ;        $(rowId(-1)) ;             3 ;                  1
DEBUG       ; �������������� �������� ��������� ;               ;               ; file                    ;                1 ;                 0 ;         $(rowId(3)) ;             2 ;                  2
ERROR       ; ��������� ����� ��������.         ;             2 ;               ; file                    ;              201 ;                 0 ;         $(rowId(2)) ;             1 ;                  1
DEBUG       ; ������ ����������� ���������      ;               ; LOGOFF        ; operator                ;                  ;                 0 ;         $(rowId(5)) ;             0 ;
DEBUG       ; ����� edition                     ;               ;               ; edition                 ;                  ;                 0 ;         $(rowId(1)) ;             0 ;
'
    );

    checkContextCase(
      '�������� � ����������� �������� ���������'
      , execLoggerMethodCsv =>
          cmn_string_table_t( fileRecCtxExecCsv, operEdtCtxExecCsv,
'
methodName  ; messageText                       ; messageValue  ; messageLabel  ; contextTypeShortName    ; contextValueId   ; openContextFlag   ; contextTypeModuleId
----------- ; --------------------------------- ; ------------- ; ------------- ; ----------------------- ; ---------------- ; ----------------- ; -------------------
debug       ; �������� edition                  ;               ; Edition1      ; edition                 ;                  ;                -1 ;
debug       ; ������������ �� edition           ;               ; Edition1      ; edition                 ;                  ;                 1 ;
info        ; ������ ��������� ����� data1.zip  ;               ; PROCESS       ; file                    ;              201 ;                 1 ;
debug       ; ������� ��������� ����� tmp1.txt  ;               ; SKIP          ; file                    ;                1 ;                -1 ;
debug       ; ������ ��������� ����� tmp2.txt   ;               ; PROCESS       ; file                    ;                2 ;                 1 ;
trace       ; ������ ��������� ������ #1        ;               ;               ; record                  ;                1 ;                 1 ;
error       ; ��������� ����� ��������.         ;               ;               ; file                    ;              201 ;                 0 ;
debug       ; ����� edition                     ;               ;               ; edition                 ;                  ;                 0 ;
'
          )
      , expectedLogCsv      =>
'
LEVEL_CODE  ; MESSAGE_TEXT                      ; MESSAGE_VALUE ; MESSAGE_LABEL ; CONTEXT_TYPE_SHORT_NAME ; CONTEXT_VALUE_ID ; OPEN_CONTEXT_FLAG ; OPEN_CONTEXT_LOG_ID ; CONTEXT_LEVEL ; CONTEXT_TYPE_LEVEL
----------- ; --------------------------------- ; ------------- ; ------------- ; ----------------------- ; ---------------- ; ----------------- ; ------------------- ; ------------- ; ------------------
DEBUG       ; �������� edition                  ;               ; Edition1      ; edition                 ;                  ;                -1 ;            $(rowId) ;             0 ;
DEBUG       ; ������������ �� edition           ;               ; Edition1      ; edition                 ;                  ;                 1 ;            $(rowId) ;             0 ;
INFO        ; ������ ��������� ����� data1.zip  ;               ; PROCESS       ; file                    ;              201 ;                 1 ;            $(rowId) ;             1 ;                  1
DEBUG       ; ������� ��������� ����� tmp1.txt  ;               ; SKIP          ; file                    ;                1 ;                -1 ;            $(rowId) ;             2 ;                  2
DEBUG       ; ������ ��������� ����� tmp2.txt   ;               ; PROCESS       ; file                    ;                2 ;                 1 ;            $(rowId) ;             2 ;                  2
TRACE       ; ������ ��������� ������ #1        ;               ;               ; record                  ;                1 ;                 1 ;            $(rowId) ;             3 ;                  1
TRACE       ; �������������� �������� ��������� ;               ;               ; record                  ;                1 ;                 0 ;        $(rowId(-1)) ;             3 ;                  1
DEBUG       ; �������������� �������� ��������� ;               ;               ; file                    ;                2 ;                 0 ;         $(rowId(5)) ;             2 ;                  2
ERROR       ; ��������� ����� ��������.         ;               ;               ; file                    ;              201 ;                 0 ;         $(rowId(3)) ;             1 ;                  1
DEBUG       ; ����� edition                     ;               ;               ; edition                 ;                  ;                 0 ;         $(rowId(2)) ;             0 ;
'
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� �������� �������� � ����������.'
        )
      , true
    );
  end checkContext;



-- testLogger
begin
  prepareTestData();
  pkg_TestUtility.beginTest( 'logger');
  checkLogToTable();
  checkGetLogger();
  checkContext();
  pkg_TestUtility.endTest();
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ������������ ������������ ����������� ����� lg_logger_t ('
        || ' testCaseNumber=' || testCaseNumber
        || ').'
      )
    , true
  );
end testLogger;

end pkg_LoggingTest;
/
