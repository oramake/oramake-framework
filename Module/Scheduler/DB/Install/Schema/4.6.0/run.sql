-- script: Install/Schema/4.6.0/run.sql
-- Обновление объектов схемы до версии 4.6.0.
--
-- Основные изменения:
--  - добавлен индекс sch_log_ix_root_date_ins;
--

create index
  sch_log_ix_root_date_ins
on
  sch_log (
    case when
      parent_log_id is null
      and sessionid is null
    then
      date_ins
    end
  )
/
