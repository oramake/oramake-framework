-- Script: Переносит записи об email в новую <ml_message> 
-- из <ml_message_2_4_0>
declare 
  -- Local variables here
  DaysBefore integer := &DaysBefore;
begin
  -- Test statements here
  insert into
    ml_message
  (
    message_id
    , parent_message_id
    , incoming_flag
    , sender_address
    , recipient_address
    , message_state_code
    , smtp_server
    , sender_text
    , recipient_text
    , copy_recipient_text
    , sender
    , recipient
    , copy_recipient
    , send_date
    , subject
    , content_type
    , message_size
    , message_uid
    , source_message_id
    , message_text
    , process_date
    , expire_date
    , retry_send_count
    , error_code
    , error_message
    , is_html
    , fetch_request_id
    , mailbox_delete_date
    , mailbox_for_delete_flag
    , date_ins
    , operator_id
  )
  select
    message_id
    , parent_message_id
    , incoming_flag
    , sender_address
    , recipient_address
    , message_state_code
    , smtp_server
    , sender_text
    , recipient_text
    , copy_recipient_text
    , sender
    , recipient
    , copy_recipient
    , send_date
    , subject
    , content_type
    , message_size
    , message_uid
    , source_message_id
    , message_text
    , process_date
    , coalesce(expire_date, date_ins + 90)
    , retry_send_count
    , error_code
    , error_message
    , is_html
    , fetch_request_id
    , mailbox_delete_date
    , mailbox_for_delete_flag
    , date_ins
    , operator_id
  from
    ml_message_2_4_0
  where
    expire_date is not null
    or date_ins > trunc(sysdate) - DaysBefore
  ;
  dbms_output.put_line('email copied: ' || sql%rowcount);
  insert into
    ml_attachment
  (
    attachment_id
    , message_id
    , file_name
    , content_type
    , attachment_data
    , is_image_content_id
    , date_ins
    , operator_id
  )
  select
    a.attachment_id
    , a.message_id
    , a.file_name
    , a.content_type
    , a.attachment_data
    , a.is_image_content_id
    , a.date_ins
    , a.operator_id
  from
    ml_message m
    inner join ml_attachment_2_4_0 a
      on m.message_id = a.message_id
  ;
  dbms_output.put_line('email attachment copied: ' || sql%rowcount);
end;
/
