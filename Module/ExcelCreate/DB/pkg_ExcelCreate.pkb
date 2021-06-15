create or replace package body pkg_ExcelCreate
as
/* package body: pkg_ExcelCreate::body */


/* group: Типы */


/* itype: TMaxVarchar2
   Тип для хранения текста в varchar2 максимального размера
*/
subtype TMaxVarchar2 is varchar2(32767);

/* itype: TName
   Тип для именования объектов (имена колонок, стилей, типов данных и т.п.)
*/
subtype TName is varchar2(128);

/* itype: TColDocumentColumn
   Тип для формирования списка колонок в документе
*/
type TRecDocumentColumn is record (
  columnDesc   varchar2(255)
, columnWidth  pls_integer
, columnFormat TName
);
type TColDocumentColumn is table of TRecDocumentColumn
;

/* itype: TColColumnName
   Тип для соответствия имен колонок в документе с их позицией
*/
type TColColumnName is table of pls_integer
  index by TName
;

/* itype: TColStyle
   Тип для стилей документа Excel
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


/* group: Переменные */


/* ivar: logger
   Объект для логгирования
*/
logger lg_logger_t := lg_logger_t.getLogger(
    moduleName  => Module_Name
  , packageName => 'pkg_ExcelCreate'
  );

/* ivar: styles
   Коллекция стилей в документе Excel
*/
styles TColStyle;

/* ivar: cols
   Коллекция колонок в документе
*/
cols TColDocumentColumn;

/* ivar: colNames
   Коллекция соответствий имен колонок документа с их позицией
*/
colNames TColColumnName;

/* ivar: cells
   Коллекция ячеек в одной строке Excel
*/
cells clob;

/* ivar: rows
   Коллекция строк на одном листе Excel
*/
rows clob;

/* ivar: worksheets
   Коллекция листов в одной книге Excel
*/
worksheets clob;

/* ivar: bufCells
   Буфер для хранения ячеек
*/
bufCells TMaxVarchar2;

/* ivar: bufRows
   Буфер для хранения строк
*/
bufRows TMaxVarchar2;

/* ivar: bufWorksheets
   Буфер для хранения листов
*/
bufWorksheets TMaxVarchar2;

/* ivar: rowNumber
   Номер последней добавленной строки на текущем листе Excel
*/
rowNumber pls_integer := 0;

/* ivar: sheetNumber
   Номер текущего листа Excel
*/
sheetNumber pls_integer := 1;

/* ivar: headerRowNumber
   Номер строки с заголовком на текущем листе Excel (для создания автофильтра)
*/
headerRowNumber pls_integer := 0;

/* ivar: isDocumentPrepared
   Признак, сформирован ли документ (true-да, false-нет)
*/
isDocumentPrepared boolean := false;


/* group: Функции */


/* group: Закрытые объявления */


/* iproc: initElement
   Выполняет инициализацию элемента книги Excel
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
   Выполняет очистку элемента книги Excel
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
   Очистка используемых ресурсов при инициализации или финализации пакета
*/
procedure cleanup
is 
-- cleanup
begin
  -- очистка nested table
  cols := TColDocumentColumn();

  -- очистка ассоциативных массивов
  colNames.delete;
  styles.delete;
  
  -- очистка элементов книги Excel
  clearElement( cells );
  clearElement( rows );
  clearElement( worksheets );
  
  -- очистка буферов элементов книги Excel
  bufCells := null;
  bufRows := null;
  bufWorksheets := null;

  -- установка первоначальных значений для других переменных
  rowNumber := 0;
  sheetNumber := 1;
  headerRowNumber := 0;
  isDocumentPrepared := false;

exception
  when others then
    raise_application_error(
        pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при очистке используемых ресурсов'
          )
      , true
      );

end cleanup;


/* iproc: flushElement
   Сбрасывает накопленный буфер по элементу Excel в clob
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
   Сбрасывает накопленный буфер по ячейкам в clob
*/
procedure flushCells
is
-- flushCells
begin
  flushElement( cells, bufCells );

end flushCells;


/* iproc: flushRows
   Сбрасывает накопленный буфер по строкам в clob
*/
procedure flushRows
is
-- flushRows
begin
  flushElement( rows, bufRows );

end flushRows;


/* iproc: flushWorksheets
   Сбрасывает накопленный буфер по листам в clob
*/
procedure flushWorksheets
is
-- flushWorksheets
begin
  flushElement( worksheets, bufWorksheets );

end flushWorksheets;


/* iproc: appendElement
   Добавляет текстовые данные в элемент книги Excel
*/
procedure appendElement (
    elm             in out nocopy clob
  , buf             in out nocopy TMaxVarchar2
  , str             in varchar2
  , newLineFlag     in boolean := false
  )
is
  -- значение элемента
  elmStr TMaxVarchar2;
  
  -- длина буфера для элемента
  bufLength pls_integer;
  -- длина строки для добавления в буфер
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
   Добавляет текстовые данные в ячейку
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
   Добавляет текстовые данные из ячеек в строку Excel
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
   Добавляет текстовые данные в строках на лист Excel
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
   Выполняет перенос одного элемента книги Excel в другой
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
  -- сброс буфера для элемента-назначения
  if destBuf is not null then
    flushElement( dest, destBuf );
  end if;
  -- сброс буфера для элемента-источника
  if srcBuf is not null then
    flushElement( src, srcBuf );
  end if;
  -- перенос одного элемента в другой
  dbms_lob.append(
      dest_lob => dest
    , src_lob  => src
    );
  -- очистка элемента источника
  clearElement( src );

end moveElement;


/* iproc: moveCells
   Выполняет перенос ячеек в строку
*/
procedure moveCells
is
-- moveCells
begin
  moveElement( rows, bufRows, cells, bufCells );

end moveCells;


/* iproc: moveRows
   Выполняет перенос строк на лист Excel
*/
procedure moveRows
is
-- moveRows
begin
  moveElement( worksheets, bufWorksheets, rows, bufRows );

end moveRows;


/* iproc: moveWorksheets
   Выполняет перенос листов в документ Excel
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
   Возвращает стиль для указанной колонки в документе

   Параметры:
     columnName - наименование колонки документа

   Возврат:
     - стиль колонки (см. константы %_StyleName)
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
      , 'Колонка с именем "' || columnName ||
          '" не найдена в списке колонок документа'
      );

end getColumnStyle;


/* iproc: initPreinstalledStyle
   Инициализирует предустановленные стили в документе Excel.

   Список стилей:

   Default:
     Тип данных                  - строка
     Вертикальное выравнивание   - по верхней границе
     Горизонтальное выравнивание - (не указано)
     Формат значения             - (не указано)
     Перенос по словам           - (не указано)
     Жирный шрифт                - (не указано)

   Text:
     Тип данных                  - строка
     Вертикальное выравнивание   - по верхней границе
     Горизонтальное выравнивание - (не указано)
     Формат значения             - @
     Перенос по словам           - (не указано)
     Жирный шрифт                - (не указано)

   Header:
     Тип данных                  - строка
     Вертикальное выравнивание   - по центру
     Горизонтальное выравнивание - по центру
     Формат значения             - (не указано)
     Перенос по словам           - да
     Жирный шрифт                - да

   General:
     Тип данных                  - число
     Вертикальное выравнивание   - по верхней границе
     Горизонтальное выравнивание - (не указано)
     Формат значения             - (не указано)
     Перенос по словам           - (не указано)
     Жирный шрифт                - (не указано)

   Number:
     Тип данных                  - число
     Вертикальное выравнивание   - по верхней границе
     Горизонтальное выравнивание - (не указано)
     Формат значения             - Fixed
     Перенос по словам           - (не указано)
     Жирный шрифт                - (не указано)

   Number0:
     Тип данных                  - число
     Вертикальное выравнивание   - по верхней границе
     Горизонтальное выравнивание - (не указано)
     Формат значения             - 0
     Перенос по словам           - (не указано)
     Жирный шрифт                - (не указано)

   Percent:
     Тип данных                  - число
     Вертикальное выравнивание   - по верхней границе
     Горизонтальное выравнивание - (не указано)
     Формат значения             - Percent
     Перенос по словам           - (не указано)
     Жирный шрифт                - (не указано)

   DateFull:
     Тип данных                  - дата
     Вертикальное выравнивание   - по центру
     Горизонтальное выравнивание - (не указано)
     Формат значения             - dd/mm/yyyy\ hh:mm:ss
     Перенос по словам           - (не указано)
     Жирный шрифт                - (не указано)

   DateShort:
     Тип данных                  - строка
     Вертикальное выравнивание   - по центру
     Горизонтальное выравнивание - (не указано)
     Формат значения             - dd\.mm\.yyyy;@
     Перенос по словам           - (не указано)
     Жирный шрифт                - (не указано)
*/
procedure initPreinstalledStyle
is
-- initPreinstalledStyle
begin
  -- стиль Default
  addStyle(
      styleName           => Default_StyleName
    , styleDataType       => String_DataType
    , verticalAlignment   => Top_Alignment
    );
    
  -- стиль Text
  addStyle(
      styleName           => Text_StyleName
    , styleDataType       => String_DataType
    , verticalAlignment   => Top_Alignment
    , formatValue         => '@'
    );

  -- стиль Header
  addStyle(
      styleName           => Header_StyleName
    , styleDataType       => String_DataType
    , verticalAlignment   => Center_Alignment
    , horizontalAlignment => Center_Alignment
    , isTextWrapped       => true
    , isFontBold          => true
    );

  -- стиль General
  addStyle(
      styleName           => General_StyleName
    , styleDataType       => Number_DataType
    , verticalAlignment   => Top_Alignment
    );

  -- стиль Number
  addStyle(
      styleName           => Number_StyleName
    , styleDataType       => Number_DataType
    , verticalAlignment   => Top_Alignment
    , formatValue         => 'Fixed'
    );

  -- стиль Number0
  addStyle(
      styleName           => Number0_StyleName
    , styleDataType       => Number_DataType
    , verticalAlignment   => Top_Alignment
    , formatValue         => '0'
    );

  -- стиль Percent
  addStyle(
      styleName           => Percent_StyleName
    , styleDataType       => Number_DataType
    , verticalAlignment   => Top_Alignment
    , formatValue         => 'Percent'
    );

  -- стиль DateFull
  addStyle(
      styleName           => DateFull_StyleName
    , styleDataType       => DateTime_DataType
    , verticalAlignment   => Center_Alignment
    , formatValue         => 'dd/mm/yyyy\ hh:mm:ss'
    );

  -- стиль DateShort
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
          'Ошибка при инициализации предустановленных стилей'
          )
      , true
      );

end initPreinstalledStyle;


/* group: Открытые объявления */


/* proc: newDocument
   Инициализация нового документа Excel
*/
procedure newDocument
is
-- newDocument
begin
  -- очистка ресурсов предыдущего документа (если он был сформирован в этой сессии)
  cleanup();
  
  -- инициализация элементов книги Excel
  initElement( cells );
  initElement( rows );
  initElement( worksheets );
  
  -- инициализация стилей
  initPreinstalledStyle();

exception
  when others then
    raise_application_error(
        pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при инициализации нового документа Excel'
          )
      , true
      );

end newDocument;


/* proc: addStyle
  Создает новый стиль для использования в документе Excel

  Параметры:
   
  styleName                 - наименование стиля
  styleDataType             - тип данных стиля (см. константы %_DataType)
  parentStyleName           - наименование родительского стиля (для наследования свойств)
  verticalAlignment         - выравнивание по вертикали
  horizontalAlignment       - выравнивание по горизонтали
  formatValue               - формат значения
  isTextWrapped             - перенос по словам
  fontName                  - наименование шрифта
  fontSize                  - размер шрифта
  isFontBold                - жирный шрифт
  isFontUnderlined          - use underlined font
  borderPosition            - позиция границы ячейки (сумма констант %_BorderPosition)
  interiorColor             - цвет заливки фона
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
     Проверяет корректность входных параметров
  */
  procedure checkInput
  is
  -- checkInput
  begin
    -- наименование стиля
    if vStyleName is null then
      raise_application_error(
        pkg_Error.IllegalArgument
      , 'Не указано наименование стиля.'
      );
    end if;
    -- тип данных стиля
    if vStyleDataType is null then
      raise_application_error(
        pkg_Error.IllegalArgument
      , 'Не указан тип данных стиля.'
      );
    end if;
    -- существование стиля с таким же именем
    if styles.exists(vStyleName) then
      raise_application_error(
        pkg_Error.IllegalArgument
      , 'Стиль с указанным именем уже существует. ' ||
          'Чтобы пересоздать существующий стиль его необходимо сначала удалить.'
      );
    end if;
    -- существование стиля-родителя
    if (
           vParentStyleName is not null
       and not styles.exists(vParentStyleName)
       ) then
      raise_application_error(
        pkg_Error.IllegalArgument
      , 'Указанный стиль-родитель не существует'
      );
    end if;

  exception
    when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при проверке параметров для создания стиля в документе Excel'
        )
      , true
      );

  end checkInput;


  /*
     Возвращает сформированный xml-тэг Alignment
  */
  function getAlignmentTag
  return varchar2
  is
    tag                     TMaxVarchar2;

  -- getAlignmentTag
  begin
    -- формируем xml-тэг только если указан хотя бы один его параметр
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
     Возвращает сформированный xml-тэг Font
  */
  function getFontTag
  return varchar2
  is
    tag                     TMaxVarchar2;

  -- getFontTag
  begin
    -- формируем xml-тэг только если указан хотя бы один его параметр
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
     Возвращает сформированный xml-тэг NumberFormat
  */
  function getNumberFormatTag
  return varchar2
  is
    tag                     TMaxVarchar2;

  -- getNumberFormatTag
  begin
    -- формируем xml-тэг только если указан хотя бы один его параметр
    if vFormatValue is not null then

      tag := '<NumberFormat ss:Format="' || vFormatValue || '"/>';

    else

      tag := null;

    end if;

    return tag;

  end getNumberFormatTag;


  /*
     Возвращает сформированный xml-тэг Borders
  */
  function getBordersTag
  return varchar2
  is
    tag                     TMaxVarchar2;


    /*
       Проверяет, необходимо ли рисовать границу в указанной позиции
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
    -- формируем xml-тэг только если указан хотя бы один его параметр
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
      Возвращает сформированный xml-тэг Interior
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
  -- проверка корректности входных параметров
  checkInput();

  -- создаем новый стиль
  styles(vStyleName).xmlTag :=
    -- наименование стиля
    '<Style ss:ID="' || vStyleName || '"' ||
      -- стиль-родитель
      case
        when vParentStyleName is not null then
          ' ss:Parent="' || vParentStyleName || '"'
      end || '>' ||
      -- выравнивание текста в ячейке
      getAlignmentTag() ||
      -- границы
      getBordersTag() ||
      -- шрифт
      getFontTag() ||
      -- заливка фона
      getInteriorTag() ||
      -- формат значения
      getNumberFormatTag() ||
      '</Style>'
  ;

  -- сохраняем порядковый номер стиля
  styles(vStyleName).styleOrder := styles.count;

  -- сохраняем тип данных стиля
  styles(vStyleName).styleDataType := vStyleDataType;

  -- сохраняем стиль-родитель
  if vParentStyleName is not null then
    styles(vStyleName).parentStyleName := vParentStyleName;
  end if;

exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при добавлении стиля в документ Excel (' ||
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
   Удаляет выбранный стиль

   Параметры:
     styleName - наименование стиля
*/
procedure removeStyle (
  styleName in varchar2
  )
is
  vStyleName TName := trim( styleName );


  /*
     Изменяет порядок стилей
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
        -- сдвигаем список стилей на 1
        styles( styleName ).styleOrder := styles( styleName ).styleOrder - 1;
      end if;
      styleName := styles.next( styleName );
    end loop;
    styleName := null;

  end reorderStyle;


-- removeStyle
begin
  -- проверка на наличие указанного стиля
  if styles.exists( vStyleName ) then

    -- изменяем порядок стилей
    reorderStyle(
      startReorderFrom => styles( vStyleName ).styleOrder
      );
    -- удаляем стиль
    styles.delete( vStyleName );

  end if;

exception
  when others then
    raise_application_error(
        pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при удалении выбранного стиля из документа Excel ( ' ||
            'styleName="' || vStyleName || '"' ||
            ' )'
          )
      , true
      );

end removeStyle;


/* proc: addColumn
   Добавляет колонку в документ Excel

   Параметры:
     columnName   - имя колонки в наборе данных
     columnDesc   - имя колонки в документе Excel
     columnWidth  - ширина колонки
     columnFormat - формат колонки (используются константы %_StyleName)
*/
procedure addColumn (
    columnName   in varchar2
  , columnDesc   in varchar2
  , columnWidth  in pls_integer := null
  , columnFormat in varchar2 := null
  )
is
  vColumnName   TName := upper( columnName );
  -- ширина колонки по умолчанию
  vColumnWidth  pls_integer := coalesce( columnWidth, 0 );
  -- формат колонки по умолчанию
  vColumnFormat TName := coalesce( columnFormat, Default_StyleName );

-- addColumn
begin
  -- добавляем новую колонку
  cols.extend;
  cols( cols.count ).columnDesc   := columnDesc;
  cols( cols.count ).columnWidth  := vColumnWidth;
  cols( cols.count ).columnFormat := vColumnFormat;

  -- сохраняем позицию колонки
  colNames( vColumnName ) := cols.count;

exception
  when others then
    raise_application_error(
        pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка добавления колонки к документу Excel ( ' ||
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
   Очищает список колонок в документе Excel
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
          'Ошибка при очистке списка колонок в документе Excel'
          )
      , true
      );

end clearColumnList;


/* proc: addCell ( varchar2 )
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
  -- индекс ячейки
  vCellIndex   pls_integer := nullif( cellIndex, 0 );
  -- кол-во ячеек для слияния с текущей (по горизонтали)
  vMergeAcross pls_integer := nullif( mergeAcross, 0 );
  -- кол-во ячеек для слияния с текущей (по вертикали)
  vMergeDown pls_integer := nullif( mergeDown, 0 );
  -- тэг данных
  dataTag TName;
  -- тип данных
  dataType TName;
  -- признак необходимости использования тэгов HTML в значении
  isHtmlEnabled boolean;

-- addCell
begin
  -- определение типа данных
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
  -- признак, нужна ли обработка HTML в значении
  isHtmlEnabled := ( useHtmlTag and dataType = String_DataType );
  -- тэг для указания формата данных
  dataTag :=
    case
      when isHtmlEnabled then
        'ss:Data'
      else
        'Data'
    end
  ;
  -- добавляем значение в ячейку
  appendCells(
    '<Cell'
      ||
      -- стиль
      case
        when style is not null then
          ' ss:StyleID="' || style || '"'
      end
      ||
      -- индекс ячейки
      case
        when vCellIndex is not null then
          ' ss:Index="' || to_char( vCellIndex ) || '"'
      end
      ||
      -- сколько слить ячеек по горизонтали
      case
        when vMergeAcross is not null then
          ' ss:MergeAcross="' || to_char( vMergeAcross ) || '"'
      end
      ||
      -- сколько слить ячеек по вертикали
      case
        when vMergeDown is not null then
          ' ss:MergeDown="' || to_char( vMergeDown ) || '"'
      end
      ||
      -- формула
      case
        when formula is not null then
          ' ss:Formula="' || formula || '"'
      end
      || '>'
      ||
      -- значение ячейки
      case
        when cellValue is not null then
          '<' || dataTag
            -- тип данных
            || ' ss:Type="' || dataType || '"'
            ||
            -- xml-тэг для обработки HTML в значении
            case
              when isHtmlEnabled then
                ' xmlns="http://www.w3.org/TR/REC-html40"'
            end
            || '>'
            ||
            -- значение ячейки
            case
              when isHtmlEnabled then
                -- значение без экранирования спецсимволов XML
                cellValue
              else
                -- экранируем спецсимволы XML
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
          'Ошибка при добавлении значения в ячейку Excel ('
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
  -- получаем дату в строковом формате Excel
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
          'Ошибка при добавлении значения ячейки в формате "Дата" ( '
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
  -- определяем формат числа
  if decimalDigit > 0 then
    fmt := 'fm999999999990.' || rpad( '0', decimalDigit, '0' );
  end if;

  -- получаем число в строковом формате Excel
  vCellValue := case
                  when decimalDigit is null then
                    replace( to_char( cellValue ), ',', '.' )
                  when decimalDigit > 0 then
                    to_char( round( cellValue, decimalDigit ), fmt )
                  when decimalDigit = 0 then
                    to_char( round( cellValue, decimalDigit ) )
                end
  ;

  -- добавляем значение
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
          'Ошибка при добавлении значения ячейки в формате "Число" ('
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
   Добавляет значение ячейки Excel в формате "строка". Стиль ячейки определяется
   по имени колонки в документе. Вызывает <addCell ( varchar2 )>.

   Параметры:
     columnName                - имя колонки документа
     cellValue                 - значение ячейки
     cellIndex                 - порядковый номер ячейки в строке
     mergeAcross               - кол-во ячеек для слияния с текущей (по горизонтали)
     mergeDown                 - кол-во ячеек для слияния с текущей (по вертикали)
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
  -- добавляем значение ячейки
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
          'Ошибка при добавлении значения ячейки Excel по имени колонки документа ('
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
   Добавляет значение ячейки Excel в формате "дата". Стиль ячейки определяется
   по имени колонки документа. Вызывает <addCell ( date )>.

   Параметры:
     columnName                - наименование колонки документа
     cellValue                 - значение ячейки в формате "дата"
     isDateTime                - значение в формате дата + время ? (true-да, false-нет)
     cellIndex                 - порядковый номер ячейки в строке
     mergeAcross               - кол-во ячеек для слияния с текущей (по горизонтали)
     mergeDown                 - кол-во ячеек для слияния с текущей (по вертикали)
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
  -- добавляем значение ячейки
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
          'Ошибка при добавлении значения ячейки Excel по имени колонки документа ( '
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
   Добавляет значение ячейки Excel в формате "число". Стиль ячейки определяется
   по имени колонки документа. Вызывает <addCell ( number )>.

   Параметры:
     columnName                - наименование колонки документа
     cellValue                 - значение ячейки в формате "число"
     decimalDigit              - кол-во десятичных знаков (см. <addCell ( number )>)
     cellIndex                 - порядковый номер ячейки в строке
     mergeAcross               - кол-во ячеек для слияния с текущей (по горизонтали)
     mergeDown                 - кол-во ячеек для слияния с текущей (по вертикали)
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
  -- добавляем значение ячейки
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
          'Ошибка при добавлении значения ячейки Excel по имени колонки документа ('
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
     Формирует формулу автосуммирования
  */
  function getAutoSumFormula
  return varchar2
  is
    -- шаблон формулы
    formula varchar2(100) :=
      '=SUM(R[-$(rangeEndNumber)]C:R[-$(rangeStartNumber)]C)'
    ;

    -- номер текущей строки на листе Excel
    currentRowNumber pls_integer := rowNumber + 1;

    -- первая строка диапазона суммирования
    vRangeFirstRow pls_integer;
    -- последняя строка диапазона суммирования
    vRangeLastRow pls_integer;

    -- начало диапазона суммирования (в терминах Excel)
    rangeStartNumber pls_integer;
    -- окончание диапазона суммирования (в терминах Excel)
    rangeEndNumber pls_integer;

  -- getAutoSumFormula
  begin
    -- расчет номера первой строки диапазона суммирования
    vRangeFirstRow :=
      coalesce( nullif( rangeFirstRow, 0 ), nullif( headerRowNumber, 0 ) + 1, 1 )
    ;
    -- расчет номера последней строки диапазона суммирования
    vRangeLastRow :=
      coalesce( nullif( rangeLastRow, 0 ), currentRowNumber - 1, 1 )
    ;

    -- определение начала диапазона
    rangeStartNumber := currentRowNumber - vRangeLastRow;
    -- определение окончания диапазона
    rangeEndNumber := currentRowNumber - vRangeFirstRow;

    -- подставляем диапазон суммирования в формулу
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
  -- добавляем значение ячейки
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
          'Ошибка при добавлении автосуммы на лист Excel ('
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
  -- добавляем значение ячейки
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
          'Ошибка при добавлении автосуммы в ячейку Excel по имени колонки ('
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
   Добавляет строку. Вызывается после того, как сформированы все ячейки,
   которые должны быть в строке

   Параметры:
     autoFitHeight - автоподбор высоты строки

   Примечание: после того, как создано нужное кол-во строк необходимо
               вызвать addWorksheet для переноса сформированных строк на
               лист Excel
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
   Формирует названия колонок документа на листе Excel
   
   Параметры:
     style                     - стиль (см. константы %_StyleName)
*/
procedure addHeaderRow (
  style in varchar2 := null
  )
is
-- addHeaderRow
begin
  -- проверяем, что добавлена хотя бы одна колонка
  if cols.count = 0 then
    raise_application_error(
        pkg_Error.IllegalArgument
      , 'В документе отсутствуют колонки. Используйте addColumn() для добавления колонок.'
      );
  end if;

  -- формируем список колонок документа
  for i in 1..cols.count loop
    addCell( cols(i).columnDesc, coalesce( style, Header_StyleName ) );
  end loop;
  addRow();

  -- сохраняем номер строки заголовка на текущем листе Excel
  headerRowNumber := rowNumber;

exception
  when others then
    raise_application_error(
        pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при формировании списка колонок документа на листе Excel ('
            || ' style="' || style || '"'
            || ').'
          )
      , true
      );

end addHeaderRow;


/* proc: setColumnWidth
   Устанавливает ширину колонок документа на листе Excel
*/
procedure setColumnWidth
is
-- setColumnWidth
begin
  -- проверяем, что добавлена хотя бы одна колонка
  if cols.count = 0 then
    raise_application_error(
        pkg_Error.IllegalArgument
      , 'В документе отсутствуют колонки. Используйте addColumn() для добавления колонок.'
      );
  end if;

  -- устанавливаем ширину колонок
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
          'Ошибка при установке длины колонок документа на листе Excel'
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
  -- начальные тэги xml для формирования листа (до данных)
  Template_Header           constant varchar2(4000) := '<Worksheet ss:Name="$(sheetName)">';
  -- автофильтр
  Template_AutoFilter       constant varchar2(4000) := '<AutoFilter x:Range="$(range)" xmlns="urn:schemas-microsoft-com:office:excel"/>';
  -- конечные тэги xml (после данных)
  Template_Footer           constant varchar2(4000) := '</Worksheet>';

-- addWorksheet
begin
  -- открываем лист
  appendWorksheets(
    replace(Template_Header, '$(sheetName)', sheetName)
  );
  
  -- добавление строк
  appendWorksheets('<Table>');
  moveRows();
  appendWorksheets('</Table>');

  -- формируем строку-автофильтр
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

  -- закрываем лист
  appendWorksheets(Template_Footer);

  -- устанавливаем текущий лист
  sheetNumber := sheetNumber + 1;
  -- очищаем кол-во строк на текущем листе
  rowNumber := 0;

exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при добавлении листа Excel (' ||
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
   Формирует документ. Вызывается после того, как сформированы все листы в Excel

   Параметры:
     encoding - кодировка документа (см. константы %_DocumentEncoding)
*/
procedure prepareDocument (
  encoding in varchar2
  )
is
  -- кодировка документа Excel
  vEncoding TName := trim( encoding );

  -- залоговок xml-документа
  header varchar2(4000) := '<?xml version="1.0" encoding="$(encoding)"?>
<?mso-application progid="Excel.Sheet"?>
<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"
  xmlns:o="urn:schemas-microsoft-com:office:office"
  xmlns:x="urn:schemas-microsoft-com:office:excel"
  xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
  xmlns:html="http://www.w3.org/TR/REC-html40">';

  -- закрывающий тэг xml-файла
  footer varchar2(50) := '</Workbook>';


  /*
     Проверяет корректность входных параметров
  */
  procedure checkInput
  is
  -- checkInput
  begin
    -- проверка на сформированный ранее документ
    if isDocumentPrepared then
      raise_application_error(
          pkg_Error.IllegalArgument
        , 'В текущей сессии ранее уже был сформирован документ. ' ||
            'Для генерации нового документа предварительно нужно вызвать newDocument().'
        );
    end if;
    -- проверка кодировки
    if vEncoding is null then
      raise_application_error(
          pkg_Error.IllegalArgument
        , 'Не указана кодировка документа Excel для генерации'
        );
    end if;

  exception
    when others then
      raise_application_error(
          pkg_Error.ErrorStackInfo
        , logger.errorStack(
            'Ошибка при проверке входных параметров при генерации документа Excel'
            )
        , true
        );

  end checkInput;


  /*
     Добавляет секцию Styles со списком стилей в определенном порядке в документ
     Excel
  */
  procedure appendOrderedStyle
  is
    -- наименование стиля
    styleName TName;

    -- тип для определения порядка добавления стилей
    type TColStyleOrder is table of TName
      index by pls_integer
    ;
    colStyleOrder TColStyleOrder;

  -- appendOrderedStyle
  begin
    -- начало секции стилей
    pkg_TextCreate.append( '<Styles>' );

    -- переопределяем порядок стилей
    colStyleOrder.delete;
    styleName := styles.first();
    while styleName is not null loop
      colStyleOrder( styles( styleName ).styleOrder ) := styleName;
      styleName := styles.next( styleName );
    end loop;
    styleName := null;

    -- формируем список стилей в рассчитанном порядке
    for i in colStyleOrder.first..colStyleOrder.last loop
      if colStyleOrder.exists(i) then
        pkg_TextCreate.append( styles( colStyleOrder(i) ).xmlTag );
      end if;
    end loop;

    -- конец секции стилей
    pkg_TextCreate.append( '</Styles>' );

  exception
    when others then
      raise_application_error(
          pkg_Error.ErrorStackInfo
        , logger.errorStack(
            'Ошибка при формировании списка стилей в документе Excel'
            )
        , true
        );

  end appendOrderedStyle;


-- prepareDocument
begin
  -- проверка корректности входных параметров
  checkInput();

  -- инициализируем новый текстовый файл
  pkg_TextCreate.newText();

  -- добавляем заголовок
  pkg_TextCreate.append(
    replace( header, '$(encoding)', vEncoding )
    );

  -- добавляем стили
  appendOrderedStyle();

  -- если данные отсутствуют, то добавляем пустые тэги для обеспечения
  -- корректности формата xml файла
  if dbms_lob.getLength( worksheets ) = 0 then
    addWorksheet( 'Sheet1', false );
  end if;
  
  -- добавляем листы
  moveWorksheets();

  -- добавляем закрывающий тэг
  pkg_TextCreate.append( footer );

  -- устанавливаем текущий лист
  sheetNumber := 1;

  -- устанавливаем признак, что документ подготовлен
  isDocumentPrepared := true;

exception
  when others then
    raise_application_error(
        pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при формировании документа Excel ('
            || ' encoding="' || encoding || '"'
            || ').'
          )
      , true
      );

end prepareDocument;


/* func: getDocument
   Возвращает сформированный документ Excel в виде CLOB

   Возврат:
     - файл в виде CLOB
*/
function getDocument
return clob
is
-- getDocument
begin
  -- если документ ещё не сформирован - сообщаем об этом
  if not isDocumentPrepared then
    raise_application_error(
        pkg_Error.IllegalArgument
      , 'В текущей сессии документ ещё не сформирован. Пожалуйста, используйте ' ||
          'prepareDocument() для генерации документа'
      );
  end if;

  -- возвращаем сформированный документ
  return pkg_TextCreate.getClob();

exception
  when others then
    raise_application_error(
        pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при получении сформированного документа Excel в виде CLOB'
          )
      , true
      );

end getDocument;


/* func: getArchivedDocument
   Возвращает заархивированный в .zip документ Excel в виде BLOB

   Параметры:
     fileName - имя файла документа в архиве

   Возврат:
     - файл в виде BLOB
*/
function getArchivedDocument (
  fileName in varchar2
  )
return blob
is
-- getArchivedDocument
begin
  -- если документ ещё не сформирован - сообщаем об этом
  if not isDocumentPrepared then
    raise_application_error(
        pkg_Error.IllegalArgument
      , 'В текущей сессии документ ещё не сформирован. Пожалуйста, используйте ' ||
          'prepareDocument() для генерации документа'
      );
  end if;

  -- возвращаем сформированный архив
  return pkg_TextCreate.getZip( fileName  );

exception
  when others then
    raise_application_error(
        pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при получении заархивированного в .zip документа Excel в виде BLOB ( ' ||
            'fileName="' || fileName || '"' ||
            ' )'
          )
      , true
      );

end getArchivedDocument;


/* func: getRowCount
   Возвращает кол-во строк на текущем листе Excel

   Возврат:
     - кол-во строк на листе
*/
function getRowCount
return pls_integer
is
-- getRowCount
begin

  return rowNumber;

end getRowCount;


/* func: getCurrentSheetNumber
   Возвращает номер текущего листа Excel

   Возврат:
     - номер листа
*/
function getCurrentSheetNumber
return pls_integer
is
-- getCurrentSheetNumber
begin

  return sheetNumber;

end getCurrentSheetNumber;


begin
  -- инициализация нового документа
  newDocument();

end pkg_ExcelCreate;
/
