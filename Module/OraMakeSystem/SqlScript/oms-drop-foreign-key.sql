-- script: oms-drop-foreign-key
-- Удаляет внешние ключи таблицы.
--
-- Параметры:
-- tableName                  - имя таблицы
--

define tableName=&1

declare
  tableName varchar2(30) := '&tableName';
begin
  dbms_output.put_line( 'drop foreign key: ' || tableName);
  for constraintRec in (
    select
      constraint_name
    from
      user_constraints
    where
      table_name = upper( tableName)
      and constraint_type = 'R'
    order by
      constraint_name
  ) loop
    execute immediate
      'alter table ' || upper( tableName) || ' drop constraint '
       || constraintRec.constraint_name
    ;
    dbms_output.put_line(
      'Foreign key ' || constraintRec.constraint_name
      || ' for table ' || upper( tableName) || ' dropped.'
    );
  end loop;
end;
/

undefine tableName
