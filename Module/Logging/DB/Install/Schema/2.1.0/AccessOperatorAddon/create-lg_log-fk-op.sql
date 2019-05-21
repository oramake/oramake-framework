alter table
  lg_log
add constraint
  lg_log_fk_operator_id
foreign key
  ( operator_id)
references
  op_operator ( operator_id)
enable novalidate
/

var jobText varchar2(4000)

begin
  :jobText :=
'execute immediate
  ''alter table
    lg_log
  enable validate lg_log_fk_operator_id
''
;
'
  ;
end;
/

@oms-run Install/Schema/add-install-job.sql validate-fk-op 10 "' || :jobText || '"
