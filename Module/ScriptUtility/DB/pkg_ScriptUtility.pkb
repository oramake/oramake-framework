create or replace package body pkg_ScriptUtility as
/* package body: pkg_ScriptUtility::body */



/* group: Константы */

/* iconst: ExecSql_Char
  Символ, обеспечивающий выполнение команды из буфера SQL в SQL*Plus.
  Явное присутствие в строковых литералах указанного символа ( с новой строки
  в отдельной строке) может приводить к ошибке при загрузке исходника пакета
  через SQL*Plus вида
  'SP2-0734: unknown command beginning "..." - rest of line ignored.'
*/
ExecSql_Char constant varchar2(1) := '/';

/* iconst: NDoc_Char
  Символ-разделитель, используемый в системе генерации автодокументации
  Natural Docs для разделения типа элемента и его названия.
  Явное указание символа в литералах с частями генерируемого кода может
  привести к некорректной генерации автодокументации по пакету
  pkg_ScriptUtility либо ошибкам при генерации спецификаци по телу пакета
  в редакторе Vim ( командой SpecGen).
*/
NDoc_Char constant varchar2(1) := ':';

/* iconst: SvnRoot_BeginComment
  Начало части комментария, содержащего путь к корневому каталогу модуля в SVN.
*/
SvnRoot_BeginComment constant varchar2(30) := ' [ SVN root: ';



/* group: Переменные */

/* ivar: logger
  Интерфейсный объект к модулю Logging
*/
  logger lg_logger_t := lg_logger_t.GetLogger(
    moduleName => 'ScriptUtility'
    , objectName => 'pkg_ScriptUtility'
  );

/* iconst: Date_DataTypeName
  Имя типа даты.
*/
Date_DataTypeName constant varchar2(30) := 'DATE';

/* iconst: Char_DataTypeName
  Имя типа char.
*/
Char_DataTypeName constant varchar2(30) := 'CHAR';

/* iconst: Number_DataTypeName
  Имя типа number.
*/
Number_DataTypeName constant varchar2(30) := 'NUMBER';

/* iconst: Varchar2_DataTypeName
  Имя типа varchar2.
*/
Varchar2_DataTypeName constant varchar2(30) := 'VARCHAR2';



/* group: Функции */

/* iproc: outputText
  Вывод текста генерации.

  Параметры:
  textString                 - текст для вывода
*/
procedure outputText(
  textString varchar2
)
is
-- outputText
begin
  pkg_Common.outputMessage( textString);
end outputText;

/* iproc: append
  Добавляет текст, дополненный переводом строки, в буфер для вывода в файл.
  При добавлении вместо Unix-перевода строки использует Dos-перевод строки.

  Параметры:
  str                         - текст для вывода в файл
*/
procedure append(
  str varchar2
)
is
begin
  pkg_File.appendUnloadData(
    replace( str || chr(10), chr(10), chr(13) || chr(10))
  );
end append;

/* proc: deleteComments
 Удаляем комментарии из скрипта
*/
function deleteComments(
  text in clob
)
return clob
is
begin
  raise_application_error(
    pkg_Error.PROCESSERROR
    , 'Not implemented'
  );
end deleteComments;

/* proc: makeColumnList
  Выводит список колонок таблицы.
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
)
is
                                       -- Временная переменная
  columnName all_tab_cols.column_name%type;
  letterCasedColumnName all_tab_cols.column_name%type;
begin
  for c in (
    select lower( a.column_name ) as column_name,
           last_value( lower( a.column_name ) ) over(
             order by a.column_id range between
             unbounded preceding and unbounded following
           ) last_column,
           a.data_type,
           a.data_length,
           a.data_precision,
           a.data_scale,
           a.char_length
      from all_tab_cols a
     where a.owner = user
           and a.table_name = upper( tableName )
     order by a.column_id
    )
  loop
    letterCasedColumnName :=
      case
        when letterCase = 0 then
          c.column_name
        when letterCase = 1 then
          lower( c.column_name )
        when letterCase = 2 then
          upper( c.column_name )
        when letterCase = 3 then
          initcap( c.column_name )
      end;
    columnName :=
      case when eraseUnderline
        then
          lower( substr( letterCasedColumnName, 1, 1))
          || replace( substr( initCap( letterCasedColumnName), 2), '_' , '' )
        else
          letterCasedColumnName
      end;
    outputText(
      prefix
      || case
           when inQuotas then ''''
         end
      || case when ( c.Data_Type = Varchar2_DataTypeName or c.Data_Type = 'CHAR' and c.Data_Length > 0 )
                   and trimVarchar then
              'trim( ' ||columnName || ')'
              else columnName
         end

      ||
      case when duplicateWithAs
        then ' as ' || letterCasedColumnName
      end
      || case
           when inQuotas then ''''
         end
      || (case when c.last_column <> c.column_name then postFix else
            coalesce( lastPostFix, postFix)
          end)
      ||
      case when WithDataType then
        GetColumnDefinition(
          dataType          => c.Data_Type
          , dataPrecision   => c.Data_Precision
          , dataScale       => c.Data_Scale
          , dataLength      => c.Data_Length
          , charLength      => c.Char_Length
        )
        else ''
      end
    );
  end loop;
end makeColumnList;

/* proc: generateInsertFake
  Генерация скрипта по добавлению fake-данных в таблицу.

  Параметры:
  tableName                   - имя таблицы
  owner                       - имя пользователя ( по-умолчанию, текущий)
*/
procedure generateInsertFake(
  tableName varchar2
  , owner varchar2 := null
)
is

  Ident_Text constant varchar2(32767) := '  ';

  NewLine_Text constant varchar2(32767) := chr(10);

  Delimiter_Text constant varchar2(32767) := ', ';

  -- Первая ли колонка
  firstColumnFlag boolean := true;

  -- Список значений колонок в выражении
  valueListText varchar2(32767);

  -- Список колонок
  columnListText varchar2(32767);

  -- Курсор для получения информации о колонках
  cursor columnCur is
select
  lower( column_name) as column_name
  , c.column_id
  , c.data_type
  , c.data_length
  , c.data_precision
from
  all_tab_cols c
where
  table_name = upper( tableName)
  and owner = coalesce( upper( generateInsertFake.owner), user)
order by
  column_id
  ;

  /*
    Получение текста sql fake-значения для колонки.
  */
  function getFakeValueText(
    columnName varchar2
    , columnNumber integer
    , dataType varchar2
    , dataLength integer
    , dataPrecision integer
  )
  return varchar2
  is
    Date_Mask constant varchar2(100) := 'dd.mm.yyyy hh24:mi:ss';

    -- Текст sql для значения
    columnValueText varchar2(32767);
  begin
    if
      dataType in ( Varchar2_DataTypeName, Char_DataTypeName)
    then
      return
        '''' || substr( columnName, 1, dataLength) || ''''
      ;
    elsif
      dataType = Number_DataTypeName
    then
      if dataPrecision = 1 then
        return
          1
        ;
      else
        return
          columnNumber
        ;
      end if;
    elsif
      dataType = Date_DataTypeName
    then
      return
        'to_date( '''
        || to_char( sysdate + columnNumber, Date_Mask)
        || ''', ''' || Date_Mask
        || ''')'
      ;
    else
      raise_application_error(
        pkg_Error.IllegalArgument
        , 'Неизвестный тип ( ' || dataType || ')'
      );
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка получения fake-значения колонки'
        )
      , true
    );
  end getFakeValueText;

-- generateInsertFake
begin
  for columnData in columnCur loop
    if not firstColumnFlag then
      columnListText :=
        columnListText || NewLine_Text
      ;
      valueListText :=
        valueListText || NewLine_Text
      ;
    end if;
    if
      (
        columnData.data_type = Varchar2_DataTypeName
        -- Имя поля не вмещается в строку значения
        and length( columnData.column_name) > columnData.data_length
      )
      or
      columnData.data_type <> Varchar2_DataTypeName
    then
      valueListText :=
        valueListText || Ident_Text || '-- ' || columnData.column_name
        || NewLine_Text
      ;
    end if;
    valueListText := valueListText || Ident_Text;
    columnListText := columnListText || Ident_Text;
    if not firstColumnFlag then
      columnListText :=
        columnListText || Delimiter_Text;
      valueListText :=
        valueListText || Delimiter_Text;
    end if;
    columnListText :=
      columnListText || columnData.column_name
    ;
    valueListText := valueListText
      || getFakeValueText(
           columnName => columnData.column_name
           , columnNumber => columnData.column_id
           , dataType => columnData.data_type
           , dataLength => columnData.data_length
           , dataPrecision => columnData.data_precision
         )
    ;
    if firstColumnFlag then
      firstColumnFlag := false;
    end if;
  end loop;
  outputText(
'insert into ' || lower( tableName) || '(
' || columnListText || '
)
values (
' || valueListText || '
);'
  );
end generateInsertFake;

/* proc: tableDefinition
  Получает определение таблицы
*/
procedure tableDefinition(
  tableName varchar2
  , sourceDbLink varchar2
  , sourceUser varchar2
)
is
  linkPostfix varchar2(100):=
    case when sourceDbLink is not null then '@' || sourceDbLink end;
                                       -- Данные колонки
  subtype typOracleIdentifier is varchar2(30);
                                       -- Текст sql
  sqlText varchar2(32767):=
  '
select
  lower( a.column_name ) as column_name
  ,
  last_value( lower( a.column_name ) ) over(
    order by a.column_id range between
    unbounded preceding and unbounded following
  ) as last_column
  , a.data_type
  , a.data_length
  , a.data_precision
  , a.data_scale
  , a.char_length
from
  all_tab_cols' || linkPostfix || ' a
where
  a.owner = upper( :sourceUser)
  and a.table_name = upper( :tableName )
order by
  a.column_id
  ';
  pkSqlText varchar2(32767):=
  '
select
  lower( a.column_name) as column_name
  ,
  last_value( lower( a.column_name ) ) over(
    order by a.column_id range between
    unbounded preceding and unbounded following
  ) as last_column
  , c.constraint_name as constraint_name
from
  all_constraints' || linkPostfix || ' c
  , all_cons_columns' || linkPostfix || ' cc
  , all_tab_cols' || linkPostfix || ' a
where
  c.owner = upper( :sourceUser)
  and c.table_name = upper( :tableName)
  and c.constraint_type = ''P''
  and cc.constraint_name = c.constraint_name
  and cc.owner = c.owner
  and a.owner = upper( :sourceUser)
  and a.table_name =  upper( :tableName)
  and a.column_name = cc.column_name
order by
  a.column_id
  ';


  procedure ColumnDefinition
  is
  -- Скрипт для колонок таблицы
    curColumn sys_refcursor;
    columnName typOracleIdentifier;
    dataType typOracleIdentifier;
    dataLength integer;
    dataPrecision integer;
    dataScale integer;
    charLength integer;
    lastColumnName typOracleIdentifier;
  begin
    open
      curColumn
    for
      sqlText
    using
      sourceUser
      , tableName
    ;
    loop
      fetch
        curColumn
      into
        columnName
        , lastColumnName
        , dataType
        , dataLength
        , dataPrecision
        , dataScale
        , charLength
      ;
      exit when curColumn%notfound;
      outputText(
  rpad( '  , ' || lower( columnName), 34)
    || rpad(
         GetColumnDefinition(
           dataType => dataType
           , dataPrecision => dataPrecision
           , dataScale => dataScale
           , dataLength => dataLength
           , charLength => charLength
         )
         , 30
       )
      );
    end loop;
    close curColumn;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка получения скрипта для колонок'
        )
      , true
    );
  end ColumnDefinition;

  procedure PrimaryKeyDefinition
  is
  -- Получение скрипта для первичного ключа
    curColumn sys_refcursor;
    columnName typOracleIdentifier;
    lastColumnName typOracleIdentifier;
    constraintName typOracleIdentifier;
                                       -- Определение
                                       -- первичного ключа
    pkDefinition varchar2( 32767) := null;
  begin
    open
      curColumn
    for
      pkSqlText
    using
      sourceUser
      , tableName
      , sourceUser
      , tableName
    ;
    loop
      fetch
        curColumn
      into
        columnName
        , lastColumnName
        , constraintName
      ;
      exit when curColumn%notfound;
      if pkDefinition is null then
        pkDefinition :=
          '  , constraint ' || lower( constraintName)
          || ' primary key( '
        ;
      end if;
      pkDefinition := pkDefinition || columnName;
      if columnName = lastColumnName then
        pkDefinition := pkDefinition || ')';
      else
        pkDefinition := pkDefinition || ', ';
      end if;
    end loop;
    close curColumn;
    outputText( pkDefinition);
    outputText(
      lpad( ' ', 4) || 'using index tablespace &indexTablespace'
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка получения скрипта для первичного ключа'
        )
      , true
    );
  end PrimaryKeyDefinition;

begin
  outputText( 'create table ' || lower( tableName ) || '(');
  ColumnDefinition;
  PrimaryKeyDefinition;
  outputText( ')');
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка получения скрипта для таблицы ( '
        || ' tableName = "' || tableName || '"'
        || ', sourceDbLink="' || sourceDbLink || '"'
        || ', sourceUser="' || sourceUser || '"'
        || ')'
      )
    , true
  );
end tableDefinition;

/* func: getColumnDefinition(type)
  Возвращает строку объявления типа колонки в таблице

  Параметры
     DataType -  соответствует Data_Type из all_tab_cols
     DataPrecision -  соответствует Data_Precision из all_tab_cols
     DataScale - соответствует Data_Scale из all_tab_cols
     DataLength - соответствует Data_Length из all_tab_cols
     CharLength - соответствует Char_Length из all_tab_cols
*/
function getColumnDefinition(
  dataType all_tab_cols.Data_Type%type
  , dataPrecision all_tab_cols.Data_Precision%type
  , dataScale  all_tab_cols.Data_Scale%type
  , dataLength  all_tab_cols.Data_Length%type
  , charLength  all_tab_cols.Char_Length%type
) return varchar2
is
                                       -- Возвращаемый результат
  def varchar2( 100 );
begin
  def :=
    case when
      dataType = Date_DataTypeName then 'date'
    when
      dataType = Varchar2_DataTypeName then 'varchar2(' || dataLength || ')'
    when dataType = 'NVARCHAR2' then
      'nvarchar2(' || charLength || ')'
    when
      dataType = 'CHAR' then 'char(' || DataLength||')'
    when
      dataType in ( Number_DataTypeName, 'FLOAT') and DataPrecision is null and dataScale = 0
    then
      'integer'
    when
      dataType in ( Number_DataTypeName, 'FLOAT') and DataPrecision is null
    then
      lower( dataType )
    when
      dataType in ( Number_DataTypeName, 'FLOAT') and DataPrecision is not null
    then
      lower( dataType ) || '('
      || DataPrecision
      || case when DataScale is not null then ',' || DataScale end
      || ')'
    when
      dataType in ( 'RAW', 'ROWID', 'CLOB', 'TIMESTAMP(6)')
    then
      lower( dataType)
    else
      null
    end;
  if Def is null then
    raise_application_error(
      pkg_Error.IllegalArgument,
      'Неизвестный тип: '||DataType||'.'
    );
  end if;
  return Def;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при определении строки объявления типа колонки.'
      )
    , true
  );
end getColumnDefinition;

/* func: getColumnDefinition(table)
  Возвращает строку объявления типа колонки в таблице.

  Параметры:
    tableName - имя таблицы
    columnName - имя колонки

  Возврат:
  - определение типа колонки
*/
function getColumnDefinition(
  tableName varchar2
  , columnName varchar2
  , raiseWhenNoDataFound integer := null
)
return varchar2
is
                                       -- Возвращаемые
                                       -- значения для типа
  dataType all_tab_cols.Data_Type%type;
  dataPrecision all_tab_cols.Data_Precision%type;
  dataScale all_tab_cols.Data_Scale%type;
  dataLength all_tab_cols.Data_Length%type;
  charLength all_tab_cols.Char_Length%type;
begin
  begin
    select
      data_type
      , data_precision
      , data_scale
      , data_length
      , char_length
    into
      dataType
      , dataPrecision
      , dataScale
      , dataLength
      , charLength
    from
      all_tab_cols
    where
      column_name = upper( columnName )
      and table_name = upper( tableName );
  exception when NO_DATA_FOUND then
    dataType := null;
    if coalesce( raiseWhenNoDataFound, 1 ) = 1 then
      raise;
    end if;
  end;
  if dataType is null then
    return null;
  else
    return
      GetColumnDefinition(
        dataType => dataType
        , dataPrecision => dataPrecision
        , dataScale => dataScale
        , dataLength => dataLength
        , charLength => charLength
      );
  end if;
end getColumnDefinition;

/* proc: generateApi
  Генерация body пакета API для таблицы.

  Параметры:
  ignoreColumnList            - список игнорируемых колонок через ","
*/
procedure generateApi(
  tableName varchar2
  , entityNameObjectiveCase varchar2
  , ignoreColumnList varchar2 := null
)
is
  entityName varchar2(30);
  -- Часть имени таблицы, соотв. имени сущности ( без префикса)
  entityPart varchar2(30);
  idColumnName varchar2(30);
  idComment varchar2( 100);
  idParameterName varchar2(30);

  cursor curField( includeId integer) is
select
  lower( substr( a.column_name, 1, 1))
  || substr(
       replace( initCap( a.column_name), '_', '')
       , 2
     )
    as parameter_name
  , a.comments
  , lower( cc.data_type) as data_type
  , lower( a.column_name) as column_name
from
  user_col_comments a
inner join
  user_tab_cols cc
on
  cc.column_name = a.column_name
where
  cc.table_name = upper( tableName)
  and a.table_name = upper( tableName)
  and cc.virtual_column = 'NO'
  and lower( a.column_name) not in
  (
    'date_ins'
    , 'operator_id'
    , 'deleted'
    , 'changed_operator_id'
    , 'change_number'
    , 'change_date'
  )
  and coalesce( instr(
    ',' || lower( ignoreColumnList) || ','
    , ',' || lower( a.column_name) || ','
  ), 0) = 0
  and ( includeId = 1 or lower( a.column_name) <> lower( idColumnName))
order by
  cc.column_id
  ;

  cursor curFindField(
    ignoreColumnList varchar2
    , parameterFlag number
  ) is
select
  lower( substr( a.column_name, 1, 1))
  || substr(
       replace( initCap( a.column_name), '_', '')
       , 2
      )
  || case when
       lower( data_type) = 'date'
     then
       initCap( interval_boundary_code)
     end
    as parameter_name
  , a.comments
  || case when
       lower( data_type) = 'date'
       and parameterFlag = 1
     then
       ' (' || interval_boundary_name || ')'
     end as comments
  , interval_boundary_code
  , lower( a.data_type) as data_type
  , lower( a.column_name) as column_name
  , lower( r_table_name) as r_table_name
  , lower( source_column_name) as source_column_name
from
  (
  select
    coalesce( r_a.column_name, a.column_name) as column_name
    , a.column_name as source_column_name
    , case when
        r_a.column_name is not null
      then
        r_a.comments
      else
        a.comments
      end as comments
    , case when
        r_a.column_name is not null
      then
        r_cc.data_type
      else
        cc.data_type
      end as data_type
    , r_a.table_name as r_table_name
    , cc.column_id
  from
    user_col_comments a
  inner join
    user_tab_cols cc
  on
    cc.table_name = upper( tableName)
    and cc.column_name = a.column_name
  left join
    -- Информация по ссылке
    (
    select
      r_con.table_name
      , conc.column_name
    from
      user_constraints con
    inner join
      user_constraints r_con
    on
      r_con.constraint_name = con.r_constraint_name
    inner join
      user_cons_columns conc
    on
      conc.constraint_name = r_con.constraint_name
    where
      con.table_name = upper( tableName)
      and con.constraint_type = 'R'
    ) cons
  on
    cons.column_name = cc.column_name
  left join
    user_col_comments r_a
  on
    r_a.table_name = cons.table_name
    and lower( cc.column_name) <> 'operator_id'
    and lower( r_a.column_name) not in
    (
      'date_ins'
      , 'operator_id'
      , 'deleted'
      , 'changed_operator_id'
      , 'change_number'
      , 'change_date'
    )
  left join
    user_tab_cols r_cc
  on
    r_cc.table_name = cons.table_name
    and r_cc.table_name = r_a.table_name
    and r_cc.column_name = r_a.column_name
  where
    a.table_name = upper( tableName)
    and lower( a.column_name) not in
    (
      'changed_operator_id'
      , 'change_number'
      , 'change_date'
      , 'operator_id'
    )
    and cc.virtual_column = 'NO'
  order by
    cc.column_id
    , r_cc.column_id
  ) a
inner join
  (
  select
    'FROM' as interval_boundary_code
    , 'от' as interval_boundary_name
  from
    dual
  union all
  select
    'TO' as interval_boundary_code
    , 'по' as interval_boundary_name
  from
    dual
  ) boundary
on
  (
    -- Интервал задаём для типа date
    parameterFlag = 1 and lower( data_type) = 'date'
    or interval_boundary_code = 'FROM'
  )
where
  instr(
    lower( ',' || ignoreColumnList || ',')
    , ',' || lower( a.column_name) || ','
  ) = 0
order by
  column_id
  , interval_boundary_code
  ;

  function translateDataType(
    dataType varchar2
    , columnName varchar2
  )
  return varchar2
  is
  begin
    return
      case when
        lower( dataType) = 'number'
        and columnName like '%\_id' escape '\'
      then
        'integer'
     else
       lower( dataType)
     end;
  end translateDataType;

  procedure prepare
  is
  -- Подготовка к генерации
  begin
    entityPart := lower( substr( tableName, instr( tableName, '_') + 1));
    entityName := replace( initcap( entityPart), '_', '');
    idColumnName := entityPart || '_id';
    idParameterName := lower( substr( idColumnName, 1, 1))
      || substr( replace( initcap( idColumnName), '_', ''), 2);
    select
      cm.comments
    into
      idComment
    from
      user_col_comments cm
    where
      table_name = upper( tableName)
      and column_name = upper( idColumnName)
    ;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка подготовки параметров для генерации'
        )
      , true
    );
  end prepare;

  /*
    Преобразование комментария к параметру.
  */
  function transformParameterComment( sourceComment varchar2)
  return varchar2
  is
  begin
    return
      case when
        upper( substr( sourceComment, 1, 2)) = substr( sourceComment, 1, 2)
      then
        substr( sourceComment, 1, 1)
      else
        lower( substr( sourceComment, 1, 1))
      end
      ||
      case when
        instr( sourceComment, chr(10)) > 0
      then
        substr( sourceComment, 2, instr( sourceComment, chr(10))-1)
      else
        substr( sourceComment, 2)
      end
    ;
  end transformParameterComment;

  procedure printInParametersDoc( includeId integer)
  is
  -- Вывод параметров процедуры или функции
  begin
    for recInParams in curField( includeId => includeId)
    loop
      outputText(
rpad( '  ' || recInParams.parameter_name, 30) || '- '  || transformParameterComment( recInParams.comments)
      );
    end loop;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка вывода параметров процедуры'
        )
      , true
    );
  end printInParametersDoc;

  procedure printFindParametersDoc( ignoreColumnList varchar2, isCursorField integer)
  is
  -- Вывод параметров процедуры или функции
  begin
    for recInParams in curFindField(
      ignoreColumnList => ignoreColumnList
      , parameterFlag => case when isCursorField = 0 then 1 end
    )
    loop
      if lower( recInParams.column_name) <> 'operator_id' then
        outputText(
rpad( '  ' || case when isCursorField = 1 then recInParams.column_name else recInParams.parameter_name end, 30) || '- '
   || transformParameterComment( recInParams.comments)
        );
      end if;
    end loop;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка вывода параметров процедуры'
        )
      , true
    );
  end printFindParametersDoc;

  procedure printInParameters( includeId integer)
  is
  -- Вывод параметров процедуры или функции
    isFirstColumn boolean := true;
  begin
    for recInParams in curField( includeId => printInParameters.includeId)
    loop
      outputText(
'  ' || case when not isFirstColumn then ', ' end || recInParams.parameter_name || ' '
     || translateDataType( recInParams.data_type, recInParams.column_name)
      );
      isFirstColumn := false;
    end loop;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          ''
        )
      , true
    );
  end printInParameters;

  procedure printFindInParameters
  is
  -- Вывод параметров процедуры или функции
    isFirstColumn boolean;
  begin
    for recInParams in curFindField(
      ignoreColumnList => 'date_ins,' || ignoreColumnList
      , parameterFlag => 1
    )
    loop
      outputText(
'  ' || case when not isFirstColumn then ', ' end || recInParams.parameter_name || ' '
     || translateDataType( recInParams.data_type, recInParams.column_name)
     || case when lower( recInParams.column_name) <> 'operator_id' then  ' := null' end
      );
      isFirstColumn := false;
    end loop;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка вывода параметров процедуры'
        )
      , true
    );
  end printFindInParameters;

  procedure printColumns( includeId integer, isFirstComma integer)
  is
  -- Вывод колонок таблицы
    isFirstColumn boolean;
  begin
    for recColumns in curField( includeId => includeId)
    loop
      outputText(
'    ' || case when not isFirstColumn or isFirstComma = 1 then ', ' end || recColumns.column_name
      );
      isFirstColumn := false;
    end loop;
  end printColumns;

  procedure printFindColumns(
    ignoreColumnList varchar2
    , isFirstComma integer
  )
  is
  -- Вывод колонок таблицы
    isFirstColumn boolean;
  begin
    for recColumns in curFindField(
      ignoreColumnList => ignoreColumnList
      , parameterFlag => 0
    )
    loop
      outputText(
'    ' || case when not isFirstColumn or isFirstComma = 1 then ', ' end
       || case when recColumns.r_table_name is not null then recColumns.r_table_name else 't' end
       || '.' || recColumns.column_name
      );
      isFirstColumn := false;
    end loop;
  end printFindColumns;

  procedure printUpdateColumns
  is
  -- Вывод колонок таблицы для update
    firstColumn boolean := true;
  begin
    for recColumns in curField( includeId => 0)
    loop
      outputText(
'    ' || case when not firstColumn then ', ' end || 't.' || recColumns.column_name
|| ' = ' || case when recColumns.parameter_name = recColumns.column_name then 'update' || entityName || '.' end
|| recColumns.parameter_name
      );
      firstColumn := false;
    end loop;
  end printUpdateColumns;

  procedure printParameters( includeId integer)
  is
  -- Вывод колонок таблицы
    firstColumn boolean := true;
  begin
    for recParameter in curField( includeId => includeId)
    loop
      outputText(
'    ' ||  ', ' || recParameter.parameter_name
      );
      firstColumn := false;
    end loop;
  end printParameters;

  procedure printFindParameters( ignoreColumnList varchar2)
  is
  -- Вывод колонок таблицы
    firstColumn boolean := true;
  begin
    for recParameter in curFindField(
      ignoreColumnList => ignoreColumnList
      , parameterFlag => 1
    )
    loop
      outputText(
'    ' ||  case when not firstColumn then ', ' end || recParameter.parameter_name
       );
      firstColumn := false;
    end loop;
  end printFindParameters;

  procedure printExceptionParameters( includeId integer)
  is
  -- Вывод колонок таблицы
    firstColumn boolean := true;
    comma varchar2(10);
  begin
    for recParameter in curField( includeId => includeId)
    loop
      comma := case when firstColumn then '' else ', ' end;
      outputText(
case when
  lower( recParameter.Data_Type) = 'varchar2'
then
'        || ''' || comma || recParameter.parameter_name
         || '="'' || ' ||  recParameter.parameter_name || ' || ''"'''
when
  lower( recParameter.Data_Type) = 'date'
then
'        || '''|| comma || recParameter.parameter_name
         || '='' || to_char( ' ||  recParameter.parameter_name || ', ''dd.mm.yyyy hh24:mi:ss'') '
else
'        || '''|| comma || recParameter.parameter_name
         || '='' || to_char( ' ||  recParameter.parameter_name || ') '
end
      );
      firstColumn := false;
    end loop;
    outputText(
'        || ''' || comma || 'operatorId='' || to_char( operatorId)'
    );
  end printExceptionParameters;

  procedure printExceptionFindParameters(
    ignoreColumnList varchar2
  )
  is
  -- Вывод колонок таблицы
    firstColumn boolean := true;
    comma varchar2(10);
  begin
    for recParameter in curFindField(
      ignoreColumnList => ignoreColumnList
      , parameterFlag => 1
    )
    loop
      comma := case when firstColumn then '' else ', ' end;
      outputText(
case when
  lower( recParameter.Data_Type) = 'varchar2'
then
'        || ''' || comma || recParameter.parameter_name
         || '="'' || ' ||  recParameter.parameter_name || ' || ''"'''
when
  lower( recParameter.Data_Type) = 'date'
then
'        || '''|| comma || recParameter.parameter_name
         || '='' || to_char( ' ||  recParameter.parameter_name || ', ''dd.mm.yyyy hh24:mi:ss'') '
else
'        || '''|| comma || recParameter.parameter_name
         || '='' || to_char( ' ||  recParameter.parameter_name || ') '
end

      );
      firstColumn := false;
    end loop;
    outputText(
'        || ''' || comma || 'operatorId='' || to_char( operatorId)'
    );
  end printExceptionFindParameters;

  procedure printReferenceTables
  is
    rTableName varchar2(30);
  begin
    for recField in curFindField(
      ignoreColumnList => null
      , parameterFlag => 0
    ) loop
      if
        rTableName is null and recField.r_table_name is not null
        or recField.r_table_name <> rTableName
      then
        rTableName := recField.r_table_name;
        outputText(
'  inner join
    ' || lower( rTableName) || '
  on
    ' || lower( rTableName) || '.' || lower( recField.source_column_name) || ' = t.' || lower( recField.source_column_name)
        );
      end if;
    end loop;
  end printReferenceTables;

  procedure printConditions( ignoreColumnList varchar2)
  is
    firstColumn boolean := true;
  begin
    for recParameter in curFindField(
      ignoreColumnList => ignoreColumnList
      , parameterFlag => 1
    )
    loop
      if lower( recParameter.column_name) <> 'operator_id' then
        outputText(
'  dynamicSql.addCondition(
    conditionText => '''
       ||
       case when
         lower( recParameter.data_type) = 'varchar2'
       then
         'lower( '
         || case when recParameter.r_table_name is not null then recParameter.r_table_name else 't' end
         || '.' || recParameter.column_name
         || ') like lower( :' || recParameter.parameter_name || ')'
       else
         case when recParameter.r_table_name is not null then recParameter.r_table_name else 't' end
         || '.' || recParameter.column_name
         ||
         case when
           lower( recParameter.data_type) = 'date'
         then
           case when
             recParameter.interval_boundary_code = 'FROM'
           then
             ' >= :'
           else
             ' <= :'
           end
         else
           ' = :'
         end
         || recParameter.parameter_name
       end || '''
    , isNullValue => ' || recParameter.parameter_name || ' is null
    , parameterName => '''
        || recParameter.parameter_name || '''
  );'
        );
        firstColumn := false;
      end if;
    end loop;
  end printConditions;

begin
  prepare();

  outputText(
'
/* func' || NDoc_Char || ' create' || entityName || '
  Создание записи ' || entityNameObjectiveCase || '.

  Параметры:'
  );
  printInParametersDoc( includeId => 0);
  outputText(
'  operatorId                 - id оператора

  Возврат:
  - id ' || entityNameObjectiveCase || '
*/
function create' || entityName || '('
  );
  printInParameters( includeId => 0);
  outputText(
'  , operatorId integer
)
return integer
is
  -- id ' || entityNameObjectiveCase || '
  ' || idParameterName || ' integer;
begin
  pkg_Operator.setCurrentUserId(
    operatorId => operatorId
  );
  insert into ' || lower( tableName ) || '('
  );
  printColumns( includeId => 1, isfirstComma => 0);
  outputText(
'    , operator_id
  )
  values(
    ' || lower( tableName) || '_seq.nextval'
  );
  printParameters( includeId => 0);
  outputText(
'    , operatorId
  )
  returning
    ' || idColumnName || '
  into
    ' || idParameterName || '
  ;
  return
    ' || idParameterName || ';
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        ''Ошибка создания записи ' || entityNameObjectiveCase || ' ( '''
  );
  printExceptionParameters( includeId => 0);
  outputText(
'        || '')''
      )
    , true
  );
end create' || entityName || ';

/* proc' || NDoc_Char || ' update' || entityName || '
  Обновление записи ' || entityNameObjectiveCase|| '.

  Параметры:'
  );
  printInParametersDoc( includeId => 1);
  outputText(
'  operatorId                 - id оператора
*/
procedure update' || entityName || '('
  );
  printInParameters( includeId => 1);
  outputText(
'  , operatorId integer
)
is
begin
  pkg_Operator.setCurrentUserId(
    operatorId => operatorId
  );
  update
    ' || lower( tableName) || ' t
  set'
  );
  printUpdateColumns;
  outputText(
'  where
    t.' || idColumnName || ' = ' || idParameterName || '
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        ''Ошибка обновления записи ' || entityNameObjectiveCase || ' ( '''
  );
  printExceptionParameters( includeId => 1);
  outputText(
'        || '')''
      )
    , true
  );
end update' || entityName || ';

/* proc' || NDoc_Char || ' delete' || entityName || '
  Удаление записи ' || entityNameObjectiveCase|| '.

  Параметры:'
  );
  outputText(
    rpad(
'  ' || idParameterName, 30) || '- id ' || entityNameObjectiveCase
  );
  outputText(
'  operatorId                  - id оператора
*/
procedure delete' || entityName || '(
  ' || idParameterName || ' integer
  , operatorId integer
)
is
begin
  pkg_Operator.setCurrentUserId(
    operatorId => operatorId
  );
  update
    ' || lower( tableName) || ' t
  set
    t.deleted = 1
  where
    t.' || idColumnName || ' = ' || idParameterName || '
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        ''Ошибка удаления записи ' || entityNameObjectiveCase || ' ( '''
  );
  outputText(
'        || '''|| idParameterName || '='' || to_char( ' || idParameterName || ') '
  );
  outputText(
'        || '')''
      )
    , true
  );
end delete' || entityName || ';

/* func' || NDoc_Char || ' find' || entityName || '
  Получение множества записей ' || entityNameObjectiveCase || '.

  Входные параметры:'
  );
  printFindParametersDoc(
    ignoreColumnList => 'date_ins,' || ignoreColumnList
  , isCursorField => 0
  );
  outputText(
'  maxRowCount                - максимальное количество возвращаемых записей
  operatorId                 - id оператора

  Поля возвращаемого курсора:'
  );
  printFindParametersDoc( ignoreColumnList => ignoreColumnList, isCursorField => 1);
  outputText(
'  operator_id                - id оператора, добавившего запись
  operator_name              - имя оператора, добавившего запись

  ( сортировка по ' || idColumnName || ' в обратном порядке)
*/
function find' || entityName || '('
  );
  printFindInParameters();
  outputText(
'  , maxRowCount integer := null
  , operatorId integer
)
return sys_refcursor
is
  -- Объект для работы с динамическим sql
  dynamicSql dyn_dynamic_sql_t;
  -- Возвращаемый курсор
  cur' || entityName || ' sys_refcursor;
begin
  pkg_Operator.setCurrentUserId(
    operatorId => operatorId
  );
  dynamicSql :=
     dyn_dynamic_sql_t(
       sqlText =>  ''
select
  a.*
from
  (
  select'
  );
  printFindColumns( ignoreColumnList => ignoreColumnList, isFirstComma => 0);
  outputText(
'    , op.operator_id
    , op.operator_name
  from
    ' || lower( tableName) || ' t'
  );
  printReferenceTables();
  outputText(
'  inner join
    op_operator op
  on
    op.operator_id = t.operator_id
  where
    $(condition)
  order by
    t.' || idColumnName  || ' desc
  ) a
where
  $(rownumCondition)
  ''
  );');
  printConditions(
    ignoreColumnList => 'date_ins,' || ignoreColumnList
  );
  outputText(
'  dynamicSql.useCondition( ''condition'');
  dynamicSql.addCondition(
    ''rownum <= :maxRowCount'', maxRowCount is null
  );
  dynamicSql.useCondition( ''rownumCondition'');
  logger.debug( ''sql="'' || dynamicSql.getSqlText() || ''"'');
  open
    cur' || entityName || '
  for
    dynamicSql.getSqlText()
  using'
  );
  printFindParameters(
    ignoreColumnList => 'operator_id,date_ins,' || ignoreColumnList
  );
  outputText(
'    , maxRowCount
  ;
  return
    cur' || entityName || ';
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        ''Ошибка поиска записи ' || entityNameObjectiveCase || ' ( '''
  );
  printExceptionFindParameters(
    ignoreColumnList => 'date_ins,' || ignoreColumnList
  );
  outputText(
'        || '', maxRowCount='' || to_char( maxRowCount)
        || '')''
      )
    , true
  );
end find' || entityName || ';'
  );
end generateApi;

/* proc: generateHistoryStructure
  Генерация файлов исторической структуры.
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
)
is
  subtype TOracleName is varchar2(30);
  historyTableName TOracleName;
  historyTriggerName TOracleName;
  idColumnName TOracleName;
  historyIdColumnName TOracleName;
  insertTriggerName TOracleName;
  viewName TOracleName;
  historyViewName TOracleName;
  historySequenceName TOracleName;

  cursor curField is
select
  a.comments
  , lower( a.column_name) as column_name
  , cc.data_type
  , cc.data_length
  , cc.data_precision
  , cc.data_scale
  , cc.char_length
  , cc.nullable
from
  user_col_comments a
  , user_tab_cols cc
where
  a.table_name = upper( tableName)
  and cc.table_name = upper( tableName)
  and cc.column_name = a.column_name
  and cc.virtual_column = 'NO'
  and lower( a.column_name) not in
  (
    'date_ins'
    , 'operator_id'
    , 'deleted'
    , 'change_operator_id'
    , 'change_number'
    , 'change_date'
  )
order by
  cc.column_id
  ;

  function checkShrink(
    objectName varchar2
  )
  return varchar2
  is
  -- Попытка сократить имя
    resultName varchar2( 100);
  begin
    resultName := objectName;
    if length( resultName) > 30 then
      resultName := replace( resultName, '_op_operator', '_operator');
    end if;
    if length( resultName) > 30 then
      resultName := replace( resultName, '_op_oper', '_oper');
    end if;
    if length( resultName) > 30 then
      resultName := replace( resultName, '_operator', '_oper');
    end if;
    if length( resultName) > 30 then
      resultName := replace( resultName, '_op_operator', '_operator');
    end if;
    if length( resultName) > 30 then
      resultName := replace( resultName, '_history', '_hist');
    end if;
    if length( resultName) > 30 then
      resultName := replace( resultName, '_change', '_chg');
    end if;
    if length( resultName) > 30 then
      resultName := replace( resultName, '_deleted', '_del');
    end if;
    if length( resultName) > 30 then
      resultName := replace( resultName, '_oper', '_opr');
    end if;
    if length( resultName) > 30 then
      resultName := replace( resultName, '_chg', '_c');
    end if;
    if length( resultName) > 30 then
      resultName := replace( resultName, '_bi_define', '_bi_def');
    end if;
    if length( resultName) > 30 then
      resultName := replace( resultName, '_bi_def', '_bi');
    end if;
    if length( resultName) > 30 then
      resultName := replace( resultName, '_base', '_bs');
    end if;
    if length( resultName) > 32 then
      resultName := replace( resultName, '_hist', '_h');
    elsif length( resultName) > 30 then
      resultName := replace( resultName, '_hist', '_hs');
    end if;
    if length( resultName) > 30 then
      resultName := replace( resultName, '_c_num', '_cn');
    end if;
    if length( resultName) > 30 then
      resultName := replace( resultName, '_c_opr', '_co');
    end if;
    if length( resultName) > 30 then
      resultName := replace( resultName, '_bs_opr', '_bo');
    end if;
    if length( resultName) > 30 then
      resultName := replace( resultName,  abbrFrom, abbrTo);
    end if;
    if length( resultName) > 30 then
      resultName := replace( resultName,  abbrFrom2, abbrTo2);
    end if;
    if length( resultName) > 30 then
      raise_application_error(
        pkg_Error.ProcessError
        , 'Не удалось сократить имя ( '
          || 'objectName="' || objectName || '"'
          || ', resultName="' || resultName || '"'
          || ').'
      );
    end if;
    return resultName;
  end checkShrink;

  procedure init
  is
    entityPart varchar2(100);
    entityName TOracleName;
  begin
    entityPart := substr( tableName, instr( tableName, '_') + 1);
    entityName := replace( initcap( entityPart), '_', '');
    idColumnName := CheckShrink( entityPart || '_id');
    historyTableName := CheckShrink( tableName || '_history');
    historyTriggerName := CheckShrink( tableName || '_bu_history');
    historyIdColumnName :=
      CheckShrink(
         lower( lower( substr( historyTableName, instr( historyTableName, '_') + 1)))
         || '_id'
      );
    insertTriggerName := CheckShrink( tableName || '_bi_define');
    viewName := CheckShrink( 'v_' || tableName);
    historyViewName := CheckShrink( 'v_' || tableName || '_history');
    historySequenceName := CheckShrink( historyTableName || '_seq');
  end init;

  procedure generateHistoryTable
  is
    isFirstColumn boolean := true;
  begin
    pkg_File.DeleteUnloadData;
    append(
'-- table: ' || historyTableName || '
-- ' || tableComment || ' ( исторические данные).
create table
  ' || historyTableName || '
('  );
    append(
  rpad( '  ' || lower( historyIdColumnName), 34) || 'integer                             not null'
     );
    for recField in curField loop
      append(
  rpad( '  ' || ', ' || lower( recField.column_name), 34)
    || rpad(
         getColumnDefinition(
           dataType => recField.data_type
           , dataPrecision => recField.data_precision
           , dataScale => recField.data_scale
           , dataLength => recField.data_length
           , charLength => recField.char_length
         )
         , 36
       ) || case when recField.nullable = 'N' then 'not null' end
      );
      isFirstColumn := true;
    end loop;
    append(
'  , deleted                       number(1)                           not null
  , change_number                 integer                             not null
  , change_date                   date                                not null
  , change_operator_id            integer                             not null
  , base_date_ins                 date                                not null
  , base_operator_id              integer                             not null
  , date_ins                      date                default sysdate not null
  , operator_id                   integer                             not null
  , constraint ' || CheckShrink ( historyTableName || '_pk' ) || ' primary key
    ( ' || historyIdColumnName || ')
    using index tablespace &indexTablespace
  , constraint ' || CheckShrink( historyTableName || '_uk') || ' unique(
      ' || idColumnName || '
      , change_number
    )
    using index tablespace &indexTablespace
  , constraint ' || CheckShrink(  historyTableName || '_ck_deleted') || ' check
    ( deleted in ( 0, 1))
  , constraint ' || CheckShrink( historyTableName || '_ck_change_num') || ' check
    ( change_number >= 1)
)
' || ExecSql_Char || '

comment on table ' || historyTableName || ' is
  ''' || tableComment || ' ( исторические данные) [ ' || svnRoot || ']''
' || ExecSql_Char || '
comment on column ' || historyTableName || '.' || historyIdColumnName || ' is
  ''' || 'Id исторической записи' || '''
/'
    );
    for recField in curField
    loop
      append(
'comment on column ' || historyTableName || '.' || recField.column_name || ' is
  ''' || recField.comments || '''
/'
      );
    end loop;
    append(
'comment on column ' || historyTableName || '.deleted is
  ''Флаг логического удаления записи ( 0 - существующая, 1 - удалена)''
' || ExecSql_Char || '
comment on column ' || historyTableName || '.change_number is
  ''Порядковый номер изменения записи ( начиная с 1)''
' || ExecSql_Char || '
comment on column ' || historyTableName || '.change_date is
  ''Дата изменения записи''
' || ExecSql_Char || '
comment on column ' || historyTableName || '.change_operator_id is
  ''Id оператора, изменившего запись''
' || ExecSql_Char || '
comment on column ' || historyTableName || '.base_date_ins is
  ''Дата добавления записи в исходной таблице''
' || ExecSql_Char || '
comment on column ' || historyTableName || '.base_operator_id is
  ''Id оператора, добавившего запись в исходной таблице''
' || ExecSql_Char || '
comment on column ' || historyTableName || '.date_ins is
  ''Дата добавления записи''
' || ExecSql_Char || '
comment on column ' || historyTableName || '.operator_id is
  ''Id оператора, добавившего запись''
' || ExecSql_Char
    );
    pkg_File.UnloadTxt(
      toPath => pkg_File.GetFilePath( outputFilePath, historyTableName || '.tab')
      , writeMode => pkg_File.Mode_Rewrite
    );
  end generateHistoryTable;

  /*
    Генерация скрипта создания последовательности для первичного ключа
    исторической таблицы.
  */
  procedure generateHistorySequence
  is
  begin
    pkg_File.deleteUnloadData();
    append(
'-- sequence: ' || historySequenceName || '
-- Последовательность для генерации первичного ключа таблицы
-- <' || historyTableName || '>.
create sequence
  ' || historySequenceName || '
' || ExecSql_Char
    );
    pkg_File.unloadTxt(
      toPath => pkg_File.getFilePath( outputFilePath, historySequenceName || '.sqs')
      , writeMode => pkg_File.Mode_Rewrite
    );
  end generateHistorySequence;

  procedure generateHistoryTrigger
  is
  begin
    pkg_File.DeleteUnloadData;
    append(
'-- trigger: ' || historyTriggerName || '
-- При изменении записи в <' || lower( tableName) || '> добавляет историческую запись со
-- старыми данными в <' || historyTableName || '>.
create or replace trigger ' || historyTriggerName || '
  before update
  on ' || lower( tableName ) || '
  for each row
declare

  -- Старые данные в виде записи
  hs ' || historyTableName || '%rowtype;

begin

  -- Используем текущего оператора если Id оператора не был задан явно
  if not updating( ''change_operator_id'') or :new.change_operator_id is null
      then
    :new.change_operator_id := pkg_Operator.getCurrentUserId();
  end if;

  -- Сохраняем время обновления данных
  :new.change_date := sysdate;

  -- Увеличиваем счетчик обновлений
  :new.change_number := :old.change_number + 1;

  -- Заполняем поля с данными'
    );
    for recField in curField loop
      append(
rpad( '  hs.' || recField.column_name, 36) || ':= :old.' || recField.column_name || ';'
      );
    end loop;
    append(
'
  -- Устанавливаем служебные поля
  ' || rpad( 'hs.' || historyIdColumnName, 34) || ':= ' || historySequenceName || '.nextval;
  hs.deleted                        := :old.deleted;
  hs.change_number                  := :old.change_number;
  hs.change_date                    := :old.change_date;
  hs.change_operator_id             := :old.change_operator_id;
  hs.base_date_ins                  := :old.date_ins;
  hs.base_operator_id               := :old.operator_id;
  hs.date_ins                       := :new.change_date;
  hs.operator_id                    := :new.change_operator_id;

  -- Добавляем историческую запись
  insert into
    ' || historyTableName || '
  values
    hs
  ;
end;
/'
    );
    pkg_File.UnloadTxt(
      toPath => pkg_File.GetFilePath( outputFilePath, historyTriggerName || '.trg')
      , writeMode => pkg_File.Mode_Rewrite
    );
  end generateHistoryTrigger;

  procedure generateInsertTrigger
  is
  begin
    pkg_File.deleteUnloadData();
    append(
'-- trigger: ' || insertTriggerName || '
-- Инициализация полей таблицы <' || lower( tableName) || '> при добавлении записи.
create or replace trigger ' || insertTriggerName || '
  before insert
  on ' || lower( tableName) || '
  for each row
begin

  -- Определяем значение первичного ключа
  if :new.' || idColumnName || ' is null then
    :new.' || idColumnName || ' := ' || checkShrink( lower(tableName) || '_seq') || '.nextval;
  end if;

  -- Id оператора, добавившего запись
  if :new.operator_id is null then
    :new.operator_id :=
      coalesce( :new.change_operator_id, pkg_Operator.getCurrentUserId())
    ;
  end if;

  -- Определяем дату добавления записи
  if :new.date_ins is null then
    :new.date_ins := sysdate;
  end if;

  -- Запись действующая по умолчанию
  if :new.deleted is null then
    :new.deleted := 0;
  end if;

  -- Определяем номер изменения
  if :new.change_number is null then
    :new.change_number := 1;
  end if;

  -- Определяем время изменения строки
  if :new.change_date is null then
    :new.change_date := :new.date_ins;
  end if;

  -- Оператор, изменивший строку
  if :new.change_operator_id is null then
    :new.change_operator_id := :new.operator_id;
  end if;
end;
/'
    );
    pkg_File.UnloadTxt(
      toPath => pkg_File.GetFilePath( outputFilePath, insertTriggerName || '.trg')
      , writeMode => pkg_File.Mode_Rewrite
    );
  end generateInsertTrigger;

  procedure generateHistoryConstraints
  is
  begin
    pkg_File.DeleteUnloadData;
    append(
'alter table
  ' || historyTableName || '
add constraint
  ' || CheckShrink( historyTableName || '_fk_base') || '
foreign key
  ( ' || idColumnName || ')
references
  ' || lower( tableName) || ' ( ' || idColumnName || ')
' || ExecSql_Char || '

alter table
  ' || historyTableName || '
add constraint
  ' || CheckShrink( historyTableName  || '_fk_chg_oper') || '
foreign key
  ( change_operator_id)
references
  op_operator ( operator_id)
' || ExecSql_Char || '

alter table
  ' || historyTableName || '
add constraint
  ' || CheckShrink( historyTableName  || '_fk_base_oper') || '
foreign key
  ( base_operator_id)
references
  op_operator ( operator_id)
' || ExecSql_Char || '

alter table
  ' || historyTableName || '
add constraint
  ' || CheckShrink( historyTableName  || '_fk_operator') || '
foreign key
  ( operator_id)
references
  op_operator ( operator_id)
/'
    );
    pkg_File.UnloadTxt(
      toPath => pkg_File.GetFilePath( outputFilePath,  historyTableName || '.con')
      , writeMode => pkg_File.Mode_Rewrite
    );
  end generateHistoryConstraints;

  procedure generateView
  is
    isFirst boolean := true;
  begin
    pkg_File.DeleteUnloadData;
    append(
'-- view: ' || viewName || '
-- ' || tableComment || ' ( актуальные данные).
create or replace force view
  ' || viewName || '
as
select
  -- SVN root: ' || svnRoot
    );
    for recField in curField loop
      append(
 '  ' || case when not isFirst then ', ' end || 't.' || recField.column_name
      );
      isFirst := false;
    end loop;
    append(
'  , t.change_number
  , t.change_date
  , t.change_operator_id
  , t.date_ins
  , t.operator_id
from
  ' || lower( tableName) || ' t
where
  t.deleted = 0
' || ExecSql_Char || '

' || 'comment on table ' || viewName || ' is
  ''' || tableComment || ' ( актуальные данные) [ ' || svnRoot || ']''
/'
    );
    for recField in curField
    loop
      append(
'comment on column ' || viewName || '.' || recField.column_name || ' is
  ''' || recField.comments || '''
/'
      );
    end loop;
    append(
'comment on column ' || viewName || '.change_number is
  ''Порядковый номер изменения записи ( начиная с 1)''
' || ExecSql_Char || '
comment on column ' || viewName || '.change_date is
  ''Дата изменения записи''
' || ExecSql_Char || '
comment on column ' || viewName || '.change_operator_id is
  ''Id оператора, изменившего запись''
' || ExecSql_Char || '
comment on column ' || viewName || '.date_ins is
  ''Дата добавления записи''
' || ExecSql_Char || '
comment on column ' || viewName || '.operator_id is
  ''Id оператора, добавившего запись''
/'
    );
    pkg_File.UnloadTxt(
      toPath => pkg_File.GetFilePath( outputFilePath,  viewName || '.vw')
      , writeMode => pkg_File.Mode_Rewrite
    );
  end generateView;

  procedure generateHistoryView
  is
    isFirst boolean := true;
  begin
    pkg_File.DeleteUnloadData;
    append(
'-- view: ' || historyViewName || '
-- ' || tableComment || ' ( актуальные и исторические данные).
create or replace force view
  ' || historyViewName || '
as
select
  -- SVN root: ' || svnRoot || '
  d.*
from
  (
  select'
  );
  for recField in curField loop
    append(
 '    ' || case when not isFirst then ', ' end || 'h.' || recField.column_name
    );
    isFirst := false;
  end loop;
  append(
'    , h.deleted
    , h.change_number
    , h.change_date
    , h.change_operator_id
    , h.base_date_ins
    , h.base_operator_id
    , h.' || historyIdColumnName || '
    , h.date_ins
    , h.operator_id
  from
    ' || historyTableName || ' h
  union all
  select'
  );
    isFirst := true;
  for recField in curField loop
    append(
 '    ' || case when not isFirst then ', ' end || 't.' || recField.column_name
    );
    isFirst := false;
  end loop;
  append(
'    , t.deleted
    , t.change_number
    , t.change_date
    , t.change_operator_id
    , t.date_ins as base_date_ins
    , t.operator_id as base_operator_id
    , cast( null as integer) as ' || historyIdColumnName || '
    , cast( null as date) date_ins
    , cast( null as integer) operator_id
  from
    ' || lower( tableName) || ' t
  ) d
' || ExecSql_Char || '

comment on table ' || historyViewName || ' is
  ''' || tableComment || ' ( актуальные и исторические данные) [ ' || svnRoot || ']''
/'
    );
    for recField in curField
    loop
      append(
'comment on column ' || historyViewName || '.' || recField.column_name || ' is
  ''' || recField.comments || '''
/'
      );
    end loop;
     append(
'comment on column ' || historyViewName || '.deleted is
  ''Флаг логического удаления записи ( 0 - существующая, 1 - удалена)''
' || ExecSql_Char || '
comment on column ' || historyViewName || '.change_number is
  ''Порядковый номер изменения записи ( начиная с 1)''
' || ExecSql_Char || '
comment on column ' || historyViewName || '.change_date is
  ''Дата изменения записи''
' || ExecSql_Char || '
comment on column ' || historyViewName || '.change_operator_id is
  ''Id оператора, изменившего запись''
' || ExecSql_Char || '
comment on column ' || historyViewName || '.base_date_ins is
  ''Дата добавления записи в исходной таблице''
' || ExecSql_Char || '
comment on column ' || historyViewName || '.base_operator_id is
  ''Id оператора, добавившего запись в исходной таблице''
' || ExecSql_Char || '
comment on column ' || historyViewName || '.' || historyIdColumnName || ' is
  ''Id исторической записи''
' || ExecSql_Char || '
comment on column ' || historyViewName || '.date_ins is
  ''Дата добавления исторической записи''
' || ExecSql_Char || '
comment on column ' || historyViewName || '.operator_id is
  ''Id оператора, добавившего историческую запись''
/'
    );
    pkg_File.UnloadTxt(
      toPath => pkg_File.GetFilePath( outputFilePath,  historyViewName || '.vw')
      , writeMode => pkg_File.Mode_Rewrite
    );
  end generateHistoryView;

begin
  init();
  generateHistoryTrigger();
  generateHistoryTable();
  generateHistorySequence();
  generateInsertTrigger();
  generateHistoryConstraints();
  generateView();
  generateHistoryView();
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка генерации файлов исторической структуры'
      )
    , true
  );
end generateHistoryStructure;



/* group: Интерфейсные таблицы ( модуль Oracle/Module/DataSync) */

/* iproc: generateInterfaceScript
  Генерирует скрипт создания интерфейсной таблицы или временной таблицы
  по исходному представлению.

  Параметры:
  outputFilePath              - путь к каталогу для создаваемых файлов
  tableName                   - имя таблицы
  sourceViewName              - имя исходного представления
  tableComment                - комментарий к таблице
  tempTableFlag               - генерация скрипта создания временных таблиц
                                ( 1 да, 0 нет ( по умолчанию))
*/
procedure generateInterfaceScript(
  outputFilePath varchar2
  , tableName varchar2
  , sourceViewName varchar2
  , tableComment varchar2
  , tempTableFlag integer := null
)
is

  cursor fieldCur is
    select
      tc.column_id as column_number
      , lower( tc.column_name) as column_name
      , tc.data_type
      , tc.data_length
      , tc.data_precision
      , tc.data_scale
      , tc.char_length
      , tc.nullable
      , cc.comments
      , case when
          tc.data_type = 'ROWID'
          and lower( tc.column_name) like 'int\_%\_rid' escape '\'
        then
          1
        end
        as rowid_index_flag
    from
      user_tab_cols tc
      left outer join user_col_comments cc
        on cc.table_name = tc.table_name
          and cc.column_name = tc.column_name
    where
      tc.table_name = sourceViewName
    order by
      1
  ;

  -- Поля первичного ключа
  primaryKeyField varchar2(100);

  -- Необходимость добавления SQL для создания индексов по полям типа rowid
  isRowidIndex boolean;

  -- Имя индекса для поля типа rowid
  rowidIndexName varchar2(100);

-- generateInterfaceScript
begin
  pkg_File.deleteUnloadData();
  append(
'-- table: ' || tableName || '
-- ' || substr(
      tableComment
      , 1
      , instr( tableComment || SvnRoot_BeginComment, SvnRoot_BeginComment) - 1
    ) || '.
create'
|| case when tempTableFlag = 1 then
    ' global temporary'
  end
|| ' table
  ' || tableName || '
('
  );
  for rec in fieldCur loop

    -- Считаем первое поле первичным ключом
    if rec.column_number = 1 then
      primaryKeyField := rec.column_name;
    end if;

    isRowidIndex := isRowidIndex or rec.rowid_index_flag = 1;

    append( rtrim(
      rpad(
        '  '
          || case when rec.column_number > 1 then ', ' end
          || lower( rec.column_name)
        , 34
      )
      || rpad(
           getColumnDefinition(
             dataType         => rec.data_type
             , dataPrecision  => rec.data_precision
             , dataScale      => rec.data_scale
             , dataLength     => rec.data_length
             , charLength     => rec.char_length
           )
           , 36
         )
      || case when rec.column_number = 1 or rec.nullable = 'N' then
          'not null'
        end
    ));
  end loop;
  append(
'  , constraint ' || substr( tableName, 1, 27) || '_pk primary key
    ( ' || primaryKeyField || ')
'
|| case when tempTableFlag = 1 then
')
on commit delete rows
'
else
'    using index tablespace &indexTablespace
)
'
end
|| ExecSql_Char || '



comment on table ' || tableName || ' is
  ''' || tableComment || '''
' || ExecSql_Char
  );
  for rec in fieldCur loop
    append(
'comment on column ' || tableName || '.' || rec.column_name || ' is
  ''' || rec.comments || '''
' || ExecSql_Char
    );
  end loop;
  if coalesce( tempTableFlag, 0) != 1 and isRowidIndex then
    append( chr(10));
    for rec in fieldCur loop
      if rec.rowid_index_flag = 1 then
        rowidIndexName := tableName || '_ix_' || rec.column_name;
        if length( rowidIndexName) > 30 then
          rowidIndexName := replace( rowidIndexName, '_ix_int_', '_ix_');
        end if;
        if length( rowidIndexName) > 30 then
          rowidIndexName := substr( rowidIndexName, 1, 30);
          if substr( rowidIndexName, -1) = '_' then
            rowidIndexName := substr( rowidIndexName, 1, 29);
          end if;
        end if;
        append(
'
-- index' || NDoc_Char || ' ' || rowidIndexName || '
-- Индекс требуется для эффективности быстрого обновления ( fast refresh)
-- материализованного представления.
create index
  ' || rowidIndexName || '
on
  ' || tableName || '(
    ' || rec.column_name || '
  )
tablespace &indexTablespace
' || ExecSql_Char
        );
      end if;
    end loop;
  end if;
  pkg_File.unloadTxt(
    toPath      => pkg_File.getFilePath( outputFilePath, tableName || '.tab')
    , writeMode => pkg_File.Mode_Rewrite
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при генерации скрипта создания таблицы ('
        || ' tableName="' || tableName || '"'
        || ', sourceViewName="' || sourceViewName || '"'
        || ', tempTableFlag=' || tempTableFlag
        || ').'
      )
    , true
  );
end generateInterfaceScript;

/* iproc: processInterfaceSourceView
  Выполняет поиск подходящих представлений и генерацию по ним скриптов
  интерфейсных таблиц.

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
  tempTableFlag               - генерация скриптов создания временных таблиц
                                ( 1 да, 0 нет ( по умолчанию))
*/
procedure processInterfaceSourceView(
  outputFilePath varchar2
  , objectPrefix varchar2 := null
  , viewName varchar2 := null
  , tableName varchar2 := null
  , tempTableFlag integer := null
)
is

  cursor viewList is
    select
      vw.view_name
      , case when
          lower( vw.view_name) like 'v\_%' escape '\'
          and (
            coalesce( tempTableFlag, 0) != 1
            or length( vw.view_name) <= 28
          )
        then
          lower( substr( vw.view_name, 3))
          || case when tempTableFlag = 1 then
              '_tmp'
            end
        end
        as table_name
      , replace(
          replace(
            cm.comments
            , ' ( исходные данные)' || SvnRoot_BeginComment
            , SvnRoot_BeginComment
          )
          , SvnRoot_BeginComment
          , case when tempTableFlag = 1 then
              ' ( временная таблица для обновления данных)'
            end
            || SvnRoot_BeginComment
        )
        as table_comment
      , lead( vw.view_name) over( order by vw.view_name)
        as next_view_name
    from
      user_views vw
      left outer join user_tab_comments cm
        on cm.table_name = vw.view_name
          and cm.table_type = 'VIEW'
    where
      ( objectPrefix is null
        or vw.view_name
          like upper( 'v\_' || objectPrefix || '\_%') escape '\'
      )
      and ( viewName is null
        or vw.view_name
          like upper( viewName) escape '\'
      )
    order by
      1
  ;

  -- Число обработанных представлений
  nProcessed pls_integer := 0;

-- processInterfaceSourceView
begin
  if objectPrefix is null and viewName is null then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Необходимо указать имя исходного представления'
        || ' или префикс объектов модуля.'
    );
  end if;
  for rec in viewList loop
    if nProcessed = 0 and tableName is not null
        and rec.next_view_name is not null
        then
      raise_application_error(
        pkg_Error.IllegalArgument
        , 'Явное указание имени таблицы ( tableName)'
          || ' некорректно в случае несколько исходных представлений ('
          || ' view_name="' || rec.view_name || '"'
          || ', next_view_name="' || rec.next_view_name || '"'
          || ').'
      );
    elsif tableName is null and rec.table_name is null then
      raise_application_error(
        pkg_Error.IllegalArgument
        , 'Не удалось определить имя таблицы по имени представления ('
          || ' view_name="' || rec.view_name || '"'
          || ').'
      );
    end if;
    generateInterfaceScript(
      outputFilePath    => outputFilePath
      , tableName       => coalesce( tableName, rec.table_name)
      , sourceViewName  => rec.view_name
      , tableComment    => rec.table_comment
      , tempTableFlag   => tempTableFlag
    );
    nProcessed := nProcessed + 1;
  end loop;
  if nProcessed = 0 then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Не найдено подходящих исходных представлений.'
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при поиске и обработке подходящих исходных представлений ('
        || ' objectPrefix="' || objectPrefix || '"'
        || ', viewName="' || viewName || '"'
        || ', tableName="' || tableName || '"'
        || ', tempTableFlag=' || tempTableFlag
        || ').'
      )
    , true
  );
end processInterfaceSourceView;

/* proc: generateInterfaceTable
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
*/
procedure generateInterfaceTable(
  outputFilePath varchar2
  , objectPrefix varchar2 := null
  , viewName varchar2 := null
  , tableName varchar2 := null
)
is
begin
  processInterfaceSourceView(
    outputFilePath      => outputFilePath
    , objectPrefix      => objectPrefix
    , viewName          => viewName
    , tableName         => tableName
    , tempTableFlag     => 0
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка генерации скриптов создания интерфейсных таблиц.'
      )
    , true
  );
end generateInterfaceTable;

/* proc: generateInterfaceTempTable
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
*/
procedure generateInterfaceTempTable(
  outputFilePath varchar2
  , objectPrefix varchar2 := null
  , viewName varchar2 := null
  , tableName varchar2 := null
)
is
begin
  processInterfaceSourceView(
    outputFilePath      => outputFilePath
    , objectPrefix      => objectPrefix
    , viewName          => viewName
    , tableName         => tableName
    , tempTableFlag     => 1
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка генерации скриптов создания интерфейсных таблиц.'
      )
    , true
  );
end generateInterfaceTempTable;

end pkg_ScriptUtility;
/
