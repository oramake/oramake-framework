--script: Show/log.sql
--���������� ����� ����.
--
--���������:
--rootLogId                   - Id �������� ������ ����
--

define rootLogId = "&1"



column message_text_ format A200 head MESSAGE_TEXT

select
  lg.log_id
  , decode( LEVEL
      , 1, ''
      , lpad( '  ', (LEVEL - 1) * 2, ' ')
    )
    -- ��������� ������ ��-�� ������ ������ ������ 4000 ��������
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
    case when &rootLogId is not null then
      &rootLogId
    else
      (
      select
        max( tt.log_id)
      from
        sch_log tt
      where
        tt.parent_log_id is null
      )
    end
connect by
  prior lg.log_id = lg.parent_log_id
order siblings by
  lg.date_ins
  , lg.log_id
/

column message_text_ clear



undefine rootLogId
