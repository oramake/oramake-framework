-- script: Do/root-level.sql
-- ��������� ������ ����������� ��� ��������� ������.
--
-- ���������:
-- 1                          - ������� �����������

begin
  lg_logger_t.getRootLogger().setLevel( '&1');
end;
/

