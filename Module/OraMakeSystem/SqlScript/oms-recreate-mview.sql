--script: oms-recreate-mview.sql
--����������� ����������������� ������������� � �������� �� ���� ����������.
--
--���������:
--oms_recrmv_mviewName                   - ��� ������������������ �������������
--oms_recrmv_mviewScript                 - ������ �������� ������������������ �������������
--
--���������:
--  - ���������� ������, ������������ ��� ������ �� ���������������� ��������;
--  - �������� ���������������� �������������� � ������� ������� 
--    <oms-drop-mview.sql>, ������� ���������� � ������� <oms-run.sql>, 
--    �.�. �������� �� ����� ����������� � ������ �������� � <SKIP_FILE_MASK> 
--    ����� "*/oms-drop-mview.sql";
--  - ���������� ���������� � ������� ������� <oms-gather-stats.sql>, �������
--    ���������� � ������� <oms-run.sql>, �.�. ���� ���������� �� �����
--    ����������� � ������ �������� � <SKIP_FILE_MASK> �����
--    "*/oms-gather-stats.sql";
--

define oms_recrmv_mviewName = "&1"
define oms_recrmv_mviewScript = "&2"

@oms-run.sql ./oms-drop-mview.sql "&oms_recrmv_mviewName"

@oms-run.sql "&oms_recrmv_mviewScript"

prompt &oms_recrmv_mviewName: refresh ...

timing start

exec dbms_mview.refresh( '&oms_recrmv_mviewName', '?', atomic_refresh=>false)

timing stop

@oms-run.sql ./oms-gather-stats.sql "&oms_recrmv_mviewName"

undefine oms_recrmv_mviewName
undefine oms_recrmv_mviewScript
