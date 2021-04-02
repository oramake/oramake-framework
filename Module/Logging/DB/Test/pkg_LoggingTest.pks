create or replace package pkg_LoggingTest is
/* package: pkg_LoggingTest
  Пакет для тестирования модуля Logging.

  SVN root: Oracle/Module/Logging
*/



/* group: Функции */

/* pfunc: updateJavaUtilLoggingLevel
  Обновляет уровень логирования в java.util.logging

  ( <body::updateJavaUtilLoggingLevel>)
*/
procedure updateJavaUtilLoggingLevel(
  loggingConfigText varchar2
  , isTraceEnabled number
);

/* pproc: testLogger
  Тестирование логирования с помощью типа <lg_logger_t>.

  Параметры:
  testCaseNumber              - Номер проверяемого тестового случая
                                ( по умолчанию без ограничений)

  ( <body::testLogger>)
*/
procedure testLogger(
  testCaseNumber integer := null
);

/* pproc: testUtility
  Тестирование логирования с помощью типа <lg_logger_t>.

  Параметры:
  testCaseNumber              - Номер проверяемого тестового случая
                                ( по умолчанию без ограничений)

  ( <body::testUtility>)
*/
procedure testUtility(
  testCaseNumber integer := null
);

end pkg_LoggingTest;
/
