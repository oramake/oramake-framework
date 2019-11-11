-- script: Install/Schema/4.1.0/run.sql
-- Установка объектов для версии 4.1.0



-- Изменения таблиц и обновление данных

@oms-run op_operator_group.sql
@oms-run op_operator_role.sql



-- Удаление таблицы

@oms-run op_grant_group_del.sql


