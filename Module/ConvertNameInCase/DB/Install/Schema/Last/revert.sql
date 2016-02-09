-- script: Install/Schema/Last/revert.sql
-- �������� ��������� ������, ������ ��������� ������� �����.


-- ������

drop package pkg_ConvertNameInCase
/


-- �������������

drop view v_ccs_case_exception
/


-- ������� �����

@oms-drop-foreign-key ccs_case_exception
@oms-drop-foreign-key ccs_type_exception


-- �������

drop table ccs_case_exception
/
drop table ccs_type_exception
/


-- ������������������

drop sequence ccs_case_exception_seq
/
