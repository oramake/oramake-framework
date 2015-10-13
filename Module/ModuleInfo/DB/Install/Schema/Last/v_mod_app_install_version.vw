-- view: v_mod_app_install_version
-- Установленные версии приложений.
--
create or replace force view
  v_mod_app_install_version
as
select
  -- SVN root: Oracle/Module/ModuleInfo
  t.app_install_result_id
  , t.install_date
  , t.module_name
  , t.svn_root
  , t.deployment_path
  , t.install_version as current_version
  , t.module_version
  , t.svn_path
  , t.svn_version_info
  , t.module_id
  , t.deployment_id
  , t.date_ins
  , t.operator_id
from
  v_mod_app_install_result t
where
  t.is_current_version = 1
/



comment on table v_mod_app_install_version is
  'Установленные версии приложений [ SVN root: Oracle/Module/ModuleInfo]'
/
comment on column v_mod_app_install_version.app_install_result_id is
  'Id результата установки приложения'
/
comment on column v_mod_app_install_version.install_date is
  'Дата установки'
/
comment on column v_mod_app_install_version.module_name is
  'Название модуля'
/
comment on column v_mod_app_install_version.svn_root is
  'Путь к корневому каталогу модуля в Subversion ( начиная с имени репозитария, например: "Oracle/Module/ModuleInfo")'
/
comment on column v_mod_app_install_version.deployment_path is
  'Путь для развертывания приложения'
/
comment on column v_mod_app_install_version.current_version is
  'Текущая версия приложения'
/
comment on column v_mod_app_install_version.module_version is
  'Версия модуля'
/
comment on column v_mod_app_install_version.svn_path is
  'Путь в Subversion, из которого были получены файлы модуля ( начиная с имени репозитария)'
/
comment on column v_mod_app_install_version.svn_version_info is
  'Информация о версии файлов модуля из Subversion ( в формате вывода утилиты svnversion)'
/
comment on column v_mod_app_install_version.module_id is
  'Id модуля'
/
comment on column v_mod_app_install_version.deployment_id is
  'Id окружения для развертывания приложений'
/
comment on column v_mod_app_install_version.date_ins is
  'Дата добавления записи'
/
comment on column v_mod_app_install_version.operator_id is
  'Id оператора, добавившего запись'
/
