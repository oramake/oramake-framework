-- script: Install/Data/3.5.0/op_role.sql
-- Добавление первоначальных ролей

merge into 
  op_role dest
using  
  (
  select
    k.short_name
    , k.role_name_rus
    , k.role_name
    , k.role_name_eng
    , k.role_name_en
    , k.description
    , 1 as operator_id
  from
    (
    select
      t.short_name
      , t.role_name_rus
      , t.role_name
      , t.role_name_eng
      , t.role_name_en
      , t.description
    from
      (
      select 
        'OpLoginAttemptGroupAdmin' as short_name
        , 'Администратор настроек параметров блокировок' as role_name_rus
        , 'Администратор настроек параметров блокировок' as role_name
        , 'LoginAttemptGroupAdmin' as role_name_eng
        , 'LoginAttemptGroupAdmin' as role_name_en
        , 'Пользователь с данной ролью имеет доступ к настройке параметров блокировки' as description
      from 
        dual
      ) t
    minus
    select
      opr.short_name
      , opr.role_name_rus
      , opr.role_name
      , opr.role_name_eng
      , opr.role_name_en
      , opr.description
    from
      op_role opr
    ) k  
  ) src
on
  (dest.short_name = src.short_name)
when not matched then 
  insert (
    dest.short_name
    , dest.role_name_rus
    , dest.role_name
    , dest.role_name_eng
    , dest.role_name_en
    , dest.description
    , dest.operator_id
  )
  values(
    src.short_name
    , src.role_name_rus
    , src.role_name
    , src.role_name_eng
    , src.role_name_en
    , src.description
    , src.operator_id
    )
when matched then 
  update set
    dest.role_name_rus = src.role_name_rus
    , dest.role_name = src.role_name
    , dest.role_name_eng = src.role_name_eng
    , dest.role_name_en = src.role_name_en
    , dest.description = src.description
/

commit;
/