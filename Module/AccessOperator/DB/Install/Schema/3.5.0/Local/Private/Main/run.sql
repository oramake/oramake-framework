-- script: Install/Schema/3.5.0/Local/Private/Main/run.sql
-- ��������� �������� ������ 3.5.0 ������

@oms-set-indexTablespace.sql


-- �������
@oms-run rp_event.sql

-- �������
@oms-run Install/Schema/Last/Local/Private/Main/op_load_lock_form_sources_tmp.tab

-- ������������������
@oms-run Install/Schema/Last/Local/Private/Main/op_login_attempt_group_seq.sqs

-- ��������
@oms-run Install/Schema/Last/Local/Private/Main/op_operator_aiud_add_event.trg
@oms-run Install/Schema/Last/Local/Private/Main/op_login_atm_grp_aiu_add_event.trg
@oms-run Install/Schema/Last/Local/Private/Main/op_login_attempt_group_bi_def.trg
