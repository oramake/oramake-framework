-- view: v_mod_module
-- ѕрограммные модули.
--
create or replace force view
  v_mod_module
as
select
  -- SVN root: Oracle/Module/ModuleInfo
  md.module_id
  , case when md.svn_root like '%/Module/_%' then
      substr( md.svn_root, instr( md.svn_root, '/Module/') + 8)
    else
      md.svn_root
    end
    as module_name
  , substr( md.svn_root, 1, instr( md.svn_root, '/') - 1)
    as repository_name
  , md.svn_root
  , md.initial_svn_root
  , md.initial_svn_revision
  , md.date_ins
  , md.operator_id
from
  mod_module md
/



comment on table v_mod_module is
  'ѕрограммные модули [ SVN root: Oracle/Module/ModuleInfo]'
/
comment on column v_mod_module.module_id is
  'Id модул€'
/
comment on column v_mod_module.module_name is
  'Ќазвание модул€'
/
comment on column v_mod_module.repository_name is
  'Ќазвание репозитари€, к которому относитс€ модуль'
/
comment on column v_mod_module.svn_root is
  'ѕуть к корневому каталогу модул€ в Subversion ( начина€ с имени репозитари€, например: "Oracle/Module/ModuleInfo")'
/
comment on column v_mod_module.initial_svn_root is
  'ѕервоначальный путь к корневому каталогу модул€ в Subversion ( начина€ с имени репозитари€, может отличатьс€ от svn_root в случае переименовани€ модул€ или переноса в другой репозитарий)'
/
comment on column v_mod_module.initial_svn_revision is
  'Ќомер правки в Subversion, в которой был создан первоначальный корневой каталог модул€ ( значение этого пол€ совместно со значением пол€ initial_svn_root составл€ют глобальный уникальный неизмен€емый идентификатор модул€)'
/
comment on column v_mod_module.date_ins is
  'ƒата добавлени€ записи'
/
comment on column v_mod_module.operator_id is
  'Id оператора, добавившего запись'
/
