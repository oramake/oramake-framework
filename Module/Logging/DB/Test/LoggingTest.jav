create or replace and compile java source named "LoggingTest" as

import java.io.*;
import java.lang.*;
import java.math.BigDecimal;
import java.sql.*;
import java.util.*;
import java.util.NoSuchElementException;
import java.util.logging.LogManager;
import java.util.zip.GZIPOutputStream;

import ru.rusfinance.netfile.*;

/** class: LoggingTest
 * Java-реализация функций пакета <pkg_LoggingTest>.
 **/
public class LoggingTest
{


/** func: updateJavaUtilLoggingLevel
 * Обновляет уровень логирования в java.util.logging.
 **/
public static void updateJavaUtilLoggingLevel(
  String loggingConfigText
  , BigDecimal isTraceEnabled
)
  throws
    java.io.IOException
    , SQLException
{
  // уровень для включения трассировки
  java.util.logging.Level javaTraceLevel = java.util.logging.Level.FINEST;

  // уровень для отключения трассировки
  java.util.logging.Level javaInfoLevel = java.util.logging.Level.INFO;

  java.util.logging.Level newLogLevel =
    isTraceEnabled.intValue() == 1 ? javaTraceLevel : javaInfoLevel
  ;
  java.util.logging.Level logLevel =
    java.util.logging.Logger.getLogger( "").getLevel()
  ;
  if ( logLevel != newLogLevel
        // не отключаем трассировку если текущий не уровень для трассировки
        && ! ( newLogLevel == javaInfoLevel && logLevel != javaTraceLevel)
      ) {
    boolean isTrace = newLogLevel == javaTraceLevel;
    String config =
      ".level = " + newLogLevel.getName() + "\n"
      + "handlers = java.util.logging.ConsoleHandler\n"
      + "java.util.logging.ConsoleHandler.level = "
        + ( isTrace ? "ALL" : newLogLevel.getName()) + "\n"
      + ( isTrace
          ? "org.apache.http.level = FINEST\n"
            + "org.apache.http.wire.level = SEVERE\n"
            + "com.ibm.as400.level = FINEST\n"
          : ""
        )
    ;
    try {
      if ( newLogLevel != javaTraceLevel) {
        java.util.logging.Logger logger =
          java.util.logging.Logger.getAnonymousLogger()
        ;
        logger.log(
          javaTraceLevel
          , "Set logging trace OFF ("
            + " level: " + logLevel.getName() + " -> " + newLogLevel.getName()
            + ")"
        );
      }
      LogManager lm = LogManager.getLogManager();
      lm.reset();
      lm.readConfiguration( new ByteArrayInputStream( config.getBytes()));
      if ( newLogLevel == javaTraceLevel) {
        java.util.logging.Logger logger =
          java.util.logging.Logger.getAnonymousLogger()
        ;
        logger.log(
          javaTraceLevel
          , "Set logging trace ON ("
            + " level: " + logLevel.getName() + " -> " + newLogLevel.getName()
            + ")"
        );
      }
    }
    catch ( SecurityException e) {
      // маскируем ошибку из-за недостатка прав доступа
      e.printStackTrace();
    }
  }
}

} // LoggingTest
/
