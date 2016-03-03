create or replace trigger opt_option_bi_define
 before insert
 on opt_option
 for each row
begin
if :new.Option_ID is null then          --���������� �������� ���������� �����.
  select opt_Option_Seq.nextval into :new.Option_ID from dual;
end if;

if :new.Operator_ID is null then        --��������, ��������� ������.
  :new.Operator_ID := pkg_Operator.GetCurrentUserID;
end if;

if :new.Date_Ins is null then           --���������� ���� �������� ������.
  :new.Date_Ins := SysDate;
end if;
  
end;--trigger;
/
