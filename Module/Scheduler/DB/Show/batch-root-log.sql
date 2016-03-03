--script: Show/batch-root-log.sql
--ѕоказывает пакеты.
--
--ѕараметры:
--batchPattern                - маска дл€ имени пакетов ( batch_short_name)
--lastDayCount                - число дней, за которые показываютс€ логи не
--                              включа€ текущий ( по умолчанию только за текущий
--                              день)
--

define batchPattern = "&1"
define lastDayCount = "to_number( coalesce( nullif( '&2', 'null'), '0'))"



column message_text_ format A200 head MESSAGE_TEXT

select
  brl.log_id
  , brl.date_ins
  , b.batch_short_name
  , brl.message_type_code
  , brl.message_text as message_text_
  , brl.operator_id
from
  v_sch_batch_root_log brl
  inner join sch_batch b
    on brl.batch_id = b.batch_id
where
  b.batch_short_name like '&batchPattern'
  and brl.date_ins >= trunc( sysdate) - &lastDayCount
order by
  brl.log_id
  , brl.date_ins
/

column message_text_ clear



undefine batchPattern
undefine lastDayCount
