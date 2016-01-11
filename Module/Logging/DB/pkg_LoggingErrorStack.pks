create or replace package pkg_LoggingErrorStack is
/* package: pkg_LoggingErrorStack
  Внутренний пакет модуля Logging, отвечающий
  за логирование информации об ошибках ( исключениях)

  SVN root: Oracle/Module/Logging
*/

/* pproc: ClearLastStack
  Сбрасывает информацию о предыдущем стеке ошибок
  (<body::ClearLastStack> ).
*/
procedure ClearLastStack;

/* pfunc: ProcessStackElement
  Логирует и запоминает параметры элемента стека.
  Возвращает строку для генерации исключения.
  (<body::ProcessStackElement> ).
*/
function ProcessStackElement(
  messageText varchar2
)
return varchar2;

/* pfunc: ProcessRemoteStackElement
  Логирует и запоминает параметры элемента стека,
  учитывая стек на удалённой базе. В случае
  наличия информации в <body::lastStack>, сначала пытается
  обработать локальный стек
  ( <body::ProcessRemoteStackElement>).
*/
function ProcessRemoteStackElement(
  messageText varchar2
  , dbLink varchar2
)
return varchar2;

/* pproc: LogErrorStack
  Логирует и очищает стек ошибок
  (<body::LogErrorStack> ).
*/
procedure LogErrorStack(
  messageText varchar2
);

/* pfunc: GetErrorStack
  Получает информацию о стеке ошибок
  (<body::GetErrorStack> ).
*/
function GetErrorStack(
  isStackPreserved integer := null
)
return varchar2;

/* pproc: GetLastStack
  Получает данные по последнему стеку.
  Если информация в <body::lastStack> не сброшена,
  возвращает данные <body::lastStack>, иначе возвращает
  данные <body::lastClearedStack>
  ( <body::GetLastStack>).
*/  
procedure GetLastStack(
  raisedText               out varchar2
  , oracleMessage          out varchar2
  , messageText            out varchar2
  , resolvedStack          out varchar2
  , callStack              out varchar2
);

end pkg_LoggingErrorStack;
/
