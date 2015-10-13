-- view: v_mod_install_module
-- Установленные модули ( учитываются только версии объектов схемы
-- основных частей модулей).
--
create or replace force view
  v_mod_install_module
as
select
  -- SVN root: Oracle/Module/ModuleInfo
  t.install_result_id
  , t.module_name
  , t.svn_root
  , t.object_schema as main_object_schema
  , t.current_version
  , t.install_date
  , t.host
  , t.os_user
  , t.svn_path
  , t.svn_version_info
  , t.module_id
  , t.install_action_id
  , t.date_ins
  , t.operator_id
from
  v_mod_install_version t
where
  -- изменение объектов схемы и данных
  t.install_type_code = 'OBJ'
  and is_main_part = 1
/


comment on table v_mod_install_module is
  'Установленные модули ( учитываются только версии объектов схемы основных частей модулей) [ SVN root: Oracle/Module/ModuleInfo]'
/
comment on column v_mod_install_module.install_result_id is
  'Id результата установки'
/
comment on column v_mod_install_module.module_name is
  'Название модуля'
/
comment on column v_mod_install_module.svn_root is
  'Путь к корневому каталогу модуля в Subversion ( начиная с имени репозитария, например: "Oracle/Module/ModuleInfo")'
/
comment on column v_mod_install_module.main_object_schema is
  'Схема, в которой расположены объекты основной части модуля ( в верхнем регистре)'
/
comment on column v_mod_install_module.current_version is
  'Текущая версия'
/
comment on column v_mod_install_module.install_date is
  'Дата установки'
/
comment on column v_mod_install_module.host is
  'Имя хоста, с которого выполнялось действие'
/
comment on column v_mod_install_module.os_user is
  'Имя пользователя операционной системы, выполнявшего действие'
/
comment on column v_mod_install_module.svn_path is
  'Путь в Subversion, из которого были получены файлы модуля ( начиная с имени репозитария)'
/
comment on column v_mod_install_module.svn_version_info is
  'Информация о версии файлов модуля из Subversion ( в формате вывода утилиты svnversion)'
/
comment on column v_mod_install_module.module_id is
  'Id модуля'
/
comment on column v_mod_install_module.install_action_id is
  'Id действия по установке ( null если нет информации по действию)'
/
comment on column v_mod_install_module.date_ins is
  'Дата добавления записи'
/
comment on column v_mod_install_module.operator_id is
  'Id оператора, добавившего запись'
/
