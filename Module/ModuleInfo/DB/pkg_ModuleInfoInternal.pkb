create or replace package body pkg_ModuleInfoInternal is
/* package body: pkg_ModuleInfoInternal::body */



/* group: ���������� */

/* ivar: isAccessOperatorFound
  ������� ����������� ������ AccessOperator.
*/
isAccessOperatorFound boolean := null;



/* group: ������� */

/* func: getCurrentOperatorId
  ���������� Id �������� ������������������� ��������� ��� ����������� ������
  AccessOperator.

  �������:
  Id �������� ��������� ���� null � ������ ������������� ������ AccessOperator.

  ���������:
  - � ������ ����������� ������ AccessOperator � ���������� ��������
    ������������������� ��������� ������������� ����������;
*/
function getCurrentOperatorId
return integer
is

  -- Id �������� ���������
  operatorId integer := null;

--getCurrentOperatorId
begin
  if coalesce( isAccessOperatorFound, true) then
    execute immediate
      'begin :operatorId := pkg_Operator.getCurrentUserId; end;'
    using
      out operatorId
    ;
  end if;
  return operatorId;
exception when others then
  if isAccessOperatorFound is null
      and (
        SQLERRM like
          '%PLS-00201: identifier ''PKG_OPERATOR'' must be declared%'
        or SQLERRM like
          '%PLS-00201: identifier ''PKG_OPERATOR.%'' must be declared%'
        or SQLERRM like
          '%PLS-00904: insufficient privilege to access object %.PKG_OPERATOR%'
        or SQLERRM like
          '%ORA-06508: PL/SQL: could not find program unit being called:%'
      )
      then
    isAccessOperatorFound := false;
    return null;
  else
    raise_application_error(
      ErrorStackInfo_Error
      , '������ ��� ����������� Id �������� ������������������� ���������.'
      , true
    );
  end if;
end getCurrentOperatorId;

/* func: getModuleId
  ���������� Id ������.

  ���������:
  svnRoot                     - ���� � ��������� �������� ������ � Subversion
                                ( ������� � ����� �����������, ��������
                                "Oracle/Module/ModuleInfo")
  initialSvnPath              - �������������� ���� � ��������� ��������
                                ������ � Subversion ( ������� � �����
                                ����������� � ������ ����� ������, � �������
                                �� ��� ������, ��������
                                "Oracle/Module/ModuleInfo@711")
  isCreate                    - ������� ������ � ������ ���������� ����������
                                ( 1 ��, 0 ��� ( �� ���������))
  operatorId                  - Id ���������, ������������ ��������
                                ( �� ��������� �������)

  �������:
  Id ������ ( �������� module_id �� ������� <mod_module>) ���� null ����
  ������ �� ������� � �� ������ isCreate = 1.

  ���������:
  - ��� ������ ������ ������ ���� ������� �������� �� null �������� svnRoot
    ���� initialSvnPath, ��� ���� � ������ �������� initialSvnPath ��������
    svnRoot ������������, ������� �������� ��������� ���������� ��� ������
    �������������;
*/
function getModuleId(
  svnRoot varchar2
  , initialSvnPath varchar2
  , isCreate integer := null
  , operatorId integer := null
)
return integer
is

  -- Id ������
  moduleId mod_module.module_id%type;

  -- �������������� �������� �������
  initialSvnRoot mod_module.initial_svn_root%type;

  -- ������, � ������� ��� ������ �������������� �������
  initialSvnRevision mod_module.initial_svn_revision%type;

  -- ���� � ��������� �������� ������, ��������� � �������
  moduleSvnRoot mod_module.svn_root%type;



  /*
    ��������� ������ �������� ��������� initialSvnPath.
  */
  procedure parseInitialSvnPath
  is

    -- ������� ����������� � ����
    iSplit pls_integer;

  begin
    if initialSvnPath is not null then
      iSplit := instr( initialSvnPath, '@');
      if iSplit > 1 then
        initialSvnRoot := substr( initialSvnPath, 1, iSplit - 1);
        initialSvnRevision := to_number( substr( initialSvnPath, iSplit + 1));
      end if;
      if initialSvnRoot is null or initialSvnRevision is null then
        raise_application_error(
          pkg_ModuleInfoInternal.IllegalArgument_Error
          , '������������ �������������� ���� � ��������� �������� ������,'
            || ' ����� ������� �������� � �������'
            || ' "<repositoryName>/<path>@<revision>".'
        );
      end if;
    end if;
  exception when others then
    raise_application_error(
      pkg_ModuleInfoInternal.ErrorStackInfo_Error
      , '������ ��� ������� �������� ��������� initialSvnPath.'
      , true
    );
  end parseInitialSvnPath;



  /*
    ��������� ����� ������.
  */
  procedure findModule
  is
  begin
    if coalesce( svnRoot, initialSvnPath) is null then
      raise_application_error(
        pkg_ModuleInfoInternal.IllegalArgument_Error
        , '�� ������� ��������� ������.'
      );
    end if;

    select
      max( md.module_id)
      , max( md.svn_root)
    into moduleId, moduleSvnRoot
    from
      mod_module md
    where
      initialSvnPath is not null
        and upper( md.initial_svn_root) = upper( initialSvnRoot)
        and md.initial_svn_revision = initialSvnRevision
      or initialSvnPath is null
        and upper( md.svn_root) = upper( svnRoot)
    ;

    -- ����� �� initial_svn_root �� ������ �������������� ������
    -- ( ���� ��� ���������������)
    if moduleId is null and initialSvnPath is null then
      select
        max( md.module_id)
        , max( md.svn_root)
      into moduleId, moduleSvnRoot
      from
        mod_module md
      where
        upper( md.initial_svn_root) = upper( svnRoot)
      having
        count(*) = 1
      ;
    end if;
  exception when others then
    raise_application_error(
      pkg_ModuleInfoInternal.ErrorStackInfo_Error
      , '������ ��� ������ ������.'
      , true
    );
  end findModule;



  /*
    ������� ������ ��� ������ � ������� mod_module.
  */
  procedure createModule
  is
  begin
    insert into
      mod_module
    (
      svn_root
      , initial_svn_root
      , initial_svn_revision
      , operator_id
    )
    values
    (
      coalesce( svnRoot, initialSvnRoot)
      , initialSvnRoot
      , initialSvnRevision
      , operatorId
    )
    returning module_id into moduleId;
  exception when others then
    raise_application_error(
      pkg_ModuleInfoInternal.ErrorStackInfo_Error
      , '������ ��� �������� ������ ��� ������ ('
        || ' initialSvnRoot="' || initialSvnRoot || '"'
        || ', initialSvnRevision=' || to_char( initialSvnRevision)
        || ').'
      , true
    );
  end createModule;



  /*
    ��������� �������� ������� ������ � ������� mod_module.
  */
  procedure updateSvnRoot
  is
  begin
    update
      mod_module md
    set
      md.svn_root = svnRoot
    where
      md.module_id = moduleId
    ;
    if SQL%ROWCOUNT = 0 then
      raise_application_error(
        pkg_ModuleInfoInternal.ProcessError_Error
        , '������ �� �������.'
      );
    end if;
  exception when others then
    raise_application_error(
      pkg_ModuleInfoInternal.ErrorStackInfo_Error
      , '������ ��� ���������� ��������� �������� � ������ ��� ������ ('
        || ' module_id=' || to_char( moduleId)
        || ').'
      , true
    );
  end updateSvnRoot;



--getModuleId
begin
  parseInitialSvnPath();
  findModule();
  if isCreate = 1 then
    if moduleId is null then
      createModule();
    elsif initialSvnPath is not null
        and nullif( svnRoot, moduleSvnRoot) is not null
        then
      updateSvnRoot();
    end if;
  end if;
  return moduleId;
exception when others then
  raise_application_error(
    pkg_ModuleInfoInternal.ErrorStackInfo_Error
    , '������ ��� ����������� Id ����������� ������ ('
      || ' svnRoot="' || svnRoot || '"'
      || ', initialSvnPath="' || initialSvnPath || '"'
      || case when isCreate is not null then
          ', isCreate=' || isCreate
        end
      || ').'
    , true
  );
end getModuleId;

end pkg_ModuleInfoInternal;
/
