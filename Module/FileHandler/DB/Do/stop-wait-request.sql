update 
  flh_request r
set 
  r.request_state_code = 'ERROR'
  , r.error_message = 'Проставлен статус ошибка для прерывания ожидания'
  , r.error_code = -1
  , r.last_processed = systimestamp
where
  request_id in 
  ( 
  select
    request_id
  from 
    v_flh_request_wait
  )
