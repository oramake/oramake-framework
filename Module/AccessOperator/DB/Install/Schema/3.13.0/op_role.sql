-- script: op_role.sql
-- Изменение таблицы <op_role>

declare
  cursor curColToDrop
  is
    select
      *
    from
      user_tab_columns utc
    where
      utc.table_name = 'OP_ROLE'
      and utc.column_name in (
        'ROLE_NAME_RUS'
        , 'ROLE_NAME_ENG'
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