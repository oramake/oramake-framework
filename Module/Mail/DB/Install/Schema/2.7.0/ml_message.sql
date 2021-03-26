drop index ml_message_ux
/

create unique index
  ml_message_ux
on
  ml_message (
    sender_address
    , recipient_address
    , send_date
    , message_uid
    , case when incoming_flag = 0 or parent_message_id is not null then
        message_id
      end
  )
tablespace &indexTablespace
/

comment on column ml_message.smtp_server is
  'SMTP-сервер для отправки сообщения (NULL для использования SMTP-сервера по умолчанию)'
/
