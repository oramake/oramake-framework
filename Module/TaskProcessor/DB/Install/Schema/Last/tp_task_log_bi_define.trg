-- trigger: tp_task_log_bi_define
-- ������������� ����� ������� <tp_task_log> ��� ������� ������.
create or replace trigger tp_task_log_bi_define
  before insert
  on tp_task_log
  for each row
begin

  -- ���������� �������� ���������� �����
  if :new.task_log_id is null then
    select
      tp_task_log_seq.nextval
    into :new.task_log_id
    from
      dual
    ;
  end if;

  -- Id ���������, ����������� ������
  if :new.operator_id is null then
    :new.operator_id := pkg_Operator.getCurrentUserId();
  end if;

  -- ���������� ���� ���������� ������
  if :new.date_ins is null then
    :new.date_ins := sysdate;
  end if;
end;
/
