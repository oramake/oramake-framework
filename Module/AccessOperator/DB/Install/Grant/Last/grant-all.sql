-- script: Install\Grant\Last\grant-all.sql
-- �������� ��������� � ������ ���� � �� ��� �������� ��� ��������� ������ 
-- ������������, ��� ������� ����������� ������ ������ ����� �����
-- create any synonym

define toUserName = "&1"

-- ������ ����
@oms-run grant_local.sql "&toUserName"

-- �������� ���������
@oms-run synonym_local.sql "&toUserName"


undefine toUserName