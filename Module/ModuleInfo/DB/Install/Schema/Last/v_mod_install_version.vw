-- view: v_mod_install_version
-- ”становленные версии частей модулей.
--
create or replace force view
  v_mod_install_version
as
select
  -- SVN root: Oracle/Module/ModuleInfo
  ir.install_result_id
  , ir.install_date
  , ir.module_name
  , ir.svn_root
  , ir.part_number
  , ir.is_main_part
  , ir.result_version as current_version
  , ir.install_type_code
  , ir.object_schema
  , ir.privs_user
  , ir.install_script
  , ir.host
  , ir.os_user
  , ir.svn_path
  , ir.svn_version_info
  , ir.module_id
  , ir.module_part_id
  , ir.install_action_id
  , ir.date_ins
  , ir.operator_id
from
  v_mod_install_result ir
where
  ir.is_current_version = 1
  and ir.result_version is not null
/


comment on table v_mod_install_version is
  '”становленные версии частей модулей [ SVN root: Oracle/Module/ModuleInfo]'
/
comment on column v_mod_install_version.install_result_id is
  'Id результата установки'
/
comment on column v_mod_install_version.install_date is
  'ƒата установки'
/
comment on column v_mod_install_version.module_name is
  'Ќазвание модул€'
/
comment on column v_mod_install_version.svn_root is
  'ѕуть к корневому каталогу модул€ в Subversion ( начина€ с имени репозитари€, например: "Oracle/Module/ModuleInfo")'
/
comment on column v_mod_install_version.part_number is
  'Ќомер части модул€ ( уникальный, начина€ с 1)'
/
comment on column v_mod_install_version.is_main_part is
  '‘лаг основной части модул€ ( 1 основна€ часть модул€, 0 дополнительна€)'
/
comment on column v_mod_install_version.current_version is
  '“екуща€ верси€'
/
comment on column v_mod_install_version.install_type_code is
  ' од типа установки'
/
comment on column v_mod_install_version.object_schema is
  '—хема, в которой расположены объекты данной части модул€ ( в верхнем регистре)'
/
comment on column v_mod_install_version.privs_user is
  '»м€ пользовател€, дл€ которого выполн€лась настройка прав доступа ( в верхнем регистре)'
/
comment on column v_mod_install_version.install_script is
  '—тартовый установочный скрипт ( может отсутствовать, если дл€ установки может быть использован только единственный тривиальный вариант, например run.sql)'
/
comment on column v_mod_install_version.host is
  '»м€ хоста, с которого выполн€лось действие'
/
comment on column v_mod_install_version.os_user is
  '»м€ пользовател€ операционной системы, выполн€вшего действие'
/
comment on column v_mod_install_version.svn_path is
  'ѕуть в Subversion, из которого были получены файлы модул€ ( начина€ с имени репозитари€)'
/
comment on column v_mod_install_version.svn_version_info is
  '»нформаци€ о версии файлов модул€ из Subversion ( в формате вывода утилиты svnversion)'
/
comment on column v_mod_install_version.module_id is
  'Id модул€'
/
comment on column v_mod_install_version.module_part_id is
  'Id части модул€'
/
comment on column v_mod_install_version.install_action_id is
  'Id действи€ по установке ( null если нет информации по действию)'
/
comment on column v_mod_install_version.date_ins is
  'ƒата добавлени€ записи'
/
comment on column v_mod_install_version.operator_id is
  'Id оператора, добавившего запись'
/
