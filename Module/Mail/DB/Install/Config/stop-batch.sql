-- script: Install/Config/deactivate-batch.sql
-- Деактивирует пакетные задания модуля ( с ожиданием остановки обработчиков).

@oms-stop-batch "Mail/%"
