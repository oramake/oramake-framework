var jobText varchar2(4000)

begin
  :jobText :=
'execute immediate
  ''alter table lg_log enable validate constraint lg_log_fk_level_code''
;';
end;
/

@oms-run Install/Schema/add-install-job.sql "validate-lg_log_fk_level_code" 10 "' || :jobText || '"
