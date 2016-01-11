-- view: v_ml_fetch_request_wait
-- ������� �� ���������� ���������, ��������� ��������� 
-- 
create or replace view v_ml_fetch_request_wait
as 
/* SVN root: Exchange/Module/Mail */
select 
  fetch_request_id as fetch_request_id
  , handler_sid as handler_sid
  , handler_serial# as handler_serial#
  , r.priority_order
  , batch_short_name as batch_short_name
from
  (
  select /*+index(r ml_fetch_request_ix_wait)*/
    case request_state_code when 'WAIT' then
      fetch_request_id   
    end as fetch_request_id    
    , 
    case request_state_code when 'WAIT' then
      handler_sid
    end as handler_sid    
    , 
    case request_state_code when 'WAIT' then
      handler_serial#
    end as handler_serial#
    , 
    case request_state_code when 'WAIT' then
      priority_order
    end as priority_order    
    ,
    case request_state_code when 'WAIT' then
      batch_short_name
    end as batch_short_name
  from
    ml_fetch_request r
  ) r
where
  fetch_request_id is not null
/
comment on table v_ml_fetch_request_wait is 
'������� �� ���������� email-���������, ��������� ��������� 
[ SVN root: Exchange/Module/Mail]
'
/
comment on column v_ml_fetch_request_wait.fetch_request_id is
'Id ������� ���������� ��������� �� �����. ��������� ����.'
/
comment on column v_ml_fetch_request_wait.handler_sid is
'������� ������ �����������: "sid"'
/
comment on column v_ml_fetch_request_wait.handler_serial# is
'������� ������ �����������: "serial#"'
/
comment on column v_ml_fetch_request_wait.priority_order is
'��������� ������� 
( ������� �������������� ������� � ������� priority_order)'
/
comment on column v_ml_fetch_request_wait.batch_short_name is
'��� �����, ����� job''� �������� ������� ������'
/
