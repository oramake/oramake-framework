create or replace package pkg_Common is
/* package: pkg_Common
  Интерфейсный пакет модуля Common.
  Содержит общеупотребительные функции различного назначения.
*/



/* group: Константы */

/* const: Module_Name
  Название модуля, к которому относится пакет.
*/
Module_Name constant varchar2(30) := 'Common';



/* group: Функции */



/* group: Параметры сессии */

/* pfunc: getInstanceName
  Возвращает имя текущей базы ( значение параметра INSTANCE_NAME).

  ( <body::getInstanceName>)
*/
function getInstanceName
return varchar2;

/* pfunc: getSessionSid
  Возвращает SID текущей сессии.

  ( <body::getSessionSid>)
*/
function getSessionSid
return number;

/* pfunc: getSessionSerial
  Возвращает serial# текущей сессии.

  Замечания:
  - для компиляции пакета при отсутствии прав на v$session выборка производится
    через динамический SQL ( в случае отсутствия прав будет возникать ошибка
    при выполнении функции);

  ( <body::getSessionSerial>)
*/
function getSessionSerial
return number;

/* pfunc: getIpAddress
  Возвращает IP адрес текущего сервера БД.

  Замечания:
  - для успешного выполнения функции в Oracle 11 и выше нужны дополнительные права;

  ( <body::getIpAddress>)
*/
function getIpAddress
return varchar2;



/* group: Настройки БД */

/* pfunc: isProduction
  Возвращает 1, если функция выполняется в промышленной базе, в других случаях
  возвращает 0.

  ( <body::isProduction>)
*/
function isProduction
return integer;



/* group: Нотификация по e-mail */

/* pfunc: getSmtpServer
  Возвращает имя ( или IP-адрес) доступного SMTP-сервера.

  ( <body::getSmtpServer>)
*/
function getSmtpServer
return varchar2;

/* pfunc: getMailAddressSource
  Формирует исходящий почтовый адрес для отправки сообщений.

  Параметры:
  systemName                  - название системы или модуля, формирующего
                                сообщение ( например, "Scheduler",
                                "DataGateway")

  ( <body::getMailAddressSource>)
*/
function getMailAddressSource(
  systemName varchar2 := null
)
return varchar2;

/* pfunc: getMailAddressDestination
  Возвращает целевой почтовый адрес для отправки сообщений.

  ( <body::getMailAddressDestination>)
*/
function getMailAddressDestination
return varchar2;

/* pproc: sendMail
  Отправляет письмо по e-mail.

  Параметры:
  mailSender                  - адрес отправителя
  mailRecipient               - адрес получателя
  subject                     - тема письма
  message                     - текст письма
  smtpServer                  - SMTP-сервер для отправки письма ( по умолчанию
                                используется сервер, возвращаемый функцией
                                <getSmtpServer>)

  ( <body::sendMail>)
*/
procedure sendMail(
  mailSender varchar2
  , mailRecipient varchar2
  , subject varchar2
  , message varchar2
  , smtpServer varchar2 := null
);



/* group: Прогресс длительных операций */

/* pproc: startSessionLongops
  Добавляет в представление v$session_longops строку для длительно выполняющейся
  операции.

  Параметры:
  operationName               - название выполняемой операции
  units                       - единица измерения объема работы
  target                      - ID объекта, над которым совершается операция
  targetDesc                  - описание объекта, над которым совершается
                                опеация
  sofar                       - объем выполненных работ
  totalWork                   - общий объем работы
  contextValue                - числовое значение, относящееся к текущему
                                состоянию

  ( <body::startSessionLongops>)
*/
procedure startSessionLongops(
  operationName varchar2
  , units varchar2 := null
  , target binary_integer := 0
  , targetDesc varchar2 := 'unknown target'
  , sofar number := 0
  , totalWork number := 0
  , contextValue binary_integer := 0
);

/* pproc: setSessionLongops
  Периодически обновляет прогресс выполнения текущей операции.

  Параметры:
  sofar                       - объем выполненных работ
  totalWork                   - общий объем работы
  contextValue                - числовое значение, относящееся к текущему
                                состоянию

  ( <body::setSessionLongops>)
*/
procedure setSessionLongops(
  sofar number
  , totalwork number
  , contextvalue binary_integer
);



/* group: Функции преобразования */

/* pfunc: transliterate
  Transliterate Russian source text into Latin.

  Parameters:
  source                      - Russian source text.

  ( <body::transliterate>)
*/
function transliterate(
  source in varchar2
)
return string;

/* pfunc: numberToWord
  Преобразовывает сумму числом в сумму прописью.
  Минимальное число: нуль рублей.
  Максимальное число: триллион рублей минус одна копейка (999999999999.99)
  Если число не может быть преобразовано в строку, функция возвращает строку
  '############################################## копеек'

  Параметр:
  source                      - сумма числом

  ( <body::numberToWord>)
*/
function numberToWord(
  source number
)
return varchar2;

/* pfunc: getStringByDelimiter
  Функция достаёт часть строки по позиции и разделителю.

  Параметры:
  initString                  - строка, в которой осуществляется поиск
  delimiter                   - разделитель
  position                    - номер подстроки ( начиная с 1)

  ( <body::getStringByDelimiter>)
*/
function getStringByDelimiter(
  initString varchar2
  , delimiter varchar2
  , position integer := 1
)
return varchar2;

/* pfunc: split
  Функция разделяет строку по заданному разделителю и преобразует к таблице
  для обработки и использования в запросах.

  Параметры:
  initString                  - входная строка для разбора
  delimiter                   - разделитель ( по умолчанию ',')

  Возвращаемое значение:
  nested table со значениями преобразованной строки.

  Пример использования:

  (code)

  select column_value as result from table( pkg_Common.split( '1,4,3,23', ','));

  (end)


  ( <body::split>)
*/
function split(
  initString varchar2
  , delimiter varchar2 := ','
)
return cmn_string_table_t
pipelined;

/* pfunc: split( CLOB)
  Перегруженная функция разделяет строку по заданному разделителю и
  преобразует к таблице для обработки и использования в запросах.
  Функция аналогична функции <split>, но обрабатывает входную строку типа CLOB.

  Параметры:
  initClob                    - входная строка для разбора
  delimiter                   - разделитель

  Возвращаемые значения:
  nested table со значениями преобразованной строки.

  ( <body::split( CLOB)>)
*/
function split(
  initClob clob
  , delimiter varchar2 := ','
)
return cmn_string_table_t
pipelined;



/* group: Отладка */

/* pproc: outputMessage
  Выводит текстовое сообщение через dbms_output.
  Строки сообщения, длина которых больше 255 символов, при выводе автоматически
  разбиваются на строки допустимого размера ( в связи ограничением на длину
  строки в процедуре dbms_output.put_line).

  Параметры:
  messageText                 - текст сообщения

  Замечания:
  - разбивка при выводе слишком длинных строк сообщения по возможности
    производится по символу новой строки ( 0x0A) либо перед пробелом;

  ( <body::outputMessage>)
*/
procedure outputMessage(
  messageText varchar2
);

end pkg_Common;
/
