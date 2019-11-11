-- script: Install\Grant\Last\grant-all.sql
-- Создание синонимов и выдача прав и на ВСЕ действия над объектами модуля 
-- Пользователь, под которым выполняется скрипт должен иметь права
-- create any synonym

define toUserName = "&1"

-- Выдача прав
@oms-run grant_local.sql "&toUserName"

-- Создание синонимов
@oms-run synonym_local.sql "&toUserName"


undefine toUserName