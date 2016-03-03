-- script: Show/batch-log-type.sql
-- Показывает последнюю ветку лога заданного типа для пакета
--
-- Параметры:
-- batchPattern               - маска для имени пакетов ( batch_short_name)
-- rootMessageTypeCode        - тип ветки лога для пакета ( например,
--                              "BSTART", по-умолчанию все типы веток)

define batchPattern = "&1"
define rootMessageTypeCode = "&2"


column message_text_ format A200 head MESSAGE_TEXT

select
  lg.log_id
  , decode( LEVEL
      , 1, ''
      , lpad( '  ', (LEVEL - 1) * 2, ' ')
    )
    -- исключаем ошибку из-за строки длиной больше 4000 символов
    || substr( lg.message_text, 1, 4000 - (LEVEL - 1) * 2)
    as message_text_
  , lg.message_type_code
  , lg.message_value
  , LEVEL
  , lg.parent_log_id
  , lg.date_ins
  , operator_id
from
  sch_log lg
start with
  lg.log_id =
    (
    select
      *
    from
      (
      select
        brl.log_id
      from
        v_sch_batch_root_log brl
      where
        brl.batch_id in
          (
          select
            b.batch_id
          from
            sch_batch b
          where
            b.batch_short_name like '&batchPattern'
          )
        and brl.message_type_code
          = coalesce( '&rootMessageTypeCode', brl.message_type_code)
      order by
        brl.date_ins desc
        , brl.log_id desc
      )
    where
      rownum = 1
    )
connect by
  prior lg.log_id = lg.parent_log_id
order siblings by
  lg.date_ins
  , lg.log_id
/

column message_text_ clear


undefine batchPattern
undefine rootMessageTypeCode
