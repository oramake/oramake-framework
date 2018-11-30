-- script: Show/branch.sql
-- ���������� ����� ����, ��������� � ���������� ����������.
--
-- ���������:
--
-- <logId>[:<maxRowCount>]
--
-- ���:
--
-- logId                      - Id ������ ���� �������� (��������) ���������
-- maxRowCount                - ������������ ����� ��������� �������
--                              (�� ��������� 30)
--
-- ���������:
-- - ��� ��������� ������������� ��� ������ ����� ���� ����� ������� ���������
--  ����������� ������� �� �������� (��� ���� ������� ����� ������, �����
--  ������� �� ������ � ���� ������);
--

var logId number
var maxRowCount number

set feedback off

declare
  paramStr varchar2(255) := trim( '&1');
  d1 integer;
begin
  d1 := instr( paramStr || ':', ':');
  :logId := to_number( substr( paramStr, 1, d1 - 1));
  :maxRowCount := coalesce( to_number( substr( paramStr, d1 + 1)), 30);
end;
/

set feedback on

column message_text_ format A200 head MESSAGE_TEXT

select
  lg.log_id
  , lg.level_code
  , decode( lg.message_level
      , 1, ''
      , lpad( '  ', (lg.message_level - 1) * 2, ' ')
    )
    -- ��������� ������ ��-�� ������ ������ ������ 4000 ��������
    || substr( lg.message_text, 1, 4000 - (lg.message_level - 1) * 2)
    as message_text_
  , lg.message_value
  , lg.message_label
  , lg.context_level
  , lg.context_type_id
  , lg.context_value_id
  , lg.open_context_log_id
  , lg.open_context_log_time
  , lg.open_context_flag
  , lg.context_type_level
  , lg.sessionid
  , lg.module_name
  , lg.object_name
  , lg.module_id
  , lg.log_time
  , lg.date_ins
  , lg.operator_id
from
  (
  select
    lg.*
    , 1 + ( lg.context_level - ccl.open_context_level)
      + case when lg.open_context_flag in ( 1, -1) then 0 else 1 end
      as message_level
  from
    v_lg_context_change_log ccl
    inner join lg_log lg
      on lg.sessionid = ccl.sessionid
        and lg.log_id >= ccl.open_log_id
        and lg.log_id <= coalesce( ccl.close_log_id, lg.log_id)
  where
    ccl.log_id = :logId
  order by
    1
  ) lg
where
  rownum <= :maxRowCount
/

column message_text_ clear
