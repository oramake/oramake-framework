-- script: Install/Schema/Last/revert.sql
-- �������� ��������� ������, ������ ��������� ������� �����.
--

-- ������
drop package pkg_Option
/
drop package pkg_OptionMain
/
drop package pkg_OptionCrypto
/

-- �������
drop function opt_getLocalCryptoKey
/

-- �������������
drop view v_opt_object_type
/
drop view v_opt_option_value
/
drop view v_opt_option_new
/
drop view v_opt_option_history
/
drop view v_opt_value
/
drop view v_opt_value_history
/

-- �������
drop table opt_value_history
/
drop table opt_value
/
drop table opt_option_history
/
drop table opt_option_new
/
drop table opt_access_level
/
drop table opt_object_type
/
drop table opt_value_type
/

-- ����
drop type opt_plsql_object_option_t
/
drop type opt_option_list_t
/
drop type opt_option_value_table_t
/
drop type opt_option_value_t
/
drop type opt_value_table_t
/
drop type opt_value_t
/

-- ������������������
drop sequence opt_object_type_seq
/
drop sequence opt_option_seq
/
drop sequence opt_option_history_seq
/
drop sequence opt_option_value_seq
/
drop sequence opt_value_history_seq
/



-- ���������� �������

-- �������������
drop view v_opt_option
/
drop view v_opt_option_new2old
/
drop view v_opt_option_new2old_diff
/

-- �������
drop table opt_option_value
/
drop table opt_option
/
drop table doc_mask
/
drop table doc_storage_rule
/

-- ������������������
drop sequence doc_mask_seq
/
drop sequence doc_storage_rule_seq
/