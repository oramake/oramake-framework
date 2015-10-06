declare
  dynamicSql dyn_dynamic_sql_t;
  
  function GetSqlWithPage(
    sqlText varchar2
    , orderByList varchar2
    , fields varchar2
  )
  return varchar2
  is
  begin
    return
      replace(
      replace(
      replace(
'select
  $(fields)
from
  (
  select
    t.*
    , rownum as record_number
  from
    (
    $(sqlText)
    ) t
  order by
    $(orderByList) 
  )
where
  record_number between ( :pageSize * ( :pageNumber - 1) + 1) and ( :pageSize * :pageNumber)
'  
     , '$(fields)'
     , fields
     )
     , '$(sqlText)'
     , sqlText
     )
     , '$(orderByList)'
     , orderByList
     );
  end GetSqlWithPage;
  
  
  
begin
  dynamicSql :=
     dyn_dynamic_sql_t(
       sqlText =>  '
select
  1 as a
from
  dual  
'
  );
  pkg_Common.OutputMessage(
    GetSqlWithPage( 
      sqlText => dynamicSql.GetSqlText
      , orderByList => 'a'
      , fields => 'a as a'
    )
  )  ;
end;  
