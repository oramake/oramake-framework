--trigger: tp_task_type_bi_define
--������������� ����� ������� <tp_task_type> ��� ������� ������.
create or replace trigger tp_task_type_bi_define
  before insert
  on tp_task_type
  for each row
begin
                                        --��������� Id ������
  if :new.task_type_id is null then
    select
      tp_task_type_seq.nextval
    into :new.task_type_id
    from
      dual
    ;
  end if;
                                        --��������, ��������� ������
  if :new.operator_id is null then
    :new.operator_id := pkg_Operator.GetCurrentUserId;
  end if;
                                        --���������� ����� �������� ������
  if :new.date_ins is null then
    :new.date_ins := sysdate;
  end if;
end;
/
