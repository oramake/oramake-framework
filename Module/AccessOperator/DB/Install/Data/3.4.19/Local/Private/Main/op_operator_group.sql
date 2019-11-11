-- script: Install\Data\3.4.19\op_operator_group.sql
-- Выдача незаблокированным операторам группы 48

begin
  insert into
    op_operator_group opg
      (
      opg.operator_id
      , opg.group_id
      , opg.date_ins
      , opg.operator_id_ins
      )
  select
    k.operator_id
    , k.group_id
    , sysdate 
    , 1
  from
    (
    select
      op.operator_id
      , 48 as group_id
    from
      op_operator op
    where
      op.date_finish is null   
    minus
    select
      t.operator_id
      , t.group_id
    from
      op_operator_group t 
    ) k
  ;
  dbms_output.put_line('Group_id = 48 added to ' || to_char(sql%rowcount) || ' operators.');
end;
/