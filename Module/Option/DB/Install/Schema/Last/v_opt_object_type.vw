-- view: v_opt_object_type
-- Типы объектов ( актуальные данные).
--
create or replace force view
  v_opt_object_type
as
select
  -- SVN root: Oracle/Module/Option
  t.object_type_id
  , t.module_id
  , md.module_name
  , t.object_type_short_name
  , t.object_type_name
  , md.svn_root as module_svn_root
  , t.date_ins
  , t.operator_id
from
  opt_object_type t
  inner join v_mod_module md
    on md.module_id = t.module_id
where
  t.deleted = 0
/



comment on table v_opt_object_type is
  'Типы объектов ( актуальные данные) [ SVN root: Oracle/Module/Option]'
/
comment on column v_opt_object_type.object_type_id is
  'Id типа объекта'
/
comment on column v_opt_object_type.module_id is
  'Id модуля, к которому относится тип объекта'
/
comment on column v_opt_object_type.module_name is
  'Название модуля, к которому относится тип объекта'
/
comment on column v_opt_object_type.object_type_short_name is
  'Короткое название типа объекта ( уникальное в рамках модуля)'
/
comment on column v_opt_object_type.object_type_name is
  'Название типа объекта'
/
comment on column v_opt_object_type.module_svn_root is
  'Путь к корневому каталогу модуля в Subversion ( начиная с имени репозитария, например: "Oracle/Module/ModuleInfo")'
/
comment on column v_opt_object_type.date_ins is
  'Дата добавления записи'
/
comment on column v_opt_object_type.operator_id is
  'Id оператора, добавившего запись'
/
