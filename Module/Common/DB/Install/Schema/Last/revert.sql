-- script: Install/Schema/Last/revert.sql
-- �������� ��������� ������, ������ ��������� ������� �����.


-- ������

drop package pkg_Common
/
drop package pkg_Error
/


-- ���������

drop function str_concat
/



-- �������

drop table cmn_database_config
/
drop table cmn_sequence
/
drop table cmn_string_uid_tmp
/


-- ����

drop type str_concat_t
/
drop type cmn_string_table_t
/
