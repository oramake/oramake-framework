--trigger: tp_task_status_bi_define
--������������� ����� ������� <tp_task_status> ��� ������� ������.
create or replace trigger tp_task_status_bi_define
  before insert
  on tp_task_status
  for each row
begin
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
