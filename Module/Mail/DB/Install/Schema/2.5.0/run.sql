-- script: Install/Schema/2.5.0/run.sql
-- Обновление объектов схемы до версии 2.5.0.
--
-- Основные изменения:
--   Изменение размера полей <ml_message>: 
--   sender_address varchar2(100), recipient_address varchar2(100). 

-- Определяем табличное пространство для индексов
@oms-set-indexTablespace.sql

@oms-run ml_message.sql
