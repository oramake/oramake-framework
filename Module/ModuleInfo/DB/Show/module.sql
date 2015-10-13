-- script: Show/module.sql
-- ѕоказывает установленные модули ( учитываютс€ только версии объектов схемы
-- основной части модулей, на основе <v_mod_install_module>).
--
-- ѕараметры:
-- modulePattern              - модуль ( шаблон дл€ like, которому должно
--                              соответствовать им€ модул€ ( module_name)
--                              или путь к корневому каталогу модул€
--                              ( svn_root) без учета регистра)
--

@@cdef.sql

select
  t.*
from
  v_mod_install_module t
where
  ( upper( t.module_name) like upper( '&1')
    or upper( t.svn_root) like upper( '&1')
  )
order by
  t.install_result_id
/
