-- script: Install/Schema/2.4.0/run.sql
-- Обновление объектов схемы до версии 2.4.0.
--
-- Основные изменения:
--  - уточнен комментарий к устаревшей таблице <tp_task_log>;
--

comment on table tp_task_log is
  'Лог выполнения заданий (устаревшая таблица, начиная с версии 2.4.0 лог сохраняется в таблице lg_log модуля Logging) [ SVN root: Oracle/Module/TaskProcessor]'
/
