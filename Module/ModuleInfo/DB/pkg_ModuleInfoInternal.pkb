create or replace package body pkg_ModuleInfoInternal is
/* package body: pkg_ModuleInfoInternal::body */



/* group: ���������� */

/* ivar: isAccessOperatorFound
  ������� ����������� ������ AccessOperator.
*/
isAccessOperatorFound boolean := null;



/* group: ������� */

/* func: compareVersion
  ���������� ������ ������.

  ���������:
  version1                    - ������ ����� ������
  version2                    - ������ ����� ������

  �������:
  -  -1 ���� version1 < version2
  -   0 ���� version1 = version2
  -   1 ���� version1 > version2
  - null ���� version1 ��� version2 ����� �������� null

  ���������:
  - ������ ������, ������������ ���� �������� �����������, ��������� �������,
    ��������, "1.0" � "1.00" � "1.0.0" �����;
*/
function compareVersion(
  version1 varchar2
  , version2 varchar2
)
return integer
is

  -- ����� ����� � ��������
  len1 integer := length( version1);
  len2 integer := length( version2);
  maxLength integer := greatest( len1, len2);

  -- ��������� ���������
  res integer;

  beg1 integer := 1;
  end1 integer;
  beg2 integer := 1;
  end2 integer;



  /*
    ���������� ��� ������.
  */
  function compareString(
    str1 varchar2
    , str2 varchar2
  )
  return integer
  is
  begin
    return
      case
        when str1 < str2 then
         -1
        when str1 > str2 then
          1
        else
          0
      end
    ;
  end compareString;



-- compareVersion
begin
  if maxLength is not null then
    res := 0;
    loop
      end1 := instr( version1 || '.', '.', beg1);
      end2 := instr( version2 || '.', '.', beg2);
      res := compareString(
        lpad(
            coalesce( substr( version1, beg1, end1 - beg1), '0')
            , maxLength
            , '0'
          )
        , lpad(
            coalesce( substr( version2, beg2, end2 - beg2), '0')
            , maxLength
            , '0'
          )
      );
      exit when res != 0;
      beg1 := end1 + 1;
      beg2 := end2 + 1;
      if beg1 > len1 or beg2 > len2 then
        res :=
          case
            when beg2 <= len2
                and ltrim( substr( version2, beg2), '.0') is not null
              then -1
            when beg1 <= len1
                and ltrim( substr( version1, beg1), '.0') is not null
              then 1
            else
              0
          end
        ;
        exit;
      end if;
    end loop;
  end if;
  return res;
exception when others then
  raise_application_error(
    pkg_ModuleInfoInternal.ErrorStackInfo_Error
    , '������ ��� ��������� ������ ('
      || ' version1="' || version1 || '"'
      || ', version2="' || version2 || '"'
      || ').'
    , true
  );
end compareVersion;

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
        -- PLS-00201: identifier 'PKG_OPERATOR' must be declared
        sqlerrm like
          '%PLS-00201: % ''PKG_OPERATOR'' %'
        -- PLS-00201: identifier 'PKG_OPERATOR.%' must be declared
        or sqlerrm like
          '%PLS-00201: % ''PKG_OPERATOR.%'' %'
        -- PLS-00904: insufficient privilege to access object %.PKG_OPERATOR%
        or sqlerrm like
          '%PLS-00904: % %.PKG_OPERATOR%'
        -- ORA-06508: PL/SQL: could not find program unit being called:%
        or sqlerrm like
          '%ORA-06508: %:%'
        -- PLS-00302: component 'GETCURRENTUSERID' must be declared
        or sqlerrm like
          '%PLS-00302: % ''GETCURRENTUSERID'' %'
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
