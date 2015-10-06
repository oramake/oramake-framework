-- script: Test/cursor-cache.sql
-- Кэш курсоров ( тест).

@reconn

declare

  logger lg_logger_t := lg_logger_t.getLogger( 'DynamicSql');

  testViewName varchar2(30) := 'v_dyn_cursor_cache_test';

  testViewSql varchar2(1000) := '
create or replace force view
  ' || testViewName || '
as
select
  t.order_number
  , to_char( order_number) as string_uid
from
  cmn_sequence t
';

  testViewSql2 varchar2(1000) := '
create or replace force view
  ' || testViewName || '
as
select
  1 as order_number
  , ''1'' as string_uid
from
  dual
';


  baseSql varchar2(1000) := '
insert into
  cmn_string_uid_tmp
(
  string_uid
)
select
  string_uid
from
  ' || testViewName || ' t
where
  order_number <= to_char( :p1)
'
;

  sqlTextCol cmn_string_table_t := cmn_string_table_t(
    baseSql
    -- другой SQL c той же длиной
    , upper( baseSql)
    -- другой SQL c другой длиной
    , baseSql || lpad( ' ', 10, '-')
    -- другой SQL c той же длиной
    , initcap( baseSql)
    -- другой SQL c другой длиной
    , baseSql || lpad( ' ', 20, '-')
    , baseSql || lpad( ' ', 30, '-')
    , baseSql || lpad( ' ', 40, '-')
    , baseSql || lpad( ' ', 50, '-')
  );

  -- Для сохранения предыдущих значений курсоров
  type CursorIdCol is table of integer;
  prevCursorIdCol CursorIdCol := CursorIdCol();

  -- Номер запуска в рамках теста
  execNumber pls_integer := 0;

  -- Id последнего использовавшегося в execSql курсора ( для тестирования)
  lastUsedCursorId integer;

  -- Кэш динамических курсоров ( используется в execSql)
  cursorCache dyn_cursor_cache_t := dyn_cursor_cache_t();



  /*
    Выполняет SQL-запрос.

    Параметры:
    sqlText                     - текст SQL-запроса

    Возврат:
    число обработанных записей.
  */
  function execSql(
    sqlText varchar2
    , p1 varchar2
    , isSave integer
  )
  return integer
  is

    -- Число обработанных записей
    nRow integer;

    -- Используемый курсор
    cursorId integer;

  begin

    -- Получаем курсор ( возможно, из кэша)
    cursorId := cursorCache.getCursor( sqlText, isSave => isSave);

    -- Сохраняем в тестовых целях
    lastUsedCursorId := cursorId;

    -- Подставляем параметры
    dbms_sql.bind_variable( cursorId, 'p1', p1);

    -- Выполняем запрос
    nRow := dbms_sql.execute( cursorId);

    -- Освобождаем курсор ( он будет сохранен в кэше)
    cursorCache.freeCursor( cursorId);

    return nRow;
  exception when others then

    -- Закрываем курсор, если он открыт
    if cursorId is not null then
      cursorCache.closeCursor( cursorId);
    end if;

    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при выполнении SQL-запроса.'
        )
      , true
    );
  end execSql;



  /*
    Начало целевого теста.
  */
  procedure startTest(
    testName varchar2
  )
  is
  begin
    dbms_output.put_line(
      chr(10) || 'startTest: ' || testName
    );
    execNumber := 0;
  end startTest;



  /*
    Выполняет тестовый запуск функции execSql.
  */
  procedure testExec(
    sqlId pls_integer := 1
    , p1 varchar2 := '1'
    , isCached boolean := false
    , isSave integer := null
  )
  is

    nProcessed integer;

  begin
    execNumber := execNumber + 1;
    begin
      nProcessed := execSql(
        sqlText   => sqlTextCol( sqlId)
        , p1      => p1
        , isSave  => isSave
      );
      rollback;
    exception when others then
      raise;
    end;
    dbms_output.put_line(
      '[' || execNumber || ']'
      || ': SQL' || sqlId
      || ': p1=' || p1
      || ': rows: ' || nProcessed
      || ' ( cursorId=' || lastUsedCursorId || ')'
    );

    if nullif(
          isCached
          , coalesce( prevCursorIdCol( sqlId) = lastUsedCursorId, false)
        )
        is not null
        then
      raise_application_error(
        pkg_Error.ProcessError
        , 'isCached not passed: '
          || case isCached when true then 'true' when false then 'false' end
      );
    end if;
    prevCursorIdCol( sqlId) := lastUsedCursorId;
  end testExec;



begin
  prevCursorIdCol.extend( sqlTextCol.count());
  pkg_DynamicSqlCache.setMaxCachedCursor( 5);

  execute immediate testViewSql;

  startTest( 'cache used');
  testExec();
  testExec( sqlId => 2, p1 => '2');
  testExec( sqlId => 3, p1 => '3');
  testExec( p1 => '2', isCached => true);
  testExec( p1 => '3', isCached => true);

  startTest( 'free unsed cursor');
  testExec( sqlId => 4);
  testExec( sqlId => 5);
  testExec( sqlId => 2, isCached => true);
  testExec( sqlId => 6);
  -- должен быть освобожден
  testExec( sqlId => 3);

  startTest( 'recreate object');
  testExec( isCached => null);
  testExec( p1 => 2, isCached => true);
  execute immediate 'drop view ' || testViewName;
  execute immediate testViewSql2;
  testExec( p1 => 2, isCached => true);
  execute immediate testViewSql;

  startTest( 'getCursor with null sqlText');
  if cursorCache.getCursor( null) is null then
    dbms_output.put_line( 'test OK');
  else
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'getCursor return not null result'
    );
  end if;

  startTest( 'not save in cache');
  cursorCache.clear();
  testExec( isSave => 0);
  testExec();

  startTest( 'save in cache');
  cursorCache.clear();
  testExec( isSave => 1);
  testExec( isCached => true);

  cursorCache.clear();
  execute immediate 'drop view ' || testViewName;
end;
/
