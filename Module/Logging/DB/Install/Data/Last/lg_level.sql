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
        , 'Логирование отключено' as level_name
        , 'Уровень используется для отключения логирования' as level_description
      from dual
      union all
      select
        pkg_Logging.Fatal_LevelCode
        , 800
        , 'Фатальная ошибка'
        , ''
      from dual
      union all
      select
        pkg_Logging.Error_LevelCode
        , 700
        , 'Ошибка'
        , ''
      from dual
      union all
      select
        pkg_Logging.Warn_LevelCode
        , 600
        , 'Предупреждение'
        , ''
      from dual
      union all
      select
        pkg_Logging.Info_LevelCode
        , 500
        , 'Информация'
        , ''
      from dual
      union all
      select
        pkg_Logging.Debug_LevelCode
        , 400
        , 'Отладка'
        , ''
      from dual
      union all
      select
        pkg_Logging.Trace_LevelCode
        , 300
        , 'Трассировка'
        , ''
      from dual
      union all
      select
        pkg_Logging.Trace2_LevelCode
        , 200
        , 'Трассировка уровня 2'
        , ''
      from dual
      union all
      select
        pkg_Logging.Trace3_LevelCode
        , 100
        , 'Трассировка уровня 3'
        , ''
      from dual
      union all
      select
        pkg_Logging.All_LevelCode
        , 0
        , 'Максимальный уровень логирования'
        , 'Уровень используется для включения логирования всех сообщений'
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
        -- временное решение (до перехода Scheduler на использование level_name)
        = coalesce( s.level_description, s.level_name)
  ;
  dbms_output.put_line( 'changed: ' || SQL%ROWCOUNT);
  commit;
end;
/
