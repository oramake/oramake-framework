alter table
  ml_message
add (
   incoming_flag                  number(1)
   , mailbox_delete_date          date
   , mailbox_for_delete_flag      number(1)
  , constraint ml_message_ck_incoming_flag check
    ( incoming_flag in ( 0, 1))
  , constraint ml_message_ck_mb_delete_date check
    ( mailbox_delete_date is null or incoming_flag = 1 and parent_message_id is null)
  , constraint ml_message_ck_mb_for_del_flg check
    ( mailbox_for_delete_flag is null or mailbox_for_delete_flag in ( 0, 1) and incoming_flag = 1 and parent_message_id is null)
)
/

update
  ml_message t
set
  t.incoming_flag =
    case when
      t.message_state_code in ( 'S', 'SC', 'SE', 'WS')
      and t.fetch_request_id is null
    then
      0
    else
      1
    end
where
  t.incoming_flag is null
/

commit
/

alter table
  ml_message
modify (
  incoming_flag not null
)
/

drop index
  ml_message_ux
/

create unique index
  ml_message_ux
on
  ml_message (
    substr( sender, 1, 1000)
    , substr( recipient, 1, 1000)
    , send_date
    , message_uid
    , case when incoming_flag = 0 or parent_message_id is not null then
        message_id
      end
  )
tablespace &indexTablespace
/


comment on column ml_message.incoming_flag is
  'Флаг входящего сообщения ( 1 входящее, 0 исходящее)'
/
comment on column ml_message.mailbox_delete_date is
  'Дата удаления сообщения из почтового ящика'
/
comment on column ml_message.mailbox_for_delete_flag is
  'Флаг необходимости удаления сообщения из почтового ящика в случае его наличия ( 1 - сообщение будет удалено, 0 - сообщение не будет удалено)'
/
