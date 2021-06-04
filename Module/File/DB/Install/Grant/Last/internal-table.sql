-- script: Install/Grant/Last/internal-table.sql
-- Выдача прав на использование таблиц <doc_output_document>,
-- <doc_input_document> и выполнение <Install/Grant/Last/run.sql>;

define toUserName=&1

grant select, insert, update, delete on doc_output_document to &toUserName
/
create or replace synonym &toUserName..doc_output_document for doc_output_document
/
grant select, insert, update, delete on doc_input_document to &toUserName
/
create or replace synonym &toUserName..doc_input_document for doc_input_document
/

-- Располагаем вызов в конце, так как выполняется команда undefine
@oms-run run.sql &toUserName

undefine toUserName

