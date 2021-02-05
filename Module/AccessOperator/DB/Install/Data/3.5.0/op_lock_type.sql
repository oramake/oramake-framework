-- script: Install/Data/3.5.0/op_lock_type.sql
-- Установка начальных данных в таблицу <op_lock_type>

merge into
  op_lock_type dst
using
  (
  select
    t.lock_type_code
    , t.lock_type_name
  from
    (
    select
      'PERMANENT' as lock_type_code
      , 'Постоянная' as lock_type_name
    from
      dual
    union all
    select
      'TEMPORAL' as lock_type_code
      , 'Временная' as lock_type_name
    from
      dual  
    union all
    select
      'UNUSED' as lock_type_code
      , 'Не используется' as lock_type_name
    from
      dual
    ) t
  minus
  select
    lt.lock_type_code
    , lt.lock_type_name
  from
    op_lock_type lt
  ) src
on
  ( dst.lock_type_code = src.lock_type_code )
when matched then
  update set
    dst.lock_type_name = src.lock_type_name
when not matched then
  insert(
    dst.lock_type_code
    , dst.lock_type_name
    , dst.operator_id
  )
  values(
    src.lock_type_code
    , src.lock_type_name 
    , 1
  )
/

commit
/