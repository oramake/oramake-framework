create or replace package body pkg_Logging is
/* package body: pkg_Logging::body */

/* proc: SetDestination
  Устанавливает единственное назначения для вывода.

  Параметры:
  destinationCode             - код назначения

  Замечания:
  - вызывает <pkg_LoggingInternal.SetDestination>;
*/
procedure SetDestination(
  destinationCode varchar2
)
is
begin
  pkg_LoggingInternal.SetDestination(
    destinationCode => destinationCode
  );
end SetDestination;

/* func: LogDebug
  Логирует отладочное сообщение уровня <Debug_LevelCode>.

  Параметры:
  Message - сообщение

  Замечания:
  - вызывает <pkg_LoggingInternal.LogMessage>;
*/
procedure LogDebug
 (Message varchar2
 )
 is
begin
  pkg_LoggingInternal.LogMessage(
    levelCode     => Debug_LevelCode
    , messageText => message
  );
end LogDebug;


/* proc: LogMessage
  Логирует информационное сообщение уровня <Info_LevelCode>.

  Параметры:
    Message - сообщение

  Замечания:
  - вызывает <pkg_LoggingInternal.LogMessage>;
*/
procedure LogMessage( Message varchar2 )
is
begin
  pkg_LoggingInternal.LogMessage(
    levelCode     => Info_LevelCode
    , messageText => message
  );
end LogMessage;

/* func: GetErrorStack
  Получает информацию о стеке ошибок.

  Параметры:
    isStackPreserved         - оставлять ли данные по стеку.
                               По-умолчанию ( null) не оставлять 
                               ( т.е. очищать), 
                               таким образом по-умолчанию 
                               после вызова стек не может быть 
                               соединён далее.

  Возврат:
    - текст с информацией о стеке

  Замечания:
  - вызывает <pkg_LoggingErrorStack.GetErrorStack>;
*/
function GetErrorStack( 
  isStackPreserved integer := null
)
return varchar2
is
begin
  return
    pkg_LoggingErrorStack.GetErrorStack(
      isStackPreserved => isStackPreserved
    );
end GetErrorStack;

/* proc: ClearErrorStack
  Очищает( сбрасывает) стек ошибок.

  Замечания:
  - вызывает <pkg_LoggingErrorStack.ClearLastStack>;
*/
procedure ClearErrorStack
is
begin
  pkg_LoggingErrorStack.ClearLastStack();
end ClearErrorStack;

end pkg_Logging;
/
