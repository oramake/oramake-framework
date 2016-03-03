-- trigger: opt_option_aiuds_2new.trg
-- Триггер используется для отражения изменений в новых таблицах.
create or replace trigger
  opt_option_aiuds_2new
after
  insert
  or update
  or delete
on
  opt_option
begin
  pkg_OptionMain.onOldAfterStatement(
    tableName       => 'OPT_OPTION'
    , statementType =>
        case
          when inserting  then 'INSERT'
          when updating   then 'UPDATE'
          when deleting   then 'DELETE'
        end
  );
end;
/
