-- script: Show/object.sql
-- Показывает устанавливавшиеся объекты БД.
--
-- Параметры:
-- objectPattern              - шаблон для выбора объектов ( значение
--                              используется без учета регистра, при отсутствии
--                              в шаблоне точки он применяется к имени
--                              объекта ( object_name), при наличии точки к
--                              схеме и имени объекта ( owner.object_name))
--
--
-- Замечания:
-- - наличие в БД указанных объектов не проверяется ( т.е. они могли быть
--  установлены, а затем удалены);
--

@@cdef.sql

select
  t.*
from
  (
  select
    '&1' as object_pattern
    , case when instr( '&1', '.') > 0 then 1 else 0 end
      as is_use_owner
  from
    dual
  ) cfg
  cross join v_mod_install_object t
where
  cfg.is_use_owner = 0
    and upper( t.object_name) like upper( cfg.object_pattern)
  or cfg.is_use_owner = 1
    and upper( t.owner || '.' || t.object_name) like upper( cfg.object_pattern)
order by
  t.install_action_id
/
