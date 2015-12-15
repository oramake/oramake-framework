--trigger: ml_message_state_bi_define
--����������� ������� ������������� ������
create or replace trigger ml_message_state_bi_define
 before insert
 on ml_message_state
 for each row
begin
                                        --��������, ��������� ������.
if :new.Operator_ID is null then
  :new.Operator_ID := pkg_Operator.GetCurrentUserID;
end if;
                                        --���������� ���� �������� ������.
if :new.Date_Ins is null then
  :new.Date_Ins := SysDate;
end if;
      
end;--trigger;
/
