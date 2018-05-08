-- trigger: lg_log_bi_define
-- ������������� ����� ������� <lg_log> ��� ���������������� ������� �������
-- �� ������ ������� (��� �������������).
--
create or replace trigger lg_log_bi_define
  before insert
  on lg_log
  for each row
  when (new.sessionid is null)
declare

  rec lg_log%rowtype;

begin

  -- ����� �������������� ����
  rec.log_id                := :new.log_id;
  rec.parent_log_id         := :new.parent_log_id;
  rec.message_type_code     := :new.message_type_code;
  rec.message_value         := :new.message_value;
  rec.message_text          := :new.message_text;
  rec.date_ins              := :new.date_ins;
  rec.operator_id           := :new.operator_id;

  pkg_LoggingInternal.beforeInsertLogRow( logRec => rec);

  -- ��������� ��������� ����
  :new.log_id               := rec.log_id;
  :new.date_ins             := rec.date_ins;
  :new.operator_id          := rec.operator_id;

  -- ��������� ����� ����
  :new.sessionid            := rec.sessionid;
  :new.level_code           := rec.level_code;
end;
/
