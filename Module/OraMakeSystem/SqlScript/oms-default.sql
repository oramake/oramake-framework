--script: oms-default.sql
--������������� �������� �� ��������� ��� ��������������� SQL*Plus.
--
--���������:
--varName                     - ��� ���������������
--defaultValue                - �������� �� ���������
--...                         - �������������� ���������, ������� �����
--                              ������������ � defaultValue � ������� ������
--                              ���� $(1),$(2),...,$(7)
--
--���������:
--  - ���������� ������, ������������ ��� ������ �� ���������������� ��������;
--  - ���� ��������������� ��� ��������� �������� ��������, �� ��� ��
--    ����������, ��� ��������� ���� ������ �������� ��������������� ���
--    ��������� � ������� ��������� SQL_DEFINE ( ��. <��������� ������ � ��>);
--  - ��������� �������� ��������������� ������������ � ������� SQL-������� ��
--    ������� dual, ��� ���� ��������������, ��� �������� defaultValue ��������
--    ������� � ��� ����������� � ��������� �������, ������� ��� �������������
--    SQL-��������� � defaultValue �������� ������ ���� �������� � ����
--    "' || <SQL-���������> || '" ( ��. ������� ����);
--  - ����� ���������� � SQL*Plus ���������� 239 ���������, � ������
--    ������������� ��� ���������� ����� ��������� defaultValue �����
--    �������������� ������ �� �������������� ��������� ���� $(n), ��� n
--    ���������� ����� ��������������� ��������� �� 1 �� 7 ( ��. ������� ����);
--  - ������ ���������� ��������� ����, ������� ��������� � ��������������
--    �������� ������� ���� �� ��������������� OMS_TEMP_FILE_PREFIX;
--
--
--
--�������:
--  - ��������� ���������� ��������
--
--(code)
--
--@oms-default.sql userName operation
--
--(end)
--
--  - ��������� �������� � �������������� SQL-���������
--
--(code)
--
--@oms-default.sql userName "' || user || '"
--
--(end)
--
--  - ��������� �������� � �������������� �������������� ����������
--
--(code)
--
--@oms-default.sql userName "' || $(1) || '" "user"
--
--(end)
--
--

define varName = "&1"
define defaultValue = "&2"

define oms_temp_file_name = "&OMS_TEMP_FILE_PREFIX..oms-default"



set termout off
spool &oms_temp_file_name
prompt select coalesce( '&&&varName', '&defaultValue') as "&varName" from dual
spool off
set termout on

get &oms_temp_file_name nolist

set termout off
change /$(1)/&3/
change /$(2)/&4/
change /$(3)/&5/
change /$(4)/&6/
change /$(5)/&7/
change /$(6)/&8/
change /$(7)/&9/
set termout on

set feedback off
column "&varName" new_value &varName head "&varName" format A60
/
column "&varName" clear
prompt
set feedback on



undefine oms_temp_file_name

undefine varName
undefine defaultValue
