-- script: Show/action.sql
-- Показывает выполнявшиеся действия по установке модулей ( на основе
-- <v_mod_install_action>), при этом выводятся последние 30 записей либо
-- записи за последние полгода.
--
-- Параметры:
-- modulePattern              - модуль ( шаблон для like, которому должно
--                              соответствовать имя модуля ( module_name)
--                              или путь к корневому каталогу модуля
--                              ( svn_root) без учета регистра)
--

@@cdef.sql

select
  a.*
from
  (
  select
    t.*
  from
    v_mod_install_action t
  where
    ( upper( t.module_name) like upper( '&1')
      or upper( t.svn_root) like upper( '&1')
    )
  order by
    t.install_action_id desc
  ) a
where
  ( rownum <= 30
    or a.date_ins >= add_months( trunc( sysdate), -6)
  )
order by
  a.install_action_id
/
