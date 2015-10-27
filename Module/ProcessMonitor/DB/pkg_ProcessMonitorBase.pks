create or replace package pkg_ProcessMonitorBase is
/* package: pkg_ProcessMonitorBase
  Пакет модуля ProcessMonitor, содержащий константы
  и базовые функции

  SVN root: Oracle/Module/ProcessMonitor
*/



/* group: Константы */



/* const: Module_Name
  Название модуля, к которому относится пакет.
*/
Module_Name constant varchar2(30) := 'ProcessMonitor';

/* const: OraKill_SessionActionCode
  Код действия orakill для сессии
*/
OraKill_SessionActionCode constant varchar2(10) := 'ORAKILL';

/* const: Trace_SessionActionCode
  Код действия "включение трассировки" для сессии
*/
Trace_SessionActionCode constant varchar2(10) := 'TRACE';

/* const: SendTrace_SessionActionCode
  Код действия "отправка сообщения трассировки" для сессии
*/
SendTrace_SessionActionCode constant varchar2(10) := 'SENDTRACE';

/* const: TraceCopyPath_OptionName
  Опция "директория для Trace-файлов" по-умолчанию.
*/
TraceCopyPath_OptionName constant varchar2(100) :=
  'DefaultTraceCopyPath';

end pkg_ProcessMonitorBase;
/
