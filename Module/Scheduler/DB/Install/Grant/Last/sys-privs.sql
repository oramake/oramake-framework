--script: Install/Schema/Last/sys-privs.sql
--������ ��������� ����������, ����������� ��� ��������� � ������ ������.
--
--���������:
--userName                    - ��� ������������, � ����� ��������
--                              ����� ���������� ������
define userName = "&1"



grant scheduler_admin to &userName
/
grant create job to &userName
/


grant select on sys.v_$session to &userName with grant option
/

-- ���������� ��� ������ ������ pkg_Scheduler
grant select on sys.v_$db_pipes to &userName
/

-- changing job_queue_proceses
grant alter system to &userName
/

grant execute on dbms_pipe to &userName
/




undefine userName
