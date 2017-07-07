-- script: Test/java-trace-on.sql
-- Âêëş÷àåò òğàññèğîâêó â java.util.logging.

begin
  pkg_LoggingTest.updateJavaUtilLoggingLevel(
    loggingConfigText => ''
    , isTraceEnabled => 1
  );
end;
/
