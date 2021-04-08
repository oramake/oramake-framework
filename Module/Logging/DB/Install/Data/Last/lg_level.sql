begin
  merge into
    lg_level d
  using
  (
    select
      *
    from
      (
      select
        pkg_Logging.Off_LevelCode as level_code
        , 999 as level_order
        , '����������� ���������' as level_name
        , '������� ������������ ��� ���������� �����������' as level_description
      from dual
      union all
      select
        pkg_Logging.Fatal_LevelCode
        , 800
        , '��������� ������'
        , ''
      from dual
      union all
      select
        pkg_Logging.Error_LevelCode
        , 700
        , '������'
        , ''
      from dual
      union all
      select
        pkg_Logging.Warn_LevelCode
        , 600
        , '��������������'
        , ''
      from dual
      union all
      select
        pkg_Logging.Info_LevelCode
        , 500
        , '����������'
        , ''
      from dual
      union all
      select
        pkg_Logging.Debug_LevelCode
        , 400
        , '�������'
        , ''
      from dual
      union all
      select
        pkg_Logging.Trace_LevelCode
        , 300
        , '�����������'
        , ''
      from dual
      union all
      select
        pkg_Logging.Trace2_LevelCode
        , 200
        , '����������� ������ 2'
        , ''
      from dual
      union all
      select
        pkg_Logging.Trace3_LevelCode
        , 100
        , '����������� ������ 3'
        , ''
      from dual
      union all
      select
        pkg_Logging.All_LevelCode
        , 0
        , '������������ ������� �����������'
        , '������� ������������ ��� ��������� ����������� ���� ���������'
      from dual
      )
    minus
    select
      t.level_code
      , t.level_order
      , t.level_name
      , t.level_description
    from
      lg_level t
  ) s
  on
  (
    d.level_code = s.level_code
  )
  when not matched then insert
  (
    level_code
    , level_order
    , level_name
    , level_description
  )
  values
  (
    s.level_code
    , s.level_order
    , s.level_name
    , s.level_description
  )
  when matched then update set
    d.level_order          = s.level_order
    , d.level_name         = s.level_name
    , d.level_description
        -- ��������� ������� (�� �������� Scheduler �� ������������� level_name)
        = coalesce( s.level_description, s.level_name)
  ;
  dbms_output.put_line( 'changed: ' || SQL%ROWCOUNT);
  commit;
end;
/
