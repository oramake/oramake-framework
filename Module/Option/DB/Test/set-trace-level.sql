-- script: Test/set-trace-level.sql
-- ������������� � ������ ����������� ������ TRACE ��� ������ � �������
-- ������ ����� dbms_output..

set feedback off

begin

  -- ����� ������ ����� dbms_output ( ����� ���������� ������ �� �����)
  pkg_Logging.setDestination(
    pkg_Logging.DbmsOutput_DestinationCode
  );

  -- �������� ����������� ��� ������
  lg_logger_t.getLogger( 'Option').setLevel( 'TRACE');
end;
/

set feedback on
