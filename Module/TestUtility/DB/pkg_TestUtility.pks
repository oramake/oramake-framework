create or replace package pkg_TestUtility
authid current_user
as
/* package: pkg_TestUtility
  Интерфейсный пакет модуля TestUtility.

  SVN root: Oracle/Module/TestUtility
*/


/* group: Константы */


/* const: Module_Name
  Название модуля, к которому относится пакет.
*/
Module_Name constant varchar2(30) := 'TestUtility';



/* group: Функции */

/* pfunc: isTestFailed
  Возвращает истину, если по последнему выполнявшемуся тесту ( текущему либо
  завершенному) зафиксирована ошибка.

  Возврат:
  истина если зафиксирована ошибка, иначе ложь.

  ( <body::isTestFailed>)
*/
function isTestFailed
return boolean;

/* pproc: beginTest
   Начало теста.

   Параметры:
     messageText                    - текст сообщения

  ( <body::beginTest>)
*/
procedure beginTest(
  messageText varchar2
);

/* pproc: endTest
  Завершение теста.

  ( <body::endTest>)
*/
procedure endTest;

/* pproc: failTest
  Неуспешное завершение теста.

  Параметры:
  failMessageText                 - сообщение о неуспешном результате

  ( <body::failTest>)
*/
procedure failTest(
  failMessageText varchar2
);

/* pproc: addTestInfo
  Добавить информацию в соообщение по тесту.

  ( <body::addTestInfo>)
*/
procedure addTestInfo(
  addonMessage varchar2
  , position integer := null
);

/* pfunc: getTestTimeSecond
  Получение интервала времени выполнения теста ( в секундах).

  ( <body::getTestTimeSecond>)
*/
function getTestTimeSecond
return number;

/* pfunc: compareChar ( func )
   Сравнение строковых данных.

   Параметры:
     actualString                   - текущая строка
     expectedString                 - ожидаемая строка
     failMessageText                - сообщение при несовпадении строк
     considerWhitespace             - учёт служебных символов при сравнении
                                      ( по-умолчанию нет )

   Возврат:
     - true в случае совпадения строк или false в противном случае

  ( <body::compareChar ( func )>)
*/
function compareChar (
    actualString        in varchar2
  , expectedString      in varchar2
  , failMessageText     in varchar2
  , considerWhitespace in boolean := null
  )
return boolean;

/* pproc: compareChar ( proc )
   Сравнение строковых данных.

   Параметры:
     actualString                   - текущая строка
     expectedString                 - ожидаемая строка
     failMessageText                - сообщение при несовпадении строк
     considerWhitespace             - учёт служебных символов при сравнении
                                      ( по-умолчанию нет )

  ( <body::compareChar ( proc )>)
*/
procedure compareChar (
    actualString        in varchar2
  , expectedString      in varchar2
  , failMessageText     in varchar2
  , considerWhitespace  in boolean := null
  );

/* pfunc: compareRowCount ( func, table )
   Сравнение текущего кол-ва строк в таблице с ожидаемым кол-вом.

   Параметры:
     tableName                      - имя таблицы
     filterCondition                - условия фильтрации строк в таблице
     expectedRowCount               - ожидаемое кол-во строк
     failMessageText                - сообщение при несовпадении кол-ва строк

   Возврат:
     - true в случае совпадения кол-ва строк или false в противном случае

   Примечание: параметр filterCondition передается в раздел where запроса без
   изменений

  ( <body::compareRowCount ( func, table )>)
*/
function compareRowCount (
    tableName            in varchar2
  , filterCondition      in varchar2 := null
  , expectedRowCount     in pls_integer
  , failMessageText      in varchar2 := null
  )
return boolean;

/* pproc: compareRowCount ( proc, table )
   Сравнение текущего кол-ва строк в таблице с ожидаемым кол-вом.

   Параметры:
     tableName                      - имя таблицы
     filterCondition                - условия фильтрации строк в таблице
     expectedRowCount               - ожидаемое кол-во строк
     failMessageText                - сообщение при несовпадении кол-ва строк

   Примечание: параметр filterCondition передается в раздел where запроса без
   изменений

  ( <body::compareRowCount ( proc, table )>)
*/
procedure compareRowCount (
    tableName            in varchar2
  , filterCondition      in varchar2 := null
  , expectedRowCount     in pls_integer
  , failMessageText      in varchar2 := null
  );

/* pfunc: compareRowCount ( func, cursor )
   Сравнение текущего кол-ва строк в sys_refcursor с ожидаемым кол-вом.

   Параметры:
     rc                             - sys_refcursor
     filterCondition                - условие фильтрации строк в курсоре
     expectedRowCount               - ожидаемое кол-во строк
     failMessageText                - сообщение при несовпадении кол-ва строк

   Возврат:
     - true в случае совпадения кол-ва строк или false в противном случае

  ( <body::compareRowCount ( func, cursor )>)
*/
function compareRowCount (
    rc                   in sys_refcursor
  , filterCondition      in varchar2 := null
  , expectedRowCount     in pls_integer
  , failMessageText      in varchar2 := null
  )
return boolean;

/* pproc: compareRowCount ( proc, cursor )
   Сравнение текущего кол-ва строк в sys_refcursor с ожидаемым кол-вом.

   Параметры:
     rc                             - sys_refcursor
     filterCondition                - условие фильтрации строк в курсоре
     expectedRowCount               - ожидаемое кол-во строк
     failMessageText                - сообщение при несовпадении кол-ва строк

  ( <body::compareRowCount ( proc, cursor )>)
*/
procedure compareRowCount (
    rc                   in sys_refcursor
  , filterCondition      in varchar2 := null
  , expectedRowCount     in pls_integer
  , failMessageText      in varchar2 := null
  );

/* pfunc: compareQueryResult ( func, cursor )
  Сравнение данных в sys_refcursor с ожидаемыми.

  Параметры:
  rc                          - Фактические данные (sys_refcursor)
  expectedCsv                 - Ожидаемые данные в CSV
  idColumnName                - Имя колонки курсора с Id строки для указания в
                                тексте сообщений (без учета регистра, колонка
                                игнорируется при сравнении)
                                (по умолчанию отсутствует)
  considerWhitespace          - Учёт служебных символов при сравнении текстовых
                                данных
                                (по умолчанию нет)
  failMessagePrefix           - Префикс сообщения при несовпадении данных
                                (по умолчанию отсутствует)

  Возврат:
  - true в случае совпадения данных или false в противном случае

  ( <body::compareQueryResult ( func, cursor )>)
*/
function compareQueryResult (
  rc in out nocopy sys_refcursor
, expectedCsv clob
, idColumnName varchar2 := null
, considerWhitespace boolean := null
, failMessagePrefix varchar2 := null
)
return boolean;

/* pproc: compareQueryResult ( proc, cursor )
  Сравнение данных в sys_refcursor с ожидаемыми.

  Параметры:
  rc                          - Фактические данные (sys_refcursor)
  expectedCsv                 - Ожидаемые данные в CSV
  idColumnName                - Имя колонки курсора с Id строки для указания в
                                тексте сообщений (без учета регистра, колонка
                                игнорируется при сравнении)
                                (по умолчанию отсутствует)
  considerWhitespace          - Учёт служебных символов при сравнении текстовых
                                данных
                                (по умолчанию нет)
  failMessagePrefix           - Префикс сообщения при несовпадении данных
                                (по умолчанию отсутствует)

  ( <body::compareQueryResult ( proc, cursor )>)
*/
procedure compareQueryResult (
  rc in out nocopy sys_refcursor
, expectedCsv clob
, idColumnName varchar2 := null
, considerWhitespace boolean := null
, failMessagePrefix varchar2 := null
);

/* pfunc: compareQueryResult ( func, table )
  Сравнение данных в таблице с ожидаемыми.

  Параметры:
  tableName                   - Имя таблицы
  filterCondition             - Условия фильтрации строк в таблице
                                (по умолчанию отсутствует)
  expectedCsv                 - Ожидаемые данные в CSV
  orderByExpression           - Выражения для упорядочения отбираемых строк
                                (по умолчанию отсутствует)
  idColumnName                - Имя колонки с Id строки для указания в тексте
                                сообщений
                                (по умолчанию отсутствует)
  considerWhitespace          - Учёт служебных символов при сравнении текстовых
                                данных
                                (по умолчанию нет)
  failMessagePrefix           - Префикс сообщения при несовпадении данных
                                (по умолчанию отсутствует)

  Возврат:
  - true в случае совпадения данных или false в противном случае

  ( <body::compareQueryResult ( func, table )>)
*/
function compareQueryResult(
  tableName varchar2
, filterCondition varchar2 := null
, expectedCsv clob
, orderByExpression varchar2 := null
, idColumnName varchar2 := null
, considerWhitespace boolean := null
, failMessagePrefix varchar2 := null
)
return boolean;

/* pproc: compareQueryResult ( proc, table )
  Сравнение данных в таблице с ожидаемыми.

  Параметры:
  tableName                   - Имя таблицы
  filterCondition             - Условия фильтрации строк в таблице
                                (по умолчанию отсутствует)
  expectedCsv                 - Ожидаемые данные в CSV
  orderByExpression           - Выражения для упорядочения отбираемых строк
                                (по умолчанию отсутствует)
  idColumnName                - Имя колонки с Id строки для указания в тексте
                                сообщений
                                (по умолчанию отсутствует)
  considerWhitespace          - Учёт служебных символов при сравнении текстовых
                                данных
                                (по умолчанию нет)
  failMessagePrefix           - Префикс сообщения при несовпадении данных
                                (по умолчанию отсутствует)

  ( <body::compareQueryResult ( proc, table )>)
*/
procedure compareQueryResult(
  tableName varchar2
, filterCondition varchar2 := null
, expectedCsv clob
, orderByExpression varchar2 := null
, idColumnName varchar2 := null
, considerWhitespace boolean := null
, failMessagePrefix varchar2 := null
);

end pkg_TestUtility;
/
