title: ��������

group: ����� ��������

������ ������������ ��� ������������ ���������� � ������� xml, ������� ��������
Excel'��



group: ���������� �� ������������� pkg_ExcelCreate

1) ������������� ����������� <pkg_ExcelCreate>:

<pkg_ExcelCreate.newDocument>: �������������� ���������� ��� ��������� ������
���������.

(code)

pkg_ExcelCreate.newDocument();

(end)

2) ���������� ������:

<pkg_ExcelCreate.addStyle>: ��������� ����� ����� ��� ������������� � ���������
Excel

��� �������� ������ ��������� Excel ������������� ���������������� ���������
����������������� ������: *Default*, *Header*, *General*, *Number*, *Number0*,
*Percent*, *DateFull*, *DateShort*, *Text*
(��. <pkg_ExcelCreate::body::initPreinstalledStyle>). ��� ������������� �����
������� ���� ����� �� ������ ������������� (��� �������� ��������� parentStyleName �
������ ����������, �������� ������� ����� ���������� / ��������������), ����
����� ������� ���� ����� � ���� (�.�. ��� �������� parentStyleName) � �������
�������� �������� ����������, ������� ����� ��������� ����� �����.

(code)

pkg_ExcelCreate.addStyle(
    styleName       => 'Default_ArialCyr10_Border'
  , styleDataType   => pkg_ExcelCreate.String_DataType
  , parentStyleName => pkg_ExcelCreate.Default_StyleName
  , fontName        => 'Arial Cyr'
  , fontSize        => 10
  , borderPosition  => pkg_ExcelCreate.Top_BorderPosition +
                         pkg_ExcelCreate.Bottom_BorderPosition +
                         pkg_ExcelCreate.Left_BorderPosition
  );

...

pkg_ExcelCreate.addColumn(
  'column_name', 'column_name', 100, 'Default_ArialCyr10_Border'
  );

(end)

������� ����������� ��� ����������������� ����� ����� � ������� ���������
<pkg_ExcelCreate.removeStyle>.

(code)

pkg_ExcelCreate.removeStyle( 'Default_ArialCyr10_Border' );

(end)

3) ��������� ������ �������, ������� ����� ��������� ��������:

<pkg_ExcelCreate.addColumn>: ��������� ������� � �������� Excel

(code)

pkg_ExcelCreate.addColumn(
  'application_id', '������������� ������', 130, pkg_ExcelCreate.Number0_StyleName
  );
pkg_ExcelCreate.addColumn(
  'application_date', '���� �������� ������', 100, pkg_ExcelCreate.DateFull_StyleName
  );

(end)

4) ��������� ������ ������� �� ����� Excel:

<pkg_ExcelCreate.setColumnWidth>: ��������� xml ����, ��������������� ������
������� �� �����. ���������� ��������������� �� ���� 2 ������ �������.

(code)

pkg_ExcelCreate.setColumnWidth();

(end)

5) ��������� ��������� � ���������:

<pkg_ExcelCreate.addHeaderRow>: ��������� �������������� ������ ������� ��
���� 2 �� ���� Excel. ���� ���� ������������� �������� ��������� ���������� �����
���������� (��������, ������ ����������, �������� ������, ���������� ��
������������� � �.�.), �� ��� ����� ����� ������������ ���������
<pkg_ExcelCreate.addCell> � <pkg_ExcelCreate.addRow> (��. ����)

(code)

pkg_ExcelCreate.addHeaderRow();

(end)

6) ���������� ������ � ������:

_pkg_ExcelCreate.addCell_:
���������� �������� � ��������� ������ ������� ������

������������� �������� ���������:
  - <pkg_ExcelCreate.addCell ( varchar2 )> - ���������� �������� ���� "������"
  - <pkg_ExcelCreate.addCell ( number )>   - ���������� �������� ���� "�����"
  - <pkg_ExcelCreate.addCell ( date )>     - ���������� �������� ���� "����"

(code)

pkg_ExcelCreate.addCell( '���� ������������:' );
pkg_ExcelCreate.addCell(
  sysdate, true, pkg_ExcelCreate.DateFull_StyleName
  );

(end)

_pkg_ExcelCreate.addCellByName_:
���������� �������� � ��������� ������ ������� ������. ����� ������ ������������
�� ����� ������� ��������� (��. ��� 2)

������������� �������� ���������:
  - <pkg_ExcelCreate.addCellByName ( varchar2 )> - ���������� �������� ���� "������"
  - <pkg_ExcelCreate.addCellByName ( number )>   - ���������� �������� ���� "�����"
  - <pkg_ExcelCreate.addCellByName ( date )>     - ���������� �������� ���� "����"

(code)

pkg_ExcelCreate.addCellByName(
  'application_id', applicationId
  );

(end)

'application_id' - ��� ������� ���������. _������ ��������������� ����� �������,
������ �� �� ���� 2 ��� ����� ��������_.
applicationId - ���������� ���� integer.

����������:

��� ������������� *addCell* � *addCellByName* ��� ������������� ��������� ����������
�������� �������� � ������� ����������� ���������� - ����������� ������� �������������
��������� ����� ������ ������������� �� ������ ���� ������������ ������

���������� �������� � ������ �� � ������:

��� ���������� �������� � ������, ������� �� �������� ������ � ������, ����������
������� � ���������� �����.

(code)

pkg_ExcelCreate.addCellByName(
  'application_id', applicationId, cellIndex => 4
  );

(end)

������� �����:

��� ������� ����� ��� ���������� �������� ���������� ������ �������� ���������
_mergeAcross_ (��� ������� �� �����������) � _mergeDown_ (��� ������� �� ���������)
� ���� ���-�� ����������� �����, ������� ����� ����� � �������.

(code)

pkg_ExcelCreate.addCellByName(
  'application_id', applicationId, mergeAcross => 1
  );
...
pkg_ExcelCreate.addCellByName(
  'application_id', applicationId, mergeDown => 1
  );

(end)

7) �������� �������� ��������:

��� �������� ������ � ������� ����� ������������ ���������:
  - <pkg_ExcelCreate.addAutoSum> - ��������� ��������� � ��������� ������.
  - <pkg_ExcelCreate.addAutoSumByName> - ��������� ��������� � ��������� ������.
    ����� ������ ������������ �� ����� ������� ��������� (��. ��� 2)

���� �������� ��� ������� ����� �� ������ � ����� ����, �� �� ������������
������������� �� ������ ��������� ����������:
  - ���� �������� �������� ���������, �� ������� �������� �� ��������� ������
    ����� ��������� � �� ������, �������������� ������ � �������
  - ���� �������� �� �������� ���������, �� ������� �������� � ������ ������
    ��������� �� ������, �������������� ������ � �������

(code)

pkg_ExcelCreate.addAutoSumByName( 'interest_amount' );
...
pkg_ExcelCreate.addAutoSumByName( 'interest_amount', cellIndex => 2 );
...
pkg_ExcelCreate.addAutoSumByName( 'interest_amount', rangeFirstRow => 1, rangeLastRow => 10 );

(end)

8) ������� ����� � ������:

<pkg_ExcelCreate.addRow>: ��������� �������������� ������ �� ���� 5 � ������.
������ � ������ ����� ��������� � ��� �� �������, � ������� ��� �����������.

(code)

...

for i in 1..colConsiderationHistory.count loop

  pkg_ExcelCreate.addCellByName(
    'application_id', colConsiderationHistory(i).application_id
    );
  pkg_ExcelCreate.addCellByName(
    'application_date', colConsiderationHistory(i).application_date, true
    );
  pkg_ExcelCreate.addCellByName(
    'bo_sending_num', colConsiderationHistory(i).bo_sending_num
    );
  pkg_ExcelCreate.addCellByName(
    'bo_reason', colConsiderationHistory(i).bo_reason
    );

...

  pkg_ExcelCreate.addRow();

...

end loop;

(end)

9) ������� �������������� ����� �� ���� Excel:

<pkg_ExcelCreate.addWorksheet>: ��������� �������������� ������ �� ���� 6 ��
���� Excel. ������ ����� ��������� � ��� �� �������, � ������� ��� �����������.

��� ������������� ����� ����������� ������������ ����� ���� Excel, ���� ����
��������� ������������ ���������� �����. ��� �������� ���������� ���������� �����
�� ������ ����� Excel.

(code)

pkg_ExcelCreate.addWorksheet(
    sheetName     => 'Test123'
  , addAutoFilter => true
  );

(end)

10) �������� ���������� ������ � ������ ������� �������:

��� ������������� ����� ������������� ��������� ������ ��������� Excel, ������
�� ������� ����� ��������� ������ ����� �������. ��� ����� ����� ����������
������� ����� (����� �������) ����� �������� ���������
<pkg_ExcelCreate.clearColumnList> ��� ������� �������� ������ ������� � �����
��������� ������ 3-8 ��� �������� ���������� �����.

11) ��������� ��������� ���������:

<pkg_ExcelCreate.prepareDocument>: �� ������ ����������� ������ Excel
��������� ����� Excel. ���������������� �������� ����� �������� � ���� clob
(<pkg_ExcelCreate.getDocument>) ��� � ���������������� .zip ������� (blob)
(<pkg_ExcelCreate.getArchivedDocument>) � ��������� ��� � ������� ��

(code)

...

pkg_ExcelCreate.prepareDocument();

update test_table t
   set t.file_body =
         pkg_ExcelCreate.getArchivedDocument(
           fileName => '123.xls'
           )
 where t.id = 1
;

...

(end)
