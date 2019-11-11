-- script: Install/Data/1.0.0/Local/private/Main/op_role.sql
-- Добавление первоначальных ролей

merge into
  op_role d
using
  (
  select
    t.role_id
    , t.short_name
    , t.role_name_rus
    , t.role_name_eng
    , t.description
  from
    (
    select
      1 as role_id
      , 'useradmin' as short_name
      , 'администратор юзеров' as role_name_rus
      , 'n/a' as role_name_eng
      , null as description
    from
      dual
    union all
    select
      5 as role_id
      , 'roleadmin' as short_name
      , 'администратор прав доступа' as role_name_rus
      , 'permissions administrator' as role_name_eng
      , null as description
    from
      dual
  ) t
  minus
  select
    opr.role_id
    , opr.short_name
    , opr.role_name_rus
    , opr.role_name_eng
    , opr.description
  from
    op_role opr
  ) s
on
  (
  d.role_id = s.role_id
  )
when not matched then insert
  (
  role_id
  , short_name
  , role_name_rus
  , role_name_eng
  , description
  )
values
  (
  s.role_id
  , s.short_name
  , s.role_name_rus
  , s.role_name_eng
  , s.description
  )
when matched then update set
  d.short_name            = s.short_name
  , d.role_name_rus       = s.role_name_rus
  , d.role_name_eng       = s.role_name_eng
  , d.description         = s.description
/

commit
/
