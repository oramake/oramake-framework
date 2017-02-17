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

end pkg_LoggingTest;
/
