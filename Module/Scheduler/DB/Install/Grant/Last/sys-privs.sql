--script: Install/Schema/Last/sys-privs.sql
--������ ��������� ����������, ����������� ��� ��������� � ������ ������.
--
--���������:
--userName                    - ��� ������������, � ����� ��������
--                              ����� ���������� ������
define userName = "&1"


-- ���������� ��� �������� � ������ ���� �� view V_SCH_BATCH
grant select on dba_jobs to &userName with grant option
/

grant select on dba_jobs_running to &userName with grant option
/

grant select on sys.v_$session to &userName with grant option
/

-- ���������� ��� ������ ������ pkg_Scheduler
grant select on sys.v_$db_pipes to &userName
/

grant alter system to &userName
/

grant execute on dbms_pipe to &userName
/



undefine userName
