--view: v_op_password_hist
-- create or replace view v_op_password_hist
create or replace view v_op_password_hist
(operator_id, password, date_begin, date_end)
as
select cast (oo.operator_id as integer), oo.password,
  (case when (select max(h.date_ins) from op_password_hist h where h.operator_id=oo.operator_id) is not null
   then (select max(h1.date_ins) from op_password_hist h1 where h1.operator_id=oo.operator_id)
   else oo.date_ins end),
  to_date('01.01.4000', 'dd.mm.yyyy')
from op_operator oo
union all
select cast (oph.operator_id as integer), oph.password,
  nvl((select max(oph1.date_ins) from op_password_hist oph1 where oph1.date_ins<oph.date_ins and oph.operator_id = oph1.operator_id),
  (select op1.date_ins from op_operator op1 where oph.operator_id = op1.operator_id)),
  oph.date_ins
from op_password_hist oph
/
