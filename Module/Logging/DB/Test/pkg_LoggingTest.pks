create or replace package pkg_LoggingTest is
/* package: pkg_LoggingTest
  ����� ��� ������������ ������ Logging.

  SVN root: Oracle/Module/Logging
*/



/* group: ������� */

/* pfunc: updateJavaUtilLoggingLevel
  ��������� ������� ����������� � java.util.logging

  ( <body::updateJavaUtilLoggingLevel>)
*/
procedure updateJavaUtilLoggingLevel(
  loggingConfigText varchar2
  , isTraceEnabled number
);

end pkg_LoggingTest;
/
