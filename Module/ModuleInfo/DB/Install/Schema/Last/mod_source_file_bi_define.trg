-- trigger: mod_source_file_bi_define
-- ������������� ����� ������� <mod_source_file> ��� ������� ������.
create or replace trigger mod_source_file_bi_define
  before insert
  on mod_source_file
  for each row
begin
                                        --���������� �������� ���������� �����
  if :new.source_file_id is null then
    select
      mod_source_file_seq.nextval
    into :new.source_file_id
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
