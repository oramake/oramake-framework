create or replace trigger sch_result_bi_define
 before insert
 on sch_result
 for each row
begin

if :new.Result_ID is null then          --���������� �������� ���������� �����.
  select SCH_Result_Seq.nextval into :new.Result_ID from dual;
end if;

if :new.Operator_ID is null then        --��������, ��������� ������.
  :new.Operator_ID := pkg_Operator.GetCurrentUserID;
end if;

if :new.Date_Ins is null then           --���������� ���� �������� ������.
  :new.Date_Ins := SysDate;
end if;

end;--trigger;
/
