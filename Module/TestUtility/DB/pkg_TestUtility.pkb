create or replace package body pkg_TestUtility
as
/* package body: pkg_TestUtility::body */


/* group: Константы */


/* ivar: TestResult_Position
   Позиция для отображения результата тестирования
*/
TestResult_Position constant pls_integer := 80;


/* group: Переменные */


/* ivar: logger
  Логер пакета.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => pkg_TestUtility.Module_Name
  , objectName  => 'pkg_TestUtility'
);

/* ivar: testInfoMessage
  Информация о тесте.
*/
testInfoMessage varchar2(32767) := null;

/* ivar: testFailMessage
  Сообщение о неуспешном результате теста.
*/
testFailMessage varchar2(32767) := null;

/* ivar: testBeginTime
  Время начала теста.
*/
testBeginTime timestamp with time zone := null;


/* group: Функции */


/* func: isTestFailed
  Возвращает истину, если по последнему выполнявшемуся тесту ( текущему либо
  завершенному) зафиксирована ошибка.

  Возврат:
  истина если зафиксирована ошибка, иначе ложь.
*/
function isTestFailed
return boolean
is
begin
  return
    testFailMessage is not null
  ;
end isTestFailed;


/* proc: beginTest
   Начало теста.

   Параметры:
     messageText                    - текст сообщения
*/
procedure beginTest(
  messageText varchar2
)
is
-- beginTest
begin
  pkg_TaskHandler.setAction( messageText);
  if not logger.isEnabledFor( pkg_Logging.Info_LevelCode) then
    logger.setLevel( pkg_Logging.Info_LevelCode);
  end if;
  testInfoMessage := messageText;
  testFailMessage := null;
  testBeginTime := systimestamp;
end beginTest;


/* proc: endTest
  Завершение теста.
*/
procedure endTest
is
  infoMessage varchar2(32767);
-- endTest
begin
  -- Начат ли тест и не закончен
  if testInfoMessage is not null then
    infoMessage :=
      rpad(
        testInfoMessage
        , TestResult_Position
      ) || ': '
    ;
    infoMessage :=
      infoMessage
      ||
      case when
        not isTestFailed()
      then
        'OK'
      else
        'FAILED (see details below)'
          || chr(10) || testFailMessage
      end
    ;
    logger.info( infoMessage);
    testInfoMessage := null;
    -- testFailMessage нужно сохранить до начала нового теста, чтобы
    -- обеспечить корректность функции isTestFailed
  end if;
end endTest;


/* proc: failTest
  Неуспешное завершение теста.

  Параметры:
  failMessageText                 - сообщение о неуспешном результате
*/
procedure failTest(
  failMessageText varchar2
)
is
begin
  if not isTestFailed() then
    testFailMessage := failMessageText;
  end if;
  endTest();
end failTest;


/* proc: addTestInfo
  Добавить информацию в соообщение по тесту.
*/
procedure addTestInfo(
  addonMessage varchar2
  , position integer := null
)
is
begin
  testInfoMessage :=
    case
      when position is not null then
        rpad( testInfoMessage, position )
      else
        testInfoMessage
    end
    || addonMessage
  ;
end addTestInfo;


/* func: getTestTimeSecond
  Получение интервала времени выполнения теста ( в секундах).
*/
function getTestTimeSecond
return number
is

  timeDiff interval day to second := systimestamp - testBeginTime;

-- getTestTimeInterval
begin
  return
    + extract( day from timeDiff) * 60 * 60 * 24
    + extract( hour from timeDiff) * 60 * 60
    + extract( minute from timeDiff) * 60
    + extract( second from timeDiff)
  ;
end getTestTimeSecond;


/* func: compareChar ( func )
   Сравнение строковых данных.

   Параметры:
     actualString                   - текущая строка
     expectedString                 - ожидаемая строка
     failMessageText                - сообщение при несовпадении строк
     considerWhitespace             - учёт служебных символов при сравнении
                                      ( по-умолчанию нет )

   Возврат:
     - true в случае совпадения строк или false в противном случае
*/
function compareChar (
    actualString        in varchar2
  , expectedString      in varchar2
  , failMessageText     in varchar2
  , considerWhitespace in boolean := null
  )
return boolean
is
  longStringFlag boolean;
  comparisonDetail varchar2(32767);

  /*
    Получение результата сравнение длинных строк.
  */
  function getComparison
  return varchar2
  is
    comparisonResult varchar2(32767);
    -- Нормализованные строки ( без символов конца строк)
    actualStringNormalized varchar2(32767) :=
      translate( actualString, 'a' || ' ' || chr(10) || chr(13) || chr(9), 'a' );
    expectedStringNormalized varchar2(32767) :=
      translate( expectedString, 'a' || ' ' || chr(10) || chr(13) || chr(9), 'a' );

    -- Максимальная известная длина, до которой строки равны
    maxEqualLength integer;
    -- Минимальная известная длина при которой строки отличаются
    minDiffLength integer;

    -- Промежуточная точка
    middlePoint integer;

  begin
    maxEqualLength := 1;
    minDiffLength :=
      coalesce( greatest( length( actualStringNormalized), length( expectedStringNormalized)), 0)
    ;
    if actualStringNormalized = expectedStringNormalized then
      if coalesce( considerWhitespace, false) = true then
        comparisonResult := 'line ends';
      end if;
    else
      -- Защита от бесконечного цикла
      for i in 1..10000 loop
        if maxEqualLength + 1 >= minDiffLength then
          exit;
        end if;
        middlePoint := round( ( maxEqualLength + minDiffLength) / 2);
        -- Сравниваем строки до срединной точки
        if
          substr( actualStringNormalized, 1, middlePoint)
          = substr( expectedStringNormalized, 1, middlePoint)
        then
          maxEqualLength := middlePoint;
        else
          minDiffLength := middlePoint;
        end if;
      end loop;
      if maxEqualLength + 1 = minDiffLength then
        comparisonResult := comparisonResult
          || chr(10) || 'maximum equal length: ' || to_char( maxEqualLength)
          || chr(10)
          || '"...' || substr( actualStringNormalized, minDiffLength, 10) || '..."'
          || ' <> '
          || '"...' || substr( expectedStringNormalized, minDiffLength, 10) || '..." (expected)'
        ;
      else
        comparisonResult := comparisonResult || chr(10) || 'could not find difference point';
      end if;
    end if;
    return
      comparisonResult
    ;
  end getComparison;

-- compareChar
begin
  if
    coalesce(
      nullif( actualString, expectedString)
      , nullif( expectedString, actualString)
    ) is null
  then
    return true;
  else
    comparisonDetail := getComparison();
    if comparisonDetail is not null then
      longStringFlag :=
        coalesce( length( actualString), 0) > 100
        and coalesce( length( expectedString), 0) > 100
      ;
      failTest(
        failMessageText
        || case when
             not longStringFlag
           then
             '; ( "' || actualString || '" <> "' || expectedString || '" ( expected))'
           end
        || ';' || comparisonDetail
      );
      return false;
    else
      return true;
    end if;
  end if;
end compareChar;


/* proc: compareChar ( proc )
   Сравнение строковых данных.

   Параметры:
     actualString                   - текущая строка
     expectedString                 - ожидаемая строка
     failMessageText                - сообщение при несовпадении строк
     considerWhitespace             - учёт служебных символов при сравнении
                                      ( по-умолчанию нет )
*/
procedure compareChar (
    actualString        in varchar2
  , expectedString      in varchar2
  , failMessageText     in varchar2
  , considerWhitespace  in boolean := null
  )
is
  dummy boolean;

-- compareChar
begin
  dummy := compareChar(
      actualString    => actualString
    , expectedString  => expectedString
    , failMessageText => failMessageText
    , considerWhitespace => considerWhitespace
    );

end compareChar;


/* func: compareRowCount ( func, table )
   Сравнение текущего кол-ва строк в таблице с ожидаемым кол-вом.

   Параметры:
     tableName                      - имя таблицы
     filterCondition                - условия фильтрации строк в таблице
     expectedRowCount               - ожидаемое кол-во строк
     failMessageText                - сообщение при несовпадении кол-ва строк

   Возврат:
     - true в случае совпадения кол-ва строк или false в противном случае

   Примечание: параметр filterCondition передается в раздел where запроса без
   изменений
*/
function compareRowCount (
    tableName            in varchar2
  , filterCondition      in varchar2 := null
  , expectedRowCount     in pls_integer
  , failMessageText      in varchar2 := null
  )
return boolean
is
  -- текущее кол-во строк
  actualRowCount pls_integer;


  /*
     Возвращает кол-во строк в таблице после применения условий фильтрации
  */
  function getTableRowCount (
      tableName           in varchar2
    , filterCondition     in varchar2 := null
    )
  return pls_integer
  is
    -- текст запроса
    sqlText varchar2(4000) := '
      select count(1)
        from $(tableName)
       where $(filterCondition)'
    ;

    -- результат
    nResult pls_integer;

  -- getTableRowCount
  begin
    -- подставляем переменные в запрос
    sqlText :=
      replace(
        replace( sqlText, '$(tableName)', tableName )
        , '$(filterCondition)', coalesce( filterCondition, '1=1' )
        )
    ;

    -- выполняем запрос
    execute immediate sqlText
       into nResult
    ;

    -- возвращаем результат
    return nResult;

  exception
    when others then
      raise_application_error(
          pkg_Error.ErrorStackInfo
        , logger.errorStack(
            'Ошибка при получении кол-ва строк в таблице (' ||
              ' tableName="' || tableName || '"' ||
              ', filterCondition="' || filterCondition || '"' ||
              ').'
            )
        , true
        );

  end getTableRowCount;


-- compareRowCount
begin
  actualRowCount := getTableRowCount(
      tableName       => tableName
    , filterCondition => filterCondition
    );

  if actualRowCount = expectedRowCount then
    return true;
  else
    pkg_TestUtility.failTest(
      failMessageText
        || ' ( '
        || 'actual[' || to_char( actualRowCount ) || ' row(s)]'
        || ' <> '
        || 'expected[' || to_char( expectedRowCount ) || ' row(s)]'
        || ' )'
      )
    ;
    return false;
  end if;

exception
  when others then
    raise_application_error(
        pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при сравнении текущего кол-ва строк с ожидаемым (' ||
            ' tableName="' || tableName || '"' ||
            ', filterCondition="' || filterCondition || '"' ||
            ', expectedRowCount=' || to_char( expectedRowCount ) ||
            ', failMessageText="' || failMessageText || '"' ||
            ').'
          )
      , true
      );

end compareRowCount;


/* proc: compareRowCount ( proc, table )
   Сравнение текущего кол-ва строк в таблице с ожидаемым кол-вом.

   Параметры:
     tableName                      - имя таблицы
     filterCondition                - условия фильтрации строк в таблице
     expectedRowCount               - ожидаемое кол-во строк
     failMessageText                - сообщение при несовпадении кол-ва строк

   Примечание: параметр filterCondition передается в раздел where запроса без
   изменений
*/
procedure compareRowCount (
    tableName            in varchar2
  , filterCondition      in varchar2 := null
  , expectedRowCount     in pls_integer
  , failMessageText      in varchar2 := null
  )
is
  dummy boolean;

-- compareRowCount
begin
  dummy := compareRowCount(
      tableName        => tableName
    , filterCondition  => filterCondition
    , expectedRowCount => expectedRowCount
    , failMessageText  => failMessageText
    );

end compareRowCount;


/* func: compareRowCount ( func, cursor )
   Сравнение текущего кол-ва строк в sys_refcursor с ожидаемым кол-вом.

   Параметры:
     rc                             - sys_refcursor
     filterCondition                - условие фильтрации строк в курсоре
     expectedRowCount               - ожидаемое кол-во строк
     failMessageText                - сообщение при несовпадении кол-ва строк

   Возврат:
     - true в случае совпадения кол-ва строк или false в противном случае
*/
function compareRowCount (
    rc                   in sys_refcursor
  , filterCondition      in varchar2 := null
  , expectedRowCount     in pls_integer
  , failMessageText      in varchar2 := null
  )
return boolean
is
  -- текущее кол-во строк в курсоре
  actualRowCount pls_integer;


  /*
     Возвращает кол-во строк в курсоре после применения условия фильтрации
  */
  function getCursorRowCount (
      rc                  in sys_refcursor
    , filterCondition     in varchar2
    )
  return pls_integer
  is
    -- TODO: в Oracle 11.2.0.2 необходимо использовать константы из dbms_sql
    -- идентификатор типа varchar2
    Varchar2_Type constant pls_integer := 1;
    -- идентификатор типа number
    Number_Type   constant pls_integer := 2;
    -- идентификатор типа date
    Date_Type     constant pls_integer := 12;
    -- идентификатор типа varchar2
    Char_Type constant pls_integer     := 96;
    -- идентификатор типа clob
    Clob_Type     constant pls_integer := 112;
    -- идентификатор типа blob
    Blob_Type     constant pls_integer := 113;
    -- идентификатор типа timestamp with local time zone
    TimestampLocalTz_Type constant pls_integer := 231;

    -- ссылка на основной курсор
    sourceRef sys_refcursor;

    -- коллекция имен полей и их типов в курсоре
    type TRecCursorColumn is record (
      col_name varchar2(30)
    , col_type varchar2(100)
    );
    type TColCursorColumns is table of TRecCursorColumn;
    cols TColCursorColumns;

    -- список полей курсора через разделитель
    cursorFieldList varchar2(4000);
    -- условие фильтрации
    vFilterCondition varchar2(4000) := coalesce( filterCondition, '1=1' );
    -- кол-во строк в курсоре после фильтрации
    nFilteredRow pls_integer;

    -- блок для применения фильтра к ref-курсору
    refCursorFilterBlock varchar2(32767) := '
      declare
        type TRecRefCursor is record (
          $(cursorFieldList)
        );
        rec TRecRefCursor;
        checkResult boolean;
        nResult pls_integer := 0;
      begin
        fetch :rc into rec;
        while :rc%found loop
          checkResult := ( $(filterCondition) );
          if checkResult then
            nResult := nResult + 1;
          end if;
          fetch :rc into rec;
        end loop;
        :nFilteredRow := nResult;
      end;'
    ;


    /*
       Формирует структуру ref-курсора
    */
    procedure parseCursorStructure (
        rc         in out sys_refcursor
      , columnList out TColCursorColumns
      )
    is
      -- идентификатор курсора
      c pls_integer;
      -- кол-во колонок в курсоре
      colCount pls_integer;
      -- параметры колонок
      cols dbms_sql.desc_tab;

    -- parseCursorStructure
    begin
      columnList := TColCursorColumns();
      -- преобразуем ref курсор в plsql курсор
      c := dbms_sql.to_cursor_number( rc );
      -- определяем набор колонок в курсоре
      dbms_sql.describe_columns( c, colCount, cols );
      for i in 1..cols.count loop
        columnList.extend;
        columnList( columnList.count ).col_name := cols(i).col_name;
        columnList( columnList.count ).col_type :=
          case cols(i).col_type
            when Varchar2_Type then
              'varchar2(' || coalesce( nullif( cols(i).col_max_len, 0 ), 1 ) || ')'
            when Number_Type then
              'number'
                || case
                     when cols(i).col_precision > 0 then
                       '(' || cols(i).col_precision || ',' || cols(i).col_scale || ')'
                     else
                       null
                   end
            when Date_Type then
              'date'
            when Char_Type then
              'char(' || coalesce( nullif( cols(i).col_max_len, 0 ), 1 ) || ')'
            when Clob_Type then
              'clob'
            when Blob_Type then
              'blob'
            when TimestampLocalTz_Type then
              'timestamp with local time zone'
            else
              null
          end
        ;
        if columnList( columnList.count).col_type is null then
          raise_application_error(
            pkg_Error.ProcessError
            , 'Не удалось определить тип колонки курсора ('
              || ' col_name="' || cols(i).col_name || '"'
              || ', col_type="' || cols(i).col_type || '"'
              || ').'
          );
        end if;
      end loop;
      -- преобразуем курсор обратно в ref
      rc := dbms_sql.to_refcursor( c );

    end parseCursorStructure;


    /*
       Возвращает список полей (и их типов) в курсоре через ","
    */
    function getCursorFieldList
    return varchar2
    is
      cursorFieldList varchar2(4000);

    -- getCursorFieldList
    begin
      for i in 1..cols.count loop
        if i > 1 then
          cursorFieldList := cursorFieldList || ', ';
        end if;
        cursorFieldList :=
          cursorFieldList
            || cols(i).col_name
            || ' '
            || cols(i).col_type
        ;
      end loop;

      return cursorFieldList;

    end getCursorFieldList;


    /*
       Преобразует переданное условие фильтрации, чтобы его можно было
       использовать в PL/SQL
    */
    procedure transformFilterCondition (
      filterCondition in out varchar2
      )
    is
      columnNameFormat varchar2(100);

    -- transformFilterCondition
    begin
      for i in 1..cols.count loop
        -- формат имени колонки в условии фильтрации
        columnNameFormat :=
          '([^[:alnum:]'']*)(' || cols(i).col_name || ')([^[:alnum:]'']*)'
        ;
        if regexp_instr( filterCondition, columnNameFormat, 1, 1, 0, 'i' ) > 0 then
          filterCondition := regexp_replace(
            filterCondition, columnNameFormat, '\1rec.\2\3', 1, 0, 'i'
            );
        end if;
      end loop;

    end transformFilterCondition;


  -- getCursorRowCount
  begin
    -- парсим структуру курсора
    sourceRef := rc;
    parseCursorStructure(
        rc         => sourceRef
      , columnList => cols
      );

    -- формируем список полей курсора
    cursorFieldList := getCursorFieldList();

    -- преобразуем условие фильтрации строк
    transformFilterCondition(
      filterCondition => vFilterCondition
      );

    -- подставляем список полей в курсоре в блок фильтрации
    refCursorFilterBlock := replace(
      refCursorFilterBlock, '$(cursorFieldList)', cursorFieldList
      );
    -- подставляем условие фильтрации в блок фильтрации
    refCursorFilterBlock := replace(
      refCursorFilterBlock, '$(filterCondition)', vFilterCondition
      );

    begin
      -- выполняем PL/SQL блок
      execute immediate refCursorFilterBlock
        using in  sourceRef
            , out nFilteredRow
      ;
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.errorStack(
            'Ошибка при выполнении динамического SQL:'
            || chr(10) || refCursorFilterBlock
            || chr(10)
          )
        , true
      );
    end;

    return nFilteredRow;

  exception
    when others then
      raise_application_error(
          pkg_Error.ErrorStackInfo
        , logger.errorStack(
            'Ошибка при подсчете кол-во строк в курсоре'
            )
        , true
        );

  end getCursorRowCount;


-- compareRowCount
begin
  -- получаем текущее кол-во строк в курсоре
  actualRowCount := getCursorRowCount(
      rc              => rc
    , filterCondition => filterCondition
    );

  if actualRowCount = expectedRowCount then
    return true;
  else
    pkg_TestUtility.failTest(
      failMessageText
        || ' ( '
        || 'actual[' || to_char( actualRowCount ) || ' row(s)]'
        || ' <> '
        || 'expected[' || to_char( expectedRowCount ) || ' row(s)]'
        || ' )'
      )
    ;
    return false;
  end if;

exception
  when others then
    raise_application_error(
        pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при сравнении текущего кол-ва строк с ожидаемым'
          )
      , true
      );

end compareRowCount;


/* proc: compareRowCount ( proc, cursor )
   Сравнение текущего кол-ва строк в sys_refcursor с ожидаемым кол-вом.

   Параметры:
     rc                             - sys_refcursor
     filterCondition                - условие фильтрации строк в курсоре
     expectedRowCount               - ожидаемое кол-во строк
     failMessageText                - сообщение при несовпадении кол-ва строк
*/
procedure compareRowCount (
    rc                   in sys_refcursor
  , filterCondition      in varchar2 := null
  , expectedRowCount     in pls_integer
  , failMessageText      in varchar2 := null
  )
is
  dummy boolean;

-- compareRowCount
begin
  dummy := compareRowCount(
      rc               => rc
    , filterCondition  => filterCondition
    , expectedRowCount => expectedRowCount
    , failMessageText  => failMessageText
    );

end compareRowCount;


end pkg_TestUtility;
/
