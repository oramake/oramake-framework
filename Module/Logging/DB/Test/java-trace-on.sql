-- script: Test/java-trace-on.sql
-- �������� ����������� � java.util.logging.

begin
  pkg_LoggingTest.updateJavaUtilLoggingLevel(
    loggingConfigText => ''
    , isTraceEnabled => 1
  );
end;
/
