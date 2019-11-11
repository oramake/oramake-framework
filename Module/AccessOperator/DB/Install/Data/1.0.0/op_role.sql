-- script: Install/Data/Last/op_role.sql
-- Добавление первоначальных ролей

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
        1 as role_id
        , 'UserAdmin' as short_name
        , 'Администратор юзеров' as role_name
        , 'N/A' as role_name_en
        , null as description
      from
        dual
      union all
      select
        5 as role_id
        , 'RoleAdmin' as short_name
        , 'Администратор прав доступа' as role_name
        , 'Permissions administrator' as role_name_en
        , null as description
      from
        dual
      union all
      select
        6 as role_id
        , 'OpShowUsers' as short_name
        , 'AccessOperator: просмотр операторов, ролей, групп' as role_name
        , 'AccessOperator: show operators, roles, groups' as role_name_en
        , 'Право на просмотр данных операторов, ролей, групп ролей' as description
      from
        dual
      union all
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
