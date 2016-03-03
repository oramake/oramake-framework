-- script: Install/Grant/Last/reference.sql
-- ѕрава на использование ссылок на таблицы модул€.

define toUserName=&1

grant select, references on doc_mask to &toUserName
/
create or replace synonym &toUserName..doc_mask for doc_mask
/

grant select, references on doc_storage_rule to &toUserName
/
create or replace synonym &toUserName..doc_storage_rule for doc_storage_rule
/

undefine toUserName
