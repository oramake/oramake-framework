create or replace package pkg_ExcelCreate
as
/* package: pkg_ExcelCreate
   ����� �������� ������� ��� ������������ ��������� � ������� Excel

   Root: *oramake/Module/ExcelCreate*
*/


/* group: ��������� */


/* const: Module_Name
   ������, � �������� ��������� �����
*/
Module_Name constant varchar2(30) := 'ExcelCreate';


/* group: ����� */


/* group: ���������������� ����� ������ */


/* const: Header_StyleName
   ����� "���������". ������ ������ *������*
*/
Header_StyleName    constant varchar2(30) := 'Header';

/* const: Text_StyleName
   ����� "�����". ������ ������ *������*
*/
Text_StyleName      constant varchar2(30) := 'Text';

/* const: Default_StyleName
   ����� �� ���������. ������ ������ *������*
*/
Default_StyleName   constant varchar2(30) := 'Default';

/* const: General_StyleName
   ����� "����� ��� ������ � ����� ����"
*/
General_StyleName   constant varchar2(30) := 'General';

/* const: Number_StyleName
   ����� "����� � ����� ����". ������ ������ *����� � 2-� ����������� �������*
*/
Number_StyleName    constant varchar2(30) := 'Number';

/* const: Number0_StyleName
   ����� "����� ��� ���������� ������"
*/
Number0_StyleName   constant varchar2(30) := 'Number0';

/* const: Percent_StyleName
   ����� "�������". ������ ������ *1/100 ���� �����*
*/
Percent_StyleName   constant varchar2(30) := 'Percent';

/* const: DateFull_StyleName
   ����� "����. ������ �����". ������ ������ *���� + �����*
*/
DateFull_StyleName  constant varchar2(30) := 'DateFull';

/* const: DateShort_StyleName
   ����� "����. �������� �����". ������ ������ *���� ��� �������*
*/
DateShort_StyleName constant varchar2(30) := 'DateShort';


/* group: ���� ������ ��� ������ */


/* const: String_DataType
   ��� ������ *������*
*/
String_DataType   constant varchar2(30) := 'String';

/* const: Number_DataType
   ��� ������ *�����*
*/
Number_DataType   constant varchar2(30) := 'Number';

/* const: DateTime_DataType
   ��� ������ *���� + �����*
*/
DateTime_DataType constant varchar2(30) := 'DateTime';


/* group: ������������ ��� ������ */


/* const: Top_Alignment
   ������������ �� ������� �������
*/
Top_Alignment constant varchar2(30) := 'Top';

/* const: Center_Alignment
   ������������ �� ������
*/
Center_Alignment constant varchar2(30) := 'Center';

/* const: Left_Alignment
   ������������ �� ������ ����
*/
Left_Alignment constant varchar2(30) := 'Left';

/* const: Right_Alignment
   ������������ �� ������� ����
*/
Right_Alignment constant varchar2(30) := 'Right';


/* group: ������� ����� � ������ ��� ������ */


/* const: Top_BorderPosition
   ����� ������ ������
*/
Top_BorderPosition constant pls_integer := 1;

/* const: Bottom_BorderPosition
   ����� ����� ������
*/
Bottom_BorderPosition constant pls_integer := 2;

/* const: Left_BorderPosition
   ����� ����� ������
*/
Left_BorderPosition constant pls_integer := 4;

/* const: Right_BorderPosition
   ����� ������ ������
*/
Right_BorderPosition constant pls_integer := 8;


/* group: ��������� ��������� Excel */


/* const: Cp866_DocumentEncoding
   ��������� Excel ��������� "CP866"
*/
Cp866_DocumentEncoding constant varchar2(30) := 'CP866';

/* const: Windows1251_DocumentEncoding
   ��������� Excel ��������� "Windows-1251"
*/
Windows1251_DocumentEncoding constant varchar2(30) := 'Windows-1251';

/* const: Utf8_DocumentEncoding
   ��������� Excel ��������� "UTF-8"
*/
Utf8_DocumentEncoding constant varchar2(30) := 'UTF-8';


/* group: Row height constants */


/* const: RowHeight_Max
   Maximum row height in Excel
*/
RowHeight_Max               constant number := 409.5;


/* group: ������� */



/* group: �������� ���������� */

/* pproc: newDocument
   ������������� ������ ��������� Excel

  ( <body::newDocument>)
*/
procedure newDocument;

/* pproc: addStyle
  ������� ����� ����� ��� ������������� � ��������� Excel

  ���������:
   
  styleName                 - ������������ �����
  styleDataType             - ��� ������ ����� (��. ��������� %_DataType)
  parentStyleName           - ������������ ������������� ����� (��� ������������ �������)
  verticalAlignment         - ������������ �� ���������
  horizontalAlignment       - ������������ �� �����������
  formatValue               - ������ ��������
  isTextWrapped             - ������� �� ������
  fontName                  - ������������ ������
  fontSize                  - ������ ������
  isFontBold                - ������ �����
  isFontUnderlined          - use underlined font
  borderPosition            - ������� ������� ������ (����� �������� %_BorderPosition)
  interiorColor             - ���� ������� ����
  
  (<body::addStyle>)
*/
procedure addStyle(
  styleName                 in varchar2
, styleDataType             in varchar2
, parentStyleName           in varchar2    := null
, verticalAlignment         in varchar2    := null
, horizontalAlignment       in varchar2    := null
, formatValue               in varchar2    := null
, isTextWrapped             in boolean     := null
, fontName                  in varchar2    := null
, fontSize                  in pls_integer := null
, isFontBold                in boolean     := null
, isFontUnderlined          in boolean     := null
, borderPosition            in pls_integer := null
, interiorColor             in varchar2    := null
);

/* pproc: removeStyle
   ������� ��������� �����

   ���������:
     styleName - ������������ �����

  ( <body::removeStyle>)
*/
procedure removeStyle (
  styleName in varchar2
  );

/* pproc: addColumn
   ��������� ������� � �������� Excel

   ���������:
     columnName   - ��� ������� � ������ ������
     columnDesc   - ��� ������� � ��������� Excel
     columnWidth  - ������ �������
     columnFormat - ������ ������� (������������ ��������� %_StyleName)

  ( <body::addColumn>)
*/
procedure addColumn (
    columnName   in varchar2
  , columnDesc   in varchar2
  , columnWidth  in pls_integer := null
  , columnFormat in varchar2 := null
  );

/* pproc: clearColumnList
   ������� ������ ������� � ��������� Excel

  ( <body::clearColumnList>)
*/
procedure clearColumnList;

/* pproc: addCell ( varchar2 )
   ��������� �������� � ������ Excel.

   ���������:
     cellValue                 - �������� ������
     style                     - ����� (��. ��������� %_StyleName)
     cellIndex                 - ���������� ����� ������ � ������
     mergeAcross               - ���-�� ����� ��� ������� � ������� (�� �����������)
     mergeDown                 - ���-�� ����� ��� ������� � ������� (�� ���������)
     formula                   - ����� �������
     useHtmlTag                - ������� ������������� HTML ����� � ��������

   ����������: ����� ���������� ���� ����������� �������� ����� ���������
   ������� addRow ��� �������� �������������� ����� � ������
   
   ���������� 2: ��� ������������� useHtmlTag=true ����������� XML �� ������������
   �, ��� �������������, ������� ������ ��������������� ��������� � �������
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
   ����������� �������� ������ � ������� "����" � ������� "������" � �������� ���
   � <addCell ( varchar2 )>

   ���������:
     cellValue                 - �������� ������ � ������� "����"
     isDateTime                - �������� � ������� ���� + ����� ? (true-��, false-���)
     style                     - ����� (��. ��������� %_StyleName)
     cellIndex                 - ���������� ����� ������ � ������
     mergeAcross               - ���-�� ����� ��� ������� � ������� (�� �����������)
     mergeDown                 - ���-�� ����� ��� ������� � ������� (�� ���������)
     formula                   - ����� �������

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
   ����������� �������� ������ � ������� "�����" � ������� "������" � �������� ���
   � <addCell ( varchar2 )>

   ���������:
     cellValue                 - �������� ������ � ������� "�����"
     decimalDigit              - ���-�� ���������� ������

       - decimalDigit is null - ����� �������������� � ������ ��� ���� (�� ���������)
       - decimalDigit = 0     - ����� ����������� �� ����� � �������������� � ������.
                                ������ �����������: ������������� �����
       - decimalDigit > 0     - ����� ����������� �� decimalDigit ������ �����
                                ������� � �������������� � ������. ������
                                �����������: ���������� ����� � decimalDigit ������
                                ����� ������� (���� ���� ����� = 0)

     style                     - ����� (��. ��������� %_StyleName)
     cellIndex                 - ���������� ����� ������ � ������
     mergeAcross               - ���-�� ����� ��� ������� � ������� (�� �����������)
     mergeDown                 - ���-�� ����� ��� ������� � ������� (�� ���������)
     formula                   - ����� �������

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
   ��������� �������� ������ Excel � ������� "������". ����� ������ ������������
   �� ����� ������� � ���������. �������� <addCell ( varchar2 )>.

   ���������:
     columnName                - ��� ������� ���������
     cellValue                 - �������� ������
     cellIndex                 - ���������� ����� ������ � ������
     mergeAcross               - ���-�� ����� ��� ������� � ������� (�� �����������)
     mergeDown                 - ���-�� ����� ��� ������� � ������� (�� ���������)

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
   ��������� �������� ������ Excel � ������� "����". ����� ������ ������������
   �� ����� ������� ���������. �������� <addCell ( date )>.

   ���������:
     columnName                - ������������ ������� ���������
     cellValue                 - �������� ������ � ������� "����"
     isDateTime                - �������� � ������� ���� + ����� ? (true-��, false-���)
     cellIndex                 - ���������� ����� ������ � ������
     mergeAcross               - ���-�� ����� ��� ������� � ������� (�� �����������)
     mergeDown                 - ���-�� ����� ��� ������� � ������� (�� ���������)

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
   ��������� �������� ������ Excel � ������� "�����". ����� ������ ������������
   �� ����� ������� ���������. �������� <addCell ( number )>.

   ���������:
     columnName                - ������������ ������� ���������
     cellValue                 - �������� ������ � ������� "�����"
     decimalDigit              - ���-�� ���������� ������ (��. <addCell ( number )>)
     cellIndex                 - ���������� ����� ������ � ������
     mergeAcross               - ���-�� ����� ��� ������� � ������� (�� �����������)
     mergeDown                 - ���-�� ����� ��� ������� � ������� (�� ���������)

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
   ��������� ������� ���������������� � ������ �� ���� Excel.
   �������� <addCell ( number )>.

   ���������:
     style                     - ����� ������� (��. %_StyleName)
     decimalDigit              - ���-�� ���������� ������ (��. <addCell ( number )>)
     rangeFirstRow             - ����� ������ ������ ��������� ������������
                                 (�� ���������, ������ ��������� ��� 1, ����
                                 ��������� �����������)
     rangeLastRow              - ����� ��������� ������ ��������� ������������
                                 (�� ���������, ���������� ������ �� ���������
                                 � ������� ��� 1, ���� �� ������� ����������
                                 ����� ������� ������)
     cellIndex                 - ���������� ����� ������ � ������

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
   ��������� ������� ���������������� � ������ Excel. ����� ������ ������������
   �� ����� ������� ���������. �������� <addAutoSum>.

   ���������:
     columnName                - ������������ ������� ���������
     decimalDigit              - ���-�� ���������� ������ (��. <addCell ( number )>)
     rangeFirstRow             - ����� ������ ������ ��������� ������������
                                 (�� ���������, ������ ��������� ��� 1, ����
                                 ��������� �����������)
     rangeLastRow              - ����� ��������� ������ ��������� ������������
                                 (�� ���������, ���������� ������ �� ���������
                                 � ������� ��� 1, ���� �� ������� ����������
                                 ����� ������� ������)
     cellIndex                 - ���������� ����� ������ � ������

  ( <body::addAutoSumByName>)
*/
procedure addAutoSumByName (
    columnName        in varchar2
  , decimalDigit      in pls_integer := null
  , rangeFirstRow     in pls_integer := null
  , rangeLastRow      in pls_integer := null
  , cellIndex         in pls_integer := null
  );

/* pproc: addRow (DEPRECATED, use addRow(height, autoFit) instead)
   ��������� ������. ���������� ����� ����, ��� ������������ ��� ������,
   ������� ������ ���� � ������

   ���������:
     autoFitHeight - ���������� ������ ������

   ����������: ����� ����, ��� ������� ������ ���-�� ����� ����������
               ������� addWorksheet ��� �������� �������������� ����� ��
               ���� Excel
*/
procedure addRow (
  autoFitHeight in boolean
  );

/* pproc: addHeaderRow
   ��������� �������� ������� ��������� �� ����� Excel
   
   ���������:
     style                     - ����� (��. ��������� %_StyleName)

  ( <body::addHeaderRow>)
*/
procedure addHeaderRow (
  style in varchar2 := null
  );

/* pproc: addRow
  Add a row (after all its cells have been generated)

  Params:
   
  height                    - Row height in points. The value specified will be reset to a maximum
                              of RowHeight_Max if exceeded.
  autoFit                   - Determine row height automatically (true or false)

  Note: Please call addWorksheet() once all required rows have been created
  
  (<body::addRow>)
*/
procedure addRow(
  height                    in number   := null
, autoFit                   in boolean  := true
);

/* pproc: setColumnWidth
   ������������� ������ ������� ��������� �� ����� Excel

  ( <body::setColumnWidth>)
*/
procedure setColumnWidth;

/* pproc: addWorksheet
  Add a sheet into an Excel workbook

  Params:
  
  sheetName                 - Excel sheet name
  addAutoFilter             - Enable auto filter (default, true)
  fitToPage                 - Fit contents to page (default, false)
  fitHeight                 - Fit to: N pages tall
  fitWidth                  - Fit to: N pages wide
  
  (<body::addWorksheet>)
*/
procedure addWorksheet (
  sheetName                 in varchar2
, addAutoFilter             in boolean := true
, fitToPage                 in boolean := false
, fitHeight                 in pls_integer := null
, fitWidth                  in pls_integer := null
);

/* pproc: prepareDocument
   ��������� ��������. ���������� ����� ����, ��� ������������ ��� ����� � Excel

   ���������:
     encoding - ��������� ��������� (��. ��������� %_DocumentEncoding)

  ( <body::prepareDocument>)
*/
procedure prepareDocument (
  encoding in varchar2
  );

/* pfunc: getDocument
   ���������� �������������� �������� Excel � ���� CLOB

   �������:
     - ���� � ���� CLOB

  ( <body::getDocument>)
*/
function getDocument
return clob;

/* pfunc: getArchivedDocument
   ���������� ���������������� � .zip �������� Excel � ���� BLOB

   ���������:
     fileName - ��� ����� ��������� � ������

   �������:
     - ���� � ���� BLOB

  ( <body::getArchivedDocument>)
*/
function getArchivedDocument (
  fileName in varchar2
  )
return blob;

/* pfunc: getRowCount
   ���������� ���-�� ����� �� ������� ����� Excel

   �������:
     - ���-�� ����� �� �����

  ( <body::getRowCount>)
*/
function getRowCount
return pls_integer;

/* pfunc: getCurrentSheetNumber
   ���������� ����� �������� ����� Excel

   �������:
     - ����� �����

  ( <body::getCurrentSheetNumber>)
*/
function getCurrentSheetNumber
return pls_integer;

end pkg_ExcelCreate;
/
