-- view: v_fd_middle_name_alias
-- Синонимы для отчества человека.
create or replace view
  v_fd_middle_name_alias
as
select
  -- SVN root: Oracle/Module/FormatData
  al.alias_type_code
  , al.alias_name
  , al.base_name
  , al.date_ins
  , al.operator_id
from
  fd_alias al
where
  al.alias_type_code = 'MN'
/



comment on table v_fd_middle_name_alias is
  'Синонимы для отчества человека [ SVN root: Oracle/Module/FormatData]'
/
comment on column v_fd_middle_name_alias.alias_type_code is
  'Код типа синонима'
/
comment on column v_fd_middle_name_alias.alias_name is
  'Исходное значение'
/
comment on column v_fd_middle_name_alias.base_name is
  'Базовая форма'
/
comment on column v_fd_middle_name_alias.date_ins is
  'Дата добавления записи'
/
comment on column v_fd_middle_name_alias.operator_id is
  'Id оператора, добавившего запись'
/
