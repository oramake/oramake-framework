-- script: Install/Schema/3.9.0/Local/Private/Main/drop_unused_objects.sql
-- Удаление неиспользуемых объектов

declare
  cursor curData
  is
  select
    *
  from
    user_objects uo
  where
    uo.object_name in (
      upper( 'op_operator_biu_define' )
      , 'OP_OPERATOR_ROLE_AIUD_ADD_EVEN'
      , 'OP_OPERATOR_GROUP_AIUD_ADD_EVE'
      , 'OP_GROUP_ROLE_AIUD_ADD_EVENT'
      , upper( 'op_operator_bu_define' )
      , upper( 'op_role_biu_define' )
      , upper( 'op_group_biu_define' )
    )
  ;
begin
  for rec in curData loop
    execute immediate
      'drop ' || rec.object_type || ' ' || rec.object_name
    ;
    dbms_output.put_line(
      rec.object_type || ' "' || rec.object_name || '" dropped...ok'
    );
  end loop;
exception
  when others then
    dbms_output.put_line(
      'Error code [' || sqlerrm || '].'
    );
end;
/
