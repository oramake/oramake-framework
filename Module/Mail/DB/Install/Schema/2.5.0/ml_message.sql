alter table
  ml_message
modify sender_address varchar2(100)
/

alter table
  ml_message
modify recipient_address varchar2(100)
/


comment on column ml_message.sender_address is
  '����� ���������� ( � ��������������� ����)'
/
comment on column ml_message.recipient_address is
  '����� ���������� ( � ��������������� ����)'
/

update
  ml_message
set
  expire_date = date_ins + 90
where
  expire_date is null
/
