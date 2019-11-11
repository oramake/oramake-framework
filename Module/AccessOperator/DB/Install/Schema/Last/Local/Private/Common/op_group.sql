-- script: Install/Schema/Last/Local/Private/Main/op_group.sql
-- Изменение pivate части таблицы <op_group>

prompt disable all triggers on op_group

alter table
  op_group
disable all triggers
/


prompt add new columns into op_group

alter table
  op_group
add
  (
  change_number integer default 1
  , change_date date default sysdate not null
  , change_operator_id integer
  )
/

comment on column op_group.change_number is
  'Номер изменения записи'
/
comment on column op_group.change_date is
  'Дата последнего изменения записи'
/
comment on column op_group.change_operator_id is
  'ИД оператора, который изменял запись последним'
/


prompt add new constraints on op_group

alter table
  op_group
add
  constraint op_group_ck_chg_nm check ( change_number >= 1)
/


prompt set change_operator_id in op_group

update
  op_group opr
set
  opr.change_operator_id = opr.operator_id
  , opr.change_date = opr.date_ins
/

commit
/


prompt modify change_operator_id in op_group to not null


alter table
  op_group
modify
  (
  change_operator_id not null
  )
/

prompt enable all triggers on op_group

alter table
  op_group
enable all triggers
/
