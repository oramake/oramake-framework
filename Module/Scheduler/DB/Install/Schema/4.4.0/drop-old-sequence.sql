begin
  for rec in (
        select
          ob.object_name
          , ob.object_type
        from
          user_objects ob
        where
          ob.object_type = 'SEQUENCE'
          and ob.object_name in (
              upper( 'sch_interval_type_seq')
              , upper( 'sch_message_type_seq')
            )
      )
      loop
    dbms_output.put_line(
      'drop: ' || lower( rec.object_type) || ': ' || rec.object_name
    );
    execute immediate
      'drop ' || rec.object_type || ' ' || rec.object_name
    ;
  end loop;
end;
/
