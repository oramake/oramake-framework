@oms-drop-type tpr_line_iterator_t
create or replace type tpr_line_iterator_t
as object
(
/* db object type: tpr_line_iterator_t
  Итератор для построчного считывания текстовых данных

  SVN root: Oracle/Module/TextParser
*/


/* group: Закрытые объявления */


/* group: Переменные */


/* ivar: textData
  Исходные текстовые данные.
*/
textData clob,

/* ivar: dataLength
  Длина текстовых данных.
*/
dataLength integer,

/* ivar: dataOffset
  Смещение в текстовых данных, начиная с которого нужно продолжать разбор.
*/
dataOffset integer,

/* ivar: lineClobFlag
   Признак, что строка представлена в виде clob
*/
lineClobFlag number(1),

/* ivar: lineText
   Данные строки в виде varchar2 (заполняется только для lineClobFlag = 0)
*/
lineText varchar2(32767),

/* ivar: lineData
   Данные строки в виде clob (заполняется только для lineClobFlag = 1)
*/
lineData clob,

/* ivar: lineNumber
  Номер текущей строки
*/
lineNumber integer,

/* ivar: logger
  Интерфейсный объект для логгирования
*/
logger lg_logger_t,


/* group: Открытые объявления */


/* group: Функции */


/* pfunc: tpr_line_iterator_t
  Создает итератор.

  Параметры:
  textData                    - текстовые данные

  ( <body::tpr_line_iterator_t>)
*/
constructor function tpr_line_iterator_t(
  textData clob
)
return self as result,


/* pfunc: next
  Переходит на следующую строку.

  Возврат:
  - true в случае успешного перехода, false при отсутствии следующей записи

  ( <body::next>)
*/
member function next(
  self in out nocopy tpr_line_iterator_t
)
return boolean,


/* pfunc: getLine
  Возвращает текущую строку

  Возврат:
  - последняя считанная строка; null, если строка не считывалась
    или в случае достижения конца файла

  (<body::getLine>)
*/
member function getLine
return varchar2,


/* pfunc: getLineClob
   Возвращает текущую строку в виде clob

   Возврат:
     - последняя считанная строка; null, если строка не считывалась или в
       случае достижения конца файла

   (<body::getLineClob>)
*/
member function getLineClob
return clob,


/* pfunc: getLineNumber
  Возвращает номер текущей строки

  Возврат:
  - номер считанной строки; 0, если строка не считывалась;
    null, если достигнут конец файла

  (<body::getLineNumber>)
*/
member function getLineNumber
return integer
)
/