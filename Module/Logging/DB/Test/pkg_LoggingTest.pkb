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

  -- �������� ������
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
      );

      -- ��������������� �������� �� ���������
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
              cinfo || '������������ �������� level_code'
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
              cinfo || '������������ �������� message_type_code'
        );
      end if;
      if length( messageText) <= 4000 then
        pkg_TestUtility.compareChar(
          actualString        => lgr.message_text
          , expectedString    => messageText
          , failMessageText   =>
              cinfo || '������������ �������� message_text'
        );
      end if;
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
            '��������� ������ "' || rec.level_description || '"'
            || ' ( ��� "' || rec.level_code || '")'
      );
    end loop;

    checkCase(
      '��������� ������ 32767 ��������'
      , messageText   =>
          rpad( '��������� ������ 32767 ��������', 32767, '.')
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
        '������ ��� ������������ ������������ ����������� ����� lg_logger_t ('
        || ' testCaseNumber=' || testCaseNumber
        || ').'
      )
    , true
  );
end testLogger;

end pkg_LoggingTest;
/
