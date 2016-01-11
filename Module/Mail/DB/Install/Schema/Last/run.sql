--script: Install/Schema/Last/run.sql
--Выполняет установку последней версии объектов схемы.
--
@oms-set-indexTablespace.sql


--
--
--

--Модуль Operator
--@@op_operator.tab

--Собственные таблицы
@@ml_attachment.tab
@@ml_message.tab
@@ml_message_state.tab
@@ml_request_state.tab
@@ml_fetch_request.tab

--Outline-ограничения целостности
@@ml_attachment.con
@@ml_message.con
@@ml_message_state.con
@@ml_request_state.con
@@ml_fetch_request.con

--Последовательности
@@sequences.sql




