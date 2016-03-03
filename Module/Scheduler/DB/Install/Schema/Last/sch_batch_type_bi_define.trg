create or replace trigger sch_batch_type_bi_define
 before insert
 on sch_batch_type
 for each row
begin

if :new.Batch_Type_ID is null then      --���������� �������� ���������� �����.
  select SCH_Batch_Type_Seq.nextval into :new.Batch_Type_ID from dual;
end if;

if :new.Operator_ID is null then        --��������, ��������� ������.
  :new.Operator_ID := pkg_Operator.GetCurrentUserID;
end if;

if :new.Date_Ins is null then           --���������� ���� �������� ������.
  :new.Date_Ins := SysDate;
end if;

end;--trigger;
/
