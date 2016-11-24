-- script: Install/Schema/Last/Common/BatchUser/revert.sql
-- �������� ��������� ������, ������ ����� ������ ������, ��������� �
-- ��������� ��������� ������ Scheduler.
--

-- �������� ���������� �������
-- ( ���� ��� ������������, �� ����� ������)
begin
  delete
    sch_job jb
  where
    jb.module_id = pkg_ModuleInfo.getModuleId(
      svnRoot => 'Oracle/Module/Calendar'
    )
  ;
  dbms_output.put_line(
    'job deleted: ' || sql%rowcount
  );
  commit;
end;
/
