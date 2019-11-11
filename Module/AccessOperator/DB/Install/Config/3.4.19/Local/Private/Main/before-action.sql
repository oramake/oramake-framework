-- script: Install/Config/3.4.19/Local/Private/Main/before-action.sql
-- Деактивация пакетных всех заданий

-- Ждем когда все задания выполнятся
@oms-run wait-job-stop.sql

-- Деактивируем батч репликации операторов
@oms-deactivate-batch.sql CopyOperator
