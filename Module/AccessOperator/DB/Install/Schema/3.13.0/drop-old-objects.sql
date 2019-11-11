-- script: drop-old-objects.sql
-- Удаление устаревших объектов

declare
  cursor curObjToDrop
  is
    select
      *
    from
      user_objects uo
    where
      uo.object_name in (
        upper( 'pkg_OperatorInternal' )
        , upper( 'v_rfi_user' )
      )
      and uo.object_type in ( 'PACKAGE', 'VIEW' )
  ;
begin
  for rec in curObjToDrop loop
    dbms_output.put_line(
      'Drop ' || rec.object_type || ' ' || rec.object_name
    );
    execute immediate
      'drop ' || rec.object_type || ' ' || rec.object_name
    ;
  end loop;
exception
  when others then
    dbms_output.put_line(
      'Error code [' || sqlerrm || '].'
    );
end;
/


declare
  cursor curTrg
  is
    select
      *
    from
      user_triggers t
    where
      t.table_name like 'OP\_%' escape '\'
      and t.table_name not in (
        'OP_PASSWORD_HIST'
        , 'OP_LOCK_TYPE'
      )
      and t.trigger_name not in (
        upper( 'op_operator_bu_history')
        , upper( 'op_operator_bu_define')
      )
  ;
begin
  for rec in curTrg loop
    pkg_Common.outputMessage(
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


declare
  cursor curSqs
  is
    select
      *
    from
      user_sequences t
    where
      t.sequence_name like 'OP\_%' escape '\'
      and t.sequence_name != 'OP_PASSWORD_HIST_SEQ'
  ;
begin
  for rec in curSqs loop
    pkg_Common.outputMessage(
      'drop sequence "' || rec.sequence_name || '"'
    );
    execute immediate
      'drop sequence ' || rec.sequence_name
    ;
  end loop;
exception
  when others then
    dbms_output.put_line(
      'Error code [' || sqlerrm || '].'
    );
end;
/
