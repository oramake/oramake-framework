-- trigger: opt_option_value_aiuds_2new.trg
-- Триггер используется для отражения изменений в новых таблицах.
create or replace trigger
  opt_option_value_aiuds_2new
after
  insert
  or update
  or delete
on
  opt_option_value
begin
  pkg_OptionMain.onOldAfterStatement(
    tableName       => 'OPT_OPTION_VALUE'
    , statementType =>
        case
          when inserting  then 'INSERT'
          when updating   then 'UPDATE'
          when deleting   then 'DELETE'
        end
  );
end;
/
