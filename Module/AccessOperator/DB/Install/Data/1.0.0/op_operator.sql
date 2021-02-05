-- script: Install\Data\Last\op_operator.sql
-- Добавление первоначальных операторов

insert into
  op_operator
(
  operator_id
  , login
  , operator_name
  , operator_name_en
  , password
  , change_password
  , date_begin
  , date_finish
  , login_attempt_group_id
  , operator_id_ins
)
select
  s.operator_id
  , s.login
  , s.operator_name
  , s.operator_name_en
  , s.password
  , 0 as change_password
  , cast( null as date) as date_begin
  , cast( null as date) as date_finish
  , 3 as login_attempt_group_id
  , 1 as operator_id_ins
from
  (
  select
    1 as operator_id
    , 'ServerSezam' as login
    , 'Server' as operator_name
    , 'N/A' as operator_name_en
    , '161CA9F82E72B4041580533241CDBAE7' as password
  from
    dual
  union all
  select
    5 as operator_id
    , 'Guest' as login
    , 'Гость' as operator_name
    , 'N/A' as operator_name_en
    , 'ADB831A7FDD83DD1E2A309CE7591DFF8' as password
  from
    dual
  ) s
where
  not exists
    (
    select
      null
    from
      op_operator t
    where
      t.operator_id = s.operator_id
    )
/

commit
/
