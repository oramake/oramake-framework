--script: oms-drop-mview.sql
--������� ����������������� �������������
--
--���������:
--mviewName                    - ��� ������������������ �������������
--
--���������:
--  - ���� ����������������� ������������� ����������� � ������ "on prebuilt table",
--    �� ����� �������� ������������������ ������������� ��������� ����� ����������� �������;
--

define mviewName = &1

prompt Dropping materialized view &mviewName ...

declare
  mviewName varchar2(30):= '&mviewName';
  tablename varchar2(30);
begin
  execute immediate 'drop materialized view ' || mviewName;
  dbms_output.put_line( 'Materialized view ' || mviewName || ' dropped' );
  
  -- ����� ����������� ������� 
  select nvl(max(table_name),'')
  into tablename
  from user_tables
  where upper(table_name) = upper(mviewName);
  
  -- ���� ����������� ������� �������, �� ������� � 
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