create or replace package body pkg_ModuleDependencySource is
/* package body: pkg_ModuleDependency::body */



/* group: Переменные */

/* ivar: lg_logger_t
  Интерфейсный объект для модуля Logging
*/
  logger lg_logger_t := lg_logger_t.GetLogger(
    moduleName =>Module_Name
    , objectName => 'pkg_ModuleDependencySource'
  );

/* group: Функции */

/* pproc: unloadObjectDependency
  Выгружает зависимости из all_dependencies.

  Параметры:
  targetDbLink                - dbLink до БД назначения для выгрузки
                                зависимостей all_dependencies.
*/
procedure unloadObjectDependency(
  targetDbLink varchar2 default null
)
is
-- unloadObjectDependency
begin
  -- Отбор списка зависимостей во временную таблицу
  insert into
    md_object_dependency_tmp
    (
    db
    , owner
    , name
    , type
    , referenced_owner
    , referenced_name
    , referenced_type
    , referenced_link_name
    , dependency_type
    )
  select
    'SYS' as db
    , d.owner
    , d.name
    , d.type
    , d.referenced_owner
    , d.referenced_name
    , d.referenced_type
    , d.referenced_link_name
    , d.dependency_type
  from
    all_dependencies d
  where
    owner not in ('SYS', 'SYSTEM', 'PUBLIC', 'MDSYS'
      , 'CTXSYS', 'OUTLN', 'DBSNMP', 'ORDSYS', 'WMSYS', 'XDB'
      , 'ORACLE_OCM', 'OLAPSYS')
    and referenced_owner not in ('SYS', 'SYSTEM', 'PUBLIC', 'MDSYS'
      , 'CTXSYS', 'OUTLN', 'DBSNMP', 'ORDSYS', 'WMSYS', 'XDB'
      , 'ORACLE_OCM', 'OLAPSYS')
    and type != 'JAVA CLASS'
  ;

  -- Выгрузка списка зависисмостей в целевю БД
  execute immediate '
merge into
  md_object_dependency' || case
    when targetDbLink is not null then '@' || targetDbLink
    end || ' t
using
  (
  select
    d.db
    , d.owner
    , d.name
    , d.type
    , d.referenced_owner
    , d.referenced_name
    , d.referenced_type
    , d.referenced_link_name
    , d.dependency_type
  from
    md_object_dependency_tmp d
  ) d
  on
  (
    t.db = d.db
    and t.owner = d.owner
    and t.name = d.name
    and t.type = d.type
    and t.referenced_owner = d.referenced_owner
    and t.referenced_name = d.referenced_name
    and t.referenced_type = d.referenced_type
  )
  when not matched then insert
  (
    db
    , owner
    , name
    , type
    , referenced_owner
    , referenced_name
    , referenced_type
    , referenced_link_name
    , dependency_type
  )
  values
  (
    d.db
    , d.owner
    , d.name
    , d.type
    , d.referenced_owner
    , d.referenced_name
    , d.referenced_type
    , d.referenced_link_name
    , d.dependency_type
  )
  when matched then update
    set
      referenced_link_name = d.referenced_link_name
      , dependency_type = d.dependency_type
      , last_refresh_date = sysdate
  ';
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка выгрузки зависимостей объектов из all_dependencies.'
      )
    , true
  );
end unloadObjectDependency;


end pkg_ModuleDependencySource;
/
