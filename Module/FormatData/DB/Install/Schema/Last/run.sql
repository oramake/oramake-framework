-- script: Install/Schema/Last/run.sql
-- Выполняет установку последней версии объектов схемы.
--

-- Определяем табличное пространство для индексов
@oms-set-indexTablespace.sql

-- Таблицы
@oms-run fd_alias.tab
@oms-run fd_alias_type.tab

-- Outline-ограничения целостности
@oms-run fd_alias.con
@oms-run fd_alias_type.con

-- Триггеры
@oms-run fd_alias_bi_define.trg
--@oms-run fd_alias_biu_format.trg
@oms-run fd_alias_type_bi_define.trg

-- Представления
@oms-run v_fd_first_name_alias.vw
@oms-run v_fd_middle_name_alias.vw
@oms-run v_fd_no_value_alias.vw
