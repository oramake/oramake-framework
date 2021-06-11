--script: Install/Config/Local/compile_all_invalid.sql
--Компилирует инвалидные объекты во всех схемах
--

prompt * Compile all invalid objects...

declare
  
  cursor curInvalid is
    select
      ob.object_name
      , a.*
    from
      (
      select
        'VIEW' as object_type
        , 'представление'as object_type_name_rus
        , 10 as priority_order
        , 'alter view $(object_name) compile' as compile_sql
      from dual
      union all select
        'TYPE BODY'
        , 'тело типа'
        , 20
        , 'alter type $(object_name) compile body'
      from dual
      ) a
      inner join all_objects ob
        on ob.object_type = a.object_type
    where
      ob.status <> 'VALID'
    order by
      a.priority_order
      , ob.object_name
  ;
  
  cursor 
    curInvalidSchema
  is
  select distinct
    ao.owner
  from
    all_objects ao
  where
    ao.status <> 'VALID'
    and ao.owner <> 'SYS'
  order by
    1
  ;
    
begin
  for recSchema in curInvalidSchema loop
    dbms_utility.compile_schema(
      schema => recSchema.owner                            
      , compile_all => false 
    );
  end loop;
                                        --Компиляция представлений
  for rec in curInvalid loop
    begin
      execute immediate
          replace( rec.compile_sql, '$(object_name)', rec.object_name)
      ;
    exception when others then
      dbms_output.put_line(
        'Ошибка при компиляции: '
        || rec.object_type_name_rus || ' ' || rec.object_name
        || ':'
      );
      dbms_output.put_line( substr( SQLERRM, 1, 250));
    end;
  end loop;
end;
/

prompt * Show invalid objects in all schema

select
  ob.owner
  , ob.object_name
  , ob.object_type
from
  all_objects ob
where
  ob.status <> 'VALID'
order by
  1
/