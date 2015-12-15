-- script: ml_request_state
-- Добавление информации в справочник <ml_request_state>
begin
  insert into ml_request_state(
    request_state_code
  ) 
  select
    request_state_code
  from  
    (
    select 
      pkg_MailInternal.Wait_RequestStateCode
        as request_state_code
    from
      dual
    union all  
    select 
      pkg_MailInternal.Processed_RequestStateCode
        as request_state_code
    from
      dual
    union all  
    select 
      pkg_MailInternal.Error_RequestStateCode
        as request_state_code
    from
      dual
    ) t   
  where
    not exists  
    (
    select
      1
    from
      ml_request_state s
    where
      s.request_state_code = t.request_state_code
    );
  dbms_output.put_line('Inserted: ' || to_char( sql%rowcount ));      
end;
/    
