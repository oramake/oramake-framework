-- script: Install/Schema/Last/Local/Private/Common/op_role.sql
-- Изменение pivate части таблицы <op_role>

prompt disable all triggers on op_role

alter table
  op_role
disable all triggers
/


prompt add new columns into op_role

alter table
  op_role
add
  (
  change_number integer default 1
  , change_date date default sysdate not null
  , change_operator_id integer
  )
/

comment on column op_role.change_number is
  'Номер изменения записи'
/
comment on column op_role.change_date is
  'Дата последнего изменения записи'
/
comment on column op_role.change_operator_id is
  'ИД оператора, который изменял запись последним'
/


prompt add new constraints on op_role

alter table
  op_role
add
  constraint op_role_ck_chg_nm check ( change_number >= 1)
/


prompt set change_operator_id in op_role

update
  op_role opr
set
  opr.change_operator_id = opr.operator_id
  , opr.change_date = opr.date_ins
/

commit
/


prompt modify change_operator_id in op_role to not null


alter table
  op_role
modify
  (
  change_operator_id not null
  )
/

prompt enable all triggers on op_role

alter table
  op_role
enable all triggers
/
