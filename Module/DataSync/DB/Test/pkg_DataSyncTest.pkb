create or replace package body pkg_DataSyncTest is
/* package body: pkg_DataSyncTest::body */



/* group: ���������� */

/* ivar: logger
  ����� ������.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => pkg_DataSync.Module_Name
  , objectName  => 'pkg_DataSyncTest'
);



/* group: ������� */

/* proc: apiTest
  ������������ API.
*/
procedure apiTest
is



  /*
    ���� ������� getTableConfigString.
  */
  procedure getTableConfigStringTest
  is



    /*
      ��������� �������� ������.
    */
    procedure checkCase(
      caseDescription varchar2
      , srcString varchar2
      , resultString varchar2 := null
      , sourceSchema varchar2 := null
      , errorMessageMask varchar2 := null
    )
    is

      -- �������� ��������� ������
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
                  || ': ��������� �� ������ �� ������������� �����'
            );
          end if;
        else
          raise;
        end if;
      end;

      -- �������� ��������� ����������
      if errorMessageMask is null then
        pkg_TestUtility.compareChar(
          actualString        => resStr
          , expectedString    => resultString
          , failMessageText   =>
              caseInfo
              || ': ������������ �������� �������'
        );
      end if;
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.errorStack(
            '������ ��� ���������� ����� ('
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
          '%����������� ��� �����: "unknownOption".%'
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ������������ getTableConfigString.'
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
        '������ ��� ������������ API.'
      )
    , true
  );
end apiTest;

/* proc: refreshTest
  ������������ ���������� ������.

  ���������:
  refreshMethod         - ����� ���������� ( "d" ���������� ������ ( ��
                          ���������), "m" � ������� ������������������
                          �������������, "t" ���������� � ��������������
                          ��������� �������)
*/
procedure refreshTest(
  refreshMethod varchar2
)
is



  /*
    ��������� �������� ������.
  */
  procedure checkCase(
    caseDescription varchar2
    , tableName varchar2
    , refreshMethod varchar2
    , createMViewFlag integer := 1
  )
  is

    -- �������� ��������� ������
    caseInfo varchar2(200) :=
      caseDescription || ' [' || tableName || ']'
    ;

    isClobColumn integer;
    isBlobColumn integer;

    nRow integer;

  -- checkCase
  begin
    -- ��������� � ������������ SQL ���������� ���������� �� ��������� �������
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
          || ': ������������ ����� ������� � ������������ �������'
    );

    if refreshMethod = pkg_DataSync.CompareTemp_RefreshMethodCode then
      pkg_TestUtility.compareRowCount(
        tableName           => 'dsn_test_cmptemp_tmp'
        , expectedRowCount  => nRow
        , failMessageText   =>
            caseInfo
            || ': ������������ ����� ������� �� ��������� �������'
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
            || ': ������������ ������ � ������������ �������'
      );
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ���������� ����� ('
          || ' caseDescription="' || caseDescription || '"'
          || ', tableName="' || tableName || '"'
          || ').'
        )
      , true
    );
  end checkCase;



  /*
    �������������� ������ � ������ �����.
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

    -- �������������� �������� ������
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
          '������ ��� ���������� ������ � ������ �����.'
        )
      , true
    );
  end prepareData;



  /*
    ������ ��������� � �������� ������.
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

    -- ������ �������� ����������� ����� �� �������� �� ��������������
    -- ��������� ������
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

    -- ������ ������ CLOB � BLOB
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
          '������ ��� ��������� �������� ������ ('
          || ' changeNumber=' || changeNumber
          || ').'
        )
      , true
    );
  end changeData;



  /*
    ���� ���������� ���������� ������.
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
            , '������������ ��� ������� ��� ������������.'
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

          -- ����� ���� �������� �-������������� ���� ������ ���� ������������
          -- ����
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
            '������ ��� ������������ ���������� ' || rec.table_name
            || ' ������� "' || rec.refresh_method || '":'
            || chr(10) || logger.getErrorStack()
        );
      end;
    end loop;
    pkg_TestUtility.endTest();
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ������������ ����������� ���������� ������.'
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
        '������ ��� ������������ ���������� ������.'
      )
    , true
  );
end refreshTest;

/* proc: testAppendData
  ��������� �������� ������ �������� <pkg_DataSync.appendData>.

  ���������:
  testCaseNumber              - ����� ������������ ��������� ������
                                (�� ��������� ��� �����������)
*/
procedure testAppendData(
  testCaseNumber integer := null
)
is

  -- ���������� ����� ������������ ��������� ������
  checkCaseNumber integer := 0;

  -- ��� �����, ������������ �� ��������� �������
  localLinkName varchar2(128);



  /*
    ���������� ������ ��� �����.
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
          '������ ��� ���������� ������ ��� �����.'
        )
      , true
    );
  end prepareTestData;


  /*
    ��������� ������ � �������� �������.
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
          '������ ��� ���������� ������� � �������� ������� ('
          || ' rowCount=' || rowCount
          || ').'
        )
      , true
    );
  end addSourceRow;



  /*
    ��������� �������� ������.
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

    -- �������� ��������� ������
    cinfo varchar2(200) :=
      'CASE ' || to_char( checkCaseNumber + 1)
      || ': "' || caseDescription || '": '
    ;

    execErrorMessage varchar2(32000);

    resNum number;



    /*
      ��������� ����� ������� � �������������� �������.
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
            cinfo || '����������� ����� ������� � �������������� ������� '
            || tableName
      );
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.errorStack(
            '������ ��� �������� ����� ������� � �������������� ������� ('
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
            cinfo || '�������� ���������� ������ ������'
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
                cinfo || '��������� �� ������ �� ������������� �����'
          );
        end if;
      else
        pkg_TestUtility.failTest(
          failMessageText   =>
            cinfo || '���������� ����������� � �������:'
            || chr(10) || logger.getErrorStack()
        );
      end if;
    end;

    -- �������� ��������� ����������
    if execErrorMessageMask is null and not pkg_TestUtility.isTestFailed() then
      if resultRowCount is not null then
        pkg_TestUtility.compareChar(
          actualString        => resNum
          , expectedString    => resultRowCount
          , failMessageText   =>
              cinfo || '����������� ����� ����������� �������'
        );
      end if;
      if tableRowCount is not null then
        pkg_TestUtility.compareRowCount(
          tableName           => tableName
          , expectedRowCount  => tableRowCount
          , failMessageText   =>
              cinfo || '����������� ����� ������� � ������� ' || tableName
        );
      end if;
      if addonTableRowCount is not null then
        pkg_TestUtility.compareRowCount(
          tableName           => addonTableName
          , expectedRowCount  => addonTableRowCount
          , failMessageText   =>
              cinfo || '����������� ����� ������� � ������� ' || addonTableName
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
          '������ ��� �������� ��������� ������ ('
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
    '�������������� �������� (��� ���������)'
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
    '�������� �������� (��� ����� �������)'
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
    '�������� �������� (������� ����� ������ ������������)'
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
    '�������� �������� (SIMPLE)'
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
        '������ ��� ������������ ������� appendData ('
        || 'testCaseNumber=' || testCaseNumber
        || ').'
      )
    , true
  );
end testAppendData;

end pkg_DataSyncTest;
/
