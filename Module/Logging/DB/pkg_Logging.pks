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



/* group: Уровни логирования */

/* const: Off_LevelCode
  Код уровня логирования "Логирование отключено".
*/
Off_LevelCode varchar2(10) := 'OFF';

/* const: Fatal_LevelCode
  Код уровня логирования "Фатальная ошибка".
*/
Fatal_LevelCode varchar2(10) := 'FATAL';

/* const: Error_LevelCode
  Код уровня логирования "Ошибка".
*/
Error_LevelCode varchar2(10) := 'ERROR';

/* const: Warn_LevelCode
  Код уровня логирования "Предупреждение".
*/
Warn_LevelCode varchar2(10) := 'WARN';

/* const: Info_LevelCode
  Код уровня логирования "Информация".
*/
Info_LevelCode varchar2(10) := 'INFO';

/* const: Debug_LevelCode
  Код уровня логирования "Отладка".
*/
Debug_LevelCode varchar2(10) := 'DEBUG';

/* const: Trace_LevelCode
  Код уровня логирования "Трассировка".
*/
Trace_LevelCode varchar2(10) := 'TRACE';

/* const: All_LevelCode
  Код уровня логирования "Максимальный уровень логирования".
*/
All_LevelCode varchar2(10) := 'ALL';

/* const: Warning_LevelCode( DEPRECATED)
  Устаревшая константа, следует использовать <Warn_LevelCode>.
*/
Warning_LevelCode varchar2(10) := Warn_LevelCode;



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

/* pproc: setDestination
  Устанавливает единственное назначения для вывода.

  Параметры:
  destinationCode             - код назначения

  Замечания:
  - вызывает <pkg_LoggingInternal.setDestination>;

  ( <body::setDestination>)
*/
procedure setDestination(
  destinationCode varchar2
);

/* pproc: logDebug
  Логирует отладочное сообщение уровня <Debug_LevelCode>.

  Параметры:
  message                     - сообщение

  Замечания:
  - вызывает <pkg_LoggingInternal.logMessage>;

  ( <body::logDebug>)
*/
procedure logDebug(
  message varchar2
);

/* pproc: logMessage
  Логирует информационное сообщение уровня <Info_LevelCode>.

  Параметры:
  message                         - сообщение

  Замечания:
  - вызывает <pkg_LoggingInternal.logMessage>;

  ( <body::logMessage>)
*/
procedure logMessage(
  message varchar2
);

/* pfunc: getErrorStack
  Получает информацию о стеке ошибок.

  Параметры:
  isStackPreserved            - оставлять ли данные по стеку.
                                По-умолчанию ( null) не оставлять
                                ( т.е. очищать),
                                таким образом по-умолчанию
                                после вызова стек не может быть
                                соединён далее.

  Возврат:
  - текст с информацией о стеке

  Замечания:
  - вызывает <pkg_LoggingErrorStack.getErrorStack>;

  ( <body::getErrorStack>)
*/
function getErrorStack(
  isStackPreserved integer := null
)
return varchar2;

/* pproc: clearErrorStack
  Очищает( сбрасывает) стек ошибок.

  Замечания:
  - вызывает <pkg_LoggingErrorStack.clearLastStack>;

  ( <body::clearErrorStack>)
*/
procedure clearErrorStack;

end pkg_Logging;
/
