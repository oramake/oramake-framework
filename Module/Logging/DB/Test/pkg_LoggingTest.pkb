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

end pkg_LoggingTest;
/
