-- script: Install/Grant/Last/internal-table.sql
-- ������ ���� �� ������������� ������ <doc_output_document>,
-- <doc_input_document> � ���������� <Install/Grant/Last/run.sql>;

define toUserName=&1

grant select, insert, update, delete on doc_output_document to &toUserName
/
create or replace synonym &toUserName..doc_output_document for doc_output_document
/
grant select, insert, update, delete on doc_input_document to &toUserName
/
create or replace synonym &toUserName..doc_input_document for doc_input_document
/

-- ����������� ����� � �����, ��� ��� ����������� ������� undefine
@oms-run run.sql &toUserName

undefine toUserName

