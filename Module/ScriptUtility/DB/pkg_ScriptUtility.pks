create or replace package pkg_ScriptUtility as
/* package: pkg_ScriptUtility
  Различные вспомогательные функции, используемые при разработке.

  SVN root: Oracle/Module/ScriptUtility
*/



/* group: Функции */

/* pproc: deleteComments
 Удаляем комментарии из скрипта

  ( <body::deleteComments>)
*/
function deleteComments(
  text in clob
)
return clob;

/* pproc: makeColumnList
  Выводит список колонок таблицы.

  ( <body::makeColumnList>)
*/
procedure makeColumnList(
  tableName varchar2
  , prefix varchar2 := ', '
  , postFix varchar2 := ''
  , lastPostFix varchar2 := ''
  , withDataType boolean := false
  , trimVarchar boolean := false
  , letterCase integer := 1
  , duplicateWithAs boolean := false
  , inQuotas boolean := false
  , eraseUnderline boolean := false
);

/* pproc: generateInsertFake
  Генерация скрипта по добавлению fake-данных в таблицу.

  Параметры:
  tableName                   - имя таблицы
  owner                       - имя пользователя ( по-умолчанию, текущий)

  ( <body::generateInsertFake>)
*/
procedure generateInsertFake(
  tableName varchar2
  , owner varchar2 := null
);

/* pproc: tableDefinition
  Получает определение таблицы

  ( <body::tableDefinition>)
*/
procedure tableDefinition(
  tableName varchar2
  , sourceDbLink varchar2
  , sourceUser varchar2
);

/* pfunc: getColumnDefinition(type)
  Возвращает строку объявления типа колонки в таблице

  Параметры
     DataType -  соответствует Data_Type из all_tab_cols
     DataPrecision -  соответствует Data_Precision из all_tab_cols
     DataScale - соответствует Data_Scale из all_tab_cols
     DataLength - соответствует Data_Length из all_tab_cols
     CharLength - соответствует Char_Length из all_tab_cols

  ( <body::getColumnDefinition(type)>)
*/
function getColumnDefinition(
  dataType all_tab_cols.Data_Type%type
  , dataPrecision all_tab_cols.Data_Precision%type
  , dataScale  all_tab_cols.Data_Scale%type
  , dataLength  all_tab_cols.Data_Length%type
  , charLength  all_tab_cols.Char_Length%type
) return varchar2;

/* pfunc: getColumnDefinition(table)
  Возвращает строку объявления типа колонки в таблице.

  Параметры:
    tableName - имя таблицы
    columnName - имя колонки

  Возврат:
  - определение типа колонки

  ( <body::getColumnDefinition(table)>)
*/
function getColumnDefinition(
  tableName varchar2
  , columnName varchar2
  , raiseWhenNoDataFound integer := null
)
return varchar2;

/* pproc: generateApi
  Генерация body пакета API для таблицы.

  Параметры:
  ignoreColumnList            - список игнорируемых колонок через ","

  ( <body::generateApi>)
*/
procedure generateApi(
  tableName varchar2
  , entityNameObjectiveCase varchar2
  , ignoreColumnList varchar2 := null
);

/* pproc: generateHistoryStructure
  Генерация файлов исторической структуры

  outputType                 - тип вывода в dbms_output.
                               null-не выводить информацию
                               1-реализация процедур
                               2-спецификация процедур
                               3-удаление последовательностей
                               4-удаление представлений

  ( <body::generateHistoryStructure>)
*/
procedure generateHistoryStructure(
  tableName varchar2
  , outputFilePath varchar2
  , moduleName varchar2
  , tableComment varchar2
  , svnRoot varchar2
  , abbrFrom varchar2 := null
  , abbrTo varchar2 := null
  , abbrFrom2 varchar2 := null
  , abbrTo2 varchar2 := null
  , historyProcedureName varchar2:= null
  , outputType integer := null
);



/* group: Интерфейсные таблицы ( модуль Oracle/Module/DataSync) */

/* pproc: generateInterfaceTable
  Генерация скриптов создания интерфейсных таблиц по представлениям с
  исходными данными.

  Параметры:
  outputFilePath              - путь к каталогу для создаваемых файлов
  objectPrefix                - префикс объектов модуля ( должен указываться,
                                если не задано значение параметра viewName)
  viewName                    - исходное представление
                                ( маска для like с символом экранирования "\",
                                по умолчанию все представления согласно
                                префиксу объектов модуля)
  tableName                   - имя интерфейсной таблицы ( может использоваться
                                только если обрабатывается одно исходное
                                представление, по умолчанию на основе имени
                                исходного представления)

  Замечания:
  - при генерации для интерфейсной таблицы создается первичный ключ по
    первому полю ( если это не так, нужно вручную уточнить скрипт);
  - комментарий для интерфейсной таблицы берется из комментария к исходному
    представлению с удалением строки "( исходные данные)", расположенной
    перед частью с SVN root, т.е. подразумевается наличие у исходного
    преставления комментария вида:
    "<Описание данных таблицы> ( исходные данные) [ SVN root: <moduleSvnRoot>]"
  - в случае, если в таблице присутствует поле типа rowid с именем
    "int_%_rid", то для него создается индекс;

  ( <body::generateInterfaceTable>)
*/
procedure generateInterfaceTable(
  outputFilePath varchar2
  , objectPrefix varchar2 := null
  , viewName varchar2 := null
  , tableName varchar2 := null
);

/* pproc: generateInterfaceTempTable
  Генерация скриптов создания временных таблицы для обновления интерфейсных
  таблиц по представлениям с исходными данными.

  Параметры:
  outputFilePath              - путь к каталогу для создаваемых файлов
  objectPrefix                - префикс объектов модуля ( должен указываться,
                                если не задано значение параметра viewName)
  viewName                    - исходное представление
                                ( маска для like с символом экранирования "\",
                                по умолчанию все представления согласно
                                префиксу объектов модуля)
  tableName                   - имя таблицы ( может использоваться
                                только если обрабатывается одно исходное
                                представление, по умолчанию на основе имени
                                исходного представления)

  Замечания:
  - при генерации для таблицы создается первичный ключ по первому полю ( если
    это не так, нужно вручную уточнить скрипт);
  - комментарий для интерфейсной таблицы берется из комментария к исходному
    представлению с удалением строки "( исходные данные)", расположенной
    перед частью с SVN root, и добавлением вместо нее строки
    "( временная таблица для обновления данных), т.е. подразумевается наличие
    у исходного преставления комментария вида:
    "<Описание данных таблицы> ( исходные данные) [ SVN root: <moduleSvnRoot>]"

  ( <body::generateInterfaceTempTable>)
*/
procedure generateInterfaceTempTable(
  outputFilePath varchar2
  , objectPrefix varchar2 := null
  , viewName varchar2 := null
  , tableName varchar2 := null
);

end;
/
