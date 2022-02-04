create or replace type tpr_csv_iterator_t
as object
(
/* db object type: tpr_csv_iterator_t
  Итератор для текстовых данных в формате CSV.

  SVN root: Oracle/Module/TextParser
*/



/* group: Закрытые объявления */



/* group: Переменные */

/* ivar: logger
  Логер пакета.
*/
logger lg_logger_t,

/* ivar: textData
  Исходные текстовые данные.
*/
textData clob,

/* ivar: headerRecordNumber
  Номер строки с названиями полей.
*/
headerRecordNumber integer,

/* ivar: skipRecordCount
  Число пропускаемых записей от начала текстовых данных.
*/
skipRecordCount integer,

/* iver: fieldSeparator
  Символ-разделитель полей записи.
*/
fieldSeparator varchar2(1),

/* ivar: noEnclosedCharFlag
  Флаг отсутствия в файле специального символа органичителя строк ( '"',
  по-умолчанию считается, что символ может быть).
*/
noEnclosedCharFlag integer,


/* ivar: parsedRecordCount
  Число разобранных записей ( включая текущую).
*/
parsedRecordCount integer,

/* ivar: recordNumber
  Номер текущей записи.
  Нумерация с 1, в случае исчерпания данных recordNumber > <parsedRecordCount>.
*/
recordNumber integer,

/* ivar: dataLength
  Длина текстовых данных.
*/
dataLength integer,

/* ivar: dataOffset
  Смещение в текстовых данных, начиная с которого нужно продолжать разбор.
*/
dataOffset integer,

/* ivar: buffer
  Буфер для чтения данных из LOB.
*/
buffer varchar2(32767),

/* ivar: bufferReadSize
  Объем данных, считываемых в буфер за один раз.
*/
bufferReadSize integer,

/* ivar: bufferLength
  Длина данных, считанных в буфер.
*/
bufferLength integer,

/* ivar: bufferOffset
  Смещение в буфере, начиная с которого нужно продолжать разбор.
*/
bufferOffset integer,

/* ivar: colValue
  Значения полей текущей строки в виде строки.
*/
colValue tpr_string_table_t,

/* ivar: colValue
  Значения полей текущей строки в виде CLOB.
*/
colValueClob tpr_clob_table_t,

/* ivar: fieldNameCount
  Число имен полей.
*/
fieldNameCount integer,

/* ivar: fieldNameList
  Список имен полей для выборки данных по имени.
*/
fieldNameList varchar2(3100),



/* group: Функции */



/* group: Закрытые объявления */

/* pproc: getFieldValue
  Возвращает значение поля с указанным номером.
  В случае некорректного номера выбрасывается исключение с информацией по
  ошибке.

  Параметры:
  fieldValue                  - значение поля в виде строки
  fieldValueClob              - значниие поля в виде CLOB (если значение не
                                влезает в строку)
  fieldNumber                 - номер поля ( начиная с 1)

  Возврат:
  - значение поля

  ( <body::getFieldValue>)
*/
member procedure getFieldValue(
  fieldValue out varchar2
, fieldValueClob out clob
, fieldNumber integer
),



/* group: Открытые объявления */

/* pfunc: tpr_csv_iterator_t
  Создает итератор.

  Параметры:
  textData                    - текстовые данные
  headerRecordNumber          - номер записи, содержащей названия полей ( 0
                                отсутствует, по умолчанию 0)
  skipRecordCount             - число пропускаемых записей от начала текстовых
                                данных ( по умолчанию headerRecordNumber)
  fieldSeparator              - символ-разделитель полей записи
                                ( по умолчанию ";")
  noEnclosedCharFlag          - флаг отсутствия в файле специального символа
                                органичителя строк ( например, '"', по-умолчанию
                                считается, что символ может быть)

  Замечания:
  - после создания итератора перед вызовом остальных функций ( за исключением
    <getDataLength>) должна быть вызвана функций <next> чтобы начать обработку
    данных ( обычно она вызывается в условии цикла while ... loop);

  ( <body::tpr_csv_iterator_t>)
*/
constructor function tpr_csv_iterator_t(
  textData clob
  , headerRecordNumber integer := null
  , skipRecordCount integer := null
  , fieldSeparator varchar2 := null
  , noEnclosedCharFlag number := null
)
return self as result,

/* pfunc: getDataLength
  Возвращает длину исходных текстовых данных.

  Возврат:
  - длина исходных текстовых данных ( в случае их отсутствия возвращает 0)

  ( <body::getDataLength>)
*/
member function getDataLength
return integer,

/* pfunc: next
  Переходит на следующую запись с данными.

  Возврат:
  - true в случае успешного перехода, false при отсутствии следующей записи

  ( <body::next>)
*/
member function next(
  self in out tpr_csv_iterator_t
)
return boolean,

/* pfunc: getRecordNumber
  Возвращает номер текущей записи.
  Записи нумеруются с 1, при этом в нумерацию включаются пропушенные от начала
  данных записи ( если такие имеются).

  Возврат:
  - номер текущей записи ( начиная с 1) или null при отсутствии текущей записи

  ( <body::getRecordNumber>)
*/
member function getRecordNumber
return integer,

/* pfunc: getFieldCount
  Возвращает число полей в текущей записи.

  Возврат:
  - число полей в текущей записи или null при отсутствии текущей записи

  ( <body::getFieldCount>)
*/
member function getFieldCount
return integer,

/* pfunc: getFieldNumber
  Возвращает порядковый номер поля по имени.

  Параметры:
  fieldName                   - имя поля
  isNotFoundRaised            - генерировать ли исключение в случае
                                отсутствия поля с указанным именем
                                ( 1 да ( по умолчанию), 0 нет)

  Возврат:
  порядковый номер поля ( начиная с 1) либо null, если поле отсутствует и
  значение параметра isNotFoundRaised равно 0.

  Замечания:
  - в качестве имени используются первые 30 символов ( начальные и конечные
    пробелы игнорируются) из значения поля в строке заголовка без учета
    регистра;

  ( <body::getFieldNumber>)
*/
member function getFieldNumber(
  fieldName varchar2
  , isNotFoundRaised integer := null
)
return integer,

/* pfunc: isFieldExists
  Проверяет наличие поля с указанным именем.

  Параметры:
  fieldName                   - имя поля

  Возврат:
  1 в случае наличия поля, иначе 0.

  Замечания:
  - для проверки наличия поля используется функция <getFieldNumber>;

  ( <body::isFieldExists>)
*/
member function isFieldExists(
  fieldName varchar2
)
return integer,

/* pfunc: getProcessedCount
  Возвращает число обработанных записей с данными. Учитывается текущая запись
  и не учитываются пропущенные записи по параметру конструктора skipRecordCount.

  Возврат:
  - число обработанных записей ( >= 0)

  ( <body::getProcessedCount>)
*/
member function getProcessedCount
return integer,

/* pfunc: getString
  Возвращает значение поля с указанным номером в виде строки.

  Параметры:
  fieldNumber                 - номер поля ( начиная с 1)

  Возврат:
  - значение поля в виде строки

  ( <body::getString>)
*/
member function getString(
  self in out tpr_csv_iterator_t
, fieldNumber integer
)
return varchar2,

/* pfunc: getString( NAME)
  Возвращает значение поля с указанным именем в виде строки.

  Параметры:
  fieldName                   - название поля
  isNotFoundRaised            - генерировать ли исключение в случае
                                отсутствия поля с указанным именем
                                ( 1 да ( по умолчанию), 0 нет)

  Возврат:
  - значение поля в виде строки

  ( <body::getString( NAME)>)
*/
member function getString(
  self in out tpr_csv_iterator_t
, fieldName varchar2
, isNotFoundRaised integer := null
)
return varchar2,

/* pfunc: getNumber
  Возвращает значение поля с указанным номером в виде числа.

  Параметры:
  fieldNumber                 - номер поля ( начиная с 1)
  decimalCharacter            - символ десятичного разделителя
  isValueErrorRaised          - генерировать ли исключение ( 1,0 )
                                в случае невозможности преобразования.
                                По-умолчанию ( null ) генерировать.
  isTrimPercent               - перед преобразованием в число удалять из
                                значения поля завершающие символы процента
                                ( "%") и пробелы
                                ( 1 да, 0 нет ( по умолчанию))

  Возврат:
  - значение поля в виде числа

  ( <body::getNumber>)
*/
member function getNumber(
  self in out tpr_csv_iterator_t
, fieldNumber integer
, decimalCharacter varchar2 := null
, isValueErrorRaised integer := null
, isTrimPercent integer := null
)
return number,

/* pfunc: getNumber( NAME)
  Возвращает значение поля с указанным именем в виде числа.

  Параметры:
  fieldName                   - название поля
  decimalCharacter            - символ десятичного разделителя
  isValueErrorRaised          - генерировать ли исключение ( 1,0 )
                                в случае невозможности преобразования.
                                По-умолчанию ( null ) генерировать.
  isNotFoundRaised            - генерировать ли исключение в случае
                                отсутствия поля с указанным именем
                                ( 1 да ( по умолчанию), 0 нет)
  isTrimPercent               - перед преобразованием в число удалять из
                                значения поля завершающие символы процента
                                ( "%") и пробелы
                                ( 1 да, 0 нет ( по умолчанию))

  Возврат:
  - значение поля в виде числа

  ( <body::getNumber( NAME)>)
*/
member function getNumber(
  self in out tpr_csv_iterator_t
, fieldName varchar2
, decimalCharacter varchar2 := null
, isValueErrorRaised integer := null
, isNotFoundRaised integer := null
, isTrimPercent integer := null
)
return number,

/* pfunc: getDate
  Возвращает значение поля с указанным номером в виде даты.

  Параметры:
  fieldNumber                 - номер поля ( начиная с 1)
  format                      - формат даты ( для to_date())
  isValueErrorRaised           - генерировать ли исключение ( 1,0 )
                                в случае невозможности преобразования.
                                По-умолчанию ( null ) генерировать.

  Возврат:
  - значение поля в виде даты

  ( <body::getDate>)
*/
member function getDate(
  self in out tpr_csv_iterator_t
, fieldNumber integer
, format varchar2
, isValueErrorRaised integer := null
)
return date,

/* pfunc: getDate( NAME)
  Возвращает значение поля с указанным именем в виде даты.

  Параметры:
  fieldName                   - название поля
  format                      - формат даты ( для to_date())
  isValueErrorRaised           - генерировать ли исключение ( 1,0 )
                                в случае невозможности преобразования.
                                По-умолчанию ( null ) генерировать.
  isNotFoundRaised            - генерировать ли исключение в случае
                                отсутствия поля с указанным именем
                                ( 1 да ( по умолчанию), 0 нет)

  Возврат:
  - значение поля в виде даты

  ( <body::getDate( NAME)>)
*/
member function getDate(
  self in out tpr_csv_iterator_t
, fieldName varchar2
, format varchar2
, isValueErrorRaised integer := null
, isNotFoundRaised integer := null
)
return date,

/* pfunc: getClob
  Возвращает значение поля с указанным номером в виде CLOB.

  Параметры:
  fieldNumber                 - номер поля ( начиная с 1)

  Возврат:
  - значение поля в виде CLOB

  ( <body::getClob>)
*/
member function getClob(
  self in out tpr_csv_iterator_t
, fieldNumber integer
)
return clob,

/* pfunc: getClob( NAME)
  Возвращает значение поля с указанным именем в виде строки.

  Параметры:
  fieldName                   - название поля
  isNotFoundRaised            - генерировать ли исключение в случае
                                отсутствия поля с указанным именем
                                ( 1 да ( по умолчанию), 0 нет)

  Возврат:
  - значение поля в виде строки

  ( <body::getClob( NAME)>)
*/
member function getClob(
  self in out tpr_csv_iterator_t
, fieldName varchar2
, isNotFoundRaised integer := null
)
return clob

)
/
