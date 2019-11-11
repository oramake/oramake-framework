-- script: Install/Schema/3.5.0/rp_event.sql
-- Изменение таблицы <rp_event>

alter table
  rp_event
drop constraint 
  rp_event_ck_event_type
/

alter table
  rp_event
add 
  constraint rp_event_ck_event_type check (event_type in ( 'D', 'I', 'U', 'L', 'R'))
/