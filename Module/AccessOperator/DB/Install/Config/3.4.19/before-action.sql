-- script: Install/Config/3.4.19/before-action.sql
-- ����������� �������� ���� �������

-- ���� ����� ��� ������� ����������
@oms-run wait-job-stop.sql
-- ������������ ��� �����
@oms-run deactivate-all.sql