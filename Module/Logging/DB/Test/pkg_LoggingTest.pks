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

/* pproc: testLogger
  ������������ ����������� � ������� ���� <lg_logger_t>.

  ���������:
  testCaseNumber              - ����� ������������ ��������� ������
                                ( �� ��������� ��� �����������)

  ( <body::testLogger>)
*/
procedure testLogger(
  testCaseNumber integer := null
);

/* pproc: testUtility
  ������������ ����������� � ������� ���� <lg_logger_t>.

  ���������:
  testCaseNumber              - ����� ������������ ��������� ������
                                ( �� ��������� ��� �����������)

  ( <body::testUtility>)
*/
procedure testUtility(
  testCaseNumber integer := null
);

end pkg_LoggingTest;
/
