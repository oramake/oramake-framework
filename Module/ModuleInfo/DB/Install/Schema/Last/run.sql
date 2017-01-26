-- script: Install/Schema/Last/run.sql
-- Выполняет установку последней версии объектов схемы.
--

-- Определяем табличное пространство для индексов
@oms-set-indexTablespace.sql


-- Собственные таблицы
@oms-run mod_app_install_result.tab
@oms-run mod_deployment.tab
@oms-run mod_install_action.tab
@oms-run mod_install_file.tab
@oms-run mod_install_result.tab
@oms-run mod_install_type.tab
@oms-run mod_module.tab
@oms-run mod_module_part.tab
@oms-run mod_source_file.tab


-- Outline-ограничения целостности
@oms-run mod_app_install_result.con
@oms-run mod_deployment.con
@oms-run mod_install_action.con
@oms-run mod_install_file.con
@oms-run mod_install_result.con
@oms-run mod_module.con
@oms-run mod_module_part.con
@oms-run mod_source_file.con


-- Последовательности
@oms-run mod_app_install_result_seq.sqs
@oms-run mod_deployment_seq.sqs
@oms-run mod_install_action_seq.sqs
@oms-run mod_install_file_seq.sqs
@oms-run mod_install_result_seq.sqs
@oms-run mod_module_part_seq.sqs
@oms-run mod_module_seq.sqs
@oms-run mod_source_file_seq.sqs
