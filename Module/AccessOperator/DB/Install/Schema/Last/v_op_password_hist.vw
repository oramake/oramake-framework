-- view: v_op_password_hist
-- Представление для просмотра истории паролей операторов

create or replace view v_op_password_hist
-- SVN root: Module/AccessOperator
as
select
  oo.operator_id as operator_id
  , oo.password as password
  , coalesce(
      (
      select
        max(h.date_ins)
      from
        op_password_hist h
      where
        h.operator_id = oo.operator_id
      )
      , oo.date_ins
    ) as date_begin
  , to_date('01.01.4000', 'dd.mm.yyyy') as date_end
from
  op_operator oo
union all
select
  oph.operator_id as operator_id
  , oph.password as password
  , coalesce(
      (
      select
        max(oph1.date_ins)
      from
        op_password_hist oph1
      where
        oph1.date_ins < oph.date_ins
        and oph.operator_id = oph1.operator_id
      )
      , (
        select
          op1.date_ins
        from
          op_operator op1
        where
          oph.operator_id = op1.operator_id
        )
    ) as date_begin
  , oph.date_ins as date_end
from
  op_password_hist oph
/

comment on table v_op_password_hist is
  'Представление для просмотра истории паролей операторов'
/
comment on column v_op_password_hist.operator_id is
  'ИД оператора'
/
comment on column v_op_password_hist.password is
  'Хэш пароля оператора'
/
comment on column v_op_password_hist.date_begin is
  'Дата начала дейтсвия оператора оператора'
/
comment on column v_op_password_hist.date_end is
  'Дата оконачния дейтсвия оператора'
/
