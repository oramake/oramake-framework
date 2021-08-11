create or replace package pkg_DataSize is
/* package: pkg_DataSize
  Интерфейсный пакет модуля DataSize.

  SVN root: Oracle/Module/DataSize
*/

/* const: Module_Name
  Название модуля, к которому относится пакет.
*/
Module_Name constant varchar2(30) := 'DataSize';



/* group: Функции */

/* pfunc: GetNextHeaderId
  Получение следующего id заголовка
  (<body::GetNextHeaderId>)

  ( <body::GetNextHeaderId>)
*/
function GetNextHeaderId
return integer;

/* pfunc: GetNextSegmentId
  Получение следующего id для <dsz_segment>
  (<body::GetNextSegmentId>)

  ( <body::GetNextSegmentId>)
*/
function GetNextSegmentId
return integer;

/* pproc: saveDataSize
  Сохранение текущего состояния dba_segment
  в таблицы <dsz_header>, <dsz_segment>.

  ( <body::saveDataSize>)
*/
procedure saveDataSize;

/* pfunc: GetMaxHeaderDate
  Возвращает дату последнего добавленного
  заголовка

  Возврат:
    - дата последнего добавленного
  заголовка

  ( <body::GetMaxHeaderDate>)
*/
function GetMaxHeaderDate
return date;

/* pfunc: GetHeaderDate
  Возвращает дату заголовка

  Параметры:
    headerId - id заголовка

  Возврат:
    - дата заголовка

  ( <body::GetHeaderDate>)
*/
function GetHeaderDate( headerId integer )
return date;

/* pfunc: CreateReport(header)
  Создание отчёта по изменению
  использованного пространства по
  dba_segments.

  Параметры:
    fromHeaderId - id начального заголовка для сравнения
    toHeaderId - id конечного заголовка для сравнения

  Возврат:
    - текст отчёта

  ( <body::CreateReport(header)>)
*/
function CreateReport(
  fromHeaderId integer
  , toHeaderId integer
)
return clob;

/* pfunc: getReport
  Создание отчёта по изменению использованного пространства по dba_segments.

  Параметры:
    dateFrom                   - дата начала для отчёта. Если не задана,
  используется последний созданный заголовок.
    recipient                  - получатель ( список ) письма с отчётом
  По-умолчанию используется pkg_Common.GetMailAddressDestination
    dataTo                     - дата окончания для отчёта. По-умолчанию
  берётся текущая дата.
    saveDataSize               - сохранять ли текущее значение. По-умолчанию
  сохранять

  Примечания:
    - в качестве заголовков для сравнения берутся заголовки
  с максимальной датой до заданной. Например, в качестве первого
  заголовка берётся заголовок с максимальной датой до dateFrom.

  Возврат:
  - отчёт в виде clob;

  ( <body::getReport>)
*/
function getReport(
  dateFrom date := null
  , recipient varchar2 := null
  , dateTo date := null
  , toSaveDataSize boolean := null
)
return clob;

/* pproc: createReport
  Создание отчёта по изменению использованного пространства по dba_segments.

  Параметры:
    dateFrom                   - дата начала для отчёта. Если не задана,
  используется последний созданный заголовок.
    recipient                  - получатель ( список ) письма с отчётом
  По-умолчанию используется pkg_Common.GetMailAddressDestination
    dataTo                     - дата окончания для отчёта. По-умолчанию
  берётся текущая дата.
    saveDataSize               - сохранять ли текущее значение. По-умолчанию
  сохранять

  Примечания:
    - в качестве заголовков для сравнения берутся заголовки
  с максимальной датой до заданной. Например, в качестве первого
  заголовка берётся заголовок с максимальной датой до dateFrom.

  ( <body::createReport>)
*/
procedure createReport(
  dateFrom date := null
  , recipient varchar2 := null
  , dateTo date := null
  , toSaveDataSize boolean := null
);

end pkg_DataSize;
/
