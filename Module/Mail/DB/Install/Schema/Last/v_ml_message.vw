-- view: v_ml_message
-- ������������ ������������� ��� ������� <ml_message>.
--
create or replace force view
  v_ml_message
as
select
  -- SVN root: Exchange/Module/Mail
  message_id
  , case when
      message_state_code = 'S'
    then
      send_date
    end as send_success_date
  , sender
  , recipient
  , sender_text
  , recipient_text
  , error_message
from
  ml_message
/

comment on table v_ml_message is
  '������������ ������������� ��� ������� <ml_message> [ SVN root: Exchange/Module/Mail]'
/

comment on column v_ml_message.message_id is
  '������������� ���������'
/
comment on column v_ml_message.send_success_date is
  '���� �������� �������� ��������� ( ��� ������������ ���������)'
/
comment on column v_ml_message.sender is
  '������ ������������ ( ������������� ������������ ��� �������� ���������, ��������������� ��� ���������)'
/
comment on column v_ml_message.recipient is
  '������ ����������� ( ������������: ������������ ��� �������� ���������, ��������������� ��� ���������)'
/
comment on column v_ml_message.sender_text is
  '������ ������������ ( ��������������: ��������������� ��� �������� ���������, ������������ ��� ���������)'
/
comment on column v_ml_message.recipient_text is
  '������ ����������� ( ��������������: ��������������� ��� �������� ���������, ������������ ��� ���������)'
/


