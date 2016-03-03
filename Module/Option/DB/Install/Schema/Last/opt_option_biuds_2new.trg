-- trigger: opt_option_biuds_2new.trg
-- Триггер используется для отражения изменений в новых таблицах.
create or replace trigger
  opt_option_biuds_2new
before
  insert
  or update
  or delete
on
  opt_option
begin
  pkg_OptionMain.onOldBeforeStatement(
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
