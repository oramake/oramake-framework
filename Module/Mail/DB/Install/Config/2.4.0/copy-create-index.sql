-- Определяем табличное пространство для индексов
@oms-set-indexTablespace.sql

--index: ml_message_ix_state_smtp
create index ml_message_ix_state_smtp on ml_message (
   message_state_code asc
   , smtp_server asc
) tablespace &indexTablespace;

--index: ml_message_ix_expire_date
create index ml_message_ix_expire_date on ml_message (
   expire_date asc
) tablespace &indexTablespace
;
--index: ml_message_ix_fetch
create index ml_message_ix_fetch on ml_message (
   fetch_request_id asc
) tablespace &indexTablespace
;

-- index: ml_message_ux
-- Индекс для исключения повторной загрузки входящих сообщений.
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


--index: ml_message_ux_rcadr_state_id
create unique index ml_message_ux_rcadr_state_id on ml_message (
   recipient_address asc,
   message_state_code asc,
   message_id asc
) tablespace &indexTablespace;


--index: ml_message_ix_source_message
create index ml_message_ix_source_message on ml_message (
   source_message_id asc
) tablespace &indexTablespace;


--index: ml_message_ix_parent_message
create index ml_message_ix_parent_message on ml_message (
   parent_message_id asc
) tablespace &indexTablespace;


--index: ml_attachment_ix_message_id
create index ml_attachment_ix_message_id on ml_attachment (
   message_id asc
) tablespace &indexTablespace;

