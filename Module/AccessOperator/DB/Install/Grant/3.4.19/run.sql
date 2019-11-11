-- script: Install\Grant\3.4.19\run.sql
-- Выполняет выдачу прав на объекты версии 3.4.19 схемы.
-- Пользователь, под которым выполняется скрипт должен иметь права
-- create any synonym

-- Создание public синонимов
@oms-run public_synonym.sql

-- Выдача public прав
@oms-run public_grant.sql