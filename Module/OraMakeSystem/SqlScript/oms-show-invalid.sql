--script: oms-show-invalid.sql
--Показывает число инвалидных объектов и список инвалидных объекты в текущей
--схеме.
--
--Замечания:
--  - скрипт используется внутри OMS;
--



prompt * Count accessable invalid objects

select
  ob.owner
  , count(*) as invalid_count
from
  all_objects ob
where
  ob.status <> 'VALID'
group by
  ob.owner
order by
  1
/



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

