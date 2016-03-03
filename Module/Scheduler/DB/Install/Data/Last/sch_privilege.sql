begin
merge into
  sch_privilege d
using
  (
  select
    pkg_Scheduler.Admin_PrivilegeCode as privilege_code
    , '��������� ���� �����' as privilege_name
  from dual
  union all select
    pkg_Scheduler.Exec_PrivilegeCode
    , '���������� ( ���������, �����������, ������, ����������)'
  from dual
  union all select
    pkg_Scheduler.Read_PrivilegeCode
    , '�������� ������'
  from dual
  union all select
    pkg_Scheduler.Write_PrivilegeCode
    , '��������� ��������� ������� ( ����� ��������� ����������)'
  from dual
  union all select
    pkg_Scheduler.WriteOption_PrivilegeCode
    , '��������� ���������� ��������� �������'
  from dual
  minus
  select
    t.privilege_code
    , t.privilege_name
  from
    sch_privilege t
  ) s
on
  (
  d.privilege_code = s.privilege_code
  )
when not matched then insert
  (
  privilege_code
  , privilege_name
  )
values
  (
  s.privilege_code
  , s.privilege_name
  )
when matched then update set
  d.privilege_name         = s.privilege_name
;
  dbms_output.put_line( 'changed: ' || SQL%ROWCOUNT);
  commit;
end;
/
