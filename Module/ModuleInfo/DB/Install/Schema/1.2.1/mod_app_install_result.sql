alter table
  mod_app_install_result
rename column
  java_return_code
to
  status_code
/

comment on column mod_app_install_result.status_code is
  'Код результата выполнения установки ( 0 означает отсутствие ошибок)'
/
