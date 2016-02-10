-- trigger: lg_log_ai_save_parent
-- ��������� �������� parent_log_id � ���������� ������.
create or replace trigger lg_log_ai_save_parent
  after insert
  on lg_log
  for each row
begin
  pkg_LoggingInternal.setLastParentLogId( :new.parent_log_id);
end;
/
