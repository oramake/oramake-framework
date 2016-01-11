begin
merge into 
  ml_message_state d
using  
  (
  select
    pkg_Mail.Received_MessageStateCode as message_state_code
    , 'Получено' as message_state_name_rus
    , 'Received' as message_state_name_eng
  from dual
  union all select
    pkg_Mail.Nested_MessageStateCode
    , 'Вложенное'
    , 'Nested'
  from dual
  union all select
    pkg_Mail.Processed_MessageStateCode
    , 'Обработано'
    , 'Processed'
  from dual
  union all select
    pkg_Mail.ProcessError_MessageStateCode
    , 'Ошибка обработки'
    , 'Process error'
  from dual
  union all select
    pkg_Mail.WaitSend_MessageStateCode
    , 'Ожидает отправки'
    , 'Wait send'
  from dual
  union all select
    pkg_Mail.SendCanceled_MessageStateCode
    , 'Отправка отменена'
    , 'Send canceled'
  from dual
  union all select
    pkg_Mail.Send_MessageStateCode
    , 'Отправлено'
    , 'Send'
  from dual
  union all select
    pkg_Mail.SendError_MessageStateCode
    , 'Ошибка отправки'
    , 'Send Error'
  from dual
  minus
  select
    message_state_code
    , message_state_name_rus
    , message_state_name_eng
  from
    ml_message_state
  ) s
on
  (
  d.message_state_code = s.message_state_code
  )
when not matched then insert  
  (
  message_state_code
  , message_state_name_rus
  , message_state_name_eng
  )
values
  (
  s.message_state_code
  , s.message_state_name_rus
  , s.message_state_name_eng
  )
when matched then update set
  d.message_state_name_rus      = s.message_state_name_rus
  , d.message_state_name_eng    = s.message_state_name_eng
;
  dbms_output.put_line('Affected: ' || to_char( sql%rowcount));      
  commit;
end;
/
