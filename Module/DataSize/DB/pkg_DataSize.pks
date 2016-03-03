create or replace package pkg_DataSize is
/* package: pkg_DataSize
  ������������ ����� ������ DataSize.

  SVN root: Oracle/Module/DataSize
*/

/* const: Module_Name
  �������� ������, � �������� ��������� �����.
*/
Module_Name constant varchar2(30) := 'DataSize';


/* pfunc: GetNextHeaderId
  ��������� ���������� id ���������
  (<body::GetNextHeaderId>)
*/
function GetNextHeaderId
return integer;

/* pfunc: GetNextSegmentId
  ��������� ���������� id ��� <dsz_segment>
  (<body::GetNextSegmentId>)
*/
function GetNextSegmentId
return integer;

/* pproc: SaveDataSize
  ���������� �������� ��������� dba_segment
  � ������� <dsz_header>, <dsz_segment>.
  (<body::SaveDataSize>)
*/
procedure SaveDataSize;

/* pproc:GetMaxHeaderDate
  ���������� ���� ���������� ������������ ���������
  (<body::GetLastHeaderDate>)
*/
function GetMaxHeaderDate
return date;

/* pfunc: CreateReport(header)
  �������� ������ �� ���������
  ��������������� ������������ ��
  dba_segments.
  (<body::CreateReport(header)>)
*/
function CreateReport(
  fromHeaderId integer
  , toHeaderId integer
)
return clob;

/* pproc: CreateReport
  �������� ������ �� ���������
  ��������������� ������������ ��
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
