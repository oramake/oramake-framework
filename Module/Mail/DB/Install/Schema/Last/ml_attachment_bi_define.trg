--trigger: ml_attachment_bi_define
--����������� ������� ������������� ������
create or replace trigger ml_attachment_bi_define
 before insert
 on ml_attachment
 for each row
begin
                                        --���������� �������� ���������� �����.     
if :new.Attachment_ID is null then
  select ml_Attachment_Seq.nextval into :new.Attachment_ID from dual;
end if;
                                        --��������, ��������� ������.
if :new.Operator_ID is null then
  :new.Operator_ID := pkg_Operator.GetCurrentUserID;
end if;
                                        --���������� ����� �������� ������.
if :new.Date_Ins is null then
  :new.Date_Ins := sysdate;
end if;

end;--trigger;
/
