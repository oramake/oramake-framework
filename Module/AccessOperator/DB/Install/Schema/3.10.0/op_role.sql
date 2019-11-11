-- script: Install/Schema/3.10.0/op_role.sql
-- Изменение private части таблицы <op_role>

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
  is_unused number(1,0) default 0
  , constraint op_role_ck_unused check (is_unused in (0,1) )
  )
/

comment on column op_role.is_unused is
  'Признак неиспользуемой роли 1-неиспользуемая, 0–используемая (роль НЕ должна включаться в список ролей для назначения операторам и в группы)'
/


alter table
  op_role
modify
  (
  is_unused not null
  )
/


prompt enable all triggers on op_role

alter table
  op_role
enable all triggers
/