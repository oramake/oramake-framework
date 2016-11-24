define tableName = "&1"



declare

  tableName varchar2(30) := '&tableName';

  existsFlag integer;

begin
  select
    count(*)
  into existsFlag
  from
    user_mview_logs t
  where
    t.master = upper( tableName)
  ;
  if existsFlag = 0 then
    execute immediate '
create materialized view log on
  ' || tableName || '
with
  primary key
'
    ;
    dbms_output.put_line(
      tableName || ': materialized log created'
    );
  else
    dbms_output.put_line(
      tableName || ': materialized log already exists'
    );
  end if;
end;
/



undefine tableName
