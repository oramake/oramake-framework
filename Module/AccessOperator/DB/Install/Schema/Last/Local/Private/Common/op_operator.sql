-- script: Install/Schema/Last/Local/Private/Main/op_operator.sql
-- Изменение pivate части таблицы <op_operator>


prompt disable all triggers on op_operator

alter table
  op_operator
disable all triggers
/


prompt add new columns into op_operator

alter table
  op_operator
add
  (
  action_type_code varchar2(20) default 'CREATEOPERATOR' not null
  , computer_name varchar2(100)
  , ip_address varchar2(15)
  , change_number integer default 1
  , change_date date default sysdate not null
  , change_operator_id integer
  )
/

comment on column op_operator.action_type_code is
  'Код типа действия'
/
comment on column op_operator.computer_name is
  'Имя компьютера, с которого производились последние действия'
/
comment on column op_operator.ip_address is
  'IP адрес компьютера, с которого производились последние действия'
/
comment on column op_operator.change_number is
  'Номер изменения записи'
/
comment on column op_operator.change_date is
  'Дата последнего изменения записи'
/
comment on column op_operator.change_operator_id is
  'ИД оператора, который изменял запись последним'
/


prompt add new constraints on op_operator

alter table
  op_operator
add
  constraint op_operator_ck_change_number check ( change_number >= 1)
/


prompt set change_operator_id in op_operator

update
  op_operator op
set
  op.change_operator_id = op.operator_id_ins
  , op.change_date = op.date_ins
/

commit
/


prompt modify change_operator_id in op_operator to not null


alter table
  op_operator
modify
  (
  change_operator_id not null
  )
/


prompt enable all triggers on op_operator

alter table
  op_operator
enable all triggers
/
