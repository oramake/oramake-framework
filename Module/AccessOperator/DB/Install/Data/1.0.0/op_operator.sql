-- script: Install\Data\Last\op_operator.sql
-- Установка первоначальных операторов

merge into
  op_operator dest
using
  (
  select
    k.operator_id
    , k.login
    , k.operator_name
    , k.operator_name_en
    , k.password
    , k.change_password
    , k.date_begin
    , k.date_finish
    , 3 as login_attempt_group_id
    , 1 as operator_id_ins
  from
    (
    select
      t.operator_id
      , t.login
      , t.operator_name
      , t.operator_name_en
      , t.password
      , t.change_password
      , t.date_begin
      , t.date_finish
    from
      (
      select
        1 as operator_id
        , 'ServerSezam' as login
        , 'Server' as operator_name
        , 'N/A' as operator_name_en
        , '161CA9F82E72B4041580533241CDBAE7' as password
        , 0 as change_password
        , cast( null as date) as date_begin
        , cast( null as date) as date_finish
      from
        dual
      union all
      select
        5 as operator_id
        , 'Guest' as login
        , 'Гость' as operator_name
        , 'N/A' as operator_name_en
        , 'ADB831A7FDD83DD1E2A309CE7591DFF8' as password
        , 0  as change_password
        , cast( null as date) as date_begin
        , cast( null as date)as date_finish
      from
        dual
      ) t
    minus
    select
      op.operator_id
      , op.login
      , op.operator_name
      , op.operator_name_en
      , op.password
      , op.change_password
      , op.date_begin
      , op.date_finish
    from
      op_operator op
    ) k
  ) src
on
  (dest.operator_id = src.operator_id)
when not matched then
  insert
    (
    dest.operator_id
    , dest.login
    , dest.operator_name
    , dest.operator_name_en
    , dest.password
    , dest.change_password
    , dest.date_begin
    , dest.date_finish
    , dest.operator_id_ins
    )
  values
    (
    src.operator_id
    , src.login
    , src.operator_name
    , src.operator_name_en
    , src.password
    , src.change_password
    , src.date_begin
    , src.date_finish
    , src.operator_id_ins
    )
when matched then
  update set
    dest.login = src.login
    , dest.operator_name = src.operator_name
    , dest.operator_name_en = src.operator_name_en
    , dest.password = src.password
    , dest.change_password = src.change_password
    , dest.date_begin = src.date_begin
    , dest.date_finish = src.date_finish
/
commit
/
