-- script: Install/Schema/3.10.0/op_group.sql
-- Изменение private части таблицы <op_group>

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
  is_unused number(1,0) default 0
  , description varchar2(4000)
  , constraint op_group_ck_unused check (is_unused in (0,1) )
  )
/

comment on column op_group.is_unused is
  'Признак неиспользуемой группы 1-неиспользуемая, 0–используемая (группа НЕ должна включаться в список групп для назначения операторам и в грант группы)'
/
comment on column op_group.description is
  'Описание группы на языке по умолчанию'
/


alter table
  op_group
modify
  (
  is_unused not null
  )
/


prompt enable all triggers on op_group

alter table
  op_group
enable all triggers
/