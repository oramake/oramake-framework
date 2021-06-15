create or replace package body pkg_ExcelCreate
as
/* package body: pkg_ExcelCreate::body */


/* group: ���� */


/* itype: TMaxVarchar2
   ��� ��� �������� ������ � varchar2 ������������� �������
*/
subtype TMaxVarchar2 is varchar2(32767);

/* itype: TName
   ��� ��� ���������� �������� (����� �������, ������, ����� ������ � �.�.)
*/
subtype TName is varchar2(128);

/* itype: TColDocumentColumn
   ��� ��� ������������ ������ ������� � ���������
*/
type TRecDocumentColumn is record (
  columnDesc   varchar2(255)
, columnWidth  pls_integer
, columnFormat TName
);
type TColDocumentColumn is table of TRecDocumentColumn
;

/* itype: TColColumnName
   ��� ��� ������������ ���� ������� � ��������� � �� ��������
*/
type TColColumnName is table of pls_integer
  index by TName
;

/* itype: TColStyle
   ��� ��� ������ ��������� Excel
*/
type TRecStyle is record (
  parentStyleName TName
, styleDataType   TName
, styleOrder      pls_integer
, xmlTag          TMaxVarchar2
);
type TColStyle is table of TRecStyle
  index by TName
;


/* group: ���������� */


/* ivar: logger
   ������ ��� ������������
*/
logger lg_logger_t := lg_logger_t.getLogger(
    moduleName  => Module_Name
  , packageName => 'pkg_ExcelCreate'
  );

/* ivar: styles
   ��������� ������ � ��������� Excel
*/
styles TColStyle;

/* ivar: cols
   ��������� ������� � ���������
*/
cols TColDocumentColumn;

/* ivar: colNames
   ��������� ������������ ���� ������� ��������� � �� ��������
*/
colNames TColColumnName;

/* ivar: cells
   ��������� ����� � ����� ������ Excel
*/
cells clob;

/* ivar: rows
   ��������� ����� �� ����� ����� Excel
*/
rows clob;

/* ivar: worksheets
   ��������� ������ � ����� ����� Excel
*/
worksheets clob;

/* ivar: bufCells
   ����� ��� �������� �����
*/
bufCells TMaxVarchar2;

/* ivar: bufRows
   ����� ��� �������� �����
*/
bufRows TMaxVarchar2;

/* ivar: bufWorksheets
   ����� ��� �������� ������
*/
bufWorksheets TMaxVarchar2;

/* ivar: rowNumber
   ����� ��������� ����������� ������ �� ������� ����� Excel
*/
rowNumber pls_integer := 0;

/* ivar: sheetNumber
   ����� �������� ����� Excel
*/
sheetNumber pls_integer := 1;

/* ivar: headerRowNumber
   ����� ������ � ���������� �� ������� ����� Excel (��� �������� �����������)
*/
headerRowNumber pls_integer := 0;

/* ivar: isDocumentPrepared
   �������, ����������� �� �������� (true-��, false-���)
*/
isDocumentPrepared boolean := false;


/* group: ������� */


/* group: �������� ���������� */


/* iproc: initElement
   ��������� ������������� �������� ����� Excel
*/
procedure initElement (
  elm in out nocopy clob
  )
is
-- initElement
begin
  dbms_lob.createTemporary( elm, true, dbms_lob.session );

end initElement;


/* iproc: clearElement
   ��������� ������� �������� ����� Excel
*/
procedure clearElement (
  elm in out nocopy clob
  )
is
-- clearElement
begin
  if elm is not null then
    dbms_lob.trim( elm, 0 );
  end if;

end clearElement;


/* iproc: cleanup
   ������� ������������ �������� ��� ������������� ��� ����������� ������
*/
procedure cleanup
is 
-- cleanup
begin
  -- ������� nested table
  cols := TColDocumentColumn();

  -- ������� ������������� ��������
  colNames.delete;
  styles.delete;
  
  -- ������� ��������� ����� Excel
  clearElement( cells );
  clearElement( rows );
  clearElement( worksheets );
  
  -- ������� ������� ��������� ����� Excel
  bufCells := null;
  bufRows := null;
  bufWorksheets := null;

  -- ��������� �������������� �������� ��� ������ ����������
  rowNumber := 0;
  sheetNumber := 1;
  headerRowNumber := 0;
  isDocumentPrepared := false;

exception
  when others then
    raise_application_error(
        pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ������� ������������ ��������'
          )
      , true
      );

end cleanup;


/* iproc: flushElement
   ���������� ����������� ����� �� �������� Excel � clob
*/
procedure flushElement (
    elm     in out nocopy clob
  , buf     in out nocopy TMaxVarchar2
  )
is
-- flushElement
begin
  dbms_lob.writeAppend(
      lob_loc => elm
    , amount  => length( buf )
    , buffer  => buf
    );
  buf := null;

end flushElement;


/* iproc: flushCells
   ���������� ����������� ����� �� ������� � clob
*/
procedure flushCells
is
-- flushCells
begin
  flushElement( cells, bufCells );

end flushCells;


/* iproc: flushRows
   ���������� ����������� ����� �� ������� � clob
*/
procedure flushRows
is
-- flushRows
begin
  flushElement( rows, bufRows );

end flushRows;


/* iproc: flushWorksheets
   ���������� ����������� ����� �� ������ � clob
*/
procedure flushWorksheets
is
-- flushWorksheets
begin
  flushElement( worksheets, bufWorksheets );

end flushWorksheets;


/* iproc: appendElement
   ��������� ��������� ������ � ������� ����� Excel
*/
procedure appendElement (
    elm             in out nocopy clob
  , buf             in out nocopy TMaxVarchar2
  , str             in varchar2
  , newLineFlag     in boolean := false
  )
is
  -- �������� ��������
  elmStr TMaxVarchar2;
  
  -- ����� ������ ��� ��������
  bufLength pls_integer;
  -- ����� ������ ��� ���������� � �����
  elmStrLength pls_integer;
  
-- appendElement
begin
  elmStr := 
    case
      when newLineFlag then
        chr(10)
      else
        null
    end || str
  ;
  bufLength := coalesce( length( buf ), 0 );
  elmStrLength := coalesce( length( elmStr ), 0 );
  
  if bufLength + elmStrLength > 32767 then
    buf := buf || substr( elmStr, 1, 32767 - bufLength );
    flushElement( elm, buf );
    appendElement(
        elm => elm
      , buf => buf
      , str => substr( elmStr, 32767 - bufLength + 1, elmStrLength )
      );
  else
    buf := buf || elmStr;
  end if;

end appendElement;


/* iproc: appendCells
   ��������� ��������� ������ � ������
*/
procedure appendCells (
    str             in varchar2
  , newLineFlag     in boolean := false
  )
is
-- appendCells
begin
  appendElement (
      elm         => cells
    , buf         => bufCells
    , str         => str
    , newLineFlag => newLineFlag
    );

end appendCells;


/* iproc: appendRows
   ��������� ��������� ������ �� ����� � ������ Excel
*/
procedure appendRows (
    str             in varchar2
  , newLineFlag     in boolean := false
  )
is
-- appendRows
begin
  appendElement (
      elm         => rows
    , buf         => bufRows
    , str         => str
    , newLineFlag => newLineFlag
    );

end appendRows;


/* iproc: appendWorksheets
   ��������� ��������� ������ � ������� �� ���� Excel
*/
procedure appendWorksheets (
    str             in varchar2
  , newLineFlag     in boolean := false
  )
is
-- appendWorksheets
begin
  appendElement (
      elm         => worksheets
    , buf         => bufWorksheets
    , str         => str
    , newLineFlag => newLineFlag
    );

end appendWorksheets;


/* iproc: moveElement
   ��������� ������� ������ �������� ����� Excel � ������
*/
procedure moveElement (
    dest        in out nocopy clob
  , destBuf     in out nocopy TMaxVarchar2
  , src         in out nocopy clob
  , srcBuf      in out nocopy TMaxVarchar2
  )
is
-- moveElement
begin
  -- ����� ������ ��� ��������-����������
  if destBuf is not null then
    flushElement( dest, destBuf );
  end if;
  -- ����� ������ ��� ��������-���������
  if srcBuf is not null then
    flushElement( src, srcBuf );
  end if;
  -- ������� ������ �������� � ������
  dbms_lob.append(
      dest_lob => dest
    , src_lob  => src
    );
  -- ������� �������� ���������
  clearElement( src );

end moveElement;


/* iproc: moveCells
   ��������� ������� ����� � ������
*/
procedure moveCells
is
-- moveCells
begin
  moveElement( rows, bufRows, cells, bufCells );

end moveCells;


/* iproc: moveRows
   ��������� ������� ����� �� ���� Excel
*/
procedure moveRows
is
-- moveRows
begin
  moveElement( worksheets, bufWorksheets, rows, bufRows );

end moveRows;


/* iproc: moveWorksheets
   ��������� ������� ������ � �������� Excel
*/
procedure moveWorksheets
is
-- moveWorksheets
begin
  if bufWorksheets is not null then
    flushWorksheets();
  end if;
  pkg_TextCreate.append( worksheets );
  clearElement( worksheets );

end moveWorksheets;


/* iproc: getColumnStyle
   ���������� ����� ��� ��������� ������� � ���������

   ���������:
     columnName - ������������ ������� ���������

   �������:
     - ����� ������� (��. ��������� %_StyleName)
*/
function getColumnStyle (
  columnName in varchar2
  )
return varchar2
is
  vColumnName TName := upper( columnName );

-- getColumnStyle
begin

  return cols( colNames( vColumnName ) ).columnFormat;

exception
  when no_data_found then
    raise_application_error(
        pkg_Error.IllegalArgument
      , '������� � ������ "' || columnName ||
          '" �� ������� � ������ ������� ���������'
      );

end getColumnStyle;


/* iproc: initPreinstalledStyle
   �������������� ����������������� ����� � ��������� Excel.

   ������ ������:

   Default:
     ��� ������                  - ������
     ������������ ������������   - �� ������� �������
     �������������� ������������ - (�� �������)
     ������ ��������             - (�� �������)
     ������� �� ������           - (�� �������)
     ������ �����                - (�� �������)

   Text:
     ��� ������                  - ������
     ������������ ������������   - �� ������� �������
     �������������� ������������ - (�� �������)
     ������ ��������             - @
     ������� �� ������           - (�� �������)
     ������ �����                - (�� �������)

   Header:
     ��� ������                  - ������
     ������������ ������������   - �� ������
     �������������� ������������ - �� ������
     ������ ��������             - (�� �������)
     ������� �� ������           - ��
     ������ �����                - ��

   General:
     ��� ������                  - �����
     ������������ ������������   - �� ������� �������
     �������������� ������������ - (�� �������)
     ������ ��������             - (�� �������)
     ������� �� ������           - (�� �������)
     ������ �����                - (�� �������)

   Number:
     ��� ������                  - �����
     ������������ ������������   - �� ������� �������
     �������������� ������������ - (�� �������)
     ������ ��������             - Fixed
     ������� �� ������           - (�� �������)
     ������ �����                - (�� �������)

   Number0:
     ��� ������                  - �����
     ������������ ������������   - �� ������� �������
     �������������� ������������ - (�� �������)
     ������ ��������             - 0
     ������� �� ������           - (�� �������)
     ������ �����                - (�� �������)

   Percent:
     ��� ������                  - �����
     ������������ ������������   - �� ������� �������
     �������������� ������������ - (�� �������)
     ������ ��������             - Percent
     ������� �� ������           - (�� �������)
     ������ �����                - (�� �������)

   DateFull:
     ��� ������                  - ����
     ������������ ������������   - �� ������
     �������������� ������������ - (�� �������)
     ������ ��������             - dd/mm/yyyy\ hh:mm:ss
     ������� �� ������           - (�� �������)
     ������ �����                - (�� �������)

   DateShort:
     ��� ������                  - ������
     ������������ ������������   - �� ������
     �������������� ������������ - (�� �������)
     ������ ��������             - dd\.mm\.yyyy;@
     ������� �� ������           - (�� �������)
     ������ �����                - (�� �������)
*/
procedure initPreinstalledStyle
is
-- initPreinstalledStyle
begin
  -- ����� Default
  addStyle(
      styleName           => Default_StyleName
    , styleDataType       => String_DataType
    , verticalAlignment   => Top_Alignment
    );
    
  -- ����� Text
  addStyle(
      styleName           => Text_StyleName
    , styleDataType       => String_DataType
    , verticalAlignment   => Top_Alignment
    , formatValue         => '@'
    );

  -- ����� Header
  addStyle(
      styleName           => Header_StyleName
    , styleDataType       => String_DataType
    , verticalAlignment   => Center_Alignment
    , horizontalAlignment => Center_Alignment
    , isTextWrapped       => true
    , isFontBold          => true
    );

  -- ����� General
  addStyle(
      styleName           => General_StyleName
    , styleDataType       => Number_DataType
    , verticalAlignment   => Top_Alignment
    );

  -- ����� Number
  addStyle(
      styleName           => Number_StyleName
    , styleDataType       => Number_DataType
    , verticalAlignment   => Top_Alignment
    , formatValue         => 'Fixed'
    );

  -- ����� Number0
  addStyle(
      styleName           => Number0_StyleName
    , styleDataType       => Number_DataType
    , verticalAlignment   => Top_Alignment
    , formatValue         => '0'
    );

  -- ����� Percent
  addStyle(
      styleName           => Percent_StyleName
    , styleDataType       => Number_DataType
    , verticalAlignment   => Top_Alignment
    , formatValue         => 'Percent'
    );

  -- ����� DateFull
  addStyle(
      styleName           => DateFull_StyleName
    , styleDataType       => DateTime_DataType
    , verticalAlignment   => Center_Alignment
    , formatValue         => 'dd/mm/yyyy\ hh:mm:ss'
    );

  -- ����� DateShort
  addStyle(
      styleName           => DateShort_StyleName
    , styleDataType       => DateTime_DataType
    , verticalAlignment   => Center_Alignment
    , formatValue         => 'dd\.mm\.yyyy;@'
    );

exception
  when others then
    raise_application_error(
        pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ������������� ����������������� ������'
          )
      , true
      );

end initPreinstalledStyle;


/* group: �������� ���������� */


/* proc: newDocument
   ������������� ������ ��������� Excel
*/
procedure newDocument
is
-- newDocument
begin
  -- ������� �������� ����������� ��������� (���� �� ��� ����������� � ���� ������)
  cleanup();
  
  -- ������������� ��������� ����� Excel
  initElement( cells );
  initElement( rows );
  initElement( worksheets );
  
  -- ������������� ������
  initPreinstalledStyle();

exception
  when others then
    raise_application_error(
        pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ������������� ������ ��������� Excel'
          )
      , true
      );

end newDocument;


/* proc: addStyle
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
*/
procedure addStyle (
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
)
is
  vStyleName                TName       := trim(styleName);
  vStyleDataType            TName       := trim(styleDataType);
  vParentStyleName          TName       := trim(parentStyleName);
  vVerticalAlignment        TName       := trim(verticalAlignment);
  vHorizontalAlignment      TName       := trim(horizontalAlignment);
  vFormatValue              TName       := trim(formatValue);
  vFontName                 TName       := trim(fontName);
  vInteriorColor            TName       := trim(interiorColor);
  vFontSize                 pls_integer := nullif(fontSize, 0);
  vBorderPosition           pls_integer := nullif(borderPosition, 0);


  /*
     ��������� ������������ ������� ����������
  */
  procedure checkInput
  is
  -- checkInput
  begin
    -- ������������ �����
    if vStyleName is null then
      raise_application_error(
        pkg_Error.IllegalArgument
      , '�� ������� ������������ �����.'
      );
    end if;
    -- ��� ������ �����
    if vStyleDataType is null then
      raise_application_error(
        pkg_Error.IllegalArgument
      , '�� ������ ��� ������ �����.'
      );
    end if;
    -- ������������� ����� � ����� �� ������
    if styles.exists(vStyleName) then
      raise_application_error(
        pkg_Error.IllegalArgument
      , '����� � ��������� ������ ��� ����������. ' ||
          '����� ����������� ������������ ����� ��� ���������� ������� �������.'
      );
    end if;
    -- ������������� �����-��������
    if (
           vParentStyleName is not null
       and not styles.exists(vParentStyleName)
       ) then
      raise_application_error(
        pkg_Error.IllegalArgument
      , '��������� �����-�������� �� ����������'
      );
    end if;

  exception
    when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� �������� ���������� ��� �������� ����� � ��������� Excel'
        )
      , true
      );

  end checkInput;


  /*
     ���������� �������������� xml-��� Alignment
  */
  function getAlignmentTag
  return varchar2
  is
    tag                     TMaxVarchar2;

  -- getAlignmentTag
  begin
    -- ��������� xml-��� ������ ���� ������ ���� �� ���� ��� ��������
    if (
          coalesce(vVerticalAlignment, vHorizontalAlignment) is not null
       or isTextWrapped is not null
       ) then

      tag := '<Alignment' ||
        case
          when vVerticalAlignment is not null then
            ' ss:Vertical="' || vVerticalAlignment || '"'
        end ||
        case
          when vHorizontalAlignment is not null then
            ' ss:Horizontal="' || vHorizontalAlignment || '"'
        end ||
        case
          when isTextWrapped is not null then
            ' ss:WrapText="' ||
              case
                when isTextWrapped then
                  '1'
                else
                  '0'
              end || '"'
        end ||
        '/>'
      ;

    else

      tag := null;

    end if;

    return tag;

  end getAlignmentTag;


  /*
     ���������� �������������� xml-��� Font
  */
  function getFontTag
  return varchar2
  is
    tag                     TMaxVarchar2;

  -- getFontTag
  begin
    -- ��������� xml-��� ������ ���� ������ ���� �� ���� ��� ��������
    if (
          vFontName         is not null
       or vFontSize         is not null
       or isFontBold        is not null
       or isFontUnderlined  is not null
       ) then

      tag := '<Font' ||
        case
          when vFontName is not null then
            ' ss:FontName="' || vFontName || '"'
        end ||
        case
          when vFontSize is not null then
            ' ss:Size="' || to_char(vFontSize) || '"'
        end ||
        case
          when isFontBold is not null then
            ' ss:Bold="' ||
              case
                when isFontBold then
                  '1'
                else
                  '0'
              end || '"'
        end ||
        case
          when nvl(isFontUnderlined, false) then
            ' ss:Underline="Single"'
        end ||
        '/>'
      ;

    else

      tag := null;

    end if;

    return tag;

  end getFontTag;


  /*
     ���������� �������������� xml-��� NumberFormat
  */
  function getNumberFormatTag
  return varchar2
  is
    tag                     TMaxVarchar2;

  -- getNumberFormatTag
  begin
    -- ��������� xml-��� ������ ���� ������ ���� �� ���� ��� ��������
    if vFormatValue is not null then

      tag := '<NumberFormat ss:Format="' || vFormatValue || '"/>';

    else

      tag := null;

    end if;

    return tag;

  end getNumberFormatTag;


  /*
     ���������� �������������� xml-��� Borders
  */
  function getBordersTag
  return varchar2
  is
    tag                     TMaxVarchar2;


    /*
       ���������, ���������� �� �������� ������� � ��������� �������
    */
    function isBorderEnabled (
      checkPosition         in pls_integer
    )
    return boolean
    is
    -- isBorderEnabled
    begin

      return (
        bitand(vBorderPosition, checkPosition) / checkPosition = 1
      );

    end isBorderEnabled;


  -- getBordersTag
  begin
    -- ��������� xml-��� ������ ���� ������ ���� �� ���� ��� ��������
    if vBorderPosition is not null then
      tag := '<Borders>' ||
        case
          when isBorderEnabled(Top_BorderPosition) then
            '<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'
        end ||
        case
          when isBorderEnabled(Bottom_BorderPosition) then
            '<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>'
        end ||
        case
          when isBorderEnabled(Left_BorderPosition) then
            '<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'
        end ||
        case
          when isBorderEnabled(Right_BorderPosition) then
            '<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'
        end ||
        '</Borders>'
      ;

    else

      tag := null;

    end if;

    return tag;

  end getBordersTag;


  /*
      ���������� �������������� xml-��� Interior
  */
  function getInteriorTag
  return varchar2
  is    
  -- getInteriorTag
  begin
    return
      case
        when vInteriorColor is not null then
          '<Interior'
            || ' ss:Color="' || vInteriorColor || '"'
            || ' ss:Pattern="Solid"'
            || '/>'
        else
          null
      end
    ;
  
  end getInteriorTag;
  
  
-- addStyle
begin
  -- �������� ������������ ������� ����������
  checkInput();

  -- ������� ����� �����
  styles(vStyleName).xmlTag :=
    -- ������������ �����
    '<Style ss:ID="' || vStyleName || '"' ||
      -- �����-��������
      case
        when vParentStyleName is not null then
          ' ss:Parent="' || vParentStyleName || '"'
      end || '>' ||
      -- ������������ ������ � ������
      getAlignmentTag() ||
      -- �������
      getBordersTag() ||
      -- �����
      getFontTag() ||
      -- ������� ����
      getInteriorTag() ||
      -- ������ ��������
      getNumberFormatTag() ||
      '</Style>'
  ;

  -- ��������� ���������� ����� �����
  styles(vStyleName).styleOrder := styles.count;

  -- ��������� ��� ������ �����
  styles(vStyleName).styleDataType := vStyleDataType;

  -- ��������� �����-��������
  if vParentStyleName is not null then
    styles(vStyleName).parentStyleName := vParentStyleName;
  end if;

exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ���������� ����� � �������� Excel (' ||
          'styleName="' || vStyleName || '"' ||
          ', styleDataType="' || vStyleDataType || '"' ||
          ', parentStyleName="' || vParentStyleName || '"' ||
          ', verticalAlignment="' || vVerticalAlignment || '"' ||
          ', horizontalAlignment="' || vHorizontalAlignment || '"' ||
          ', formatValue="' || vFormatValue || '"' ||
          ', isTextWrapped="' ||
            case
              when isTextWrapped then
                'Y'
              when not isTextWrapped then
                'N'
            end || '"' ||
          ', fontName="' || vFontName || '"' ||
          ', fontSize=' || to_char(vFontSize) ||
          ', isFontBold="' ||
            case
              when isFontBold then
                'Y'
              when not isFontBold then
                'N'
            end || '"' ||
          ', isFontUnderlined="' ||
            case
              when isFontUnderlined then
                'Y'
              when not isFontUnderlined then
                'N'
            end || '"' ||
          ', borderPosition=' || to_char(vBorderPosition) ||
          ', interiorColor=' || to_char(vInteriorColor) ||
          ')'
      )
    , true
    );

end addStyle;


/* proc: removeStyle
   ������� ��������� �����

   ���������:
     styleName - ������������ �����
*/
procedure removeStyle (
  styleName in varchar2
  )
is
  vStyleName TName := trim( styleName );


  /*
     �������� ������� ������
  */
  procedure reorderStyle (
    startReorderFrom in pls_integer
    )
  is
    styleName TName;

  -- reorderStyle
  begin

    styleName := styles.first();
    while styleName is not null loop
      if styles( styleName ).styleOrder > startReorderFrom then
        -- �������� ������ ������ �� 1
        styles( styleName ).styleOrder := styles( styleName ).styleOrder - 1;
      end if;
      styleName := styles.next( styleName );
    end loop;
    styleName := null;

  end reorderStyle;


-- removeStyle
begin
  -- �������� �� ������� ���������� �����
  if styles.exists( vStyleName ) then

    -- �������� ������� ������
    reorderStyle(
      startReorderFrom => styles( vStyleName ).styleOrder
      );
    -- ������� �����
    styles.delete( vStyleName );

  end if;

exception
  when others then
    raise_application_error(
        pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� �������� ���������� ����� �� ��������� Excel ( ' ||
            'styleName="' || vStyleName || '"' ||
            ' )'
          )
      , true
      );

end removeStyle;


/* proc: addColumn
   ��������� ������� � �������� Excel

   ���������:
     columnName   - ��� ������� � ������ ������
     columnDesc   - ��� ������� � ��������� Excel
     columnWidth  - ������ �������
     columnFormat - ������ ������� (������������ ��������� %_StyleName)
*/
procedure addColumn (
    columnName   in varchar2
  , columnDesc   in varchar2
  , columnWidth  in pls_integer := null
  , columnFormat in varchar2 := null
  )
is
  vColumnName   TName := upper( columnName );
  -- ������ ������� �� ���������
  vColumnWidth  pls_integer := coalesce( columnWidth, 0 );
  -- ������ ������� �� ���������
  vColumnFormat TName := coalesce( columnFormat, Default_StyleName );

-- addColumn
begin
  -- ��������� ����� �������
  cols.extend;
  cols( cols.count ).columnDesc   := columnDesc;
  cols( cols.count ).columnWidth  := vColumnWidth;
  cols( cols.count ).columnFormat := vColumnFormat;

  -- ��������� ������� �������
  colNames( vColumnName ) := cols.count;

exception
  when others then
    raise_application_error(
        pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ���������� ������� � ��������� Excel ( ' ||
            'columnName="' || columnName || '"' ||
            ', columnDesc="' || columnDesc || '"' ||
            ', columnWidth=' || to_char( columnWidth ) ||
            ', columnFormat="' || columnFormat || '"' ||
            ' )'
          )
      , true
      );

end addColumn;


/* proc: clearColumnList
   ������� ������ ������� � ��������� Excel
*/
procedure clearColumnList
is
-- clearColumnList
begin
  cols := TColDocumentColumn();

exception
  when others then
    raise_application_error(
        pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ������� ������ ������� � ��������� Excel'
          )
      , true
      );

end clearColumnList;


/* proc: addCell ( varchar2 )
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
*/
procedure addCell (
    cellValue       in varchar2
  , style           in varchar2 := null
  , cellIndex       in pls_integer := null
  , mergeAcross     in pls_integer := null
  , mergeDown       in pls_integer := null
  , formula         in varchar2 := null
  , useHtmlTag      in boolean := false
  )
is
  -- ������ ������
  vCellIndex   pls_integer := nullif( cellIndex, 0 );
  -- ���-�� ����� ��� ������� � ������� (�� �����������)
  vMergeAcross pls_integer := nullif( mergeAcross, 0 );
  -- ���-�� ����� ��� ������� � ������� (�� ���������)
  vMergeDown pls_integer := nullif( mergeDown, 0 );
  -- ��� ������
  dataTag TName;
  -- ��� ������
  dataType TName;
  -- ������� ������������� ������������� ����� HTML � ��������
  isHtmlEnabled boolean;

-- addCell
begin
  -- ����������� ���� ������
  dataType :=
    case
      when (
               styles.exists( style )
           and styles( style ).styleDataType is not null
           ) then
        styles( style ).styleDataType
      else
        String_DataType
    end
  ;
  -- �������, ����� �� ��������� HTML � ��������
  isHtmlEnabled := ( useHtmlTag and dataType = String_DataType );
  -- ��� ��� �������� ������� ������
  dataTag :=
    case
      when isHtmlEnabled then
        'ss:Data'
      else
        'Data'
    end
  ;
  -- ��������� �������� � ������
  appendCells(
    '<Cell'
      ||
      -- �����
      case
        when style is not null then
          ' ss:StyleID="' || style || '"'
      end
      ||
      -- ������ ������
      case
        when vCellIndex is not null then
          ' ss:Index="' || to_char( vCellIndex ) || '"'
      end
      ||
      -- ������� ����� ����� �� �����������
      case
        when vMergeAcross is not null then
          ' ss:MergeAcross="' || to_char( vMergeAcross ) || '"'
      end
      ||
      -- ������� ����� ����� �� ���������
      case
        when vMergeDown is not null then
          ' ss:MergeDown="' || to_char( vMergeDown ) || '"'
      end
      ||
      -- �������
      case
        when formula is not null then
          ' ss:Formula="' || formula || '"'
      end
      || '>'
      ||
      -- �������� ������
      case
        when cellValue is not null then
          '<' || dataTag
            -- ��� ������
            || ' ss:Type="' || dataType || '"'
            ||
            -- xml-��� ��� ��������� HTML � ��������
            case
              when isHtmlEnabled then
                ' xmlns="http://www.w3.org/TR/REC-html40"'
            end
            || '>'
            ||
            -- �������� ������
            case
              when isHtmlEnabled then
                -- �������� ��� ������������� ������������ XML
                cellValue
              else
                -- ���������� ����������� XML
                pkg_ExcelCreateUtility.encodeXmlValue( cellValue )
            end
            ||
          '</' || dataTag || '>'
      end
      ||
    '</Cell>'
    )
  ;

exception
  when others then
    raise_application_error(
        pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ���������� �������� � ������ Excel ('
            || ' cellValue="' || cellValue || '"'
            || ', style="' || style || '"'
            || ', cellIndex=' || to_char( cellIndex )
            || ', mergeAcross=' || to_char( mergeAcross )
            || ', mergeDown=' || to_char( mergeDown )
            || ', formula="' || formula || '"'
            || ').'
          )
      , true
      );

end addCell;


/* proc: addCell ( date )
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
*/
procedure addCell (
    cellValue       in date
  , isDateTime      in boolean := false
  , style           in varchar2 := null
  , cellIndex       in pls_integer := null
  , mergeAcross     in pls_integer := null
  , mergeDown       in pls_integer := null
  , formula         in varchar2 := null
  )
is
  vCellValue TName;

-- addCell
begin
  -- �������� ���� � ��������� ������� Excel
  vCellValue := case
                  when isDateTime then
                    pkg_ExcelCreateUtility.getExcelDateTime( cellValue )
                  when not isDateTime then
                    pkg_ExcelCreateUtility.getExcelDate( cellValue )
                  else
                    null
                end;

  addCell(
      cellValue   => vCellValue
    , style       => style
    , cellIndex   => cellIndex
    , mergeAcross => mergeAcross
    , mergeDown   => mergeDown
    , formula     => formula
    );

exception
  when others then
    raise_application_error(
        pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ���������� �������� ������ � ������� "����" ( '
            || 'cellValue="' || to_char( cellValue, 'dd.mm.yyyy' ) || '"'
            || ', isDateTime="'
                 || case
                      when isDateTime then
                        'Y'
                      when not isDateTime then
                        'N'
                    end || '"'
            || ', style="' || style || '"'
            || ', cellIndex=' || to_char( cellIndex )
            || ', mergeAcross=' || to_char( mergeAcross )
            || ', mergeDown=' || to_char( mergeDown )
            || ', formula="' || formula || '"'
            || ').'
          )
      , true
      );

end addCell;


/* proc: addCell ( number )
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
*/
procedure addCell (
    cellValue        in number
  , decimalDigit     in pls_integer := null
  , style            in varchar2 := null
  , cellIndex        in pls_integer := null
  , mergeAcross      in pls_integer := null
  , mergeDown        in pls_integer := null
  , formula          in varchar2 := null
  )
is
  vCellValue varchar2(38);
  fmt        varchar2(41);

-- addCell
begin
  -- ���������� ������ �����
  if decimalDigit > 0 then
    fmt := 'fm999999999990.' || rpad( '0', decimalDigit, '0' );
  end if;

  -- �������� ����� � ��������� ������� Excel
  vCellValue := case
                  when decimalDigit is null then
                    replace( to_char( cellValue ), ',', '.' )
                  when decimalDigit > 0 then
                    to_char( round( cellValue, decimalDigit ), fmt )
                  when decimalDigit = 0 then
                    to_char( round( cellValue, decimalDigit ) )
                end
  ;

  -- ��������� ��������
  addCell(
      cellValue   => vCellValue
    , style       => style
    , cellIndex   => cellIndex
    , mergeAcross => mergeAcross
    , mergeDown   => mergeDown
    , formula     => formula
    );

exception
  when others then
    raise_application_error(
        pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ���������� �������� ������ � ������� "�����" ('
            || ' cellValue=' || to_char( cellValue )
            || ', decimalDigit=' || to_char( decimalDigit )
            || ', style="' || style || '"'
            || ', cellIndex=' || to_char( cellIndex )
            || ', mergeAcross=' || to_char( mergeAcross )
            || ', mergeDown=' || to_char( mergeDown )
            || ', formula="' || formula || '"'
            || ').'
          )
      , true
      );

end addCell;


/* proc: addCellByName ( varchar2 )
   ��������� �������� ������ Excel � ������� "������". ����� ������ ������������
   �� ����� ������� � ���������. �������� <addCell ( varchar2 )>.

   ���������:
     columnName                - ��� ������� ���������
     cellValue                 - �������� ������
     cellIndex                 - ���������� ����� ������ � ������
     mergeAcross               - ���-�� ����� ��� ������� � ������� (�� �����������)
     mergeDown                 - ���-�� ����� ��� ������� � ������� (�� ���������)
*/
procedure addCellByName (
    columnName      in varchar2
  , cellValue       in varchar2
  , cellIndex       in pls_integer := null
  , mergeAcross     in pls_integer := null
  , mergeDown       in pls_integer := null
  )
is
-- addCellByName
begin
  -- ��������� �������� ������
  addCell(
      cellValue   => cellValue
    , style       => getColumnStyle( columnName )
    , cellIndex   => cellIndex
    , mergeAcross => mergeAcross
    , mergeDown   => mergeDown
    );

exception
  when others then
    raise_application_error(
        pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ���������� �������� ������ Excel �� ����� ������� ��������� ('
            || ' columnName="' || columnName || '"'
            || ', cellValue="' || cellValue || '"'
            || ', cellIndex=' || to_char( cellIndex )
            || ', mergeAcross=' || to_char( mergeAcross )
            || ', mergeDown=' || to_char( mergeDown )
            || ').'
          )
      , true
      );

end addCellByName;


/* proc: addCellByName ( date )
   ��������� �������� ������ Excel � ������� "����". ����� ������ ������������
   �� ����� ������� ���������. �������� <addCell ( date )>.

   ���������:
     columnName                - ������������ ������� ���������
     cellValue                 - �������� ������ � ������� "����"
     isDateTime                - �������� � ������� ���� + ����� ? (true-��, false-���)
     cellIndex                 - ���������� ����� ������ � ������
     mergeAcross               - ���-�� ����� ��� ������� � ������� (�� �����������)
     mergeDown                 - ���-�� ����� ��� ������� � ������� (�� ���������)
*/
procedure addCellByName (
    columnName      in varchar2
  , cellValue       in date
  , isDateTime      in boolean := false
  , cellIndex       in pls_integer := null
  , mergeAcross     in pls_integer := null
  , mergeDown       in pls_integer := null
  )
is
-- addCellByName
begin
  -- ��������� �������� ������
  addCell(
      cellValue   => cellValue
    , isDateTime  => isDateTime
    , style       => getColumnStyle( columnName )
    , cellIndex   => cellIndex
    , mergeAcross => mergeAcross
    , mergeDown   => mergeDown
    );

exception
  when others then
    raise_application_error(
        pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ���������� �������� ������ Excel �� ����� ������� ��������� ( '
            || 'columnName="' || columnName || '"'
            || ', cellValue="' || to_char( cellValue, 'dd.mm.yyyy' ) || '"'
            || ', isDateTime="'
                 || case
                      when isDateTime then
                        'Y'
                      when not isDateTime then
                        'N'
                    end || '"'
            || ', cellIndex=' || to_char( cellIndex )
            || ', mergeAcross=' || to_char( mergeAcross )
            || ', mergeDown=' || to_char( mergeDown )
            || ').'
          )
      , true
      );

end addCellByName;


/* proc: addCellByName ( number )
   ��������� �������� ������ Excel � ������� "�����". ����� ������ ������������
   �� ����� ������� ���������. �������� <addCell ( number )>.

   ���������:
     columnName                - ������������ ������� ���������
     cellValue                 - �������� ������ � ������� "�����"
     decimalDigit              - ���-�� ���������� ������ (��. <addCell ( number )>)
     cellIndex                 - ���������� ����� ������ � ������
     mergeAcross               - ���-�� ����� ��� ������� � ������� (�� �����������)
     mergeDown                 - ���-�� ����� ��� ������� � ������� (�� ���������)
*/
procedure addCellByName (
    columnName       in varchar2
  , cellValue        in number
  , decimalDigit     in pls_integer := null
  , cellIndex        in pls_integer := null
  , mergeAcross      in pls_integer := null
  , mergeDown        in pls_integer := null
  )
is
-- addCellByName
begin
  -- ��������� �������� ������
  addCell(
      cellValue    => cellValue
    , decimalDigit => decimalDigit
    , style        => getColumnStyle( columnName )
    , cellIndex    => cellIndex
    , mergeAcross  => mergeAcross
    , mergeDown    => mergeDown
    );

exception
  when others then
    raise_application_error(
        pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ���������� �������� ������ Excel �� ����� ������� ��������� ('
            || ' columnName="' || columnName || '"'
            || ', cellValue=' || to_char( cellValue )
            || ', decimalDigit=' || to_char( decimalDigit )
            || ', cellIndex=' || to_char( cellIndex )
            || ', mergeAcross=' || to_char( mergeAcross )
            || ', mergeDown=' || to_char( mergeDown )
            || ').'
          )
      , true
      );

end addCellByName;


/* proc: addAutoSum
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
*/
procedure addAutoSum (
    style             in varchar2
  , decimalDigit      in pls_integer := null
  , rangeFirstRow     in pls_integer := null
  , rangeLastRow      in pls_integer := null
  , cellIndex         in pls_integer := null
  )
is
  /*
     ��������� ������� ����������������
  */
  function getAutoSumFormula
  return varchar2
  is
    -- ������ �������
    formula varchar2(100) :=
      '=SUM(R[-$(rangeEndNumber)]C:R[-$(rangeStartNumber)]C)'
    ;

    -- ����� ������� ������ �� ����� Excel
    currentRowNumber pls_integer := rowNumber + 1;

    -- ������ ������ ��������� ������������
    vRangeFirstRow pls_integer;
    -- ��������� ������ ��������� ������������
    vRangeLastRow pls_integer;

    -- ������ ��������� ������������ (� �������� Excel)
    rangeStartNumber pls_integer;
    -- ��������� ��������� ������������ (� �������� Excel)
    rangeEndNumber pls_integer;

  -- getAutoSumFormula
  begin
    -- ������ ������ ������ ������ ��������� ������������
    vRangeFirstRow :=
      coalesce( nullif( rangeFirstRow, 0 ), nullif( headerRowNumber, 0 ) + 1, 1 )
    ;
    -- ������ ������ ��������� ������ ��������� ������������
    vRangeLastRow :=
      coalesce( nullif( rangeLastRow, 0 ), currentRowNumber - 1, 1 )
    ;

    -- ����������� ������ ���������
    rangeStartNumber := currentRowNumber - vRangeLastRow;
    -- ����������� ��������� ���������
    rangeEndNumber := currentRowNumber - vRangeFirstRow;

    -- ����������� �������� ������������ � �������
    formula :=
      replace(
          replace( formula, '$(rangeStartNumber)', to_char( rangeStartNumber ) )
        , '$(rangeEndNumber)', to_char( rangeEndNumber )
        )
    ;

    return formula;

  end getAutoSumFormula;


-- addAutoSum
begin
  -- ��������� �������� ������
  addCell(
      cellValue    => 0
    , decimalDigit => decimalDigit
    , style        => style
    , cellIndex    => cellIndex
    , formula      => getAutoSumFormula()
    );

exception
  when others then
    raise_application_error(
        pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ���������� ��������� �� ���� Excel ('
            || ' style="' || style || '"'
            || ', decimalDigit=' || to_char( decimalDigit )
            || ', rangeFirstRow=' || to_char( rangeFirstRow )
            || ', rangeLastRow=' || to_char( rangeLastRow )
            || ', cellIndex=' || to_char( cellIndex )
            || ').'
          )
      , true
      );

end addAutoSum;


/* proc: addAutoSumByName
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
*/
procedure addAutoSumByName (
    columnName        in varchar2
  , decimalDigit      in pls_integer := null
  , rangeFirstRow     in pls_integer := null
  , rangeLastRow      in pls_integer := null
  , cellIndex         in pls_integer := null
  )
is
-- addAutoSumByName
begin
  -- ��������� �������� ������
  addAutoSum(
      style         => getColumnStyle( columnName )
    , decimalDigit  => decimalDigit
    , rangeFirstRow => rangeFirstRow
    , rangeLastRow  => rangeLastRow
    , cellIndex     => cellIndex
    );

exception
  when others then
    raise_application_error(
        pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ���������� ��������� � ������ Excel �� ����� ������� ('
            || ' columnName="' || columnName || '"'
            || ', decimalDigit=' || to_char( decimalDigit )
            || ', rangeFirstRow=' || to_char( rangeFirstRow )
            || ', rangeLastRow=' || to_char( rangeLastRow )
            || ', cellIndex=' || to_char( cellIndex )
            || ').'
          )
      , true
      );

end addAutoSumByName;


/* proc: addRow (DEPRECATED, use addRow(height, autoFit) instead)
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
  )
is
-- addRow
begin
  -- pass parameters into the new interface
  addRow( autoFit => autoFitHeight );

end addRow;


/* proc: addRow
  Add a row (after all its cells have been generated)

  Params:
   
  height                    - row height in points. The value specified will be reset to a maximum
                              of RowHeight_Max if exceeded.
  autoFit                   - determine row height automatically (true or false)

  Note: Please call addWorksheet() once all required rows have been created
*/
procedure addRow(
  height                    in number   := null
, autoFit                   in boolean  := true
)
is
  -- maximum height - RowHeight_Max
  vHeight                   number := least(height, RowHeight_Max);
  vAutoFit                  number(1) :=  case
                                            when nvl(autoFit, true) then
                                              1
                                            else
                                              0
                                          end;

begin
  -- opening tag
  appendRows(
    '<Row' ||
      ' ss:AutoFitHeight="' || to_char(vAutoFit) || '"' ||
      case
        when vHeight is not null then
          ' ss:Height="' || to_char(vHeight, 'fm99990.00') || '"'
      end || '>'
  , true
  );
  
  -- move all the cells into the row
  moveCells();
  
  -- closing tag
  appendRows( '</Row>' );

  -- keep track of current row number
  rowNumber := rowNumber + 1;

exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Error in adding a row onto an Excel worksheet (' ||
          'height="' || to_char(vHeight) || '"' ||
          ', autoFit="' ||
              case
                when autoFit then
                  'Y'
                else
                  'N'
              end || '"' ||
          ')'
      )
    , true
    );

end addRow;


/* proc: addHeaderRow
   ��������� �������� ������� ��������� �� ����� Excel
   
   ���������:
     style                     - ����� (��. ��������� %_StyleName)
*/
procedure addHeaderRow (
  style in varchar2 := null
  )
is
-- addHeaderRow
begin
  -- ���������, ��� ��������� ���� �� ���� �������
  if cols.count = 0 then
    raise_application_error(
        pkg_Error.IllegalArgument
      , '� ��������� ����������� �������. ����������� addColumn() ��� ���������� �������.'
      );
  end if;

  -- ��������� ������ ������� ���������
  for i in 1..cols.count loop
    addCell( cols(i).columnDesc, coalesce( style, Header_StyleName ) );
  end loop;
  addRow();

  -- ��������� ����� ������ ��������� �� ������� ����� Excel
  headerRowNumber := rowNumber;

exception
  when others then
    raise_application_error(
        pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ������������ ������ ������� ��������� �� ����� Excel ('
            || ' style="' || style || '"'
            || ').'
          )
      , true
      );

end addHeaderRow;


/* proc: setColumnWidth
   ������������� ������ ������� ��������� �� ����� Excel
*/
procedure setColumnWidth
is
-- setColumnWidth
begin
  -- ���������, ��� ��������� ���� �� ���� �������
  if cols.count = 0 then
    raise_application_error(
        pkg_Error.IllegalArgument
      , '� ��������� ����������� �������. ����������� addColumn() ��� ���������� �������.'
      );
  end if;

  -- ������������� ������ �������
  for i in 1..cols.count loop
    appendRows(
      '<Column ss:Width="' || to_char( cols(i).columnWidth ) || '"/>'
      )
    ;
  end loop;

exception
  when others then
    raise_application_error(
        pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ��������� ����� ������� ��������� �� ����� Excel'
          )
      , true
      );

end setColumnWidth;


/* proc: addWorksheet
  Add a sheet into an Excel workbook

  Params:
  
  sheetName                 - Excel sheet name
  addAutoFilter             - Enable auto filter (default, true)
  fitToPage                 - Fit contents to page (default, false)
  fitHeight                 - Fit to: N pages tall
  fitWidth                  - Fit to: N pages wide
*/
procedure addWorksheet (
  sheetName                 in varchar2
, addAutoFilter             in boolean := true
, fitToPage                 in boolean := false
, fitHeight                 in pls_integer := null
, fitWidth                  in pls_integer := null
)
is
  -- ��������� ���� xml ��� ������������ ����� (�� ������)
  Template_Header           constant varchar2(4000) := '<Worksheet ss:Name="$(sheetName)">';
  -- ����������
  Template_AutoFilter       constant varchar2(4000) := '<AutoFilter x:Range="$(range)" xmlns="urn:schemas-microsoft-com:office:excel"/>';
  -- �������� ���� xml (����� ������)
  Template_Footer           constant varchar2(4000) := '</Worksheet>';

-- addWorksheet
begin
  -- ��������� ����
  appendWorksheets(
    replace(Template_Header, '$(sheetName)', sheetName)
  );
  
  -- ���������� �����
  appendWorksheets('<Table>');
  moveRows();
  appendWorksheets('</Table>');

  -- ��������� ������-����������
  if (addAutoFilter and nullif(headerRowNumber, 0) is not null) then
    appendWorksheets(
      replace(
        Template_AutoFilter, '$(range)',
          'R' || to_char(headerRowNumber) || 'C1:' ||
            'R' || to_char(headerRowNumber) || 'C' || to_char(cols.count)
      )
    );
  end if;

  -- spreadsheet options
  appendWorksheets(
    '<WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">' ||
    case
      when fitToPage then
        '<FitToPage/>'
    end                                                                 ||
    case
      when fitHeight is not null or fitWidth is not null then
        '<Print>'                                                       ||
        case
          when fitHeight is not null then
            '<FitHeight>' || to_char(fitHeight) || '</FitHeight>'
        end                                                             ||
        case
          when fitWidth is not null then
            '<FitWidth>' || to_char(fitWidth) || '</FitWidth>'
        end                                                             ||
        '</Print>'
    end                                                                 ||
    '</WorksheetOptions>'
  );

  -- ��������� ����
  appendWorksheets(Template_Footer);

  -- ������������� ������� ����
  sheetNumber := sheetNumber + 1;
  -- ������� ���-�� ����� �� ������� �����
  rowNumber := 0;

exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ���������� ����� Excel (' ||
          'sheetName="' || sheetName || '"' ||
          ', addAutoFilter="' ||
            case
              when addAutoFilter then
                'Y'
              when not addAutoFilter then
                'N'
            end || '"' ||
          ', fitToPage="' ||
            case
              when fitToPage then
                'Y'
              else
                'N'
            end || '"' ||
          ', fitHeight=' || to_char(fitHeight) ||
          ', fitWidth='  || to_char(fitWidth)  ||
          ')'
      )
    , true
    );

end addWorksheet;


/* proc: prepareDocument
   ��������� ��������. ���������� ����� ����, ��� ������������ ��� ����� � Excel

   ���������:
     encoding - ��������� ��������� (��. ��������� %_DocumentEncoding)
*/
procedure prepareDocument (
  encoding in varchar2
  )
is
  -- ��������� ��������� Excel
  vEncoding TName := trim( encoding );

  -- ��������� xml-���������
  header varchar2(4000) := '<?xml version="1.0" encoding="$(encoding)"?>
<?mso-application progid="Excel.Sheet"?>
<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"
  xmlns:o="urn:schemas-microsoft-com:office:office"
  xmlns:x="urn:schemas-microsoft-com:office:excel"
  xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
  xmlns:html="http://www.w3.org/TR/REC-html40">';

  -- ����������� ��� xml-�����
  footer varchar2(50) := '</Workbook>';


  /*
     ��������� ������������ ������� ����������
  */
  procedure checkInput
  is
  -- checkInput
  begin
    -- �������� �� �������������� ����� ��������
    if isDocumentPrepared then
      raise_application_error(
          pkg_Error.IllegalArgument
        , '� ������� ������ ����� ��� ��� ����������� ��������. ' ||
            '��� ��������� ������ ��������� �������������� ����� ������� newDocument().'
        );
    end if;
    -- �������� ���������
    if vEncoding is null then
      raise_application_error(
          pkg_Error.IllegalArgument
        , '�� ������� ��������� ��������� Excel ��� ���������'
        );
    end if;

  exception
    when others then
      raise_application_error(
          pkg_Error.ErrorStackInfo
        , logger.errorStack(
            '������ ��� �������� ������� ���������� ��� ��������� ��������� Excel'
            )
        , true
        );

  end checkInput;


  /*
     ��������� ������ Styles �� ������� ������ � ������������ ������� � ��������
     Excel
  */
  procedure appendOrderedStyle
  is
    -- ������������ �����
    styleName TName;

    -- ��� ��� ����������� ������� ���������� ������
    type TColStyleOrder is table of TName
      index by pls_integer
    ;
    colStyleOrder TColStyleOrder;

  -- appendOrderedStyle
  begin
    -- ������ ������ ������
    pkg_TextCreate.append( '<Styles>' );

    -- �������������� ������� ������
    colStyleOrder.delete;
    styleName := styles.first();
    while styleName is not null loop
      colStyleOrder( styles( styleName ).styleOrder ) := styleName;
      styleName := styles.next( styleName );
    end loop;
    styleName := null;

    -- ��������� ������ ������ � ������������ �������
    for i in colStyleOrder.first..colStyleOrder.last loop
      if colStyleOrder.exists(i) then
        pkg_TextCreate.append( styles( colStyleOrder(i) ).xmlTag );
      end if;
    end loop;

    -- ����� ������ ������
    pkg_TextCreate.append( '</Styles>' );

  exception
    when others then
      raise_application_error(
          pkg_Error.ErrorStackInfo
        , logger.errorStack(
            '������ ��� ������������ ������ ������ � ��������� Excel'
            )
        , true
        );

  end appendOrderedStyle;


-- prepareDocument
begin
  -- �������� ������������ ������� ����������
  checkInput();

  -- �������������� ����� ��������� ����
  pkg_TextCreate.newText();

  -- ��������� ���������
  pkg_TextCreate.append(
    replace( header, '$(encoding)', vEncoding )
    );

  -- ��������� �����
  appendOrderedStyle();

  -- ���� ������ �����������, �� ��������� ������ ���� ��� �����������
  -- ������������ ������� xml �����
  if dbms_lob.getLength( worksheets ) = 0 then
    addWorksheet( 'Sheet1', false );
  end if;
  
  -- ��������� �����
  moveWorksheets();

  -- ��������� ����������� ���
  pkg_TextCreate.append( footer );

  -- ������������� ������� ����
  sheetNumber := 1;

  -- ������������� �������, ��� �������� �����������
  isDocumentPrepared := true;

exception
  when others then
    raise_application_error(
        pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ������������ ��������� Excel ('
            || ' encoding="' || encoding || '"'
            || ').'
          )
      , true
      );

end prepareDocument;


/* func: getDocument
   ���������� �������������� �������� Excel � ���� CLOB

   �������:
     - ���� � ���� CLOB
*/
function getDocument
return clob
is
-- getDocument
begin
  -- ���� �������� ��� �� ����������� - �������� �� ����
  if not isDocumentPrepared then
    raise_application_error(
        pkg_Error.IllegalArgument
      , '� ������� ������ �������� ��� �� �����������. ����������, ����������� ' ||
          'prepareDocument() ��� ��������� ���������'
      );
  end if;

  -- ���������� �������������� ��������
  return pkg_TextCreate.getClob();

exception
  when others then
    raise_application_error(
        pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ��������� ��������������� ��������� Excel � ���� CLOB'
          )
      , true
      );

end getDocument;


/* func: getArchivedDocument
   ���������� ���������������� � .zip �������� Excel � ���� BLOB

   ���������:
     fileName - ��� ����� ��������� � ������

   �������:
     - ���� � ���� BLOB
*/
function getArchivedDocument (
  fileName in varchar2
  )
return blob
is
-- getArchivedDocument
begin
  -- ���� �������� ��� �� ����������� - �������� �� ����
  if not isDocumentPrepared then
    raise_application_error(
        pkg_Error.IllegalArgument
      , '� ������� ������ �������� ��� �� �����������. ����������, ����������� ' ||
          'prepareDocument() ��� ��������� ���������'
      );
  end if;

  -- ���������� �������������� �����
  return pkg_TextCreate.getZip( fileName  );

exception
  when others then
    raise_application_error(
        pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ��������� ����������������� � .zip ��������� Excel � ���� BLOB ( ' ||
            'fileName="' || fileName || '"' ||
            ' )'
          )
      , true
      );

end getArchivedDocument;


/* func: getRowCount
   ���������� ���-�� ����� �� ������� ����� Excel

   �������:
     - ���-�� ����� �� �����
*/
function getRowCount
return pls_integer
is
-- getRowCount
begin

  return rowNumber;

end getRowCount;


/* func: getCurrentSheetNumber
   ���������� ����� �������� ����� Excel

   �������:
     - ����� �����
*/
function getCurrentSheetNumber
return pls_integer
is
-- getCurrentSheetNumber
begin

  return sheetNumber;

end getCurrentSheetNumber;


begin
  -- ������������� ������ ���������
  newDocument();

end pkg_ExcelCreate;
/
