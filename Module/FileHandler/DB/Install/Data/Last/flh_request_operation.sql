-- script: flh_request_operation
-- Добавление информации в справочник <flh_request_operation>
begin
  insert into flh_request_operation(
    operation_code
  ) 
  select
    operation_code
  from  
    (
    select 
      pkg_FileHandlerBase.FileList_OperationCode
        as operation_code
    from
      dual
    union all  
    select 
      pkg_FileHandlerBase.DirList_OperationCode
        as operation_code
    from
      dual
    union all  
    select 
      pkg_FileHandlerBase.Copy_OperationCode
        as operation_code
    from
      dual
    union all  
    select 
      pkg_FileHandlerBase.Delete_OperationCode
        as operation_code
    from
      dual
    union all  
    select 
      pkg_FileHandlerBase.LoadText_OperationCode
        as operation_code
    from
      dual
    union all  
    select 
      pkg_FileHandlerBase.LoadBinary_OperationCode
        as operation_code
    from
      dual
    union all  
    select 
      pkg_FileHandlerBase.UnloadText_OperationCode
        as operation_code
    from
      dual
    union all  
    select 
      pkg_FileHandlerBase.Command_OperationCode
        as operation_code
    from
      dual
    ) t   
  where
    not exists  
    (
    select
      1
    from
      flh_request_operation op
    where
      op.operation_code = t.operation_code
    );
  dbms_output.put_line('Inserted: ' || to_char( SQL%RowCount ));      
end;
/    
