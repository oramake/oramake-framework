-- script: Install/Config/3.4.19/Local/Private/Main/before-action.sql
-- ����������� �������� ���� �������

-- ���� ����� ��� ������� ����������
@oms-run wait-job-stop.sql

-- ������������ ���� ���������� ����������
@oms-deactivate-batch.sql CopyOperator
