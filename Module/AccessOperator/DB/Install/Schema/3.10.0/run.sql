-- script: Install/Schema/3.10.0/Local/Private/Main/run.sql
-- Установка объектов версии 3.10.0 модуля


@oms-set-indexTablespace.sql



-- Запуск скриптов

@oms-run op_login_attempt_group.sql
@oms-run op_role.sql
@oms-run op_group.sql


-- Создание представлений

@oms-run Install/Schema/Last/v_op_login_attempt_group.vw
