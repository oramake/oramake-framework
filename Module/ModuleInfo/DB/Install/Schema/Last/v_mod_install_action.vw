-- view: v_mod_install_action
-- ƒействи€ по установке модулей.
--
create or replace force view
  v_mod_install_action
as
select
  -- SVN root: Oracle/Module/ModuleInfo
  ia.install_action_id
  , ia.host
  , ia.host_process_start_time
  , ia.host_process_id
  , ia.os_user
  , md.module_name
  , md.svn_root
  , ia.module_version
  , ia.install_version
  , ia.action_goal_list
  , ia.action_option_list
  , ia.svn_path
  , ia.svn_version_info
  , ia.module_id
  , ia.date_ins
  , ia.operator_id
from
  mod_install_action ia
  inner join v_mod_module md
    on md.module_id = ia.module_id
/



comment on table v_mod_install_action is
  'ƒействи€ по установке модулей [ SVN root: Oracle/Module/ModuleInfo]'
/
comment on column v_mod_install_action.install_action_id is
  'Id действи€ по установке'
/
comment on column v_mod_install_action.host is
  '»м€ хоста, с которого выполн€лось действие'
/
comment on column v_mod_install_action.host_process_start_time is
  '¬рем€ начала выполнени€ процесса, в котором выполн€лось действие ( указываетс€ локальное врем€ на хосте)'
/
comment on column v_mod_install_action.host_process_id is
  '»дентификатор процесса на хосте, в котором выполн€лось действие'
/
comment on column v_mod_install_action.os_user is
  '»м€ пользовател€ операционной системы, выполн€вшего действие'
/
comment on column v_mod_install_action.module_name is
  'Ќазвание модул€'
/
comment on column v_mod_install_action.svn_root is
  'ѕуть к корневому каталогу модул€ в Subversion ( начина€ с имени репозитари€, например: "Oracle/Module/ModuleInfo")'
/
comment on column v_mod_install_action.module_version is
  '¬ерси€ модул€'
/
comment on column v_mod_install_action.install_version is
  '”станавливаема€ верси€ модул€'
/
comment on column v_mod_install_action.action_goal_list is
  '÷ели выполнени€ действи€ ( список с пробелами в качестве разделител€)'
/
comment on column v_mod_install_action.action_option_list is
  'ѕараметры действи€ ( список с пробелами в качестве разделител€)'
/
comment on column v_mod_install_action.svn_path is
  'ѕуть в Subversion, из которого были получены файлы модул€ ( начина€ с имени репозитари€)'
/
comment on column v_mod_install_action.svn_version_info is
  '»нформаци€ о версии файлов модул€ из Subversion ( в формате вывода утилиты svnversion)'
/
comment on column v_mod_install_action.module_id is
  'Id модул€'
/
comment on column v_mod_install_action.date_ins is
  'ƒата добавлени€ записи'
/
comment on column v_mod_install_action.operator_id is
  'Id оператора, добавившего запись'
/
