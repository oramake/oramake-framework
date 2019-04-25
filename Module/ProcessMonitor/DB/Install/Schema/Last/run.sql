-- script: Install/Schema/Last/run.sql
-- Выполняет установку последней версии объектов схемы.


-- Определяем табличное пространство для индексов
@oms-set-indexTablespace.sql


-- Таблицы

@oms-run prm_batch_config.tab
@oms-run prm_registered_session.tab
@oms-run prm_session_action.tab


-- Outline-ограничения целостности

@oms-run prm_session_action.con
