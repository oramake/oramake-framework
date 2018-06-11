begin
  for allClasses in (
select
  *
from
  all_java_classes
where
  name like 'org/tigris/subversion%'
  and name not like '%$%'
)
  loop
    execute immediate
'drop java source "' || allclasses.name  || '"';
  end loop;
end;
/


