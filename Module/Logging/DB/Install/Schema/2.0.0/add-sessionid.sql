alter table
  lg_log
add (
  sessionid                     number
)
/

alter table
  lg_log
modify (
  sessionid  not null
      enable novalidate
)
/




comment on column lg_log.sessionid is
  'Идентификатор сессии (значение v$session.audsid либо уникальное отрицательное значение если v$session.audsid равно 0)'
/
