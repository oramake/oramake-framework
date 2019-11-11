-- script: Show/option.sql
-- Показывает настроечные параметры с текущими используемыми значениями
-- (из <v_opt_option_value>).
--
-- Параметры:
-- findString                 - Строка для отбора параметров
--                              (шаблон для like без учета регистра)
--
-- Для отображения параметра досточно выполнения любого из условий:
-- - имя параметра (option_short_name) подходит под findString (сравнение
--  по like без учета регистра);
-- - имя модуля (module_name) или имя объекта (object_short_name) или имя типа
--  объекта (object_type_short_name) равно findString (без учета регистра);
-- - в findString присутствует точка и строка вида
--  "<module_name>.<object_short_name>.<object_type_short_name>.<option_short_name>"
--  подходит под findString (по like без учета регистра, при этом
--  если findString начинается/заканчивается на точку, то в начало/конец
--  строки findString добавляется символ "%", если указано две точки подряд,
--  то между ними вставляется символ "%", подстрока ".-." заменяется на "...");
--
--  Примеры:
--
--  - показать параметры с именами, оканчивающимися на "DbLink"
--
--    > SQL> @option.sql %DbLink
--
--  - показать параметры пакетного задания "ClearOldLog"
--
--    > SQL> @option.sql ClearOldLog
--
--    или более точно
--
--    > SQL> @option.sql .ClearOldLog.batch.
--
--  - показать параметры пакетных заданий с именами, содержащими "Mail"
--
--    > SQL> @option.sql .%Mail%.batch.
--
--  - показать параметры модуля "Scheduler"
--
--    > SQL> @option.sql scheduler
--
--    или более точно
--
--    > SQL> @option.sql scheduler.
--
--  - показать параметры модуля "Scheduler", не относящиеся к объектам
--    (в т.ч. пакетным заданиям)
--
--    > SQL> @option.sql scheduler.-.
--

var findString varchar2(255)
exec :findString := trim( '&1')


select
  t.*
from
  v_opt_option_value t
where
  upper( t.module_name) = upper( :findString)
  or upper( t.object_short_name) = upper( :findString)
  or upper( t.object_type_short_name) = upper( :findString)
  or upper( t.option_short_name) like upper( :findString)
  or :findString like '%.%'
    and upper(
      t.module_name
      || '.' || t.object_short_name
      || '.' || t.object_type_short_name
      || '.' || t.option_short_name
    )
    like upper(
      case when :findString like '.%' then
        '%'
      end
      || replace( replace( replace(
          :findString, '...', '.%.%.'), '..', '.%.'), '.-.', '...')
      || case when :findString like '%.' then
          '%'
        end
    )
order by
  t.module_name
  , t.module_svn_root
  , t.object_short_name nulls first
  , t.option_short_name
/



undefine findString
