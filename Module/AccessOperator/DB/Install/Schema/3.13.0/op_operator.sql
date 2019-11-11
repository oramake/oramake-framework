-- script: op_operator.sql
-- Изменение таблицы <op_operator>

declare
  cursor curColToDrop
  is
    select
      *
    from
      user_tab_columns utc
    where
      utc.table_name = 'OP_OPERATOR'
      and utc.column_name in (
        'OPERATOR_NAME_RUS'
        , 'OPERATOR_NAME_ENG'
      )
  ;
begin
  for rec in curColToDrop loop
    dbms_output.put_line(
      'Drop column "' || rec.table_name || '.' || rec.column_name || '"'
    );
    execute immediate
      'alter table ' || rec.table_name || ' drop column ' || rec.column_name || ' cascade constraint'
    ;
  end loop;
exception
  when others then
    dbms_output.put_line(
      'Error code [' || sqlerrm || '].'
    );
end;
/