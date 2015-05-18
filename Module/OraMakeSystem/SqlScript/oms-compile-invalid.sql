--script: oms-compile-invalid.sql
--����������� ���������� ������� � ������� �����.
--
--���������:
--  - ������ ������������ ������ OMS;
--



prompt * Show invalid objects in user schema

column object_name format A100

select
  ob.object_type
  , case when
      object_type like 'JAVA %'
    then
      dbms_java.longname( ob.object_name)
    else
      ob.object_name
    end as object_name
from
  user_objects ob
where
  ob.status <> 'VALID'
order by
  1
/



prompt * Compile user invalid objects...

declare

  cursor curInvalid is
    select
      ob.object_name
      , a.*
    from
      (
      select
        'VIEW' as object_type
        , '�������������'as object_type_name_rus
        , 10 as priority_order
        , 'alter view $(object_name) compile' as compile_sql
      from dual
      union all select
        'TYPE BODY'
        , '���� ����'
        , 20
        , 'alter type $(object_name) compile body'
      from dual
      ) a
      inner join user_objects ob
        on ob.object_type = a.object_type
    where
      ob.status <> 'VALID'
    order by
      a.priority_order
      , ob.object_name
  ;

begin
  dbms_utility.compile_schema(
    schema => user
    , compile_all => false
  );
                                        --���������� �������������
  for rec in curInvalid loop
    begin
      execute immediate
          replace( rec.compile_sql, '$(object_name)', rec.object_name)
      ;
    exception when others then
      dbms_output.put_line(
        '������ ��� ����������: '
        || rec.object_type_name_rus || ' ' || rec.object_name
        || ':'
      );
      dbms_output.put_line( substr( SQLERRM, 1, 250));
    end;
  end loop;
end;
/



@@oms-show-invalid.sql
