create or replace package body pkg_TestUtility
as
/* package body: pkg_TestUtility::body */


/* group: ��������� */


/* ivar: TestResult_Position
   ������� ��� ����������� ���������� ������������
*/
TestResult_Position constant pls_integer := 80;


/* group: ���������� */


/* ivar: logger
  ����� ������.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => pkg_TestUtility.Module_Name
  , objectName  => 'pkg_TestUtility'
);

/* ivar: testInfoMessage
  ���������� � �����.
*/
testInfoMessage varchar2(32767) := null;

/* ivar: testFailMessage
  ��������� � ���������� ���������� �����.
*/
testFailMessage varchar2(32767) := null;

/* ivar: testBeginTime
  ����� ������ �����.
*/
testBeginTime timestamp with time zone := null;


/* group: ������� */


/* func: isTestFailed
  ���������� ������, ���� �� ���������� �������������� ����� ( �������� ����
  ������������) ������������� ������.

  �������:
  ������ ���� ������������� ������, ����� ����.
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
   ������ �����.

   ���������:
     messageText                    - ����� ���������
*/
procedure beginTest(
  messageText varchar2
)
is
begin
  if not logger.isEnabledFor( pkg_Logging.Info_LevelCode) then
    logger.setLevel( pkg_Logging.Info_LevelCode);
  end if;
  testInfoMessage := messageText;
  testFailMessage := null;
  testBeginTime := systimestamp;
end beginTest;


/* proc: endTest
  ���������� �����.
*/
procedure endTest
is
  infoMessage varchar2(32767);
-- endTest
begin
  -- ����� �� ���� � �� ��������
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
    -- testFailMessage ����� ��������� �� ������ ������ �����, �����
    -- ���������� ������������ ������� isTestFailed
  end if;
end endTest;


/* proc: failTest
  ���������� ���������� �����.

  ���������:
  failMessageText                 - ��������� � ���������� ����������
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
  �������� ���������� � ���������� �� �����.
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
  ��������� ��������� ������� ���������� ����� ( � ��������).
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
   ��������� ��������� ������.

   ���������:
     actualString                   - ������� ������
     expectedString                 - ��������� ������
     failMessageText                - ��������� ��� ������������ �����
     considerWhitespace             - ���� ��������� �������� ��� ���������
                                      ( ��-��������� ��� )

   �������:
     - true � ������ ���������� ����� ��� false � ��������� ������
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
    ��������� ���������� ��������� ������� �����.
  */
  function getComparison
  return varchar2
  is
    comparisonResult varchar2(32767);
    -- ��������������� ������ ( ��� �������� ����� �����)
    actualStringNormalized varchar2(32767) :=
      translate( actualString, 'a' || ' ' || chr(10) || chr(13) || chr(9), 'a' );
    expectedStringNormalized varchar2(32767) :=
      translate( expectedString, 'a' || ' ' || chr(10) || chr(13) || chr(9), 'a' );

    -- ������������ ��������� �����, �� ������� ������ �����
    maxEqualLength integer;
    -- ����������� ��������� ����� ��� ������� ������ ����������
    minDiffLength integer;

    -- ������������� �����
    middlePoint integer;

  begin
    maxEqualLength := 1;
    minDiffLength :=
      coalesce( greatest( length( actualStringNormalized), length( expectedStringNormalized)), 0)
    ;
    if coalesce(
          actualStringNormalized = expectedStringNormalized
          , coalesce( actualStringNormalized, expectedStringNormalized) is null
        )
        then
      if coalesce( considerWhitespace, false) = true then
        comparisonResult := 'line ends';
      end if;
    else
      -- ������ �� ������������ �����
      for i in 1..10000 loop
        if maxEqualLength + 1 >= minDiffLength then
          exit;
        end if;
        middlePoint := round( ( maxEqualLength + minDiffLength) / 2);
        -- ���������� ������ �� ��������� �����
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
   ��������� ��������� ������.

   ���������:
     actualString                   - ������� ������
     expectedString                 - ��������� ������
     failMessageText                - ��������� ��� ������������ �����
     considerWhitespace             - ���� ��������� �������� ��� ���������
                                      ( ��-��������� ��� )
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
   ��������� �������� ���-�� ����� � ������� � ��������� ���-���.

   ���������:
     tableName                      - ��� �������
     filterCondition                - ������� ���������� ����� � �������
     expectedRowCount               - ��������� ���-�� �����
     failMessageText                - ��������� ��� ������������ ���-�� �����

   �������:
     - true � ������ ���������� ���-�� ����� ��� false � ��������� ������

   ����������: �������� filterCondition ���������� � ������ where ������� ���
   ���������
*/
function compareRowCount (
    tableName            in varchar2
  , filterCondition      in varchar2 := null
  , expectedRowCount     in pls_integer
  , failMessageText      in varchar2 := null
  )
return boolean
is
  -- ������� ���-�� �����
  actualRowCount pls_integer;


  /*
     ���������� ���-�� ����� � ������� ����� ���������� ������� ����������
  */
  function getTableRowCount (
      tableName           in varchar2
    , filterCondition     in varchar2 := null
    )
  return pls_integer
  is
    -- ����� �������
    sqlText varchar2(10000) := '
      select count(1)
        from $(tableName)
       where $(filterCondition)'
    ;

    -- ���������
    nResult pls_integer;

  -- getTableRowCount
  begin
    -- ����������� ���������� � ������
    sqlText :=
      replace(
        replace( sqlText, '$(tableName)', tableName )
        , '$(filterCondition)', coalesce( filterCondition, '1=1' )
        )
    ;

    -- ��������� ������
    execute immediate sqlText
       into nResult
    ;

    -- ���������� ���������
    return nResult;

  exception
    when others then
      raise_application_error(
          pkg_Error.ErrorStackInfo
        , logger.errorStack(
            '������ ��� ��������� ���-�� ����� � ������� (' ||
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
          '������ ��� ��������� �������� ���-�� ����� � ��������� (' ||
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
   ��������� �������� ���-�� ����� � ������� � ��������� ���-���.

   ���������:
     tableName                      - ��� �������
     filterCondition                - ������� ���������� ����� � �������
     expectedRowCount               - ��������� ���-�� �����
     failMessageText                - ��������� ��� ������������ ���-�� �����

   ����������: �������� filterCondition ���������� � ������ where ������� ���
   ���������
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
   ��������� �������� ���-�� ����� � sys_refcursor � ��������� ���-���.

   ���������:
     rc                             - sys_refcursor
     filterCondition                - ������� ���������� ����� � �������
     expectedRowCount               - ��������� ���-�� �����
     failMessageText                - ��������� ��� ������������ ���-�� �����

   �������:
     - true � ������ ���������� ���-�� ����� ��� false � ��������� ������
*/
function compareRowCount (
    rc                   in sys_refcursor
  , filterCondition      in varchar2 := null
  , expectedRowCount     in pls_integer
  , failMessageText      in varchar2 := null
  )
return boolean
is
  -- ������� ���-�� ����� � �������
  actualRowCount pls_integer;


  /*
     ���������� ���-�� ����� � ������� ����� ���������� ������� ����������
  */
  function getCursorRowCount (
      rc                  in sys_refcursor
    , filterCondition     in varchar2
    )
  return pls_integer
  is
    -- TODO: � Oracle 11.2.0.2 ���������� ������������ ��������� �� dbms_sql
    -- ������������� ���� varchar2
    Varchar2_Type constant pls_integer := 1;
    -- ������������� ���� number
    Number_Type   constant pls_integer := 2;
    -- ������������� ���� date
    Date_Type     constant pls_integer := 12;
    -- ������������� ���� varchar2
    Char_Type constant pls_integer     := 96;
    -- ������������� ���� clob
    Clob_Type     constant pls_integer := 112;
    -- ������������� ���� blob
    Blob_Type     constant pls_integer := 113;
    -- ������������� ���� timestamp with local time zone
    TimestampLocalTz_Type constant pls_integer := 231;

    -- ������ �� �������� ������
    sourceRef sys_refcursor;

    -- ��������� ���� ����� � �� ����� � �������
    type TRecCursorColumn is record (
      col_name varchar2(30)
    , col_type varchar2(100)
    );
    type TColCursorColumns is table of TRecCursorColumn;
    cols TColCursorColumns;

    -- ������ ����� ������� ����� �����������
    cursorFieldList varchar2(10000);
    -- ������� ����������
    vFilterCondition varchar2(10000) := coalesce( filterCondition, '1=1' );
    -- ���-�� ����� � ������� ����� ����������
    nFilteredRow pls_integer;

    -- ���� ��� ���������� ������� � ref-�������
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
       ��������� ��������� ref-�������
    */
    procedure parseCursorStructure (
        rc         in out sys_refcursor
      , columnList out TColCursorColumns
      )
    is
      -- ������������� �������
      c pls_integer;
      -- ���-�� ������� � �������
      colCount pls_integer;
      -- ��������� �������
      cols dbms_sql.desc_tab;

    -- parseCursorStructure
    begin
      columnList := TColCursorColumns();
      -- ����������� ref ������ � plsql ������
      c := dbms_sql.to_cursor_number( rc );
      -- ���������� ����� ������� � �������
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
            , '�� ������� ���������� ��� ������� ������� ('
              || ' col_name="' || cols(i).col_name || '"'
              || ', col_type="' || cols(i).col_type || '"'
              || ').'
          );
        end if;
      end loop;
      -- ����������� ������ ������� � ref
      rc := dbms_sql.to_refcursor( c );

    end parseCursorStructure;


    /*
       ���������� ������ ����� (� �� �����) � ������� ����� ","
    */
    function getCursorFieldList
    return varchar2
    is
      cursorFieldList varchar2(10000);

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
       ����������� ���������� ������� ����������, ����� ��� ����� ����
       ������������ � PL/SQL
    */
    procedure transformFilterCondition (
      filterCondition in out varchar2
      )
    is
      columnNameFormat varchar2(100);

    -- transformFilterCondition
    begin
      for i in 1..cols.count loop
        -- ������ ����� ������� � ������� ����������
        columnNameFormat :=
          '(\W|^)(' || cols(i).col_name || ')(\W|$)'
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
    -- ������ ��������� �������
    sourceRef := rc;
    parseCursorStructure(
        rc         => sourceRef
      , columnList => cols
      );

    -- ��������� ������ ����� �������
    cursorFieldList := getCursorFieldList();

    -- ����������� ������� ���������� �����
    transformFilterCondition(
      filterCondition => vFilterCondition
      );

    -- ����������� ������ ����� � ������� � ���� ����������
    refCursorFilterBlock := replace(
      refCursorFilterBlock, '$(cursorFieldList)', cursorFieldList
      );
    -- ����������� ������� ���������� � ���� ����������
    refCursorFilterBlock := replace(
      refCursorFilterBlock, '$(filterCondition)', vFilterCondition
      );

    begin
      -- ��������� PL/SQL ����
      execute immediate refCursorFilterBlock
        using in  sourceRef
            , out nFilteredRow
      ;
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.errorStack(
            '������ ��� ���������� ������������� SQL:'
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
            '������ ��� �������� ���-�� ����� � �������'
            )
        , true
        );

  end getCursorRowCount;


-- compareRowCount
begin
  -- �������� ������� ���-�� ����� � �������
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
          '������ ��� ��������� �������� ���-�� ����� � ���������'
          )
      , true
      );

end compareRowCount;


/* proc: compareRowCount ( proc, cursor )
   ��������� �������� ���-�� ����� � sys_refcursor � ��������� ���-���.

   ���������:
     rc                             - sys_refcursor
     filterCondition                - ������� ���������� ����� � �������
     expectedRowCount               - ��������� ���-�� �����
     failMessageText                - ��������� ��� ������������ ���-�� �����
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


/* func: compareQueryResult ( func, cursor )
  ��������� ������ � sys_refcursor � ����������.

  ���������:
  rc                          - ����������� ������ (sys_refcursor)
  expectedCsv                 - ��������� ������ � CSV
  tableName                   - ��� �������  �������� � ������ ���������
                                (�� ��������� �����������)
  idColumnName                - ��� ������� ������� � Id ������ ��� �������� �
                                ������ ��������� (��� ����� ��������, �������
                                ������������ ��� ���������)
                                (�� ��������� �����������)
  considerWhitespace          - ���� ��������� �������� ��� ��������� ���������
                                ������
                                (�� ��������� ���)
  failMessagePrefix           - ������� ��������� ��� ������������ ������
                                (�� ��������� �����������)

  �������:
  - true � ������ ���������� ������ ��� false � ��������� ������

  ���������:
  - � ������ ������� idColumnName � �������� ���������� �������� �����
    ��������� ������ $(rowId), ������ Id ������� ������, � ������ $(rowId(n)),
    ������ Id �������������� ������ � ������� � ������� n (���������� �������
    ���� n �������������, ����� ������������� �������), �������� $(rowId(1))
    ����� Id ������ ������ � �������, $(rowId(-1)) ����� Id ���������� ������
    � �������;
*/
function compareQueryResult (
  rc in out nocopy sys_refcursor
, expectedCsv clob
, tableName varchar2 := null
, idColumnName varchar2 := null
, considerWhitespace boolean := null
, failMessagePrefix varchar2 := null
)
return boolean
is

  -- ������ ���� � ������ CSV
  Date_Format constant varchar2( 30) := 'dd.mm.yyyy hh24:mi:ss';

  -- ������������ ��������
  isOk boolean := true;

  -- �������� ��� ������� ������ CSV
  csvIterator tpr_csv_iterator_t;
  iteratorRow   boolean;

  -- ������� ����������� ������� � CSV
  fieldNumber integer;

  -- ����� ������� � Id ������ (����������� ���� ������ idColumnName)
  idColumnNumber integer;

  -- ������������� ����������� ������ (����������� ���� ������ idColumnName)
  subtype IdStringT is varchar2(200);
  idString IdStringT;

  -- �������������� ����������� � ���������� ����� ������ (�� rowNumber)
  type IdColT is table of IdStringT;
  idCol IdColT := IdColT();

  -- ���������� ��� ������ � ��������
  cursorSQL         integer;
  rowNumber         integer := 1;
  columnCount       integer;
  columnList        dbms_sql.desc_tab;
  tempNumVariable   number;
  tempDateVariable  date;
  tempVariable      varchar2( 4000);
  cursorRow         integer;



  /*
    ������������� ���������� ���������� �����.
  */
  procedure setFailed(
    messageText varchar2 := null
  )
  is
  begin
    if isOk then
      isOk := false;
      failTest( failMessageText => failMessagePrefix || messageText);
    end if;
  end setFailed;



  /*
   ����������� �������
  */
  procedure defineCursorColumn
  is
  begin
    dbms_sql.describe_columns(
      cursorSQL
    , columnCount
    , columnList
    );
    for columnNumber in 1 .. columnCount
    loop
      if columnList(columnNumber).col_type = 12 -- date
      then
        dbms_sql.define_column(
          cursorSQL
        , columnNumber
        , tempDateVariable
        );
      elsif columnList(columnNumber).col_type = 2 -- number
      then
        dbms_sql.define_column(
          cursorSQL
        , columnNumber
        , tempNumVariable
        );
      else
        dbms_sql.define_column(
          cursorSQL
        , columnNumber
        , tempVariable
        , 4000
        );
      end if;
      if idColumnName is not null
            and lower( columnList( columnNumber).col_name)
              = lower( idColumnName)
          then
        idColumnNumber := columnNumber;
      end if;
    end loop;
    if idColumnName is not null and idColumnNumber is null then
      raise_application_error(
        pkg_Error.IllegalArgument
        , '� ������� ����������� ��������� ������� � Id ������ ('
          || ' idColumnName="' || idColumnName || '"'
          || ').'
      );
    end if;
  end defineCursorColumn;



  /*
    ��������� idString ��������� ��� ������� ������.
  */
  procedure fillIdString
  is
  begin
    if columnList( idColumnNumber).col_type = 12 -- date
    then
      dbms_sql.column_value( cursorSQL, idColumnNumber, tempDateVariable);
      idString := to_char( tempDateVariable, Date_Format);
    elsif columnList(idColumnNumber).col_type = 2 -- number
    then
      dbms_sql.column_value( cursorSQL, idColumnNumber, tempNumVariable);
      idString := to_char(
        tempNumVariable
        , 'tm9'
        , 'NLS_NUMERIC_CHARACTERS = ''. '''
      );
    else
      dbms_sql.column_value( cursorSQL, idColumnNumber, tempVariable);
      idString := '"' || tempVariable || '"';
    end if;
    idCol.extend( 1);
    idCol( idCol.last()) := idString;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ����������� Id ������.'
        )
      , true
    );
  end fillIdString;



  /*
    ��������� ��� ������ �������� ��������, ����������� Id ������.
  */
  function isRowidMacro(
    str varchar2
  )
  return boolean
  is
  begin
    return
      coalesce(
        idColumnName is not null
        and (
          str = '$(rowId)'
          or str like '$(rowId(%))'
        )
        , false
      )
    ;
  end isRowidMacro;



  /*
    ���������� �������� ������� � Id ������.
  */
  function getRowidMacroValue(
    macroName varchar2
  )
  return varchar2
  is

    i integer;
    cnt integer;
    lb integer;

  begin
    if macroName = '$(rowId)' then
      i := idCol.count();
    else
      i := to_number( substr( macroName, 9, length( macroName) - 10));
      cnt := idCol.count();
      lb := - ( cnt - 1);
      if i < lb or i > cnt then
        raise_application_error(
          pkg_Error.IllegalArgument
          , '������� ������������ �������� � ������� $(rowId(n)) ('
            || ' n=' || i
            || ', �������� �������� [' || lb || ';' || cnt || ']'
            || ').'
        );
      end if;
      if i < 1 then
        i := cnt + i;
      end if;
    end if;
    return idCol( i);
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ����������� �������� ������� � Id ������ ('
          || ' macroName="' || macroName || '"'
          || ').'
        )
      , true
    );
  end getRowidMacroValue;



  /*
    ��������� �������� ����, ������������ � ������
  */
  procedure compareColumn(
    columnNumber integer
    , columnName varchar2
    , actualString varchar2
    , expectedString varchar2
  )
  is

    isMacro boolean := false;
    macroValue IdStringT;

  begin
    if isRowidMacro( expectedString) then
      isMacro := true;
      macroValue := getRowidMacroValue( macroName => expectedString);
    end if;
    isOk := isOk and compareChar(
      failMessageText =>
        failMessagePrefix
        || '������������ �������� ���� ' || columnName
        || case when tableName is not null then
            ' ������� ' || tableName
          end
        || ', ������ '
          || case when idColumnNumber is not null then
              lower( idColumnName)
              || '='
              || idString
              || ' (#' || rowNumber || ')'
            else
              '#' || rowNumber
            end
        || case when isMacro then
            ' (������ "' || expectedString || '")'
          end
      , actualString        => actualString
      , expectedString      =>
          case when isMacro then
            macroValue
          else
            expectedString
          end
      , considerWhitespace  => coalesce( considerWhitespace, false)
    );
  end compareColumn;



  /*
   ��������� ���� ���� � ���������
  */
  procedure compareDateColumn(
    columnNumber  integer
    , columnName varchar2
  )
  is
  begin
    dbms_sql.column_value( cursorSQL, columnNumber, tempDateVariable);
    compareColumn(
      columnNumber      => columnNumber
      , columnName      => columnName
      , actualString    =>
          to_char( tempDateVariable, Date_Format)
      , expectedString  =>
          to_char(
            to_date( trim( csvIterator.getString( fieldNumber)), Date_Format)
            , Date_Format
          )
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��������� ���� ���� � ��������� ('
        || ' fieldNumber=' || fieldNumber
        || ', columnNumber=' || columnNumber
        || ', columnName="' || columnName || '"'
        || ')'
        )
      , true
    );
  end compareDateColumn;



  /*
   ��������� ���� ��������� � ���������
  */
  procedure compareNumberColumn(
    columnNumber  integer
    , columnName varchar2
  )
  is

    expectedString varchar2(100);

  begin
    expectedString := trim( csvIterator.getString( fieldNumber));
    if not isRowidMacro( expectedString) then
      expectedString := to_char(
        csvIterator.getNumber( fieldNumber, decimalCharacter => '.')
      );
    end if;
    dbms_sql.column_value( cursorSQL, columnNumber, tempNumVariable);
    compareColumn(
      columnNumber      => columnNumber
      , columnName      => columnName
      , actualString    => to_char( tempNumVariable)
      , expectedString  => expectedString
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��������� ��������� ���� � ��������� ('
        || ' fieldNumber=' || fieldNumber
        || ', columnNumber=' || columnNumber
        || ', columnName="' || columnName || '"'
        || ')'
        )
      , true
    );
  end compareNumberColumn;



  /*
   ��������� ���������� ���� � ���������
  */
  procedure compareCharColumn(
    columnNumber  integer
    , columnName varchar2
  )
  is
  begin
    dbms_sql.column_value( cursorSQL, columnNumber, tempVariable);
    compareColumn(
      columnNumber      => columnNumber
      , columnName      => columnName
      , actualString    => tempVariable
      , expectedString  => trim( csvIterator.getString( fieldNumber))
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��������� ���������� ���� � ��������� ('
        || ' fieldNumber=' || fieldNumber
        || ', columnNumber=' || columnNumber
        || ', columnName="' || columnName || '"'
        || ', iteratorRow='
          || case when
               iteratorRow then 'true'
             when
               not iteratorRow then 'false'
             end
        || ')'
        )
      , true
    );
  end compareCharColumn;



-- compareQueryResult ( func, cursor )
begin
  csvIterator := tpr_csv_iterator_t(
    -- ���������� ������ ������ � ������
    textData              => ltrim( expectedCsv, ' ' || chr(13) || chr(10))
    -- ����� ����� � 1-� ������
    , headerRecordNumber  => 1
    -- 2-� ������ ���������� (� �������������)
    , skipRecordCount     => 2
  );
  cursorSQL := dbms_sql.to_cursor_number( rc);
  defineCursorColumn();
  -- ���������
  loop
    cursorRow := dbms_sql.fetch_rows( cursorSQL);
    if idColumnNumber is not null then
      fillIdString();
    end if;
    iteratorRow := csvIterator.next();
    if
      cursorRow = 0 and iteratorRow
    then
      setFailed(
        '��������� ������ �����'
        || case when tableName is not null then
            ' � ������� ' || tableName
          end
        || ' ( >= ' || rowNumber || ')'
      );
      exit;
    elsif
      nvl(cursorRow, 1) != 0 and not iteratorRow
    then
      setFailed(
        '��������� ������ �����'
        || case when tableName is not null then
            ' � ������� ' || tableName
          end
        || ' ( < ' || rowNumber || ')'
      );
      exit;
    elsif
      cursorRow = 0 and not iteratorRow
    then
      exit;
    end if;
    fieldNumber := 1;
    for columnNumber in 1..columnCount loop
      continue when columnNumber = idColumnNumber;
      if columnList(columnNumber).col_type = 12 -- date
      then
        compareDateColumn(
          columnNumber => columnNumber
          , columnName => columnList( columnNumber).col_name
        );
      elsif columnList(columnNumber).col_type = 2 -- number
      then
        compareNumberColumn(
          columnNumber => columnNumber
          , columnName => columnList( columnNumber).col_name
        );
      else
        compareCharColumn(
          columnNumber => columnNumber
          , columnName => columnList( columnNumber).col_name
        );
      end if;
      fieldNumber := fieldNumber + 1;
    end loop;
    rowNumber := rowNumber + 1;
  end loop;
  dbms_sql.close_cursor( cursorSQL);
  return isOk;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��������� ������ ������� � CSV ('
        || ' idColumnName="' || idColumnName || '"'
        || case when idString is not null then
            ', idString=' || idString
          end
        || ', failMessagePrefix="' || failMessagePrefix || '"'
        || ').'
      )
    , true
  );
end compareQueryResult;

/* proc: compareQueryResult ( proc, cursor )
  ��������� ������ � sys_refcursor � ����������.

  ���������:
  rc                          - ����������� ������ (sys_refcursor)
  expectedCsv                 - ��������� ������ � CSV
  tableName                   - ��� �������  �������� � ������ ���������
                                (�� ��������� �����������)
  idColumnName                - ��� ������� ������� � Id ������ ��� �������� �
                                ������ ��������� (��� ����� ��������, �������
                                ������������ ��� ���������)
                                (�� ��������� �����������)
  considerWhitespace          - ���� ��������� �������� ��� ��������� ���������
                                ������
                                (�� ��������� ���)
  failMessagePrefix           - ������� ��������� ��� ������������ ������
                                (�� ��������� �����������)

  ���������:
  - � ������ ������� idColumnName � �������� ���������� �������� �����
    ��������� ������ $(rowId), ������ Id ������� ������, � ������ $(rowId(n)),
    ������ Id �������������� ������ � ������� � ������� n (���������� �������
    ���� n �������������, ����� ������������� �������), �������� $(rowId(1))
    ����� Id ������ ������ � �������, $(rowId(-1)) ����� Id ���������� ������
    � �������;
*/
procedure compareQueryResult (
  rc in out nocopy sys_refcursor
, expectedCsv clob
, tableName varchar2 := null
, idColumnName varchar2 := null
, considerWhitespace boolean := null
, failMessagePrefix varchar2 := null
)
is

  dummy boolean;

begin
  dummy := compareQueryResult(
    rc                  => rc
  , expectedCsv         => expectedCsv
  , tableName           => tableName
  , idColumnName        => idColumnName
  , considerWhitespace  => considerWhitespace
  , failMessagePrefix   => failMessagePrefix
  );
end compareQueryResult;

/* func: compareQueryResult ( func, table )
  ��������� ������ � ������� � ����������.

  ���������:
  tableName                   - ��� �������
  tableExpression             - ��������� ��� ������� ������ �� �������, ���
                                ���������� ������� ����������� ���������������
                                �� �������
                                (�� ��������� �����������)
  filterCondition             - ������� ���������� ����� � �������
                                (�� ��������� �����������)
  expectedCsv                 - ��������� ������ � CSV
  orderByExpression           - ��������� ��� ������������ ���������� �����
                                (�� ��������� �����������)
  idColumnName                - ��� ������� � Id ������ ��� �������� � ������
                                ���������
                                (�� ��������� �����������)
  considerWhitespace          - ���� ��������� �������� ��� ��������� ���������
                                ������
                                (�� ��������� ���)
  failMessagePrefix           - ������� ��������� ��� ������������ ������
                                (�� ��������� �����������)

  �������:
  - true � ������ ���������� ������ ��� false � ��������� ������

  ���������:
  - � ������ ������� idColumnName � �������� ���������� �������� �����
    ��������� ������ $(rowId), ������ Id ������� ������, � ������ $(rowId(n)),
    ������ Id �������������� ������ � ������� � ������� n (���������� �������
    ���� n �������������, ����� ������������� �������), �������� $(rowId(1))
    ����� Id ������ ������ � �������, $(rowId(-1)) ����� Id ���������� ������
    � �������;
*/
function compareQueryResult(
  tableName varchar2
, tableExpression varchar2 := null
, filterCondition varchar2 := null
, expectedCsv clob
, orderByExpression varchar2 := null
, idColumnName varchar2 := null
, considerWhitespace boolean := null
, failMessagePrefix varchar2 := null
)
return boolean
is

  rc sys_refcursor;

  -- ����� SQL ��� ���������� �� ������� ����������� ������
  sqlText varchar2(10000);



  /*
    ��������� � sqlText ������ ������� �� CSV.
  */
  procedure addColumnList
  is

    -- �������� ��� ������� ������ CSV
    cit tpr_csv_iterator_t;

  begin
    cit := tpr_csv_iterator_t(
      -- ���������� ������ ������ � ������
      textData              => ltrim( expectedCsv, ' ' || chr(13) || chr(10))
      -- ����� �������� ����� ����� �� 1-� �������� ������
      , headerRecordNumber  => 0
    );
    if cit.next() then
      for i in 1 .. cit.getFieldCount() loop
        sqlText := sqlText
          || case when i > 1  then ', ' end
          || lower( trim( cit.getString( fieldNumber => i)))
        ;
      end loop;
    else
      -- ����� �������� ���� �� ���� ���� ��� ��������� �������� �������
      sqlText := sqlText || 'null as c1';
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ���������� � SQL ������ ������� �� CSV.'
        )
      , true
    );
  end addColumnList;



-- compareQueryResult
begin
  sqlText :=
'select
  ' || case when idColumnName is not null  then
      idColumnName || ', '
    end
  ;
  addColumnList();
  sqlText := sqlText ||
'
from
  ' || coalesce( tableExpression, tableName)
  || case when filterCondition is not null then
'
where
  ' || filterCondition
    end
  || case when orderByExpression is not null then
'
order by
  ' || orderByExpression
    end
  ;
  logger.trace( 'compareQueryResult: sqlText:' || chr(10) || sqlText);
  open rc for sqlText;
  return
    compareQueryResult(
      rc                  => rc
    , expectedCsv         => expectedCsv
    , tableName           => tableName
    , idColumnName        => idColumnName
    , considerWhitespace  => considerWhitespace
    , failMessagePrefix   => failMessagePrefix
    )
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��������� ������ � CSV ('
        || ' tableName="' || tableName || '"'
        || ', tableExpression="' || tableExpression || '"'
        || ', filterCondition="' || filterCondition || '"'
        || ', orderByExpression="' || orderByExpression || '"'
        || ', idColumnName="' || idColumnName || '"'
        || ', failMessagePrefix="' || failMessagePrefix || '"'
        || ', sqlText="' || sqlText || '"'
        || ').'
      )
    , true
  );
end compareQueryResult;

/* proc: compareQueryResult ( proc, table )
  ��������� ������ � ������� � ����������.

  ���������:
  tableName                   - ��� �������
  tableExpression             - ��������� ��� ������� ������ �� �������, ���
                                ���������� ������� ����������� ���������������
                                �� �������
                                (�� ��������� �����������)
  filterCondition             - ������� ���������� ����� � �������
                                (�� ��������� �����������)
  expectedCsv                 - ��������� ������ � CSV
  orderByExpression           - ��������� ��� ������������ ���������� �����
                                (�� ��������� �����������)
  idColumnName                - ��� ������� � Id ������ ��� �������� � ������
                                ���������
                                (�� ��������� �����������)
  considerWhitespace          - ���� ��������� �������� ��� ��������� ���������
                                ������
                                (�� ��������� ���)
  failMessagePrefix           - ������� ��������� ��� ������������ ������
                                (�� ��������� �����������)

  ���������:
  - � ������ ������� idColumnName � �������� ���������� �������� �����
    ��������� ������ $(rowId), ������ Id ������� ������, � ������ $(rowId(n)),
    ������ Id �������������� ������ � ������� � ������� n (���������� �������
    ���� n �������������, ����� ������������� �������), �������� $(rowId(1))
    ����� Id ������ ������ � �������, $(rowId(-1)) ����� Id ���������� ������
    � �������;
*/
procedure compareQueryResult(
  tableName varchar2
, tableExpression varchar2 := null
, filterCondition varchar2 := null
, expectedCsv clob
, orderByExpression varchar2 := null
, idColumnName varchar2 := null
, considerWhitespace boolean := null
, failMessagePrefix varchar2 := null
)
is

  dummy boolean;

begin
  dummy := compareQueryResult(
      tableName           => tableName
    , tableExpression     => tableExpression
    , filterCondition     => filterCondition
    , expectedCsv         => expectedCsv
    , orderByExpression   => orderByExpression
    , idColumnName        => idColumnName
    , considerWhitespace  => considerWhitespace
    , failMessagePrefix   => failMessagePrefix
  );
end compareQueryResult;

end pkg_TestUtility;
/
