create or replace package body pkg_DataSyncTest is
/* package body: pkg_DataSyncTest::body */



/* group: Переменные */

/* ivar: logger
  Логер пакета.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => pkg_DataSync.Module_Name
  , objectName  => 'pkg_DataSyncTest'
);



/* group: Функции */

/* proc: apiTest
  Тестирование API.
*/
procedure apiTest
is



  /*
    Тест функции getTableConfigString.
  */
  procedure getTableConfigStringTest
  is



    /*
      Проверяет тестовый случай.
    */
    procedure checkCase(
      caseDescription varchar2
      , srcString varchar2
      , resultString varchar2 := null
      , sourceSchema varchar2 := null
      , errorMessageMask varchar2 := null
    )
    is

      -- Описание тестового случая
      caseInfo varchar2(200) :=
        'getTableConfigString: ' || caseDescription
      ;

      resStr varchar2(32000);

      errorMessage varchar2(32000);

    begin
      begin
        resStr := pkg_DataSync.getTableConfigString(
          srcString       => srcString
          , sourceSchema  => sourceSchema
        );
      exception when others then
        if errorMessageMask is not null then
          errorMessage := logger.getErrorStack();
          if errorMessage not like errorMessageMask then
            pkg_TestUtility.compareChar(
              actualString        => errorMessage
              , expectedString    => errorMessageMask
              , failMessageText   =>
                  caseInfo
                  || ': Сообщение об ошибке не соответствует маске'
            );
          end if;
        else
          raise;
        end if;
      end;

      -- Проверка успешного результата
      if errorMessageMask is null then
        pkg_TestUtility.compareChar(
          actualString        => resStr
          , expectedString    => resultString
          , failMessageText   =>
              caseInfo
              || ': Некорректное значение функции'
        );
      end if;
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.errorStack(
            'Ошибка при выполнении теста ('
            || ' caseDescription="' || caseDescription || '"'
            || ').'
          )
        , true
      );
    end checkCase;



  -- getTableConfigStringTest
  begin
    checkCase(
      'minimal'
      , 'dst_table'
      , 'dst_table:d:v_dst_table::::'
    );
    checkCase(
      'minimal for temp'
      , 'dst_table : t'
      , 'dst_table:t:v_dst_table:dst_table_tmp:::'
    );
    checkCase(
      'minimal for mview'
      , ' dst_table : m '
      , 'dst_table:m:v_dst_table::::'
    );

    checkCase(
      'minimal with option'
      , 'dst_table:excludeColumnList=Date_Ins'
      , 'dst_table:d:v_dst_table::date_ins::'
    );

    checkCase(
      'with sourceSchema'
      , 'dst_table'
      , 'dst_table:d:tst_user.v_dst_table::::'
      , sourceSchema => 'tst_user'
    );

    checkCase(
      'full'
      , 'dst_table : t : tst_user.v_dst_special : src.dst_table_new_tmp :
          excludeColumnList = Change_Number  , change_date, date_ins
        '
      , 'dst_table:t:tst_user.v_dst_special:src.dst_table_new_tmp:change_number,change_date,date_ins::'
    );

    checkCase(
      'unknown option'
      , 'dst_table : excludeColumnList = date_ins   unknownOption = jjj'
      , errorMessageMask =>
          '%Неизвестное имя опции: "unknownOption".%'
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при тестировании getTableConfigString.'
        )
      , true
    );
  end getTableConfigStringTest;



-- apiTest
begin
  pkg_TestUtility.beginTest( 'API');
  getTableConfigStringTest();
  pkg_TestUtility.endTest();
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при тестировании API.'
      )
    , true
  );
end apiTest;

/* proc: refreshTest
  Тестирование обновления данных.

  Параметры:
  refreshMethod         - метод обновления ( "d" сравнением данных ( по
                          умолчанию), "m" с помощью материализованного
                          представления, "t" сравнением с использованием
                          временной таблицы)
*/
procedure refreshTest(
  refreshMethod varchar2
)
is



  /*
    Проверяет тестовый случай.
  */
  procedure checkCase(
    caseDescription varchar2
    , tableName varchar2
    , refreshMethod varchar2
    , createMViewFlag integer := 1
  )
  is

    -- Описание тестового случая
    caseInfo varchar2(200) :=
      caseDescription || ' [' || tableName || ']'
    ;

    isClobColumn integer;
    isBlobColumn integer;

    nRow integer;

  -- checkCase
  begin
    -- выполняем в динамическом SQL аналогично выполнению из пакетного задания
    execute immediate
'
begin
  dsn_test_t().refresh(
    forTableName        => :tableName
    , createMViewFlag   => :createMViewFlag
  );
end;
'
    using
      tableName
      , createMViewFlag
    ;

    select
      count(*)
    into nRow
    from
      dsn_test_source
    ;
    pkg_TestUtility.compareRowCount(
      tableName           => tableName
      , expectedRowCount  => nRow
      , failMessageText   =>
          caseInfo
          || ': Некорректное число записей в интерфейсной таблице'
    );

    if refreshMethod = pkg_DataSync.CompareTemp_RefreshMethodCode then
      pkg_TestUtility.compareRowCount(
        tableName           => 'dsn_test_cmptemp_tmp'
        , expectedRowCount  => nRow
        , failMessageText   =>
            caseInfo
            || ': Некорректное число записей во временной таблице'
      );
    end if;

    if not pkg_TestUtility.isTestFailed() then
      select
        max(
            case when lower( tc.column_name) = 'clob_column' then 1 else 0 end
          )
          as is_clob_column
        , max(
            case when lower( tc.column_name) = 'blob_column' then 1 else 0 end
          )
          as is_blob_column
      into isClobColumn, isBlobColumn
      from
        user_tab_columns tc
      where
        tc.table_name = upper( tableName)
      ;
      pkg_TestUtility.compareRowCount(
        tableName           =>
'(
select
  null
from
  ' || tableName || ' d
where
  exists
    (
    select
      null
    from
      dsn_test_source s
    where
      (
        coalesce( s.owner, d.owner) is null
        or s.owner = d.owner
      )
      and (
        coalesce( s.table_name, d.table_name) is null
        or s.table_name = d.table_name
      )
      and (
        coalesce( s.row_uid, d.row_uid) is null
        or s.row_uid = d.row_uid
      )
      and (
        coalesce( s.tablespace_name, d.tablespace_name) is null
        or s.tablespace_name = d.tablespace_name
      )
      and (
        coalesce( s.status, d.status) is null
        or s.status = d.status
      )
      and (
        coalesce( s.num_rows, d.num_rows) is null
        or s.num_rows = d.num_rows
      )
      and (
        coalesce( s.last_analyzed, d.last_analyzed) is null
        or s.last_analyzed = d.last_analyzed
      )'
|| case when isClobColumn = 1 then
'
      and (
        s.clob_column is null
          and d.clob_column is null
        or s.clob_column is not null
          and d.clob_column is not null
          and dbms_lob.compare( s.clob_column, d.clob_column) = 0
      )'
  end
|| case when isBlobColumn = 1 then
'
      and (
        s.blob_column is null
          and d.blob_column is null
        or s.blob_column is not null
          and d.blob_column is not null
          and dbms_lob.compare( s.blob_column, d.blob_column) = 0
      )'
  end
|| '
    )
)'
        , expectedRowCount  => nRow
        , failMessageText   =>
            caseInfo
            || ': Некорректные данные в интерфейсной таблице'
      );
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при выполнении теста ('
          || ' caseDescription="' || caseDescription || '"'
          || ', tableName="' || tableName || '"'
          || ').'
        )
      , true
    );
  end checkCase;



  /*
    Подготавливает данные к началу теста.
  */
  procedure prepareData(
    tableName varchar2
    , refreshMethod varchar2
  )
  is
  begin
    if refreshMethod = pkg_DataSync.MView_RefreshMethodCode then
      begin
        execute immediate
          'drop materialized view log on dsn_test_source'
        ;
      exception when others then
        logger.clearErrorStack();
      end;
      begin
        execute immediate
          'drop materialized view ' || tableName || ' preserve table'
        ;
      exception when others then
        logger.clearErrorStack();
      end;
      begin
        execute immediate
          'drop materialized view log on ' || tableName
        ;
      exception when others then
        logger.clearErrorStack();
      end;
    end if;

    -- подготавливаем тестовые данные
    delete
      dsn_test_source t
    where
      t.owner = 'dsn_test'
    ;
    insert into
      dsn_test_source
    (
      owner
      , table_name
      , row_uid
      , num_rows
      , clob_column
      , blob_column
    )
    select
      'dsn_test' as owner
      , 't' || level as table_name
      , 'dsn_test.t' || level as row_uid
      , level as num_rows
      , case when mod( level, 2) = 1 then
          'clob_' || level
        end
        as clob_column
      , case when mod( level, 2) = 1 then
          hextoraw( to_char( level + 64*64*64, 'fmxxxxxx'))
        end
        as blob_column
    from
      dual
    connect by
      level <= 100
    ;
    commit;
    execute immediate
      'truncate table ' || tableName
    ;
    if refreshMethod = pkg_DataSync.MView_RefreshMethodCode then
      dsn_test_t().createMLog(
        forTableName => tableName
      );
      dsn_test_source_t().createMLog(
        forTableName => 'dsn_test_source'
      );
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при подготовке данных к началу теста.'
        )
      , true
    );
  end prepareData;



  /*
    Вносит изменение в исходные данные.
  */
  procedure changeData(
    changeNumber pls_integer
  )
  is
  begin
    delete
      dsn_test_source t
    where
      t.owner = 'dsn_test'
      and t.table_name = 't1' || changeNumber
    ;
    update
      dsn_test_source t
    set
      t.last_analyzed = sysdate
      , t.status = 'upd: ' || changeNumber
    where
      t.owner = 'dsn_test'
      and t.table_name = 't2' || changeNumber
    ;
    insert into
      dsn_test_source
    (
      owner
      , table_name
      , status
    )
    values
    (
      'dsn_test'
      , 'i1' || changeNumber
      , 'ins: ' || changeNumber
    );

    -- меняем значение уникального ключа на значение из предварительно
    -- удаленной записи
    delete
      dsn_test_source t
    where
      t.owner = 'dsn_test'
      and t.table_name = 't3' || changeNumber
    ;
    update
      dsn_test_source t
    set
      t.row_uid = replace( t.row_uid, '.t4', '.t3')
      , t.last_analyzed = sysdate
      , t.status = 'upd: ' || changeNumber
    where
      t.owner = 'dsn_test'
      and t.table_name = 't4' || changeNumber
    ;

    -- меняем только CLOB и BLOB
    update
      dsn_test_source t
    set
      t.clob_column = 'upd: ' || changeNumber
      , t.blob_column = hextoraw( to_char( changeNumber, 'fmx'))
    where
      t.owner = 'dsn_test'
      and t.table_name = 't5' || changeNumber
    ;

    commit;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при изменении исходных данных ('
          || ' changeNumber=' || changeNumber
          || ').'
        )
      , true
    );
  end changeData;



  /*
    Тест выполнения обновления данных.
  */
  procedure processTest
  is

    cursor tableCur is
      select
        a.*
      from
        (
        select
          rownum as list_order
          , pkg_Common.getStringByDelimiter( t.column_value, ':', 1)
            as table_name
          , coalesce(
              pkg_Common.getStringByDelimiter( t.column_value, ':', 2)
              , pkg_DataSync.Compare_RefreshMethodCode
            )
            as refresh_method
        from
          table( dsn_test_t().tableList) t
        ) a
      where
        nullif( refreshMethod, a.refresh_method) is null
      order by
        a.list_order
    ;

    testedMethod varchar2(1);

  begin
    for rec in tableCur loop
      if coalesce( rec.refresh_method != testedMethod, true) then
        if testedMethod is not null then
          pkg_TestUtility.endTest();
        end if;
        pkg_TestUtility.beginTest(
          'refresh: method "' || rec.refresh_method || '"'
        );
        testedMethod := rec.refresh_method;
      end if;
      begin
        if rec.table_name not like 'dsn\_%' escape '\' then
          raise_application_error(
            pkg_Error.IllegalArgument
            , 'Некорректное имя таблицы для тестирования.'
          );
        end if;

        prepareData(
          tableName       => rec.table_name
          , refreshMethod => rec.refresh_method
        );

        checkCase( 'first refresh', rec.table_name, rec.refresh_method);

        checkCase( 'without change', rec.table_name, rec.refresh_method);

        changeData( 1);
        checkCase( 'after change', rec.table_name, rec.refresh_method);

        changeData( 2);
        checkCase( 'after change N2', rec.table_name, rec.refresh_method);

        if rec.refresh_method = pkg_DataSync.MView_RefreshMethodCode then
          execute immediate
            'drop materialized view log on dsn_test_source'
          ;
          changeData( 3);
          dsn_test_source_t().createMLog(
            forTableName => 'dsn_test_source'
          );

          -- чтобы дата создания м-представления была больше даты пересоздания
          -- лога
          dbms_lock.sleep(1);

          checkCase(
            'after recreate mlog', rec.table_name, rec.refresh_method
          );

          changeData( 4);
          checkCase(
            'after recreate mview', rec.table_name, rec.refresh_method
          );
        end if;
      exception when others then
        pkg_TestUtility.failTest(
          failMessageText  =>
            'Ошибка при тестировании обновления ' || rec.table_name
            || ' методом "' || rec.refresh_method || '":'
            || chr(10) || logger.getErrorStack()
        );
      end;
    end loop;
    pkg_TestUtility.endTest();
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при тестировании тривиальных обновления данных.'
        )
      , true
    );
  end processTest;



-- refreshTest
begin
  processTest();
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при тестировании обновления данных.'
      )
    , true
  );
end refreshTest;

/* proc: testAppendData
  Тестирует выгрузку данных функцией <pkg_DataSync.appendData>.

  Параметры:
  testCaseNumber              - Номер проверяемого тестового случая
                                (по умолчанию без ограничений)
*/
procedure testAppendData(
  testCaseNumber integer := null
)
is

  -- Порядковый номер проверяемого тестового случая
  checkCaseNumber integer := 0;

  -- Имя линка, указывающего на локальные объекты
  localLinkName varchar2(128);



  /*
    Подготовка данных для теста.
  */
  procedure prepareTestData
  is

    pragma autonomous_transaction;

  begin
    select global_name into localLinkName from global_name;
    execute immediate 'truncate table dsn_test_app_dst';
    execute immediate 'truncate table dsn_test_app_dst_a1';
    execute immediate 'truncate table dsn_test_app_dst_a2';
    delete dsn_test_app_source where app_source_id > 25000;
    commit;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при подготовке данных для теста.'
        )
      , true
    );
  end prepareTestData;


  /*
    Добавляет записи в исходную таблицу.
  */
  procedure addSourceRow(
    rowCount integer
    , dateIns date := null
  )
  is

    pragma autonomous_transaction;

  begin
    insert /*+ append */ into
      dsn_test_app_source
    (
      app_source_id
      , owner
      , object_name
      , subobject_name
      , object_id
      , object_type
      , last_ddl_time
      , clob_column
      , blob_column
      , date_ins
    )
    select
      t.app_source_id + max_app_source_id as app_source_id
      , t.owner
      , t.object_name
      , t.subobject_name
      , t.object_id
      , t.object_type
      , t.last_ddl_time
      , t.clob_column
      , t.blob_column
      , coalesce( dateIns, t.date_ins) as date_ins
    from
      dsn_test_app_source t
      , (
        select
          max( app_source_id) as max_app_source_id
        from
          dsn_test_app_source
        )
    where
      t.app_source_id <= rowCount
    ;
    commit;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при добавлении записей в исходную таблицу ('
          || ' rowCount=' || rowCount
          || ').'
        )
      , true
    );
  end addSourceRow;



  /*
    Проверяет тестовый случай.
  */
  procedure checkCase(
    caseDescription varchar2
    , targetDbLink varchar2 := localLinkName
    , tableName varchar2 := null
    , idTableName varchar2 := null
    , addonTableList cmn_string_table_t := null
    , addonTableName varchar2 := null
    , addonSourceTableName varchar2 := null
    , addonExcludeColumnList varchar2 := null
    , sourceTableName varchar2 := null
    , excludeColumnList varchar2 := null
    , toDate date := null
    , maxExecTime interval day to second := null
    , resultRowCount integer := null
    , tableRowCount integer := null
    , addonTableRowCount integer := null
    , addon1RowCount integer := null
    , addon2RowCount integer := null
    , execErrorMessageMask varchar2 := null
    , nextCaseUsedCount pls_integer := null
  )
  is

    -- Описание тестового случая
    cinfo varchar2(200) :=
      'CASE ' || to_char( checkCaseNumber + 1)
      || ': "' || caseDescription || '": '
    ;

    execErrorMessage varchar2(32000);

    resNum number;



    /*
      Проверяет число записей в дополнительной таблице.
    */
    procedure checkAddonRowCount(
      iAddon integer
      , expectedRowCount integer
    )
    is

      tableName varchar2(300);

    begin
      tableName := substr(
        addonTableList( iAddon)
        , 1
        , instr( addonTableList( iAddon) || ':', ':') - 1
      );
      pkg_TestUtility.compareRowCount(
        tableName           => tableName
        , expectedRowCount  => expectedRowCount
        , failMessageText   =>
            cinfo || 'Неожиданное число записей в дополнительной таблице '
            || tableName
      );
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.errorStack(
            'Ошибка при проверке числа записей в дополнительной таблице ('
            || ' iAddon=' || iAddon
            || ', expectedRowCount=' || expectedRowCount
            || ').'
          )
        , true
      );
    end checkAddonRowCount;



  -- checkCase
  begin
    checkCaseNumber := checkCaseNumber + 1;
    if pkg_TestUtility.isTestFailed()
          or testCaseNumber is not null
            and testCaseNumber
              not between checkCaseNumber
                and checkCaseNumber + coalesce( nextCaseUsedCount, 0)
        then
      return;
    end if;
    logger.info( '*** ' || cinfo);
    begin
      if addonTableName is not null
            or addonSourceTableName is not null
            or addonExcludeColumnList is not null
          then
        resNum := pkg_DataSync.appendData(
          targetDbLink              => targetDbLink
          , tableName               => tableName
          , idTableName             => idTableName
          , addonTableName          => addonTableName
          , addonSourceTableName    => addonSourceTableName
          , addonExcludeColumnList  => addonExcludeColumnList
          , sourceTableName         => sourceTableName
          , excludeColumnList       => excludeColumnList
          , toDate                  => toDate
          , maxExecTime             => maxExecTime
        );
      else
        resNum := pkg_DataSync.appendData(
          targetDbLink              => targetDbLink
          , tableName               => tableName
          , idTableName             => idTableName
          , addonTableList          => addonTableList
          , sourceTableName         => sourceTableName
          , excludeColumnList       => excludeColumnList
          , toDate                  => toDate
          , maxExecTime             => maxExecTime
        );
      end if;
      if execErrorMessageMask is not null then
        pkg_TestUtility.failTest(
          failMessageText   =>
            cinfo || 'Успешное выполнение вместо ошибки'
        );
      end if;
    exception when others then
      if execErrorMessageMask is not null then
        execErrorMessage := logger.getErrorStack();
        if execErrorMessage not like execErrorMessageMask then
          pkg_TestUtility.compareChar(
            actualString        => execErrorMessage
            , expectedString    => execErrorMessageMask
            , failMessageText   =>
                cinfo || 'Сообщение об ошибке не соответствует маске'
          );
        end if;
      else
        pkg_TestUtility.failTest(
          failMessageText   =>
            cinfo || 'Выполнение завершилось с ошибкой:'
            || chr(10) || logger.getErrorStack()
        );
      end if;
    end;

    -- Проверка успешного результата
    if execErrorMessageMask is null and not pkg_TestUtility.isTestFailed() then
      if resultRowCount is not null then
        pkg_TestUtility.compareChar(
          actualString        => resNum
          , expectedString    => resultRowCount
          , failMessageText   =>
              cinfo || 'Неожиданное число выгруженных записей'
        );
      end if;
      if tableRowCount is not null then
        pkg_TestUtility.compareRowCount(
          tableName           => tableName
          , expectedRowCount  => tableRowCount
          , failMessageText   =>
              cinfo || 'Неожиданное число записей в таблице ' || tableName
        );
      end if;
      if addonTableRowCount is not null then
        pkg_TestUtility.compareRowCount(
          tableName           => addonTableName
          , expectedRowCount  => addonTableRowCount
          , failMessageText   =>
              cinfo || 'Неожиданное число записей в таблице ' || addonTableName
        );
      end if;
      if addon1RowCount is not null then
        checkAddonRowCount(
          iAddon => 1
          , expectedRowCount => addon1RowCount
        );
      end if;
      if addon2RowCount is not null then
        checkAddonRowCount(
          iAddon => 2
          , expectedRowCount => addon2RowCount
        );
      end if;
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при проверке тестового случая ('
          || ' caseNumber=' || checkCaseNumber
          || ', caseDescription="' || caseDescription || '"'
          || ').'
        )
      , true
    );
  end checkCase;



-- testAppendData
begin
  prepareTestData();
  pkg_TestUtility.beginTest( 'append data');

  checkCase(
    'Первоначальная выгрузка (все параметры)'
    , tableName               => 'dsn_test_app_dst'
    , idTableName             => 'dsn_test_app_source'
    , addonTableList          =>
        cmn_string_table_t(
          'dsn_test_app_dst_a1 : v_dsn_test_app_dst_a1_src'
          , 'dsn_test_app_dst_a2 : v_dsn_test_app_dst_a1_src'
            || ' : excludeColumnList=last_ddl_time'
        )
    , sourceTableName         => 'v_dsn_test_app_dst_src'
    , excludeColumnList       => 'object_Id,subobject_name'
    , toDate                  => sysdate
    , maxExecTime             => INTERVAL '5' MINUTE
    , resultRowCount          => 25000
    , tableRowCount           => 25000
    , addon1RowCount          => 50000
    , addon2RowCount          => 50000
  );

  checkCase(
    'Повторая выгрузка (нет новых записей)'
    , tableName               => 'dsn_test_app_dst'
    , idTableName             => 'dsn_test_app_source'
    , addonTableList          =>
        cmn_string_table_t(
          'dsn_test_app_dst_a1 : v_dsn_test_app_dst_a1_src'
          , 'dsn_test_app_dst_a2 : v_dsn_test_app_dst_a1_src'
            || ' : excludeColumnList=last_ddl_time'
        )
    , sourceTableName         => 'v_dsn_test_app_dst_src'
    , excludeColumnList       => 'object_Id,subobject_name'
    , toDate                  => sysdate
    , maxExecTime             => INTERVAL '5' MINUTE
    , resultRowCount          => 0
    , tableRowCount           => 25000
    , addon1RowCount          => 50000
    , addon2RowCount          => 50000
  );

  addSourceRow( rowCount => 3, dateIns => sysdate - 3/24);
  addSourceRow( rowCount => 2, dateIns => sysdate - 3/24/60);

  checkCase(
    'Повторая выгрузка (слишком новые записи игнорируются)'
    , tableName               => 'dsn_test_app_dst'
    , idTableName             => 'dsn_test_app_source'
    , addonTableList          =>
        cmn_string_table_t(
          'dsn_test_app_dst_a1 : v_dsn_test_app_dst_a1_src'
          , 'dsn_test_app_dst_a2 : v_dsn_test_app_dst_a1_src'
            || ' : excludeColumnList=last_ddl_time'
        )
    , sourceTableName         => 'v_dsn_test_app_dst_src'
    , excludeColumnList       => 'object_Id,subobject_name'
    , toDate                  => null
    , maxExecTime             => INTERVAL '5' MINUTE
    , resultRowCount          => 3
    , tableRowCount           => 25003
    , addon1RowCount          => 50006
    , addon2RowCount          => 50006
  );

  checkCase(
    'Повторая выгрузка (SIMPLE)'
    , tableName               => 'dsn_test_app_dst'
    , idTableName             => 'dsn_test_app_source'
    , addonTableName          => 'dsn_test_app_dst_a2'
    , addonSourceTableName    => 'v_dsn_test_app_dst_a1_src'
    , addonExcludeColumnList  => 'last_ddl_time'
    , sourceTableName         => 'v_dsn_test_app_dst_src'
    , excludeColumnList       => 'object_Id,subobject_name'
    , toDate                  => sysdate
    , maxExecTime             => INTERVAL '5' MINUTE
    , resultRowCount          => 2
    , tableRowCount           => 25005
    , addonTableRowCount      => 50010
  );

  pkg_TestUtility.endTest();
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при тестировании функции appendData ('
        || 'testCaseNumber=' || testCaseNumber
        || ').'
      )
    , true
  );
end testAppendData;

end pkg_DataSyncTest;
/
