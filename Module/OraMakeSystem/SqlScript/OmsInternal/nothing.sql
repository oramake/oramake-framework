--script: OmsInternal/nothing.sql
--Пустой скрипт, ничего не делает.
--
--Замечания:
--  - вызывается из скрита <oms-run.sql> в случае, если не нужно выполнять
--    пользовательский скрипт ( т.к. команда "@" без аргументов вызывает
--    в SQL*Plus 11.1.0.7.0 сообщение об ошибке
--    "SP2-1506: START, @ or @@ command has no arguments");
--
