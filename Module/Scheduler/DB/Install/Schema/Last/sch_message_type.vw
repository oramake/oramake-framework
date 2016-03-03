-- view: sch_message_type
-- Типы сообщений лога ( представление, созданное вместо таблицы
-- sch_message_type при установке модуля Loggiing версии 1.4.0 для обеспечения
-- совместимости с модулем Scheduler).
--
create or replace view
  sch_message_type
as
select
  t.message_type_code
  , t.message_type_name as message_type_name_rus
  , t.message_type_name_en as message_type_name_eng
  , t.date_ins
from
  lg_message_type t
/

comment on table sch_message_type is
  'Типы сообщений лога ( представление, созданное вместо таблицы sch_message_type при установке модуля Loggiing версии 1.4.0 для обеспечения совместимости с модулем Scheduler)'
/
