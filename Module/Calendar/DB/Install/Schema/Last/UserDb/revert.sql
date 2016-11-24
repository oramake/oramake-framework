-- script: Install/Schema/Last/UserDb/revert.sql
-- Отменяет установку модуля, удаляя созданные объекты схемы в
-- пользовательской БД.
--

-- Представления

drop view v_cdr_day
/
drop view v_cdr_day_type
/


-- Материализованные представления

drop materialized view mv_cdr_day
/
drop materialized view mv_cdr_day_type
/
