--script: Install/Schema/Last/run.sql
--��������� ��������� ������ �������� �����.



@oms-set-indexTablespace.sql


-- ����������� �������
@@lg_destination.tab
@@lg_level.tab

-- �������������

--������ ���� �� ������������� ���� �������������
@oms-run ./Install/Grant/Last/all-to-public.sql
