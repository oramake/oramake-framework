-- script: Install/Schema/Last/UserDb/run.sql
-- ��������� ��������� ��������� ������ �������� ����� � ��������������� ��.


-- ���������� ��������� ������������ ��� ��������
@oms-set-indexTablespace.sql


-- ���������� ���� � ����� � �������� ��
@oms-run Install/Schema/Last/UserDb/Custom/set-sourceDbLink.sql
@oms-run Install/Schema/Last/UserDb/Custom/set-sourceSchema.sql


-- �������� ���. �������������
@oms-run ./oms-recreate-mview.sql mv_cdr_day Install/Schema/Last/UserDb/mv_cdr_day.snp
@oms-run ./oms-recreate-mview.sql mv_cdr_day_type Install/Schema/Last/UserDb/mv_cdr_day_type.snp
