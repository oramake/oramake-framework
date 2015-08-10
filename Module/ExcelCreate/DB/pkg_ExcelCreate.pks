create or replace package pkg_ExcelCreate
as
/* package: pkg_ExcelCreate
   Пакет содержит функции для формирования документа в формате Excel

   SVN root: *Oracle/Module/ExcelCreate*
*/


/* group: Константы */


/* const: Module_Name
   Модуль, к которому относится пакет
*/
Module_Name constant varchar2(30) := 'ExcelCreate';


/* group: Стили */


/* group: Предопределенных набор стилей */


/* const: Header_StyleName
   Стиль "Заголовок". Формат данных *строка*
*/
Header_StyleName    constant varchar2(30) := 'Header';

/* const: Text_StyleName
   Стиль "Текст". Формат данных *строка*
*/
Text_StyleName      constant varchar2(30) := 'Text';

/* const: Default_StyleName
   Стиль по умолчанию. Формат данных *строка*
*/
Default_StyleName   constant varchar2(30) := 'Default';

/* const: General_StyleName
   Стиль "Число или строка в общем виде"
*/
General_StyleName   constant varchar2(30) := 'General';

/* const: Number_StyleName
   Стиль "Число в общем виде". Формат данных *число с 2-я десятичными знаками*
*/
Number_StyleName    constant varchar2(30) := 'Number';

/* const: Number0_StyleName
   Стиль "Число без десятичных знаков"
*/
Number0_StyleName   constant varchar2(30) := 'Number0';

/* const: Percent_StyleName
   Стиль "Процент". Формат данных *1/100 доля числа*
*/
Percent_StyleName   constant varchar2(30) := 'Percent';

/* const: DateFull_StyleName
   Стиль "Дата. Полная форма". Формат данных *дата + время*
*/
DateFull_StyleName  constant varchar2(30) := 'DateFull';

/* const: DateShort_StyleName
   Стиль "Дата. Короткая форма". Формат данных *дата без времени*
*/
DateShort_StyleName constant varchar2(30) := 'DateShort';


/* group: Типы данных для стилей */


/* const: String_DataType
   Тип данных *строка*
*/
String_DataType   constant varchar2(30) := 'String';

/* const: Number_DataType
   Тип данных *число*
*/
Number_DataType   constant varchar2(30) := 'Number';

/* const: DateTime_DataType
   Тип данных *дата + время*
*/
DateTime_DataType constant varchar2(30) := 'DateTime';


/* group: Выравнивание для стилей */


/* const: Top_Alignment
   Выравнивание по верхней границе
*/
Top_Alignment constant varchar2(30) := 'Top';

/* const: Center_Alignment
   Выравнивание по центру
*/
Center_Alignment constant varchar2(30) := 'Center';

/* const: Left_Alignment
   Выравнивание по левому краю
*/
Left_Alignment constant varchar2(30) := 'Left';

/* const: Right_Alignment
   Выравнивание по правому краю
*/
Right_Alignment constant varchar2(30) := 'Right';


/* group: Позиция рамки в ячейке для стилей */


/* const: Top_BorderPosition
   Рамка вверху ячейки
*/
Top_BorderPosition constant pls_integer := 1;

/* const: Bottom_BorderPosition
   Рамка внизу ячейки
*/
Bottom_BorderPosition constant pls_integer := 2;

/* const: Left_BorderPosition
   Рамка слева ячейки
*/
Left_BorderPosition constant pls_integer := 4;

/* const: Right_BorderPosition
   Рамка справа ячейки
*/
Right_BorderPosition constant pls_integer := 8;


/* group: Кодировка документа Excel */


/* const: Cp866_DocumentEncoding
   Кодировка Excel документа "CP866"
*/
Cp866_DocumentEncoding constant varchar2(30) := 'CP866';

/* const: Windows1251_DocumentEncoding
   Кодировка Excel документа "Windows-1251"
*/
Windows1251_DocumentEncoding constant varchar2(30) := 'Windows-1251';

/* const: Utf8_DocumentEncoding
   Кодировка Excel документа "UTF-8"
*/
Utf8_DocumentEncoding constant varchar2(30) := 'UTF-8';


/* group: Функции */



/* group: Открытые объявления */

/* pproc: newDocument
   Инициализация нового документа Excel

  ( <body::newDocument>)
*/
procedure newDocument;

/* pproc: addStyle
   Создает новый стиль для использования в документе Excel

   Параметры:
     styleName           - наименование стиля
     styleDataType       - тип данных стиля (см. константы %_DataType)
     parentStyleName     - наименование родительского стиля (для наследования
                           свойств)
     verticalAlignment   - выравнивание по вертикали
     horizontalAlignment - выравнивание по горизонтали
     formatValue         - формат значения
     isTextWrapped       - перенос по словам
     fontName            - наименование шрифта
     fontSize            - размер шрифта
     isFontBold          - жирный шрифт
     borderPosition      - позиция границы ячейки (сумма констант %_BorderPosition)
     interiorColor       - цвет заливки фона

  ( <body::addStyle>)
*/
procedure addStyle (
    styleName           in varchar2
  , styleDataType       in varchar2
  , parentStyleName     in varchar2    := null
  , verticalAlignment   in varchar2    := null
  , horizontalAlignment in varchar2    := null
  , formatValue         in varchar2    := null
  , isTextWrapped       in boolean     := null
  , fontName            in varchar2    := null
  , fontSize            in pls_integer := null
  , isFontBold          in boolean     := null
  , borderPosition      in pls_integer := null
  , interiorColor       in varchar2    := null
  );

/* pproc: removeStyle
   Удаляет выбранный стиль

   Параметры:
     styleName - наименование стиля

  ( <body::removeStyle>)
*/
procedure removeStyle (
  styleName in varchar2
  );

/* pproc: addColumn
   Добавляет колонку в документ Excel

   Параметры:
     columnName   - имя колонки в наборе данных
     columnDesc   - имя колонки в документе Excel
     columnWidth  - ширина колонки
     columnFormat - формат колонки (используются константы %_StyleName)

  ( <body::addColumn>)
*/
procedure addColumn (
    columnName   in varchar2
  , columnDesc   in varchar2
  , columnWidth  in pls_integer := null
  , columnFormat in varchar2 := null
  );

/* pproc: clearColumnList
   Очищает список колонок в документе Excel

  ( <body::clearColumnList>)
*/
procedure clearColumnList;

/* pproc: addCell ( varchar2 )
   Добавляет значение в ячейку Excel.

   Параметры:
     cellValue                 - значение ячейки
     style                     - стиль (см. константы %_StyleName)
     cellIndex                 - порядковый номер ячейки в строке
     mergeAcross               - кол-во ячеек для слияния с текущей (по горизонтали)
     mergeDown                 - кол-во ячеек для слияния с текущей (по вертикали)
     formula                   - текст формулы
     useHtmlTag                - признак использования HTML тегов в значении

   Примечание: после добавления всех необходимых значений ячеек требуется
   вызвать addRow для переноса сформированных ячеек в строку
   
   Примечание 2: при использовании useHtmlTag=true спецсимволы XML не экранируются
   и, при необходимости, требуют ручной предварительной обработки с помощью
   <pkg_ExcelCreateUtility.encodeXmlValue()>

  ( <body::addCell ( varchar2 )>)
*/
procedure addCell (
    cellValue       in varchar2
  , style           in varchar2 := null
  , cellIndex       in pls_integer := null
  , mergeAcross     in pls_integer := null
  , mergeDown       in pls_integer := null
  , formula         in varchar2 := null
  , useHtmlTag      in boolean := false
  );

/* pproc: addCell ( date )
   Преобразует значение ячейки в формате "дата" к формату "строка" и передает его
   в <addCell ( varchar2 )>

   Параметры:
     cellValue                 - значение ячейки в формате "дата"
     isDateTime                - значение в формате дата + время ? (true-да, false-нет)
     style                     - стиль (см. константы %_StyleName)
     cellIndex                 - порядковый номер ячейки в строке
     mergeAcross               - кол-во ячеек для слияния с текущей (по горизонтали)
     mergeDown                 - кол-во ячеек для слияния с текущей (по вертикали)
     formula                   - текст формулы

  ( <body::addCell ( date )>)
*/
procedure addCell (
    cellValue       in date
  , isDateTime      in boolean := false
  , style           in varchar2 := null
  , cellIndex       in pls_integer := null
  , mergeAcross     in pls_integer := null
  , mergeDown       in pls_integer := null
  , formula         in varchar2 := null
  );

/* pproc: addCell ( number )
   Преобразует значение ячейки в формате "число" к формату "строка" и передает его
   в <addCell ( varchar2 )>

   Параметры:
     cellValue                 - значение ячейки в формате "число"
     decimalDigit              - кол-во десятичных знаков

       - decimalDigit is null - число конвертируется в строку как есть (по умолчанию)
       - decimalDigit = 0     - число округляется до целых и конвертируется в строку.
                                Формат отображения: целочисленное число
       - decimalDigit > 0     - число округляется до decimalDigit знаков после
                                запятой и конвертируется в строку. Формат
                                отображения: десятичное число с decimalDigit знаков
                                после запятой (даже если число = 0)

     style                     - стиль (см. константы %_StyleName)
     cellIndex                 - порядковый номер ячейки в строке
     mergeAcross               - кол-во ячеек для слияния с текущей (по горизонтали)
     mergeDown                 - кол-во ячеек для слияния с текущей (по вертикали)
     formula                   - текст формулы

  ( <body::addCell ( number )>)
*/
procedure addCell (
    cellValue        in number
  , decimalDigit     in pls_integer := null
  , style            in varchar2 := null
  , cellIndex        in pls_integer := null
  , mergeAcross      in pls_integer := null
  , mergeDown        in pls_integer := null
  , formula          in varchar2 := null
  );

/* pproc: addCellByName ( varchar2 )
   Добавляет значение ячейки Excel в формате "строка". Стиль ячейки определяется
   по имени колонки в документе. Вызывает <addCell ( varchar2 )>.

   Параметры:
     columnName                - имя колонки документа
     cellValue                 - значение ячейки
     cellIndex                 - порядковый номер ячейки в строке
     mergeAcross               - кол-во ячеек для слияния с текущей (по горизонтали)
     mergeDown                 - кол-во ячеек для слияния с текущей (по вертикали)

  ( <body::addCellByName ( varchar2 )>)
*/
procedure addCellByName (
    columnName      in varchar2
  , cellValue       in varchar2
  , cellIndex       in pls_integer := null
  , mergeAcross     in pls_integer := null
  , mergeDown       in pls_integer := null
  );

/* pproc: addCellByName ( date )
   Добавляет значение ячейки Excel в формате "дата". Стиль ячейки определяется
   по имени колонки документа. Вызывает <addCell ( date )>.

   Параметры:
     columnName                - наименование колонки документа
     cellValue                 - значение ячейки в формате "дата"
     isDateTime                - значение в формате дата + время ? (true-да, false-нет)
     cellIndex                 - порядковый номер ячейки в строке
     mergeAcross               - кол-во ячеек для слияния с текущей (по горизонтали)
     mergeDown                 - кол-во ячеек для слияния с текущей (по вертикали)

  ( <body::addCellByName ( date )>)
*/
procedure addCellByName (
    columnName      in varchar2
  , cellValue       in date
  , isDateTime      in boolean := false
  , cellIndex       in pls_integer := null
  , mergeAcross     in pls_integer := null
  , mergeDown       in pls_integer := null
  );

/* pproc: addCellByName ( number )
   Добавляет значение ячейки Excel в формате "число". Стиль ячейки определяется
   по имени колонки документа. Вызывает <addCell ( number )>.

   Параметры:
     columnName                - наименование колонки документа
     cellValue                 - значение ячейки в формате "число"
     decimalDigit              - кол-во десятичных знаков (см. <addCell ( number )>)
     cellIndex                 - порядковый номер ячейки в строке
     mergeAcross               - кол-во ячеек для слияния с текущей (по горизонтали)
     mergeDown                 - кол-во ячеек для слияния с текущей (по вертикали)

  ( <body::addCellByName ( number )>)
*/
procedure addCellByName (
    columnName       in varchar2
  , cellValue        in number
  , decimalDigit     in pls_integer := null
  , cellIndex        in pls_integer := null
  , mergeAcross      in pls_integer := null
  , mergeDown        in pls_integer := null
  );

/* pproc: addAutoSum
   Добавляет формулу автосуммирования в ячейку на лист Excel.
   Вызывает <addCell ( number )>.

   Параметры:
     style                     - стиль колонки (см. %_StyleName)
     decimalDigit              - кол-во десятичных знаков (см. <addCell ( number )>)
     rangeFirstRow             - номер первой строки диапазона суммирования
                                 (по умолчанию, строка залоговка или 1, если
                                 заголовок отсутствует)
     rangeLastRow              - номер последней строки диапазона суммирования
                                 (по умолчанию, предыдущая строка по отношению
                                 к текущей или 1, если не удалось определить
                                 номер текущей строки)
     cellIndex                 - порядковый номер ячейки в строке

  ( <body::addAutoSum>)
*/
procedure addAutoSum (
    style             in varchar2
  , decimalDigit      in pls_integer := null
  , rangeFirstRow     in pls_integer := null
  , rangeLastRow      in pls_integer := null
  , cellIndex         in pls_integer := null
  );

/* pproc: addAutoSumByName
   Добавляет формулу автосуммирования в ячейку Excel. Стиль ячейки определяется
   по имени колонки документа. Вызывает <addAutoSum>.

   Параметры:
     columnName                - наименование колонки документа
     decimalDigit              - кол-во десятичных знаков (см. <addCell ( number )>)
     rangeFirstRow             - номер первой строки диапазона суммирования
                                 (по умолчанию, строка залоговка или 1, если
                                 заголовок отсутствует)
     rangeLastRow              - номер последней строки диапазона суммирования
                                 (по умолчанию, предыдущая строка по отношению
                                 к текущей или 1, если не удалось определить
                                 номер текущей строки)
     cellIndex                 - порядковый номер ячейки в строке

  ( <body::addAutoSumByName>)
*/
procedure addAutoSumByName (
    columnName        in varchar2
  , decimalDigit      in pls_integer := null
  , rangeFirstRow     in pls_integer := null
  , rangeLastRow      in pls_integer := null
  , cellIndex         in pls_integer := null
  );

/* pproc: addRow
   Добавляет строку. Вызывается после того, как сформированы все ячейки,
   которые должны быть в строке

   Параметры:
     autoFitHeight - автоподбор высоты строки

   Примечание: после того, как создано нужное кол-во строк необходимо
               вызвать addWorksheet для переноса сформированных строк на
               лист Excel

  ( <body::addRow>)
*/
procedure addRow (
  autoFitHeight in boolean := null
  );

/* pproc: addHeaderRow
   Формирует названия колонок документа на листе Excel
   
   Параметры:
     style                     - стиль (см. константы %_StyleName)

  ( <body::addHeaderRow>)
*/
procedure addHeaderRow (
  style in varchar2 := null
  );

/* pproc: setColumnWidth
   Устанавливает ширину колонок документа на листе Excel

  ( <body::setColumnWidth>)
*/
procedure setColumnWidth;

/* pproc: addWorksheet
   Добавляет лист в книгу Excel

   Параметры:
     sheetName     - имя листа Excel
     addAutoFilter - добавить строку автофильтра на лист Excel?

  ( <body::addWorksheet>)
*/
procedure addWorksheet (
    sheetName     in varchar2
  , addAutoFilter in boolean := true
  );

/* pproc: prepareDocument
   Формирует документ. Вызывается после того, как сформированы все листы в Excel

   Параметры:
     encoding - кодировка документа (см. константы %_DocumentEncoding)

  ( <body::prepareDocument>)
*/
procedure prepareDocument (
  encoding in varchar2
  );

/* pfunc: getDocument
   Возвращает сформированный документ Excel в виде CLOB

   Возврат:
     - файл в виде CLOB

  ( <body::getDocument>)
*/
function getDocument
return clob;

/* pfunc: getArchivedDocument
   Возвращает заархивированный в .zip документ Excel в виде BLOB

   Параметры:
     fileName - имя файла документа в архиве

   Возврат:
     - файл в виде BLOB

  ( <body::getArchivedDocument>)
*/
function getArchivedDocument (
  fileName in varchar2
  )
return blob;

/* pfunc: getRowCount
   Возвращает кол-во строк на текущем листе Excel

   Возврат:
     - кол-во строк на листе

  ( <body::getRowCount>)
*/
function getRowCount
return pls_integer;

/* pfunc: getCurrentSheetNumber
   Возвращает номер текущего листа Excel

   Возврат:
     - номер листа

  ( <body::getCurrentSheetNumber>)
*/
function getCurrentSheetNumber
return pls_integer;

end pkg_ExcelCreate;
/
