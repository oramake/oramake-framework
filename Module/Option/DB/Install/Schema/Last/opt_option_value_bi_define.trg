create or replace trigger opt_option_value_bi_define
 before insert
 on opt_option_value
 for each row
begin      
if :new.Option_Value_ID is null then    --���������� �������� ���������� �����.
  select opt_Option_Value_Seq.nextval into :new.Option_Value_ID from dual;
end if;

if :new.Operator_ID is null then        --��������, ��������� ������.
  :new.Operator_ID := pkg_Operator.GetCurrentUserID;
end if;

if :new.Date_Ins is null then           --���������� ���� �������� ������.
  :new.Date_Ins := SysDate;
end if;
  
end;--trigger;
/
