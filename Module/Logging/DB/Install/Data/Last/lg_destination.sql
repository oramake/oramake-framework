begin
  merge into
    lg_destination d
  using
  (
    select
      *
    from
      (
      select
        pkg_Logging.DbmsOutput_DestinationCode as destination_code
        , 'Вывод через dbms_output' as destination_description
      from dual
      union all
      select
        pkg_Logging.Scheduler_DestinationCode
        , 'Лог модуля Scheduler'
      from dual
      union all
      select
        pkg_Logging.Table_DestinationCode
        , 'Таблица в БД'
      from dual
      )
    minus
    select
      t.destination_code
      , t.destination_description
    from
      lg_destination t
  ) s
  on
  (
    d.destination_code = s.destination_code
  )
  when not matched then insert
  (
    destination_code
    , destination_description
  )
  values
  (
    s.destination_code
    , s.destination_description
  )
  when matched then update set
    d.destination_description     = s.destination_description
  ;
  dbms_output.put_line( 'changed: ' || SQL%ROWCOUNT);
end;
/

