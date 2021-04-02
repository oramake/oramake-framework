create or replace package pkg_LoggingUtility is
/* package: pkg_LoggingUtility
  Дополнительные функции модуля Logging для использования в других модулях.

  SVN root: Oracle/Module/Logging
*/



/* group: Функции */

/* pfunc: clearLog
  Удаляет записи лога.

  Параметры:
  toTime                      - Время, до которого нужно удалить логи
                                (не включая)

  Возврат:
  число удаленных записей

  ( <body::clearLog>)
*/
function clearLog(
  toTime timestamp with time zone
)
return integer;

end pkg_LoggingUtility;
/
