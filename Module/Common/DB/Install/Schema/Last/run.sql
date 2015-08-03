-- script: Install/Schema/Last/run.sql
-- ��������� ��������� ��������� ������ �������� �����.

-- ������������� ��������� ������������
-- ��� ��������

@oms-set-indexTablespace.sql

-- �������

@oms-run cmn_database_config.tab
@oms-run cmn_sequence.tab
@oms-run cmn_string_uid_tmp.tab
@oms-run cmn_type_exception.tab
@oms-run cmn_case_exception.tab

@oms-run fill_cmn_sequence.sql

-- ���������� ������� �������������
@oms-run str_concat.sql

@oms-run cmn_string_table_t.typ


-- ������� ����������� �����������

@oms-run cmn_type_exception.con
@oms-run cmn_case_exception.con

-- ������������������

@oms-run cmn_case_exception_seq.sqs


-- �������������

@oms-run v_cmn_case_exception.vw


-- ��������
@oms-run cmn_type_exception_bi_define.trg
@oms-run cmn_case_exception_bi_define.trg