create package pkg_Scheduler is
/* package: pkg_Scheduler(dummy)
  Временная спецификация для компиляции pkg_LoggingInternal.

  SVN root: Oracle/Module/Logging
*/



/* const: Error_MessageTypeCode
  Код типа сообщений "Ошибка".
*/
Error_MessageTypeCode constant varchar2(10) := 'ERROR';

/* const: Warning_MessageTypeCode
  Код типа сообщений "Предупреждение".
*/
Warning_MessageTypeCode constant varchar2(10) := 'WARNING';

/* const: Info_MessageTypeCode
  Код типа сообщений "Информация".
*/
Info_MessageTypeCode constant varchar2(10) := 'INFO';

/* const: Debug_MessageTypeCode
  Код типа сообщений "Отладка".
*/
Debug_MessageTypeCode constant varchar2(10) := 'DEBUG';



/* group: Функции */

/* pproc: dummyProcedure
  Процедура для того, чтобы при компиляции реализации пакета, выводилась
  ошибка.
*/
procedure dummyProcedure;

/* pproc: writeLog
  Записывает сообщение в лог (таблицу sch_log).

  Параметры:
  messageTypeCode           - код типа сообщения
  messageText               - текст сообщения
  messageValue              - целое значение, связанное с сообщением
  operatorId                - Id оператора
*/
procedure writeLog(
  messageTypeCode varchar2
  , messageText varchar2
  , messageValue number := null
  , operatorId integer := null
);

/* pproc: setDebugFlag
  Устанавливает флаг отладки в указанное значение.
*/
procedure setDebugFlag(
  flagValue integer := 1
);

/* pfunc: getDebugFlag
  Возвращает значение флага отладки.
*/
function getDebugFlag
return integer;


end pkg_Scheduler;
/
