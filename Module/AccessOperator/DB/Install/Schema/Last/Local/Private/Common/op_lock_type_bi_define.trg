-- script: Install/Schema/Last/op_lock_type_bi_define.trg
-- Триггер на заполенние служебных полей в таблице <op_lock_type>

create or replace trigger op_lock_type_bi_define
before insert on op_lock_type
for each row
begin
  if :new.date_ins is null then
    :new.date_ins := sysdate;
  end if;
  if :new.operator_id is null then
    :new.operator_id := pkg_operator.GETCURRENTUSERID();
  end if;
end op_lock_type_bi_define;
/
