-- script: oms-drop-mview.sql
-- Удаляет материализованное представление
--
-- Параметры:
-- mviewName                  - имя материализованного представления
--
-- Замечания:
--  - если материализованное представление создавалась с опцией "on prebuilt
--    table", то после удаления материализованного представления удаляется
--    также одноименная таблица;
--

define mviewName = &1

prompt Dropping materialized view &mviewName ...

declare
  mviewName varchar2(30):= '&mviewName';
  tablename varchar2(30);
begin
  execute immediate 'drop materialized view ' || mviewName;
  dbms_output.put_line( 'Materialized view ' || mviewName || ' dropped' );

  -- search for the same name table
  select nvl(max(table_name),'')
  into tablename
  from user_tables
  where upper(table_name) = upper(mviewName);

  -- if the table of the same name is found, then delete it
  if upper(tablename) = upper(mviewName) Then
    execute immediate 'drop table '||tablename;
      dbms_output.put_line( 'Table ' || tablename || ' dropped' );
  end If;

exception
  when others
    then
      dbms_output.put_line( 'Exception: [' || sqlerrm || ']' );

end;
/

undefine mviewName
