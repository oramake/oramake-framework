alter table
  lg_log
add constraint
  lg_log_fk_level_code
foreign key
  ( level_code)
references
  lg_level (
    message_level_code
  )
enable novalidate
/

alter table
  lg_log
add constraint
  lg_log_fk_module_id
foreign key
  ( module_id)
references
  mod_module (
    module_id
  )
enable novalidate
/

var jobText varchar2(4000)

begin
  :jobText :=
'execute immediate
  ''alter table
    lg_log
  enable validate constraint lg_log_fk_level_code
  enable validate constraint lg_log_fk_module_id
''
;
'
  ;
end;
/

@oms-run Install/Schema/add-install-job.sql validate-fk 10 "' || :jobText || '"

@oms-run Install/Schema/2.1.0/AccessOperatorAddon/create-lg_log-fk-op.sql
