-- script: Install/Schema/2.7.0/revert.sql
-- Отменяет изменения в объектах схемы, внесенные при установке версии 2.7.0.
--


-- Определяем табличное пространство для индексов
@oms-set-indexTablespace.sql

drop index ml_message_ux
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
