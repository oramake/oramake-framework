-- script: Install/Config/3.4.19/after-action.sql
-- ��������� �������� �������

define usedDayCount = '0'

-- ���������� ��� �������� �������, ������� ������ �����������
@oms-run activate-all.sql

-- ����������� ���������� ������� �� ���� ������
@oms-run compile_all_invalid.sql

undefine usedDayCount
