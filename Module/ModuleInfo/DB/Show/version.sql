-- script: Show/version.sql
-- Показывает текущие установленные версии частей модулей ( в т.ч. версии
-- установок настройки прав доступа, на основе <v_mod_install_version>).
--
-- Параметры:
-- modulePattern              - модуль ( шаблон для like, которому должно
--                              соответствовать имя модуля ( module_name)
--                              или путь к корневому каталогу модуля
--                              ( svn_root) без учета регистра)
--

@@cdef.sql

select
  t.*
from
  v_mod_install_version t
where
  ( upper( t.module_name) like upper( '&1')
    or upper( t.svn_root) like upper( '&1')
  )
order by
  t.install_result_id
/
