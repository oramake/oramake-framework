create or replace package pkg_Logging is
/* package: pkg_Logging
  Интерфейсный пакет модуля Logging.

  SVN root: Oracle/Module/Logging
*/



/* group: Константы */

/* const: Module_Name
  Название модуля, к которому относится пакет.
*/
Module_Name constant varchar2(30) := 'Logging';



/* group: Уровни сообщений лога */

/* const: Off_LevelCode
  Код уровня "Логирование отключено".
*/
Off_LevelCode varchar2(10) := 'OFF';

/* const: Fatal_LevelCode
  Код уровня "Фатальная ошибка".
*/
Fatal_LevelCode varchar2(10) := 'FATAL';

/* const: Error_LevelCode
  Код уровня "Ошибка".
*/
Error_LevelCode varchar2(10) := 'ERROR';

/* const: Warning_LevelCode
  Код уровня "Предупреждение".
*/
Warning_LevelCode varchar2(10) := 'WARN';

/* const: Info_LevelCode
  Код уровня "Информация".
*/
Info_LevelCode varchar2(10) := 'INFO';

/* const: Debug_LevelCode
  Код уровня "Отладка".
*/
Debug_LevelCode varchar2(10) := 'DEBUG';

/* const: Trace_LevelCode
  Код уровня "Трассировка".
*/
Trace_LevelCode varchar2(10) := 'TRACE';

/* const: All_LevelCode
  Код уровня "Максимальный уровень логирования".
*/
All_LevelCode varchar2(10) := 'ALL';



/* group: Назначения вывода */

/* const: DbmsOutput_DestinationCode
  Код назначения "Вывод через dbms_output".
*/
DbmsOutput_DestinationCode varchar2(10) := 'DBOUT';

/* const: Table_DestinationCode
  Код назначения "Таблица лога в БД".
*/
Table_DestinationCode varchar2(10) := 'TAB';



/* group: Функции */

/* pproc: SetDestination
  Устанавливает единственное назначения для вывода
  (<body::SetDestination>)
*/
procedure SetDestination(
  destinationCode varchar2
);

/* pproc: LogMessage
  Логирует информационное сообщение
  ( <body::LogMessage>)
*/
procedure LogMessage( Message varchar2 );

/* pfunc: LogDebug
  Логирует отладочное сообщение
  ( вызова ( <body::LogDebug>)
*/
procedure LogDebug( Message varchar2 );

/* pfunc: GetErrorStack
  Получает информацию о стеке ошибок
  ( <body::GetErrorStack>).
*/
function GetErrorStack(
  isStackPreserved integer := null
)
return varchar2;

/* pproc: ClearErrorStack
   Очищает( сбрасывает) стек ошибок
  ( <body::ClearErrorStack>).
*/
procedure ClearErrorStack;

end pkg_Logging;
/
