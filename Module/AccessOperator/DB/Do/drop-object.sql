define objectType=&1
define objectName=&2


declare
  cursor curObject
  is
    select
      *
    from
      user_objects t
    where
      t.object_type = upper( '&objectType')
      and t.object_name = upper( '&objectName')
  ;
  
-- main
begin
  for rec in curObject loop
    pkg_Common.outputMessage(
      'drop ' || rec.object_type || ' ' || rec.object_name
    );
    execute immediate
      'drop ' || rec.object_type || ' ' || rec.object_name
    ;
  end loop;
end;
/


undefine objectType
undefine objectName