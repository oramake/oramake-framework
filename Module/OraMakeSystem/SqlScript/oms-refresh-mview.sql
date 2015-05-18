--script: oms-refresh-mview.sql
--��������� ����������������� ������������� � �������� �� ���� ����������.
--
--���������:
--mviewName                   - ��� ������������������ �������������
--
--���������:
--  - ���������� ������, ������������ ��� ������ �� ���������������� ��������;
--  - ���������� ���������� � ������� ������� <oms-gather-stats.sql>, �������
--    ���������� � ������� <oms-run.sql>, �.�. ���� ���������� �� �����
--    ����������� � ������ �������� � <SKIP_FILE_MASK> �����
--    "*/oms-gather-stats.sql";
--

define mviewName = "&1"



prompt &mviewName: refresh ...

timing start

exec dbms_mview.refresh( '&mviewName', '?')

timing stop

@oms-run.sql ./oms-gather-stats.sql "&mviewName"



undefine mviewName
