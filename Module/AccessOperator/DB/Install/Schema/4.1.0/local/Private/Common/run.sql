-- script: db/install/schema/4.1.0/local/private/Common/run.sql
-- Обновление объектов схемы до версии 1.1.0.
--
-- Основные изменения:
--  - перезаливка триггера (другого модуля, TODO: разобраться)
--

-- Определяем табличное пространство для индексов
@oms-set-indexTablespace.sql

@oms-run op_group_aiud_add_event.trg


