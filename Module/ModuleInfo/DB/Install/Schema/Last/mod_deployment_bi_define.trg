-- trigger: mod_deployment_bi_define
-- ������������� ����� ������� <mod_deployment> ��� ������� ������.
create or replace trigger mod_deployment_bi_define
  before insert
  on mod_deployment
  for each row
begin

  -- ���������� �������� ���������� �����
  if :new.deployment_id is null then
    select
      mod_deployment_seq.nextval
    into :new.deployment_id
    from
      dual
    ;
  end if;

  -- Id ���������, ����������� ������
  if :new.operator_id is null then
    :new.operator_id := pkg_ModuleInfoInternal.getCurrentOperatorId();
  end if;

  -- ���������� ���� ���������� ������
  if :new.date_ins is null then           
    :new.date_ins := sysdate;
  end if;
end;
/
