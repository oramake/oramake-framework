-- view: v_mod_app_install_result
-- Результаты установки приложений.
--
create or replace force view
  v_mod_app_install_result
as
select
  -- SVN root: Oracle/Module/ModuleInfo
  t.app_install_result_id
  , md.module_name
  , md.svn_root
  , dp.deployment_path
  , t.install_date
  , t.install_version
  , t.module_version
  , t.is_current_version
  , t.svn_path
  , t.svn_version_info
  , t.java_return_code
  , t.error_message
  , t.module_id
  , t.deployment_id
  , t.date_ins
  , t.operator_id
from
  mod_app_install_result t
  inner join mod_deployment dp
    on dp.deployment_id = t.deployment_id
  inner join v_mod_module md
    on md.module_id = t.module_id
/



comment on table v_mod_app_install_result is
  'Результаты установки приложений [ SVN root: Oracle/Module/ModuleInfo]'
/
comment on column v_mod_app_install_result.app_install_result_id is
  'Id результата установки приложения'
/
comment on column v_mod_app_install_result.module_name is
  'Название модуля'
/
comment on column v_mod_app_install_result.svn_root is
  'Путь к корневому каталогу модуля в Subversion ( начиная с имени репозитария, например: "Oracle/Module/ModuleInfo")'
/
comment on column v_mod_app_install_result.deployment_path is
  'Путь для развертывания приложения'
/
comment on column v_mod_app_install_result.install_date is
  'Дата установки'
/
comment on column v_mod_app_install_result.install_version is
  'Устанавливаемая версия приложения'
/
comment on column v_mod_app_install_result.module_version is
  'Версия модуля'
/
comment on column v_mod_app_install_result.is_current_version is
  'Флаг текущей версии ( 1 - текущая, 0 - ранее установленная не текущая, null - установка не была успешно завершена)'
/
comment on column v_mod_app_install_result.svn_path is
  'Путь в Subversion, из которого были получены файлы модуля ( начиная с имени репозитария)'
/
comment on column v_mod_app_install_result.svn_version_info is
  'Информация о версии файлов модуля из Subversion ( в формате вывода утилиты svnversion)'
/
comment on column v_mod_app_install_result.java_return_code is
  'Код результата выполнения установки Java-приложения ( 0 означает отсутствие ошибок)'
/
comment on column v_mod_app_install_result.error_message is
  'Текст сообщения об ошибках при выполнении установки'
/
comment on column v_mod_app_install_result.module_id is
  'Id модуля'
/
comment on column v_mod_app_install_result.deployment_id is
  'Id окружения для развертывания приложений'
/
comment on column v_mod_app_install_result.date_ins is
  'Дата добавления записи'
/
comment on column v_mod_app_install_result.operator_id is
  'Id оператора, добавившего запись'
/
