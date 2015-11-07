--script: Install/Schema/Last/run.sql
--Выполняет установку последней версии объектов схемы.
--


--Собственные таблицы
@@doc_input_document.tab
@@doc_output_document.tab
@@tmp_file_name.tab

--Последовательности
@@sequences.sql

--Триггеры
@@doc_input_document_bi_define.trg
@@doc_output_document_bi_define.trg
@@tmp_file_name_bi_define.trg
