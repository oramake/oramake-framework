alter table
  lg_log
add (
  module_name                   varchar2(128)
  , object_name                   varchar2(128)
  , module_id                     integer
)
/

comment on column lg_log.module_name is
  'Имя модуля, добавившего запись'
/
comment on column lg_log.object_name is
  'Имя объекта модуля (пакета, типа, скрипта), добавившего запись'
/
comment on column lg_log.module_id is
  'Id модуля, добавившего запись (если удалось определить)'
/
comment on column lg_log.parent_log_id is
  'Устаревшее поле: Id родительской записи лога'
/
comment on column lg_log.message_type_code is
  'Устаревшее поле: Код типа сообщения'
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

@oms-run Install/Schema/add-install-job.sql "validate-lg_log_fk_module_id" "15" "execute immediate ''alter table lg_log enable validate constraint lg_log_fk_module_id'';"
