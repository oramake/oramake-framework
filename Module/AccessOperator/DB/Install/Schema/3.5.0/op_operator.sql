-- script: Install/Schema/3.5.0/op_operator.sql
-- Изменение таблицы <op_operator>

alter table
  op_operator
disable all triggers
/

alter table
  op_operator
add
  (
  login_attempt_group_id integer
  , curr_login_attempt_count integer default 0
  , last_success_login_date date
  )
/

comment on column op_operator.login_attempt_group_id is
  'Идентификатор группы параметров блокировки'
/
comment on column op_operator.curr_login_attempt_count is
  'Текущее количество неуспешных попыток входа'
/
comment on column op_operator.last_success_login_date is
  'Дата/время последнего успешного входа в систему'
/


prompt set new fields in op_operator

update
  op_operator op
set
  op.login_attempt_group_id =
    case when
      op.operator_id in (1, 5)
    then
      3
    else
      1
    end
/

commit
/

alter table
  op_operator
enable all triggers
/
