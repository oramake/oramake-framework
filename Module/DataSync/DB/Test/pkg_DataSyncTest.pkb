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
      , 'dst_table:d:v_dst_table::'
    );
    checkCase(
      'minimal for temp'
      , 'dst_table : t'
      , 'dst_table:t:v_dst_table:dst_table_tmp:'
    );
    checkCase(
      'minimal for mview'
      , ' dst_table : m '
      , 'dst_table:m:v_dst_table::'
    );

    checkCase(
      'minimal with option'
      , 'dst_table:excludeColumnList=Date_Ins'
      , 'dst_table:d:v_dst_table::date_ins'
    );

    checkCase(
      'with sourceSchema'
      , 'dst_table'
      , 'dst_table:d:tst_user.v_dst_table::'
      , sourceSchema => 'tst_user'
    );

    checkCase(
      'full'
      , 'dst_table : t : tst_user.v_dst_special : src.dst_table_new_tmp :
          excludeColumnList = Change_Number  , change_date, date_ins
        '
      , 'dst_table:t:tst_user.v_dst_special:src.dst_table_new_tmp:change_number,change_date,date_ins'
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

    pkg_TestUtility.compareRowCount(
      tableName           =>
'(
select
  t.owner
  , t.table_name
  , t.row_uid
  , t.tablespace_name
  , t.status
  , t.num_rows
  , t.last_analyzed
from
  ' || tableName || ' t
intersect
select
  s.*
from
  dsn_test_source s
)'
      , expectedRowCount  => nRow
      , failMessageText   =>
          caseInfo
          || ': ������������ ������ � ������������ �������'
    );
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
    )
    select
      'dsn_test' as owner
      , 't' || level as table_name
      , 'dsn_test.t' || level as row_uid
      , level as num_rows
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

end pkg_DataSyncTest;
/
