create or replace package pkg_DataSize is
/* package: pkg_DataSize
  ������������ ����� ������ DataSize.

  SVN root: Oracle/Module/DataSize
*/

/* const: Module_Name
  �������� ������, � �������� ��������� �����.
*/
Module_Name constant varchar2(30) := 'DataSize';



/* group: ������� */

/* pfunc: GetNextHeaderId
  ��������� ���������� id ���������
  (<body::GetNextHeaderId>)

  ( <body::GetNextHeaderId>)
*/
function GetNextHeaderId
return integer;

/* pfunc: GetNextSegmentId
  ��������� ���������� id ��� <dsz_segment>
  (<body::GetNextSegmentId>)

  ( <body::GetNextSegmentId>)
*/
function GetNextSegmentId
return integer;

/* pproc: saveDataSize
  ���������� �������� ��������� dba_segment
  � ������� <dsz_header>, <dsz_segment>.

  ( <body::saveDataSize>)
*/
procedure saveDataSize;

/* pfunc: GetMaxHeaderDate
  ���������� ���� ���������� ������������
  ���������

  �������:
    - ���� ���������� ������������
  ���������

  ( <body::GetMaxHeaderDate>)
*/
function GetMaxHeaderDate
return date;

/* pfunc: GetHeaderDate
  ���������� ���� ���������

  ���������:
    headerId - id ���������

  �������:
    - ���� ���������

  ( <body::GetHeaderDate>)
*/
function GetHeaderDate( headerId integer )
return date;

/* pfunc: CreateReport(header)
  �������� ������ �� ���������
  ��������������� ������������ ��
  dba_segments.

  ���������:
    fromHeaderId - id ���������� ��������� ��� ���������
    toHeaderId - id ��������� ��������� ��� ���������

  �������:
    - ����� ������

  ( <body::CreateReport(header)>)
*/
function CreateReport(
  fromHeaderId integer
  , toHeaderId integer
)
return clob;

/* pfunc: getReport
  �������� ������ �� ��������� ��������������� ������������ �� dba_segments.

  ���������:
    dateFrom                   - ���� ������ ��� ������. ���� �� ������,
  ������������ ��������� ��������� ���������.
    recipient                  - ���������� ( ������ ) ������ � �������
  ��-��������� ������������ pkg_Common.GetMailAddressDestination
    dataTo                     - ���� ��������� ��� ������. ��-���������
  ������ ������� ����.
    saveDataSize               - ��������� �� ������� ��������. ��-���������
  ���������

  ����������:
    - � �������� ���������� ��� ��������� ������� ���������
  � ������������ ����� �� ��������. ��������, � �������� �������
  ��������� ������ ��������� � ������������ ����� �� dateFrom.

  �������:
  - ����� � ���� clob;

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
  �������� ������ �� ��������� ��������������� ������������ �� dba_segments.

  ���������:
    dateFrom                   - ���� ������ ��� ������. ���� �� ������,
  ������������ ��������� ��������� ���������.
    recipient                  - ���������� ( ������ ) ������ � �������
  ��-��������� ������������ pkg_Common.GetMailAddressDestination
    dataTo                     - ���� ��������� ��� ������. ��-���������
  ������ ������� ����.
    saveDataSize               - ��������� �� ������� ��������. ��-���������
  ���������

  ����������:
    - � �������� ���������� ��� ��������� ������� ���������
  � ������������ ����� �� ��������. ��������, � �������� �������
  ��������� ������ ��������� � ������������ ����� �� dateFrom.

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
