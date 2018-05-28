alter table
  lg_log
add (
  level_code                    varchar2(10)
  , constraint lg_log_ck_level_code check
      (level_code not in ('ALL','OFF'))
      enable novalidate
)
/

alter table
  lg_log
modify (
  level_code  not null
      enable novalidate
)
/

comment on column lg_log.level_code is
  'Код уровня логирования'
/

alter table
  lg_log
add constraint
  lg_log_fk_level_code
foreign key
  ( level_code)
references
  lg_level (
    level_code
  )
enable novalidate
/


@oms-run add-lg_log_ck_level_code-job.sql
@oms-run add-lg_log_fk_level_code-job.sql
