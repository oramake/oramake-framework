-- view: v_ml_message
-- Интерфейсное представления для таблицы <ml_message>.
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
  'Интерфейсное представления для таблицы <ml_message> [ SVN root: Exchange/Module/Mail]'
/

comment on column v_ml_message.message_id is
  'Идентификатор сообщения'
/
comment on column v_ml_message.send_success_date is
  'Дата успешной отправки сообщения ( для отправляемых сообщений)'
/
comment on column v_ml_message.sender is
  'Адреса отправителей ( кодированныее оригинальные для входящих сообщений, преобразованные для исходящих)'
/
comment on column v_ml_message.recipient is
  'Адреса получателей ( кодированные: оригинальные для входящих сообщений, преобразованные для исходящих)'
/
comment on column v_ml_message.sender_text is
  'Адреса отправителей ( декодированные: преобразованные для входящих сообщений, оригинальные для исходящих)'
/
comment on column v_ml_message.recipient_text is
  'Адреса получателей ( декодированные: преобразованные для входящих сообщений, оригинальные для исходящих)'
/


