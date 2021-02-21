-- Install/Data/1.0.0/op_login_attempt_group.sql
-- Установка начальных данных в таблицу <op_login_attempt_group>

merge into
  op_login_attempt_group dst
using
  (
  select
    t.login_attempt_group_id
    , t.login_attempt_group_name
    , t.is_default
    , t.lock_type_code
    , t.max_login_attempt_count
    , t.locking_time
    , t.used_for_cl
    , t.password_validity_period
    , t.block_wait_period
  from
    (
    select
      1 as login_attempt_group_id
      , 'Пользователи' as login_attempt_group_name
      , 1 as is_default
      , 'PERMANENT' as lock_type_code
      , 10 as max_login_attempt_count
      , null as locking_time
      , 0 as used_for_cl
      , 60 as password_validity_period
      , 1 as block_wait_period
    from
      dual
    union all
    select
      2 as login_attempt_group_id
      , 'Пользователи Инфо банка' as login_attempt_group_name
      , 0 as is_default
      , 'TEMPORAL' as lock_type_code
      , 5 as max_login_attempt_count
      , 1800 as locking_time
      , 0 as used_for_cl
      , null as password_validity_period
      , null as block_wait_period
    from
      dual
    union all
    select
      3 as login_attempt_group_id
      , 'Системные сервисы' as login_attempt_group_name
      , 0 as is_default
      , 'UNUSED' as lock_type_code
      , null as max_login_attempt_count
      , null as locking_time
      , 0 as used_for_cl
      , null as password_validity_period
      , null as block_wait_period
    from
      dual
    union all
    select
      4 as login_attempt_group_id
      , 'Для Credilogic' as login_attempt_group_name
      , 0 as is_default
      , 'PERMANENT' as lock_type_code
      , 5 as max_login_attempt_count
      , null as locking_time
      , 1 as used_for_cl
      , 60 as password_validity_period
      , null as block_wait_period
    from
      dual
    union all
    select
      null as login_attempt_group_id
      , 'Пользователи (при удалении сотрудника оператор не блокируется)' as login_attempt_group_name
      , 0 as is_default
      , 'PERMANENT' as lock_type_code
      , 5 as max_login_attempt_count
      , null as locking_time
      , 0 as used_for_cl
      , null as password_validity_period
      , null as block_wait_period
    from
      dual
    union all
    select
      null as login_attempt_group_id
      , 'Пользователи (при удалении сотрудника оператор блокируется через 3 дня)' as login_attempt_group_name
      , 0 as is_default
      , 'PERMANENT' as lock_type_code
      , 5 as max_login_attempt_count
      , null as locking_time
      , 0 as used_for_cl
      , null as password_validity_period
      , 3 as block_wait_period
    from
      dual
    union all
    select
      null as login_attempt_group_id
      , 'Пользователи МультиБанк' as login_attempt_group_name
      , 0 as is_default
      , 'TEMPORAL' as lock_type_code
      , 10 as max_login_attempt_count
      , 180 as locking_time
      , 0 as used_for_cl
      , null as password_validity_period
      , null as block_wait_period
    from
      dual
    union all
    select
      null as login_attempt_group_id
      , 'Пользователи Siebel CRM' as login_attempt_group_name
      , 0 as is_default
      , 'TEMPORAL' as lock_type_code
      , 10 as max_login_attempt_count
      , 180 as locking_time
      , 0 as used_for_cl
      , null as password_validity_period
      , null as block_wait_period
    from
      dual
    ) t
  minus
  select
    k.login_attempt_group_id
    , k.login_attempt_group_name
    , k.is_default
    , k.lock_type_code
    , k.max_login_attempt_count
    , k.locking_time
    , k.used_for_cl
    , k.password_validity_period
    , k.block_wait_period
  from
    op_login_attempt_group k
  ) src
on
  ( upper( trim( dst.login_attempt_group_name)) = upper( trim( src.login_attempt_group_name)))
when not matched then
  insert(
    dst.login_attempt_group_id
    , dst.login_attempt_group_name
    , dst.is_default
    , dst.lock_type_code
    , dst.max_login_attempt_count
    , dst.locking_time
    , dst.used_for_cl
    , dst.block_wait_period
    , dst.operator_id
  )
  values(
    src.login_attempt_group_id
    , src.login_attempt_group_name
    , src.is_default
    , src.lock_type_code
    , src.max_login_attempt_count
    , src.locking_time
    , src.used_for_cl
    , src.block_wait_period
    , 1
  )
/

commit
/