-- script: Install/Schema/Last/revert.sql
-- �������� ��������� ������, ������ ��������� ������� �����.


-- �������� ����� �������� �����
@oms-run Install/Schema/Last/Common/revert.sql


-- ������

drop package pkg_Logging
/
drop package pkg_LoggingErrorStack
/
drop package pkg_LoggingInternal
/


-- ����

@oms-drop-type lg_logger_t


-- ������� �����

@oms-drop-foreign-key lg_destination
@oms-drop-foreign-key lg_level
@oms-drop-foreign-key lg_log
@oms-drop-foreign-key lg_message_type


-- �������

drop table lg_destination
/
drop table lg_level
/
drop table lg_log
/
drop table lg_message_type
/


-- ������������������

drop sequence lg_log_seq
/
