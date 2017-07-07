create or replace package body pkg_LoggingTest is
/* package body: pkg_LoggingTest::body */



/* group: ���������� */

/* ivar: logger
  ����� ������.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => pkg_Logging.Module_Name
  , objectName  => 'pkg_LoggingTest'
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
  rootLogger lg_logger_t := lg_logger_t.getRootLogger();

  -- ������������ � ������ ������
  testLogger lg_logger_t := lg_logger_t.getLogger(
    moduleName    => 'TestModule'
    , objectName  => 'pkg_TestModule'
  );



  /*
    ������������ ����������� � �������.
  */
  procedure testLogToTable
  is



    /*
      ��������� �������� ������.
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
              cinfo || '�������� ���������� ������ ������'
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



  -- testLogToTable
  begin
    pkg_TestUtility.beginTest( 'logger: log to table');

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

    pkg_TestUtility.endTest();
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ������������ ����������� � �������.'
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
        '������ ��� ������������ ������������ ����������� ����� lg_logger_t ('
        || ' testCaseNumber=' || testCaseNumber
        || ').'
      )
    , true
  );
end testLogger;

end pkg_LoggingTest;
/
