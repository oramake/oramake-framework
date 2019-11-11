--trigger: op_password_hist_bi_define
-- create trigger op_password_hist_bi_define
create or replace trigger op_password_hist_bi_define
 before
 insert
 on op_password_hist
 referencing old as old new as new
 for each row
begin
  --���������� �������� ���������� �����.
  if :new.password_history_id is null then
    select
      op_password_hist_seq.nextval
    into
      :new.password_history_id
    from
      dual;
  end if;

  --��������, ��������� ������.
  if :new.Operator_id_ins is null then
    :new.Operator_id_ins := 1;
  end if;
end op_password_hist_bi_define;
/
