-- script: Install/Schema/3.13.0/Local/Prviate/Main/drop-old-objects.sql
-- Удаление устарешвих объектов версии 3.13.0 модуля

declare
  cursor curTrgToDrop
  is
    select
      *
    from
      user_triggers t
    where
      upper( t.trigger_name ) in (
        upper( 'op_operator_aiu_addpublicgroup' )
        , upper( 'op_group_ai_add_to_adm_grt_grp' )
        , upper( 'op_role_ai_add_to_admin_group' )
        , upper( 'op_group_biu_define' )
      )
  ;
begin
  for rec in curTrgToDrop loop
    dbms_output.put_line(
      'drop trigger "' || rec.trigger_name || '"'
    );
    execute immediate
      'drop trigger "' || rec.trigger_name || '"'
    ;
  end loop;
exception
  when others then
    dbms_output.put_line(
      'Error code [' || sqlerrm || '].'
    );
end;
/
