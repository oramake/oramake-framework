create or replace trigger sch_condition_bi_define
 before insert
 on sch_condition
 for each row
begin

if :new.Condition_ID is null then       --���������� �������� ���������� �����.
  select SCH_Condition_Seq.nextval into :new.Condition_ID from dual;
end if;

if :new.Operator_ID is null then        --��������, ��������� ������.
  :new.Operator_ID := pkg_Operator.GetCurrentUserID;
end if;

if :new.Date_Ins is null then           --���������� ���� �������� ������.
  :new.Date_Ins := SysDate;
end if;

end;--trigger;
/
