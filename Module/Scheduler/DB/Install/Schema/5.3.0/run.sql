-- script: Install/Schema/5.3.0/run.sql
-- Обновление объектов схемы до версии 5.3.0.
--
-- Основные изменения:
--  - увеличена максимальная длина поля privilege_name;
--

@oms-run sch_privilege.sql
