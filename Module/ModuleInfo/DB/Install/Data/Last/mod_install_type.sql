begin
merge into 
  mod_install_type d
using  
  (
  select
    pkg_ModuleInfo.Object_InstallTypeCode as install_type_code
    , 'Изменение объектов схемы и данных' as install_type_name
  from dual
  union all select
    pkg_ModuleInfo.Privs_InstallTypeCode
    , 'Настройка прав доступа'
  from dual
  minus
  select
    t.install_type_code
    , t.install_type_name
  from
    mod_install_type t
  ) s
on
  (
  d.install_type_code = s.install_type_code
  )
when not matched then insert  
  (
  install_type_code
  , install_type_name
  )
values
  (
  s.install_type_code
  , s.install_type_name
  )
when matched then update set
  d.install_type_name            = s.install_type_name
;
  dbms_output.put_line( 'changed: ' || SQL%ROWCOUNT);
  commit;
end;
/
