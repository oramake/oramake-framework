create or replace package body pkg_ModuleDependency is
/* package body: pkg_ModuleDependency::body */



/* group: ���� */

/* itype: TColLogger
  ��������� �������� ��.
*/
type md_object_map_t is table of varchar2(100) index by varchar2(128);



/* group: ���������� */

/* ivar: lg_logger_t
  ������������ ������ ��� ������ Logging
*/
  logger lg_logger_t := lg_logger_t.GetLogger(
    moduleName => pkg_ModuleDependency.Module_Name
    , objectName => 'pkg_ModuleDependency'
  );

/* ivar: ObjectMap
  ����� ������-�����.
*/
  objectMap md_object_map_t;



/* group: ������� */

/* pproc: createDependency
  ������� ����������� ������ �� ������.

  ���������:
  svnRoot                     - ���� � ��������� �������� ������ � Subversion
  referencedSvnRoot varchar2  - ���� � ��������� �������� ������, �� �������� �������
  buildSource varchar2        - ��������, �� �������� ��������� �����������.
                              - ���������� ��������: SYS, MAP.XML
*/
procedure createDependency(
  svnRoot varchar2
  , referencedSvnRoot varchar2
  , buildSource varchar2
)
is
begin
  merge into
    md_module_dependency t
  using
    (
    select
      svnRoot as svn_root
      , referencedSvnRoot as referenced_svn_root
    from
      dual
    ) d
  on
    (
    t.svn_root = d.svn_root
    and t.referenced_svn_root = d.referenced_svn_root
    )
  when not matched then insert
    (
    svn_root
    , referenced_svn_root
    , source
    , last_refresh_date
    )
    values
    (
    d.svn_root
    , d.referenced_svn_root
    , buildSource
    , sysdate
    )
  when matched then update
    set
      source = case
          when buildSource = MapXML_SourceTypeCode then buildSource
          else source
        end
      , last_refresh_date = sysdate
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ���������� ����������� ('
        || 'svnRoot="' || svnRoot || '"'
        || ', dependencySvnRoot="' || referencedSvnRoot || '"'
        || ').'
      )
    , true
  );
end createDependency;

/* pproc: findDependency
  ������� ���������� ������ ������������ ��� ������,
  �������������� ����������� � ����������� � ������� md_module_dependency

  ���������:
  svnRoot                     - ���� � ��������� �������� ������ � Subversion
  referencedSvnRoot varchar2  - ���� � ��������� �������� ������, �� �������� �������
  buildSource varchar2        - ��������, �� �������� ��������� �����������.
                              - ���������� ��������: SYS, MAP.XML

  ������� ( ������ ):
  svnRoot                     - ���� � ��������� �������� ������ � Subversion
  referencedSvnRoot varchar2  - ���� � ��������� �������� ������, �� �������� �������
  buildSource varchar2        - ��������, �� �������� ��������� �����������.
                              - ���������� ��������: SYS, MAP.XML
  last_refresh_date           - ���� ���������� ���������� ������
  date_ins                    - ���� ���������� ������

*/
function findDependency(
  svnRoot varchar2
  , referencedSvnRoot varchar2
  , buildSource varchar2
)
return sys_refcursor
is
  -- ������������ ������
  rc sys_refcursor;
  dsql dyn_dynamic_sql_t := dyn_dynamic_sql_t( '
select
  svn_root
  referenced_svn_root
from
  md_module_dependency
where
  $(condition)
'
  );
-- findDependency
begin
  dsql.addCondition(
    'svn_root=":svnRoot"', svnRoot is null
  );
  dsql.addCondition(
    'referenced_svn_root=":referencedSvnRoot"', referencedSvnRoot is null
  );
  dsql.addCondition(
    'source=":buildSource"', buildSource is null
  );
  dsql.useCondition('condition');
  open rc for
    dsql.getSqlText()
  using
    svnRoot
    , referencedSvnRoot
    , buildSource
  ;
  return rc;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ������ ������������ ����� �������� ('
        || 'svnRoot = "' || svnRoot || '"'
        || ', referencedSvnRoot = "' || referencedSvnRoot || '"'
        || ', buildSource = "' || buildSource || '"'
        || ').'
      )
    , true
  );
end findDependency;

/* pproc: deleteDependency
  ������� ������� ����������� ������, ����������� � ������� md_module_dependency

  ���������:
  svnRoot                     - ���� � ��������� �������� ������ � Subversion
  referencedSvnRoot varchar2  - ���� � ��������� �������� ������, �� �������� �������
*/
procedure deleteDependency(
  svnRoot varchar2
  , referencedSvnRoot varchar2
)
is
-- deleteDependency
begin
  delete from
    md_module_dependency
  where
    svn_root = svnRoot
    and referenced_svn_root = referencedSvnRoot
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ �������� ����������� ������('
        || 'svnRoot="' || svnRoot || '"'
        || ', referencedSvnRoot="' || referencedSvnRoot || '"'
        || ')'
      )
  );
end deleteDependency;


/* pproc: refreshDependencyFromMapXML
  ��������� ������ ������������ ������ �� ������ �������
  �� ���������� map.xml.

  ���������:
  svnRoot                     - ���� � ��������� �������� ������ � Subversion
*/
procedure refreshDependencyFromMapXML(
  svnRoot varchar2
)
is
  -- ���������� map.xml
  mapBody clob;
  mapXml XMLType;

  procedure readMapBody
  is
  begin
    select
      file_data
    into
      mapBody
    from
      ss_file
    where
      file_name = 'map.xml'
      and upper(repository_name || '/' || svn_path) like upper(svnRoot || '/' || '%')
    ;
    -- ��������� ������ ����� ��� ������ ������ � ������ map.xml
    mapBody := replace(replace(mapBody, '\<', '<'), '\>', '>');
    mapBody := replace(replace(mapBody, '\<', '<'), '\>', '>');
    mapBody := replace(replace(mapBody, '\<', '<'), '\>', '>');
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ������ map.xml ������ "' || svnRoot || '".'
        )
      , true
    );
  end readMapBody;

  procedure parseMapBody
  is
  begin
    mapXml := XMLType(mapBody);
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ �������� map.xml ������ "' || svnRoot || '".'
        )
      , true
    );
  end parseMapBody;

  procedure buildDependency
  is
    i integer;
    rXml XMLType;
    referencedSvnRootNode XMLType;
  -- buildDependency
  begin
    i := 1;
    loop
      rXml := mapXml.extract('/map/depend/module[' || i ||']');
      exit when rXml is null;
      referencedSvnRootNode := rXml.extract('//text()');
      if referencedSvnRootNode is not null then
        createDependency(
          svnRoot => svnRoot
          , referencedSvnRoot => referencedSvnRootNode.getStringVal()
          , buildSource => MapXML_SourceTypeCode
        );
      end if;
      i := i + 1;
    end loop;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ���������� ������������ ������ "' || svnRoot || '".'
        )
      , true
    );
  end buildDependency;

-- refreshDependencyFromMapXML
begin
  -- ������ map.xml
  readMapBody();

  -- ������� map.xml
  parseMapBody();

  -- ���������� ������������ �� map.xml
  buildDependency();

exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ���������� ������ ������������ ������ �� map.xml ('
        || 'svnRoot="' || svnRoot || '"'
        || ')'
      )
  );
end refreshDependencyFromMapXML;

/* pproc: refreshDependencyFromMapSYS
  ��������� ������ ������������ ������ �� ������ �������
  �� ���������� ���������� ������������� all_dependencies.

  ���������:
  svnRoot                     - ���� � ��������� �������� ������ � Subversion
*/
procedure refreshDependencyFromSYS(
  svnRoot varchar2
)
is

  procedure readObjectMap
  is
    objectCount number := 0;
  begin
    -- ����� �������� ��������� ���� ��� �� ������
    if objectMap.count() = 0 then
      for curObject in (
        -- ��� ������� �� �������
        -- ��� ������
        select distinct repository_name || '/' || substr(svn_path, 1, instr(svn_path, 'Trunk', 1) - 2) module_name
        , substr(svn_path, instr(svn_path, '/', -1) + 1, length(svn_path) - instr(svn_path, '/', -1) - 4) object_name from ss_file
        where
        file_name like '%pks'
        union
        -- ��� �������
        select distinct repository_name || '/' || substr(svn_path, 1, instr(svn_path, 'Trunk', 1) - 2) module_name
        , substr(svn_path, instr(svn_path, '/', -1) + 1, length(svn_path) - instr(svn_path, '/', -1) - 4) object_name from ss_file
        where
        file_name like '%tab'
        union
        -- ��� ����
        select distinct repository_name || '/' || substr(svn_path, 1, instr(svn_path, 'Trunk', 1) - 2) module_name
        , substr(svn_path, instr(svn_path, '/', -1) + 1, length(svn_path) - instr(svn_path, '/', -1) - 4) object_name from ss_file
        where
        file_name like '%typ'
        union
        -- ��� �������������
        select distinct repository_name || '/' || substr(svn_path, 1, instr(svn_path, 'Trunk', 1) - 2) module_name
        , substr(svn_path, instr(svn_path, '/', -1) + 1, length(svn_path) - instr(svn_path, '/', -1) - 3) object_name from ss_file
        where
        file_name like '%vw'
      )
      loop
        objectMap(upper(curObject.Object_Name)) := curObject.Module_Name;
        objectCount := objectCount + 1;
      end loop;
      logger.trace('���������� ����� ������-������. ����� ��������: ' || objectCount);

    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ���������� ����� ������-������.'
        )
      , true
    );
  end readObjectMap;

  procedure buildDependency
  is
    dependencyCount number := 0;
    dependency md_object_dependency%rowtype;
    cursor curDependency is
      -- ����������� ������
      select d.*
      from md_object_dependency d ,
      (
      -- ������ ������
      select
        substr(svn_path, instr(svn_path, '/', -1) + 1, length(svn_path) - instr(svn_path, '/', -1) - 4) object_name
      from
        ss_file
      where
        repository_name || '/' || svn_path like svnRoot || '/%'
        and file_name like '%pks'
      union
      -- ���� ������
      select
        substr(svn_path, instr(svn_path, '/', -1) + 1, length(svn_path) - instr(svn_path, '/', -1) - 4) object_name
      from
        ss_file
      where
        repository_name || '/' || svn_path like svnRoot || '/%'
        and file_name like '%typ'
      -- ������������� ������
      union
      select
        substr(svn_path, instr(svn_path, '/', -1) + 1, length(svn_path) - instr(svn_path, '/', -1) - 3) object_name
      from
        ss_file
      where
        repository_name || '/' || svn_path like svnRoot || '/%'
        and file_name like '%vw'
      ) p
      where upper(d.name) = upper(p.object_name)
      ;
  -- buildDependency
  begin
    open curDependency;
    loop
      fetch curDependency into dependency;
      exit when curDependency%notfound;
      dependencyCount := dependencyCount + 1;
      if objectMap.exists(upper(dependency.Referenced_Name)) then
        logger.trace('��� ������ "' || svnRoot
          || '" ������� �����������: ' || dependency.Name
          || ' => ' || dependency.Referenced_Name
        );
        createDependency(
          svnRoot => svnRoot
          , referencedSvnRoot => objectMap(upper(dependency.Referenced_Name))
          , buildSource => Sys_SourceTypeCode
        );
      else
        logger.trace('��� ������ "' || svnRoot
          || '" � ����� ������-������ �� ������� �����������: ' || dependency.Name
          || ' => ' || dependency.Referenced_Name
        );
      end if;
    end loop;
    logger.trace('��� ������ "' || svnRoot || '" ������� ������������: ' || to_char(dependencyCount));
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ���������� ������������ ������ "' || svnRoot || '".'
        )
      , true
    );
  end buildDependency;

-- refreshDependencyFromSYS
begin
  -- ������ ������ ������-������
  readObjectMap();

  -- ���������� ������������ �� all_dependencies
  buildDependency();

exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ���������� ������ ������������ ������ �� all_dependencies ('
        || 'svnRoot="' || svnRoot || '"'
        || ')'
      )
  );
end refreshDependencyFromSYS;

/* pproc: refreshAllDependencyFromSVN
  ��������� ������ ������������ ���� ������� �� SVN
  �� ���������� map.xml.
*/
procedure refreshAllDependencyFromSVN
is
-- refreshAllDependencyFromSVN
begin
  for curModule in (
    select
      substr(repository_name || '/' || svn_path, 1, length(repository_name || '/' || svn_path) - 18 ) as svn_root
    from
      ss_file s
    where
      upper(file_name) = upper('map.xml')
    order by
      repository_name
      , svn_path
    )
  loop
    begin
      refreshDependencyFromMapXML(curModule.svn_root);
    exception when others then
      logger.trace(logger.getErrorStack());
    end;
  end loop;
end refreshAllDependencyFromSVN;

/* pproc: refreshAllDependencyFromSYS
  ��������� ������ ������������ ���� ������� �� SVN
  �� ���������� ���������� ������������� all_dependencies.
*/
procedure refreshAllDependencyFromSYS
is
-- refreshAllDependencyFromSYS
begin
  for curModule in (
    select
      substr(repository_name || '/' || svn_path, 1, length(repository_name || '/' || svn_path) - 18 ) as svn_root
    from
      ss_file s
    where
      upper(file_name) = upper('map.xml')
    order by
      repository_name
      , svn_path
    )
  loop
    begin
      logger.trace('���������� ������������ ������: ' || curModule.svn_root);
      refreshDependencyFromSYS(curModule.svn_root);
    exception when others then
      logger.trace(logger.getErrorStack());
    end;
  end loop;
end refreshAllDependencyFromSYS;

end pkg_ModuleDependency;
/
