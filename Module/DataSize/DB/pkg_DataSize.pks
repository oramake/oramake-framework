create or replace package pkg_DataSize is
/* package: pkg_DataSize
  Интерфейсный пакет модуля DataSize.

  SVN root: Oracle/Module/DataSize
*/

/* const: Module_Name
  Название модуля, к которому относится пакет.
*/
Module_Name constant varchar2(30) := 'DataSize';


/* pfunc: GetNextHeaderId
  Получение следующего id заголовка
  (<body::GetNextHeaderId>)
*/
function GetNextHeaderId
return integer;

/* pfunc: GetNextSegmentId
  Получение следующего id для <dsz_segment>
  (<body::GetNextSegmentId>)
*/
function GetNextSegmentId
return integer;

/* pproc: SaveDataSize
  Сохранение текущего состояния dba_segment
  в таблицы <dsz_header>, <dsz_segment>.
  (<body::SaveDataSize>)
*/
procedure SaveDataSize;

/* pproc:GetMaxHeaderDate
  Возвращает дату последнего добавленного заголовка
  (<body::GetLastHeaderDate>)
*/
function GetMaxHeaderDate
return date;

/* pfunc: CreateReport(header)
  Создание отчёта по изменению
  использованного пространства по
  dba_segments.
  (<body::CreateReport(header)>)
*/
function CreateReport(
  fromHeaderId integer
  , toHeaderId integer
)
return clob;

/* pproc: CreateReport
  Создание отчёта по изменению
  использованного пространства по
  dba_segments.
  (<body::CreateReport>)
*/
procedure CreateReport(
  dateFrom date := null
  , recipient varchar2 := null
  , dateTo date := null
  , toSaveDataSize boolean := null
);

end pkg_DataSize;
/
