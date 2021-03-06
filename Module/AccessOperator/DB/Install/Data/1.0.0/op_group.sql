-- script: Install\Data\Last\op_group.sql
-- ?????????? ?????????????? ????? ??? ?????? ? ???????

merge into
  op_group dest
using
  (
  select
    k.group_id
    , k.group_name
    , k.group_name_en
    , 1 as operator_id
  from
    (
    select
      t.group_id
      , t.group_name
      , t.group_name_en
    from
      (
      select
        1 as group_id
        , '?????? ??????' as group_name
        , 'Full Access'   as group_name_en
      from
        dual
      ) t
    minus
    select
      opg.group_id
      , opg.group_name
      , opg.group_name_en
    from
      op_group opg
    ) k
  ) src
on
  (dest.group_id = src.group_id)
when not matched then
  insert (
    dest.group_id
    , dest.group_name
    , dest.group_name_en
    , dest.operator_id
  )
  values (
    src.group_id
    , src.group_name
    , src.group_name_en
    , src.operator_id
    )
when matched then
  update set
    dest.group_name = src.group_name
    , dest.group_name_en = src.group_name_en
/
commit
/
