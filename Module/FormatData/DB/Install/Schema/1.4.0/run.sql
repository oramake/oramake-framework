-- script: Install/Schema/1.4.0/run.sql
-- Обновление объектов схемы до версии 1.4.0.
--
-- Основные изменения:
--  - в таблице <fd_alias_type> поле alias_type_name_rus переименовано в
--    alias_type_name, а поле operator_id удалено;
--  - в таблице <fd_alias> поле operator_id удалено;
--

@oms-run fd_alias_type.sql
@oms-run fd_alias.sql
