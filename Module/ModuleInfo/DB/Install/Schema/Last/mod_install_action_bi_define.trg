-- trigger: mod_install_action_bi_define
-- ������������� ����� ������� <mod_install_action> ��� ������� ������.
create or replace trigger mod_install_action_bi_define
  before insert
  on mod_install_action
  for each row
begin
                                        --���������� �������� ���������� �����
  if :new.install_action_id is null then
    select
      mod_install_action_seq.nextval
    into :new.install_action_id
    from
      dual
    ;
  end if;
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
