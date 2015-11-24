-- script: flh_request_state
-- Добавление информации в справочник <flh_request_state>
begin
  insert into flh_request_state(
    request_state_code
  ) 
  select
    request_state_code
  from  
    (
    select 
      pkg_FileHandlerBase.Wait_RequestStateCode
        as request_state_code
    from
      dual
    union all  
    select 
      pkg_FileHandlerBase.Processed_RequestStateCode
        as request_state_code
    from
      dual
    union all  
    select 
      pkg_FileHandlerBase.Error_RequestStateCode
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
      flh_request_state s
    where
      s.request_state_code = t.request_state_code
    );
  dbms_output.put_line('Inserted: ' || to_char( SQL%RowCount ));      
end;
/    
