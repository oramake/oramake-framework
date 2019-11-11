-- script: Install/Data/3.10.0/Local/Private/Main/op_login_attempt_group.sql
--  орректировка данных в таблице <op_login_attempt_group>

update
  op_login_attempt_group t
set
  t.block_wait_period = 1
where
  upper( t.login_attempt_group_name ) = upper( 'ѕользователи' )
/

merge into
  op_login_attempt_group dst
using
  (
  select
    t.login_attempt_group_name
    , t.is_default
    , t.lock_type_code
    , t.max_login_attempt_count
    , t.locking_time
    , t.used_for_cl
    , t.block_wait_period
  from
    (
    select
      'ѕользователи (при удалении сотрудника оператор не блокируетс€)' as login_attempt_group_name
      , 0 as is_default
      , 'PERMANENT' as lock_type_code
      , 5 as max_login_attempt_count
      , null as locking_time
      , 0 as used_for_cl
      , null as block_wait_period
    from
      dual
    union all
    select
      'ѕользователи (при удалении сотрудника оператор блокируетс€ через 3 дн€)' as login_attempt_group_name
      , 0 as is_default
      , 'PERMANENT' as lock_type_code
      , 5 as max_login_attempt_count
      , null as locking_time
      , 0 as used_for_cl
      , 3 as block_wait_period
    from
      dual
    ) t
  minus
  select
    k.login_attempt_group_name
    , k.is_default
    , k.lock_type_code
    , k.max_login_attempt_count
    , k.locking_time
    , k.used_for_cl
    , k.block_wait_period
  from
    op_login_attempt_group k
  ) src
on
  ( upper( dst.login_attempt_group_name ) = upper( src.login_attempt_group_name ) )
when not matched then
  insert(
    dst.login_attempt_group_name
    , dst.is_default
    , dst.lock_type_code
    , dst.max_login_attempt_count
    , dst.locking_time
    , dst.used_for_cl
    , dst.block_wait_period
    , dst.operator_id
  )
  values(
    src.login_attempt_group_name
    , src.is_default
    , src.lock_type_code
    , src.max_login_attempt_count
    , src.locking_time
    , src.used_for_cl
    , src.block_wait_period
    , 1
  )
when matched then
  update set
    dst.is_default = src.is_default
    , dst.lock_type_code = src.lock_type_code
    , dst.max_login_attempt_count = src.max_login_attempt_count
    , dst.locking_time = src.locking_time
    , dst.used_for_cl = src.used_for_cl
    , dst.block_wait_period = src.block_wait_period
/

commit
/
