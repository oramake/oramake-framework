-- script: Install/Schema/Last/revert.sql
-- �������� ��������� ������, ������ ��������� ������� �����.


-- ������

drop package pkg_TestUtility
/
drop package pkg_Tests
/


-- ������� �����

@oms-drop-foreign-key tsu_job
@oms-drop-foreign-key tsu_process


-- �������

drop table tsu_job
/
drop table tsu_process
/


-- ������������������

drop sequence tsu_job_seq
/
drop sequence tsu_process_seq
/
