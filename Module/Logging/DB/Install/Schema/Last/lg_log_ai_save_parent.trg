-- trigger: lg_log_ai_save_parent
-- Сохраняет значение parent_log_id в переменной пакета.
create or replace trigger lg_log_ai_save_parent
  after insert
  on lg_log
  for each row
begin
  pkg_LoggingInternal.setLastParentLogId(
    case
      -- Поддержка совместимости с Scheduler
      when :new.message_type_code in (
            'BSTART'
            , 'JSTART'
          )
          then
        :new.log_id
      else
        :new.parent_log_id
    end
  );
end;
/
