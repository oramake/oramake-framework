-- trigger: opt_option_value_biuds_2new.trg
-- ������� ������������ ��� ��������� ��������� � ����� ��������.
create or replace trigger
  opt_option_value_biuds_2new
before
  insert
  or update
  or delete
on
  opt_option_value
begin
  if updating then
    raise_application_error(
      pkg_Error.ProcessError
      , '��������� ������ � ������� opt_option_value'
        || ' � ������� ������� update ���������.'
    );
  end if;
  pkg_OptionMain.onOldBeforeStatement(
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
