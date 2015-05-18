--script: oms-drop-type.sql
--������� SQL-��� �������������� ( "force") �������, ��� ���� ��������� ��
--���������� ���� ������� ���������� �����������.
--
--���������:
--typeName                    - ��� SQL-����
--
--���������:
--  - ���������� ������, ������������ ��� ������ �� ���������������� ��������;
--  - ������ ������������ ��� �������� ���� ����� �������������, ����� �� ����
--    ������ ��-�� ������� ������������;
--  - ������, ����������� ��-�� ���������� ���������� ����, ������������;
--  - � ������� ���������� ������������� ��������������� SQL*Plus ��������
--    "set define on"; ���� ��� ������, �� ����� ������ ������� ����� ���������
--    ������� "set define off";
--

set define on

define typeName = "&1"



declare

  typeName varchar2(30) := '&typeName';
  
begin
  dbms_output.put_line( 'drop type: ' || typeName);
  execute immediate 'drop type ' || typeName || ' force';
exception when others then
                                        --ORA-04043: object * does not exist
  if SQLCODE = -04043 then
    null;
  else
    raise;
  end if;
end;
/



undefine typeName
