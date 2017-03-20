create or replace package pkg_LoggingErrorStack is
/* package: pkg_LoggingErrorStack
  Внутренний пакет модуля Logging, отвечающий
  за логирование информации об ошибках ( исключениях)

  SVN root: Oracle/Module/Logging
*/



/* group: Функции */

/* pproc: clearLastStack
  Сбрасывает информацию о предыдущем стеке ошибок

  Примечание:
  - может быть вызвана как в блоке обработки исключений,
    так и вне его.
  - вызывает <clearLastStack(messageText)>
    с сообщением "Сброс стека"

  ( <body::clearLastStack>)
*/
procedure clearLastStack;

/* pfunc: processStackElement
  Логирует и запоминает параметры элемента стека.
  Возвращает строку для генерации исключения.

  Параметры:
  messageText                 - текст сообщения

  Возврат:
  - текст для генерации исключения, при небольшой длине стека не отличается от
    messageText

  Примечание:
  - может быть вызвана как в блоке обработки исключений, так и вне его.  При
    вызове вне блока исключения, вероятнее стек не сможет быть соединён с
    предыдущим, если он не сброшен.

  ( <body::processStackElement>)
*/
function processStackElement(
  messageText varchar2
)
return varchar2;

/* pproc: logErrorStack
  Очищает стек ошибок. Логирует информацию о стеке с уровнем
  <pkg_Logging.Error_LevelCode>, если удалось связать стек с предыдущей
  информацией.

  Параметры:
  messageText                 - текст дополнительного сообщения

  ( <body::logErrorStack>)
*/
procedure logErrorStack(
  messageText varchar2
);

/* pfunc: processRemoteStackElement
  Логирует и запоминает параметры элемента стека, учитывая стек на удалённой
  базе. В случае наличия информации в <body::lastStack>, сначала пытается
  обработать локальный стек

  Параметры:
  messageText                 - текст сообщения
  dbLink                      - имя линка к БД

  Возврат:
  - текст для генерации исключения, при небольшой длине стека не отличается от
    messageText

  Примечание:
  - используется функция <getRemoteStack>;
  - рекомендуется вызывать в блоке обработки исключений;

  ( <body::processRemoteStackElement>)
*/
function processRemoteStackElement(
  messageText varchar2
  , dbLink varchar2
)
return varchar2;

/* pfunc: getErrorStack
  Получает информацию о стеке ошибок.

  isStackPreserved            - оставлять ли данные по стеку.
                                По-умолчанию ( null) не оставлять ( т.е.
                                очищать), таким образом по-умолчанию после
                                вызова стек не может быть соединён далее.

  Возврат:
  - текст с информацией о стеке

  Примечание:
  - рекомендуется вызывать в блоке обработки исключения;

  ( <body::getErrorStack>)
*/
function getErrorStack(
  isStackPreserved integer := null
)
return varchar2;

/* pproc: getLastStack
  Получает данные по последнему стеку.
  Если информация в <body::lastStack> не сброшена,
  возвращает данные <body::lastStack>, иначе возвращает
  данные <body::lastClearedStack>.

  Параметры:
  raisedText                 - сообщение для генерации исключения,
                               возвращаемое функцией <processStackElement>
  oracleMessage              - значение <errorStack> сообщения в стеке
  messageText                - переданный текст сообщения об ошибке
  resolvedStack              - полный расшированный текст сообщения
                               об ошибке
  callStack                  - текст информации о стеке вызовов

  ( <body::getLastStack>)
*/
procedure getLastStack(
  raisedText               out varchar2
  , oracleMessage          out varchar2
  , messageText            out varchar2
  , resolvedStack          out varchar2
  , callStack              out varchar2
);

end pkg_LoggingErrorStack;
/
