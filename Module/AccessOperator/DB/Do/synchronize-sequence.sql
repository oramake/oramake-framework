define tableName = "&1"
define sequenceName = "&2"
define pkColumnName = "&3"


declare
  tableName varchar2(30) := '&tableName';
  sequenceName varchar2(30) := coalesce( '&sequenceName', tableName || '_seq' );
  pkColumnName varchar2(30) := coalesce(
    '&pkColumnName'
    , substr( tableName, instr( tableName, '_') + 1) || '_id'
  );
  startValue integer;
begin
  execute immediate
  '
  select
    coalesce( max( ' || pkColumnName || '), 0) + 1
  from
    ' || tableName
  into
    startValue
  ;
  execute immediate
    'drop sequence ' || sequenceName
  ;
  execute immediate
    'create sequence ' || sequenceName || ' start with ' || to_char( startValue)
  ;
  dbms_output.put_line( '* sequence ' || sequenceName || ' recreated: new value: ' || to_char( startValue));
end;
/


undefine pkColumnName
undefine sequenceName
undefine tableName