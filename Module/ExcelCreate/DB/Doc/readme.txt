title: Описание

group: Общее описание

Модуль предназначен для формирования документов в формате xml, который читается
Excel'ем



group: Инструкция по использованию pkg_ExcelCreate

1) Инициализация функционала <pkg_ExcelCreate>:

<pkg_ExcelCreate.newDocument>: подготавливает функционал для генерации нового
документа.

(code)

pkg_ExcelCreate.newDocument();

(end)

2) Добавление стилей:

<pkg_ExcelCreate.addStyle>: добавляет новый стиль для использования в документе
Excel

При создании нового документа Excel автоматически инициализируются несколько
предустановленных стилей: *Default*, *Header*, *General*, *Number*, *Number0*,
*Percent*, *DateFull*, *DateShort*, *Text*
(см. <pkg_ExcelCreate::body::initPreinstalledStyle>). При необходимости можно
создать свой стиль на основе существующего (при указании параметра parentStyleName и
списка параметров, значения которых нужно определить / переопределить), либо
можно создать свой стиль с нуля (т.е. без указания parentStyleName) с помощью
указания значений параметров, которые будет содержать новый стиль.

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

Удалить добавленный или предустановленный стиль можно с помощью процедуры
<pkg_ExcelCreate.removeStyle>.

(code)

pkg_ExcelCreate.removeStyle( 'Default_ArialCyr10_Border' );

(end)

3) Генерация списка колонок, которые будет содержать документ:

<pkg_ExcelCreate.addColumn>: добавляет колонку в документ Excel

(code)

pkg_ExcelCreate.addColumn(
  'application_id', 'Идентификатор анкеты', 130, pkg_ExcelCreate.Number0_StyleName
  );
pkg_ExcelCreate.addColumn(
  'application_date', 'Дата создания анкеты', 100, pkg_ExcelCreate.DateFull_StyleName
  );

(end)

4) Установка ширины колонок на листе Excel:

<pkg_ExcelCreate.setColumnWidth>: формирует xml тэги, устанавливающие ширину
колонок на листе. Использует сгенерированный на шаге 2 список колонок.

(code)

pkg_ExcelCreate.setColumnWidth();

(end)

5) Генерация заголовка в документе:

<pkg_ExcelCreate.addHeaderRow>: переносит сформированный список колонок на
шаге 2 на лист Excel. Если есть необходимость добавить некоторую информацию перед
заголовком (например, список параметров, название отчета, информацию по
использованию и т.п.), то для этого нужно использовать процедуры
<pkg_ExcelCreate.addCell> и <pkg_ExcelCreate.addRow> (см. ниже)

(code)

pkg_ExcelCreate.addHeaderRow();

(end)

6) Добавление данных в ячейку:

_pkg_ExcelCreate.addCell_:
Добавление значения в очередную ячейку текущей строки

Перегруженные варианты процедуры:
  - <pkg_ExcelCreate.addCell ( varchar2 )> - добавление значения типа "строка"
  - <pkg_ExcelCreate.addCell ( number )>   - добавление значения типа "число"
  - <pkg_ExcelCreate.addCell ( date )>     - добавление значения типа "дата"

(code)

pkg_ExcelCreate.addCell( 'Дата формирования:' );
pkg_ExcelCreate.addCell(
  sysdate, true, pkg_ExcelCreate.DateFull_StyleName
  );

(end)

_pkg_ExcelCreate.addCellByName_:
Добавление значения в очередную ячейку текущей строки. Стиль ячейки определяется
по имени колонки документа (см. шаг 2)

Перегруженные варианты процедуры:
  - <pkg_ExcelCreate.addCellByName ( varchar2 )> - добавление значения типа "строка"
  - <pkg_ExcelCreate.addCellByName ( number )>   - добавление значения типа "число"
  - <pkg_ExcelCreate.addCellByName ( date )>     - добавление значения типа "дата"

(code)

pkg_ExcelCreate.addCellByName(
  'application_id', applicationId
  );

(end)

'application_id' - имя колонки документа. _Должно соответствовать имени колонки,
данной ей на шаге 2 без учета регистра_.
applicationId - переменная типа integer.

Примечание:

При использовании *addCell* и *addCellByName* нет необходимости указывать конкретные
варианты процедур с помощью именованных параметров - необходимый вариант перегруженной
процедуры будет выбран автоматически на основе типа используемых данных

Добавление значений в ячейку по её номеру:

Для добавления значения в ячейку, которая не является первой в строке, необходимо
указать её порядковый номер.

(code)

pkg_ExcelCreate.addCellByName(
  'application_id', applicationId, cellIndex => 4
  );

(end)

Слияние ячеек:

Для слияния ячеек при добавлении значения необходимо задать значение параметра
_mergeAcross_ (для слияния по горизонтали) и _mergeDown_ (для слияния по вертикали)
в виде кол-ва последующих ячеек, которые будут слиты с текущей.

(code)

pkg_ExcelCreate.addCellByName(
  'application_id', applicationId, mergeAcross => 1
  );
...
pkg_ExcelCreate.addCellByName(
  'application_id', applicationId, mergeDown => 1
  );

(end)

7) Создание итоговых автосумм:

При создании строки с итогами можно использовать процедуры:
  - <pkg_ExcelCreate.addAutoSum> - добавляет автосумму в очередную ячейку.
  - <pkg_ExcelCreate.addAutoSumByName> - добавляет автосумму в очередную ячейку.
    Стиль ячейки определяется по имени колонки документа (см. шаг 2)

Если диапазон для расчета суммы не указан в явном виде, то он определяется
автоматически на основе следующей информации:
  - если документ содержит заголовок, то берется диапазон со следующей строки
    после заголовка и до строки, предшествующей строке с итогами
  - если документ не содержит заголовок, то берется диапазон с первой строки
    документа до строки, предшествующей строке с итогами

(code)

pkg_ExcelCreate.addAutoSumByName( 'interest_amount' );
...
pkg_ExcelCreate.addAutoSumByName( 'interest_amount', cellIndex => 2 );
...
pkg_ExcelCreate.addAutoSumByName( 'interest_amount', rangeFirstRow => 1, rangeLastRow => 10 );

(end)

8) Перенос ячеек в строку:

<pkg_ExcelCreate.addRow>: переносит сформированные ячейки на шаге 5 в строку.
Ячейки в строке будут находится в том же порядке, в котором они добавлялись.

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

9) Перенос сформированных строк на лист Excel:

<pkg_ExcelCreate.addWorksheet>: переносит сформированные строки на шаге 6 на
лист Excel. Строки будут находится в том же порядке, в котором они добавлялись.

При необходимости можно динамически генерировать новый лист Excel, если было
добавлено определенное количество строк. Это позволит ограничить количество строк
на каждом листе Excel.

(code)

pkg_ExcelCreate.addWorksheet(
    sheetName     => 'Test123'
  , addAutoFilter => true
  );

(end)

10) Создание нескольких листов с разным набором колонок:

При необходимости можно сгенерировать несколько листов документа Excel, каждый
из которых будет содержать разный набор колонок. Для этого перед генерацией
каждого листа (после первого) нужно вызывать процедуру
<pkg_ExcelCreate.clearColumnList> для очистки текущего списка колонок и затем
выполнять пункты 3-8 для создания очередного листа.

11) Генерация итогового документа:

<pkg_ExcelCreate.prepareDocument>: на основе добавленных листов Excel
формирует книгу Excel. Результатирующий документ можно получить в виде clob
(<pkg_ExcelCreate.getDocument>) или в заархивированном .zip формате (blob)
(<pkg_ExcelCreate.getArchivedDocument>) и сохранить его в таблице БД

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
