-- script: Do/batch-log-level.sql
-- ������������� ������� ����������� ��� �����.
--
-- ���������:
-- batchShortName             - ��� �����
-- loggingLevelCode           - ������� ����������� �����
--                              ( "" ��� ������������� ������ ��-���������)
--
-- ���������:
-- - � ������ ��������� ���������� ������� ����������� commit;
--

define batchShortName = "&1"
define loggingLevelCode = "&2"

declare

  batchShortName sch_batch.batch_short_name%type := '&batchShortName';
  loggingLevelCode varchar2(30) := '&loggingLevelCode';

begin
  sch_batch_option_t( batchShortName).addString(
    optionShortName     => 'LoggingLevelCode'
    , optionName        => '������� ����������� ��������� �������'
    , stringValue       => loggingLevelCode
    , changeValueFlag   => 1
  );
  commit;
end;
/

undefine batchShortName
undefine loggingLevelCode
