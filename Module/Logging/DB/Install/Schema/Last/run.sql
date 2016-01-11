--script: Install/Schema/Last/run.sql
--Установка последней версии объектов схемы.



@oms-set-indexTablespace.sql


-- Собственные таблицы
@@lg_destination.tab
@@lg_level.tab

-- Представления

--Выдача прав на использование всем пользователям
@oms-run ./Install/Grant/Last/all-to-public.sql
