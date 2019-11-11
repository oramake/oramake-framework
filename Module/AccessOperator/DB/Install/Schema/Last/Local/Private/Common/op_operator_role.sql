-- script: Install/Schema/Last/Local/Private/Common/op_operator_role.sql
-- Изменение pivate части таблицы <op_operator_role>

prompt disable all triggers on op_operator_role

alter table
  op_operator_role
disable all triggers
/


prompt add new columns into op_operator_role

alter table
  op_operator_role
add
  (
  action_type_code varchar2(20) default 'CREATEOPERATORROLE' not null
  , computer_name varchar2(100)
  , ip_address varchar2(15)
  , change_number integer default 1
  , change_date date default sysdate not null
  , change_operator_id integer
  )
/

comment on column op_operator_role.action_type_code is
  'Код типа действия'
/
comment on column op_operator_role.computer_name is
  'Имя компьютера, с которого производились последние действия'
/
comment on column op_operator_role.ip_address is
  'IP адрес компьютера, с которого производились последние действия'
/
comment on column op_operator_role.change_number is
  'Номер изменения записи'
/
comment on column op_operator_role.change_date is
  'Дата последнего изменения записи'
/
comment on column op_operator_role.change_operator_id is
  'ИД оператора, который изменял запись последним'
/


prompt add new constraints on op_operator_role

alter table
  op_operator_role
add
  constraint op_operator_role_ck_chg_nm check ( change_number >= 1)
/


prompt set change_operator_id in op_operator_role

update
  op_operator_role opr
set
  opr.change_operator_id = opr.operator_id_ins
  , opr.change_date = opr.date_ins
/

commit
/


prompt modify change_operator_id in op_operator_role to not null


alter table
  op_operator_role
modify
  (
  change_operator_id not null
  )
/

prompt enable all triggers on op_operator_role

alter table
  op_operator_role
enable all triggers
/
