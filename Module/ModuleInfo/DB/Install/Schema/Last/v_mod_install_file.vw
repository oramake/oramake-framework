-- view: v_mod_install_file
-- Устанавливавшиеся файлы модулей.
--
create or replace force view
  v_mod_install_file
as
select
  -- SVN root: Oracle/Module/ModuleInfo
  t.install_file_id
  , t.install_action_id
  , sf.module_name
  , sf.svn_root
  , sf.file_path
  , t.install_user
  , t.run_level
  , t.start_date
  , t.finish_date
  , sf.object_name
  , sf.object_type
  , t.source_file_id
  , t.date_ins
  , t.operator_id
from
  mod_install_file t
  inner join v_mod_source_file sf
    on sf.source_file_id = t.source_file_id
/


comment on table v_mod_install_file is
  'Устанавливавшиеся файлы модулей [ SVN root: Oracle/Module/ModuleInfo]'
/
comment on column v_mod_install_file.install_file_id is
  'Id записи'
/
comment on column v_mod_install_file.install_action_id is
  'Id действия по установке'
/
comment on column v_mod_install_file.module_name is
  'Название модуля'
/
comment on column v_mod_install_file.svn_root is
  'Путь к корневому каталогу модуля в Subversion ( начиная с имени репозитария, например: "Oracle/Module/ModuleInfo")'
/
comment on column v_mod_install_file.file_path is
  'Путь к исходному файлу'
/
comment on column v_mod_install_file.install_user is
  'Имя пользователя, под которым выполнялась установка ( в верхнем регистре)'
/
comment on column v_mod_install_file.run_level is
  'Уровень вложенности выполняемого файла ( 1 для файла верхнего уровня, 2 для вызываемого из него файла и т.д.)'
/
comment on column v_mod_install_file.start_date is
  'Дата начала установки файла'
/
comment on column v_mod_install_file.finish_date is
  'Дата завершения установки файла ( null если она не была успешно завершена)'
/
comment on column v_mod_install_file.object_name is
  'Имя объекта БД, которому соответствует исходный файл'
/
comment on column v_mod_install_file.object_type is
  'Тип объекта БД, которому соответствует исходный файл'
/
comment on column v_mod_install_file.source_file_id is
  'Id исходного файла'
/
comment on column v_mod_install_file.date_ins is
  'Дата добавления записи'
/
comment on column v_mod_install_file.operator_id is
  'Id оператора, добавившего запись'
/
