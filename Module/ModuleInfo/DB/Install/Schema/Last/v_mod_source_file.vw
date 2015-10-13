-- view: v_mod_source_file
-- Исходные файлы модулей.
--
create or replace force view
  v_mod_source_file
as
select
  -- SVN root: Oracle/Module/ModuleInfo
  sf.source_file_id
  , md.module_name
  , md.svn_root
  , sf.file_path
  , mp.part_number
  , mp.is_main_part
  , sf.object_name
  , sf.object_type
  , sf.module_id
  , sf.module_part_id
  , sf.date_ins
  , sf.operator_id
from
  mod_source_file sf
  inner join v_mod_module md
    on md.module_id = sf.module_id
  inner join mod_module_part mp
    on mp.module_part_id = sf.module_part_id
/



comment on table v_mod_source_file is
  'Исходные файлы модулей [ SVN root: Oracle/Module/ModuleInfo]'
/
comment on column v_mod_source_file.source_file_id is
  'Id исходного файла'
/
comment on column v_mod_source_file.module_name is
  'Название модуля'
/
comment on column v_mod_source_file.svn_root is
  'Путь к корневому каталогу модуля в Subversion ( начиная с имени репозитария, например: "Oracle/Module/ModuleInfo")'
/
comment on column v_mod_source_file.file_path is
  'Путь к исходному файлу'
/
comment on column v_mod_source_file.part_number is
  'Номер части модуля ( уникальный, начиная с 1)'
/
comment on column v_mod_source_file.is_main_part is
  'Флаг основной части модуля ( 1 основная часть модуля, 0 дополнительная)'
/
comment on column v_mod_source_file.object_name is
  'Имя объекта БД, которому соответствует исходный файл'
/
comment on column v_mod_source_file.object_type is
  'Тип объекта БД, которому соответствует исходный файл'
/
comment on column v_mod_source_file.module_id is
  'Id модуля'
/
comment on column v_mod_source_file.module_part_id is
  'Id части модуля'
/
comment on column v_mod_source_file.date_ins is
  'Дата добавления записи'
/
comment on column v_mod_source_file.operator_id is
  'Id оператора, добавившего запись'
/
