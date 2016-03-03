create or replace trigger sch_batch_role_bi_define
 before insert
 on sch_batch_role
 for each row
begin

if :new.Batch_Role_ID is null then --���������� �������� ���������� �����.
  select sch_Batch_Role_Seq.nextval into :new.Batch_Role_ID from dual;
end if;

if :new.Operator_ID is null then        --��������, ��������� ������.
  :new.Operator_ID := pkg_Operator.GetCurrentUserID;
end if;

if :new.Date_Ins is null then           --���������� ���� �������� ������.
  :new.Date_Ins := SysDate;
end if;

end;--trigger;
/
