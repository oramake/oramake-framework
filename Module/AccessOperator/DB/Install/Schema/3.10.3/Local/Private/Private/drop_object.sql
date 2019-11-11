-- script: Install/Schema/3.10.0/Local/Private/Main/drop_object.sql
-- Удаление неиспользуемых объектов

declare
  cursor curTrg
  is
  select
    *
  from
    user_triggers ut
  where
    ut.trigger_name = upper( 'op_role_ai_grant_to_admin' )
  ;
begin
  for rec in curTrg loop
    execute immediate
      'drop trigger ' || rec.trigger_name
    ;
    dbms_output.put_line(
      'Trigger "' || rec.trigger_name || '" dropped...ok'
    );
  end loop;
exception
  when others then
    dbms_output.put_line(
      'Error code [' || sqlerrm || '].'
    );
end;
/
