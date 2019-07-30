-- view: v_fd_no_value_alias
-- Синонимы для отсутствующего значения.
create or replace view
  v_fd_no_value_alias
as
select
  -- SVN root: Oracle/Module/FormatData
  al.alias_type_code
  , al.alias_name
  , al.base_name
  , al.date_ins
from
  fd_alias al
where
  al.alias_type_code = 'NV'
/



comment on table v_fd_no_value_alias is
  'Синонимы, используемые при получении базовой формы значений [ SVN root: Oracle/Module/FormatData]'
/
comment on column v_fd_no_value_alias.alias_type_code is
  'Код типа синонима'
/
comment on column v_fd_no_value_alias.alias_name is
  'Исходное значение'
/
comment on column v_fd_no_value_alias.base_name is
  'Базовая форма'
/
comment on column v_fd_no_value_alias.date_ins is
  'Дата добавления записи'
/
