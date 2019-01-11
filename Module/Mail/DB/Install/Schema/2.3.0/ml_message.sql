alter table
  ml_message
add (
  retry_send_count                  integer
);

comment on column ml_message.retry_send_count is
  'Количество повторных попыток отправки сообщения'
/

