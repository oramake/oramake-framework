-- trigger: mod_install_type_bi_define
-- ������������� ����� ������� <mod_install_type> ��� ������� ������.
create or replace trigger mod_install_type_bi_define
  before insert
  on mod_install_type
  for each row
begin
                                        --Id ���������, ����������� ������
  if :new.operator_id is null then
    :new.operator_id := pkg_ModuleInfoInternal.getCurrentOperatorId();
  end if;
                                        --���������� ���� ���������� ������
  if :new.date_ins is null then           
    :new.date_ins := sysdate;
  end if;
end;
/
