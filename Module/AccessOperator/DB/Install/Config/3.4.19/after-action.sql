-- script: Install/Config/3.4.19/after-action.sql
-- Активация пакетных заданий

define usedDayCount = '0'

-- Активируем все пакетные задания, которые раньше запускались
@oms-run activate-all.sql

-- Компилируем инвалидные объекты во всех схемах
@oms-run compile_all_invalid.sql

undefine usedDayCount
