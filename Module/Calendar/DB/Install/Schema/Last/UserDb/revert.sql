-- script: Install/Schema/Last/UserDb/revert.sql
-- �������� ��������� ������, ������ ��������� ������� ����� �
-- ���������������� ��.
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

-- �������� ���������� ������
begin
  opt_option_list_t( moduleSvnRoot => 'Oracle/Module/Calendar').deleteAll();
end;
/

-- ������
drop package pkg_Calendar
/
