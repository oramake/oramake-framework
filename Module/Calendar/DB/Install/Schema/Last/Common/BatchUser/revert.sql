-- script: Install/Schema/Last/Common/BatchUser/revert.sql
-- ќтмен€ет установку модул€, удал€€ общие данные модул€, св€занные с
-- пакетными задани€ми модул€ Scheduler.
--

-- ”даление публичного задани€
-- ( если оно используетс€, то будет ошибка)
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
