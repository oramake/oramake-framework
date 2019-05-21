create or replace package body pkg_Logging is
/* package body: pkg_Logging::body */



/* group: Функции */

/* proc: setDestination
  Устанавливает единственное назначение для вывода.

  Параметры:
  destinationCode             - Код назначения
                                (null для возврата к выводу по умолчанию)

  Замечания:
  - по умолчанию (если не задано единственное назначение для вывода)
    логируемые сообщения добавляются в таблицу <lg_log>, а в тестовых БД
    дополнительно выводятся через пакет dbms_output;
*/
procedure setDestination(
  destinationCode varchar2
)
is
begin
  pkg_LoggingInternal.setDestination(
    destinationCode => destinationCode
  );
end setDestination;

/* proc: logDebug
  Логирует отладочное сообщение уровня <Debug_LevelCode>.

  Параметры:
  message                     - сообщение

  Замечания:
  - вызывает <pkg_LoggingInternal.logMessage>;
*/
procedure logDebug(
  message varchar2
)
is
begin
  pkg_LoggingInternal.logMessage(
    levelCode     => Debug_LevelCode
    , messageText => message
  );
end logDebug;

/* proc: logMessage
  Логирует информационное сообщение уровня <Info_LevelCode>.

  Параметры:
  message                         - сообщение

  Замечания:
  - вызывает <pkg_LoggingInternal.logMessage>;
*/
procedure logMessage(
  message varchar2
)
is
begin
  pkg_LoggingInternal.logMessage(
    levelCode     => Info_LevelCode
    , messageText => message
  );
end logMessage;

/* func: getErrorStack
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
*/
function getErrorStack(
  isStackPreserved integer := null
)
return varchar2
is
begin
  return
    pkg_LoggingErrorStack.getErrorStack(
      isStackPreserved => isStackPreserved
    );
end getErrorStack;

/* proc: clearErrorStack
  Очищает( сбрасывает) стек ошибок.

  Замечания:
  - вызывает <pkg_LoggingErrorStack.clearLastStack>;
*/
procedure clearErrorStack
is
begin
  pkg_LoggingErrorStack.clearLastStack();
end clearErrorStack;

end pkg_Logging;
/
