-- trigger: opt_option_value_aiud_2new.trg
-- Триггер используется для отражения изменений в новых таблицах.
create or replace trigger
  opt_option_value_aiud_2new
after
  insert
  or update
  or delete
on
  opt_option_value
for each row
begin
  pkg_OptionMain.onOldAfterRow(
    tableName       => 'OPT_OPTION_VALUE'
    , statementType =>
        case
          when inserting  then 'INSERT'
          when updating   then 'UPDATE'
          when deleting   then 'DELETE'
        end
    , newRowId      => :new.option_value_id
    , oldRowId      => :old.option_value_id
  );
end;
/
