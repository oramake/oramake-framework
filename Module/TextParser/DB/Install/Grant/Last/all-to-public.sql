-- script: Install/Grant/Last/all-to-public.sql
-- Выдача прав на использование модуля пользователю public

grant execute on tpr_csv_iterator_t to public
/
create or replace public synonym tpr_csv_iterator_t for tpr_csv_iterator_t
/

grant execute on tpr_line_iterator_t to public
/
create or replace public synonym tpr_line_iterator_t for tpr_line_iterator_t
/


