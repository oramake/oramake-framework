-- script: op_group.sql
-- Изменение таблицы <op_group>

declare
  cursor curColToDrop
  is
    select
      *
    from
      user_tab_columns utc
    where
      utc.table_name = 'OP_GROUP'
      and utc.column_name in (
        'GROUP_NAME_RUS'
        , 'GROUP_NAME_ENG'
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