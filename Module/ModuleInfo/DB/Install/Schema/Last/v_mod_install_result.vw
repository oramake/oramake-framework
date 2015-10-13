-- view: v_mod_install_result
-- Результаты действий по установке модулей.
--
create or replace force view
  v_mod_install_result
as
select
  -- SVN root: Oracle/Module/ModuleInfo
  ir.install_result_id
  , ir.install_date
  , md.module_name
  , md.svn_root
  , mp.part_number
  , mp.is_main_part
  , ir.result_version
  , ir.install_type_code
  , ir.object_schema
  , ir.privs_user
  , ir.install_script
  , ir.is_current_version
  , ir.install_user
  , ir.install_version
  , ir.is_full_install
  , ir.is_revert_install
  , ia.module_version
  , ia.host
  , ia.os_user
  , ia.action_goal_list
  , ia.action_option_list
  , ia.svn_path
  , ia.svn_version_info
  , ir.module_id
  , ir.module_part_id
  , ir.install_action_id
  , ir.date_ins
  , ir.operator_id
from
  mod_install_result ir
  inner join v_mod_module md
    on md.module_id = ir.module_id
  inner join mod_module_part mp
    on mp.module_part_id = ir.module_part_id
  left outer join mod_install_action ia
    on ia.install_action_id = ir.install_action_id
/



comment on table v_mod_install_result is
  'Результаты действий по установке модулей [ SVN root: Oracle/Module/ModuleInfo]'
/
comment on column v_mod_install_result.install_result_id is
  'Id результата установки'
/
comment on column v_mod_install_result.install_date is
  'Дата установки'
/
comment on column v_mod_install_result.module_name is
  'Название модуля'
/
comment on column v_mod_install_result.svn_root is
  'Путь к корневому каталогу модуля в Subversion ( начиная с имени репозитария, например: "Oracle/Module/ModuleInfo")'
/
comment on column v_mod_install_result.part_number is
  'Номер части модуля ( уникальный, начиная с 1)'
/
comment on column v_mod_install_result.is_main_part is
  'Флаг основной части модуля ( 1 основная часть модуля, 0 дополнительная)'
/
comment on column v_mod_install_result.result_version is
  'Версия, получившаяся результате выполнения установки ( отличается от install_version в случае выполнения отмены установки обновления, null в случае полной отмены установки)'
/
comment on column v_mod_install_result.install_type_code is
  'Код типа установки'
/
comment on column v_mod_install_result.object_schema is
  'Схема, в которой расположены объекты данной части модуля ( в верхнем регистре)'
/
comment on column v_mod_install_result.privs_user is
  'Имя пользователя, для которого выполнялась настройка прав доступа ( в верхнем регистре)'
/
comment on column v_mod_install_result.install_script is
  'Стартовый установочный скрипт ( может отсутствовать, если для установки может быть использован только единственный тривиальный вариант, например run.sql)'
/
comment on column v_mod_install_result.is_current_version is
  'Флаг текущей версии ( 1 текущая, иначе 0)'
/
comment on column v_mod_install_result.install_user is
  'Имя пользователя, под которым выполнялась установка ( в верхнем регистре)'
/
comment on column v_mod_install_result.install_version is
  'Устанавливаемая версия'
/
comment on column v_mod_install_result.is_full_install is
  'Флаг полной установки ( 1 при полной установке, 0 при установке обновления)'
/
comment on column v_mod_install_result.is_revert_install is
  'Флаг выполнения отмены установки версии ( 1 отмена установки версии, 0 установка версии)'
/
comment on column v_mod_install_result.module_version is
  'Версия модуля'
/
comment on column v_mod_install_result.host is
  'Имя хоста, с которого выполнялось действие'
/
comment on column v_mod_install_result.os_user is
  'Имя пользователя операционной системы, выполнявшего действие'
/
comment on column v_mod_install_result.action_goal_list is
  'Цели выполнения действия ( список с пробелами в качестве разделителя)'
/
comment on column v_mod_install_result.action_option_list is
  'Параметры действия ( список с пробелами в качестве разделителя)'
/
comment on column v_mod_install_result.svn_path is
  'Путь в Subversion, из которого были получены файлы модуля ( начиная с имени репозитария)'
/
comment on column v_mod_install_result.svn_version_info is
  'Информация о версии файлов модуля из Subversion ( в формате вывода утилиты svnversion)'
/
comment on column v_mod_install_result.module_id is
  'Id модуля'
/
comment on column v_mod_install_result.module_part_id is
  'Id части модуля'
/
comment on column v_mod_install_result.install_action_id is
  'Id действия по установке ( null если нет информации по действию)'
/
comment on column v_mod_install_result.date_ins is
  'Дата добавления записи'
/
comment on column v_mod_install_result.operator_id is
  'Id оператора, добавившего запись'
/
