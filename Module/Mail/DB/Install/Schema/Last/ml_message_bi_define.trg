--trigger: ml_message_bi_define
--����������� ������� ������������� ������
create or replace trigger ml_message_bi_define
 before insert
 on ml_message
 for each row
begin
                                        --���������� �������� ���������� �����.     
if :new.Message_ID is null then
  select ml_Message_Seq.nextval into :new.Message_ID from dual;
end if;
                                        --��������, ��������� ������.
if :new.Operator_ID is null then
  :new.Operator_ID := pkg_Operator.GetCurrentUserID;
end if;
                                        --���������� ����� �������� ������.
if :new.Date_Ins is null then
  :new.Date_Ins := sysdate;
end if;
                                        --����������� ����� �����������
:new.Sender_Address := lower( trim( :new.Sender_Address));
                                        --����������� ����� ����������
:new.Recipient_Address := lower( trim( :new.Recipient_Address));

end;--trigger;
/
