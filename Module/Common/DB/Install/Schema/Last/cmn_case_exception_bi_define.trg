-- trigger: cmn_case_exception_bi_define
-- ������������� ����� ������� <cmn_case_exception> ��� ������� ������.

create or replace trigger cmn_case_exception_bi_define
  before insert
  on cmn_case_exception
  for each row
begin
  -- Id ������
  if :new.exception_case_id is null then
    select
      cmn_case_exception_seq.nextval
    into
      :new.exception_case_id
    from
      dual
    ;
  end if;
  
  -- Id ���������, ����������� ������
  if :new.operator_id is null then
    :new.operator_id := pkg_Operator.GetCurrentUserId();
  end if;

  -- ���������� ����� �������� ������
  if :new.date_ins is null then
    :new.date_ins := sysdate;
  end if;
end cmn_case_exception_bi_define;
/