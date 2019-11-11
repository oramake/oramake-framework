-- scrupt: run.sql
-- Установка объектов

@oms-check-lock op_operator

-- Запуск скриптов

@oms-run drop-old-objects.sql
@oms-run op_operator.sql
@oms-run op_role.sql
@oms-run op_group.sql


