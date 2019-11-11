-- script: Install/Data/1.0.0/Local/private/Main/op_group.sql
-- Добавление первоначальных ролей для работы с модулем

merge into
  op_group dest
using
  (
  select
    k.group_id
    , k.group_name_rus
    , k.group_name
    , k.group_name_eng
    , 1 as operator_id
  from
    (
    select
      t.group_id
      , t.group_name_rus
      , t.group_name
      , t.group_name_eng
      , t.is_grant_only
    from
      (
      select
        1 as group_id
        , 'Полный доступ' as group_name_rus
        , 'Полный доступ' as group_name
        , 'Full Access'   as group_name_eng
      from
        dual
      ) t
    minus
    select
      opg.group_id
      , opg.group_name_rus
      , opg.group_name
      , opg.group_name_eng
    from
      op_group opg
    ) k
  ) src
on
  (dest.group_id = src.group_id)
when not matched then
  insert
    (
    dest.group_id
    , dest.group_name_rus
    , dest.group_name
    , dest.group_name_eng
    , dest.operator_id
    )
  values
    (
    src.group_id
    , src.group_name_rus
    , src.group_name
    , src.group_name_eng
    , src.operator_id
    )
when matched then
  update set
    dest.group_name_rus = src.group_name_rus
    , dest.group_name_eng = src.group_name_eng
/
commit
/
