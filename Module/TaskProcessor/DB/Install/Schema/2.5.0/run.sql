-- script: Install/Schema/2.5.0/run.sql
-- Обновление объектов схемы до версии 2.5.0.
--
-- Основные изменения:
--  - в таблицу <tp_task> добавлено поле exec_result_string;
--

@oms-run tp_task.sql
