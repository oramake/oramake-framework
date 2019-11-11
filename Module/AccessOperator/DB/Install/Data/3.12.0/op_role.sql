-- script: Install/Data/3.12.0/op_role.sql
-- Добавление ролей

merge into
  op_role dest
using
  (
  select
    k.role_id
    , k.short_name
    , k.role_name
    , k.role_name_en
    , k.description
    , 1 as operator_id
  from
    (
    select
      coalesce( t.role_id, opr.role_id ) as role_id
      , t.short_name
      , t.role_name
      , t.role_name_en
      , t.description
    from
      (
      select
        7 as role_id
        , 'OpModifiedUserChangePassword' as short_name
        , 'AccessOperator: изменение паролей модифицированным пользователям' as role_name
        , 'AccessOperator: change password to modified user' as role_name_en
        , 'Право на изменение пароля модифицированным пользователям' as description
      from
        dual
      ) t
    left join
      op_role opr
    on
      t.short_name = opr.short_name
    minus
    select
      opr.role_id
      , opr.short_name
      , opr.role_name
      , opr.role_name_en
      , opr.description
    from
      op_role opr
    ) k
  ) src
on
  ( dest.role_id = src.role_id )
when not matched then
  insert(
    dest.role_id
    , dest.short_name
    , dest.role_name
    , dest.role_name_en
    , dest.description
    , dest.operator_id
  )
  values(
    src.role_id
    , src.short_name
    , src.role_name
    , src.role_name_en
    , src.description
    , src.operator_id
  )
/

commit
/
