--script: oms-gather-stats.sql
--�������� ���������� �� ������� ��� ������������������ �������������
--�������� ������������.
--
--���������:
--tableName                   - ��� ������� ( ������������������ �������������)
--
--���������:
--  - ���������� ������, ������������ ��� ������ �� ���������������� ��������;
--  - ���������� ������ ����������, ������� ���������� �� ����� � ��������;
--  - ��������� ����� ���������� ���������� ����������, ������������ ���
--    ���������� ����� ���������� � �� ( � ������ ��������� ��������� �
--    ������ ������ ��������� ���������);
--

define tableName = "&1"



prompt &tableName: gather stats ...

timing start

begin
  dbms_stats.gather_table_stats(
    ownname         => user
    , tabname       => '&tableName'
    , method_opt    =>'FOR ALL INDEXED COLUMNS SIZE AUTO'
    , cascade       => true
  );
end;
/

timing stop



undefine tableName
