-- script: Install/Config/3.4.19/before-action.sql
-- Деактивация пакетных всех заданий

-- Ждем когда все задания выполнятся
@oms-run wait-job-stop.sql
-- Деактивируем все батчи
@oms-run deactivate-all.sql