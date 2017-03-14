create or replace package body pkg_ModuleInfo is
/* package body: pkg_ModuleInfo::body */



/* group: ������� */



/* group: ������ � �� */

/* func: getModuleId
  ��������� id ������.


  ���������:
  findModuleString            - ������ ��� ������ ������ (
                                ����� ��������� � ����� �� ��� ���������
                                ������: ���������, ���� � ��������� ��������,
                                �������������� ���� � ��������� �������� �
                                Subversion)
  moduleName                  - �������� ������ ( �������� "ModuleInfo")
  svnRoot                     - ���� � ��������� �������� ������ � Subversion
                                ( ������� � ����� �����������, ��������
                                "Oracle/Module/ModuleInfo")
  initialSvnPath              - �������������� ���� � ��������� ��������
                                ������ � Subversion ( ������� � �����
                                ����������� � ������ ����� ������, � �������
                                �� ��� ������, ��������
                                "Oracle/Module/ModuleInfo@711")
  raiseExceptionFlag          - ����������� �� ���������� ���� ������ �� ������
                                ( ��-��������� 1-�����������);

  �������:
  Id ������ ( �������� module_id �� ������� <mod_module>) ���� null ����
  ������ �� ������� � raiseExceptionFlag = 0.
*/
function getModuleId(
  findModuleString varchar2 := null
  , moduleName varchar2 := null
  , svnRoot varchar2 := null
  , initialSvnPath varchar2 := null
  , raiseExceptionFlag number := null
)
return varchar2
is

  -- ��������� id ������
  moduleId integer;

  -- ���������� ��������� �������
  foundModuleCount integer;

-- getModuleId
begin
  -- ���� ���� ����� �� ��������������� ���� � SVN
  if initialSvnPath is not null
    or
    findModuleString is not null
    and findModuleString like '%@%'
  then
    if findModuleString is not null and findModuleString like '%@%'
       and initialSvnPath is not null
       and upper( initialSvnPath) <> upper( findModuleString)
    then
      raise_application_error(
        pkg_ModuleInfoInternal.ProcessError_Error
        , '�������������� ���� �� ������������� ������ ��� ������ ������'
      );
    end if;
    moduleId := pkg_ModuleInfoInternal.getModuleId(
      svnRoot => null
      , initialSvnPath => coalesce( initialSvnPath, findModuleString)
    );
  end if;
  -- ���� ����� ���� �� ���� �������� - �� �������������� ���� ������ � SVN
  if
    ( moduleName is not null
      or svnRoot is not null
      or ( findModuleString is not null and findModuleString not like '%@%')
    )
  then
    select
      max( module_id)
      , count(1) as found_module_count
    into
      moduleId
      , foundModuleCount
    from
      v_mod_module
    where
      -- ��������� ����������� ��� ���������� ������
      (
        moduleId is not null
        and module_id = moduleId
        or
        moduleId is null
      )
      -- ��������� ��� ������
      and (
        moduleName is not null
        and upper( module_name) = upper( moduleName)
        or
        moduleName is null
      )
      -- ��������� �������� ������� � SVN
      and (
        svnRoot is not null
        and upper( svn_root) = upper( svnRoot)
        or
        svnRoot is null
      )
      -- ��������� ������ ������
      and (
        findModuleString is not null
        and (
          findModuleString like '%@%'
          and moduleId = module_id
          or
          findModuleString like '%/%'
          and upper( svn_root) = upper( findModuleString)
          or
          upper( module_name) = upper( findModuleString)
        )
        or findModuleString is null
      )
    ;
    if ( foundModuleCount > 1) then
      raise_application_error(
        pkg_ModuleInfoInternal.ProcessError_Error
        , '������� ����� ������ ������ � ���������� ����������� ������'
      );
    end if;
  end if;
  if coalesce( raiseExceptionFlag, 1) = 1 and moduleId is null then
    raise_application_error(
      pkg_ModuleInfoInternal.ProcessError_Error
      , '������ �� ������'
    );
  end if;
  return
    moduleId
  ;
exception when others then
  raise_application_error(
    pkg_ModuleInfoInternal.ErrorStackInfo_Error
    , '������ ��������� id ������ ('
      || ' findModuleString="' || findModuleString || '"'
      || ', moduleName="' || moduleName || '"'
      || ', svnRoot="' || svnRoot || '"'
      || ', initialSvnPath="' || initialSvnPath || '"'
      || ', raiseExceptionFlag=' || to_char( raiseExceptionFlag)
      || ')'
    , true
  );
end getModuleId;

/* func: getInstallModuleVersion
  ���������� ������������� � �� ������ ������.
  ��� ����������� ������ ����������� ������ ������ �������� ����� ��������
  ������ �������.

  ���������:
  svnRoot                     - ���� � ��������� �������� ������ � Subversion
                                ( ������� � ����� �����������, ��������
                                "Oracle/Module/ModuleInfo")
  initialSvnPath              - �������������� ���� � ��������� ��������
                                ������ � Subversion ( ������� � �����
                                ����������� � ������ ����� ������, � �������
                                �� ��� ������, ��������
                                "Oracle/Module/ModuleInfo@711")
  mainObjectSchema            - �����, � ������� ����������� ������� ��������
                                ����� ������ ( ���������� ��������� � ������
                                ������� ��������� � ������ �����)

  �������:
  ����� ������������� ������ ���� null ��� ���������� ������ �� ���������.

  ���������:
  - ������ ���� ������� ������� �� null �������� svnRoot ���� initialSvnPath,
    ��� ���� � ������ �������� initialSvnPath �������� svnRoot ������������;
  - ������� �������� ���������� �������������;
*/
function getInstallModuleVersion(
  svnRoot varchar2 := null
  , initialSvnPath varchar2 := null
  , mainObjectSchema varchar2 := null
)
return varchar2
is

  -- ������� ������
  currentVersion v_mod_install_module.current_version%type;

  -- ����� ���������� ���������
  nFound integer;

  -- Id ������
  moduleId integer;

begin
  moduleId := pkg_ModuleInfoInternal.getModuleId(
    svnRoot           => svnRoot
    , initialSvnPath  => initialSvnPath
  );
  select
    max( t.current_version)
    , count(*)
  into currentVersion, nFound
  from
    v_mod_install_module t
  where
    t.module_id = moduleId
    and nullif( upper( mainObjectSchema), t.main_object_schema) is null
  ;
  if nFound > 1 then
    raise_application_error(
      pkg_ModuleInfoInternal.ProcessError_Error
      , '���������� ���������� ������, �.�. ������� ��������� ���������'
        || ' ������ ('
        || ' nFound=' || nFound
        || ').'
    );
  end if;
  return currentVersion;
exception when others then
  raise_application_error(
    pkg_ModuleInfoInternal.ErrorStackInfo_Error
    , '������ ��� ����������� ������������� ������ ������.'
    , true
  );
end getInstallModuleVersion;



/* group: ��������� ���������� */

/* ifunc: getDeployment
  ���������� Id ��������� ��� ������������� ����������.
  ��������� ����� ������ � ������� <mod_deployment>, � ������ ����������
  ���������� ������ ��� �����������.

  ���������:
  deploymentPath              - ���� ��� ������������� ����������
  operatorId                  - Id ���������, ������������ ��������
                                ( �� ��������� �������)

  �������:
  Id ������ ( �������� deployment_id �� ������� <mod_deployment>);
*/
function getDeployment(
  deploymentPath varchar2
  , operatorId integer := null
)
return integer
is

  -- Id ������
  deploymentId mod_deployment.deployment_id%type;



  /*
    ��������� ������ � ������� mod_deployment.
  */
  procedure createDeployment
  is
  begin
    insert into
      mod_deployment
    (
      deployment_path
      , operator_id
    )
    values
    (
      deploymentPath
      , operatorId
    )
    returning deployment_id into deploymentId;
  exception when others then
    raise_application_error(
      pkg_ModuleInfoInternal.ErrorStackInfo_Error
      , '������ ��� ���������� ������.'
      , true
    );
  end createDeployment;



--getDeployment
begin
  select
    max( t.deployment_id)
  into deploymentId
  from
    mod_deployment t
  where
    upper( t.deployment_path) = upper( deploymentPath)
  ;
  if deploymentId is null then
    createDeployment();
  end if;
  return deploymentId;
exception when others then
  raise_application_error(
    pkg_ModuleInfoInternal.ErrorStackInfo_Error
    , '������ ��� ����������� Id ��������� ��� ������������� ���������� ('
      || ' deploymentPath="' || deploymentPath || '"'
      || ').'
    , true
  );
end getDeployment;

/* func: getAppInstallVersion
  ���������� ������������� ������ ����������.

  ���������:
  deploymentPath              - ���� ��� ������������� ����������
  svnRoot                     - ���� � ��������� �������� ������ � Subversion
                                ( ������� � ����� �����������, ��������
                                "Oracle/Module/ModuleInfo")
  initialSvnPath              - �������������� ���� � ��������� ��������
                                ������ � Subversion ( ������� � �����
                                ����������� � ������ ����� ������, � �������
                                �� ��� ������, ��������
                                "Oracle/Module/ModuleInfo@711")

  �������:
  ����� ������������� ������ ���� null ��� ���������� ������ �� ���������.

  ���������:
  - ������ ���� ������� ������� �� null �������� svnRoot ���� initialSvnPath,
    ��� ���� � ������ �������� initialSvnPath �������� svnRoot ������������;
  - ������� �������� ���������� �������������;
*/
function getAppInstallVersion(
  deploymentPath varchar2
  , svnRoot varchar2 := null
  , initialSvnPath varchar2 := null
)
return varchar2
is

  -- ������� ������
  currentVersion v_mod_app_install_version.current_version%type;

  -- Id ������
  moduleId integer;

begin
  moduleId := pkg_ModuleInfoInternal.getModuleId(
    svnRoot           => svnRoot
    , initialSvnPath  => initialSvnPath
  );
  select
    max( t.current_version)
  into currentVersion
  from
    v_mod_app_install_version t
  where
    t.module_id = moduleId
    and upper( t.deployment_path) = upper( deploymentPath)
  ;
  return currentVersion;
exception when others then
  raise_application_error(
    pkg_ModuleInfoInternal.ErrorStackInfo_Error
    , '������ ��� ����������� ������������� ������ ����������.'
    , true
  );
end getAppInstallVersion;

/* iproc: clearCurrentVersion
  ���������� ���� ������� ������ � ����� ������������� ������, ��� ����
  ������ �������������� ����������� � ������������ ������� ��������
  ����������.

  ���������:
  moduleId                    - Id ������
  deploymentId                - Id ��������� ��� ������������� ����������
*/
procedure clearCurrentVersion(
  moduleId integer
  , deploymentId integer
)
is

  cursor curCurrentVersion is
    select
      t.is_current_version
    from
      mod_app_install_result t
    where
      t.is_current_version = 1
      and t.module_id = moduleId
      and t.deployment_id = deploymentId
    for update of t.is_current_version wait 5
  ;

begin
  for cv in curCurrentVersion loop
    update
      mod_app_install_result t
    set
      t.is_current_version = 0
    where current of curCurrentVersion;
  end loop;
exception when others then
  raise_application_error(
    pkg_ModuleInfoInternal.ErrorStackInfo_Error
    , '������ ��� ������ ����� ������� ������ � ������������ ������ ('
      || ' moduleId=' || moduleId
      || ', deploymentId=' || deploymentId
      || ').'
    , true
  );
end clearCurrentVersion;

/* func: startAppInstall
  ��������� ���������� � ������ ��������� ����������.
  ������� ������ ���������� ����� ������� ��������� ����������, ��� ���� �����
  ���������� ��������� ���������� ( � �������� ���� ���������� �����������)
  ������ ���� ������� ������� <finishAppInstall>.

  ���������:
  moduleSvnRoot               - ���� � ��������� �������� ����������������
                                ������ � Subversion ( ������� � �����
                                �����������, ��������
                                "Oracle/Module/ModuleInfo")
  moduleInitialSvnPath        - �������������� ���� � ��������� ��������
                                ���������������� ������ � Subversion ( �������
                                � ����� ����������� � ������ ����� ������, �
                                ������� �� ��� ������, ��������
                                "Oracle/Module/ModuleInfo@711")
  moduleVersion               - ������ ������ ( ��������, "1.1.0")
  deploymentPath              - ���� ��� ������������� ����������
  installVersion              - ��������������� ������ ����������
  svnPath                     - ���� � Subversion, �� �������� ���� ��������
                                ����� ������ ( ������� � ����� �����������,
                                null � ������ ���������� ����������)
  svnVersionInfo              - ���������� � ������ ������ ������ �� Subversion
                                ( � ������� ������ ������� svnversion,
                                null � ������ ���������� ����������)
  operatorId                  - Id ���������, ������������ ��������
                                ( �� ��������� �������)

  �������:
  Id ����������� ������ ( ���� app_install_result_id �������
  <mod_app_install_result>).

  ���������:
  - ��� ������ ������� ��������� ���������� � ������� ������������� �������
    ����������, �.�. ���������, ��� ����� ������������� ������ ����������
    ���������������� ����� ���������� ����� ������;
*/
function startAppInstall(
  moduleSvnRoot varchar2
  , moduleInitialSvnPath varchar2
  , moduleVersion varchar2
  , deploymentPath varchar2
  , installVersion varchar2
  , svnPath varchar2 := null
  , svnVersionInfo varchar2 := null
  , operatorId integer := null
)
return integer
is

  -- ������ ����������� ������
  rec mod_app_install_result%rowtype;



  /*
    ��������� ������ ��� ���������� ��������� ����������.
  */
  procedure addAppInstallResult
  is
  begin
    insert into
      mod_app_install_result
    values
      rec
    returning app_install_result_id into rec.app_install_result_id;
  exception when others then
    raise_application_error(
      pkg_ModuleInfoInternal.ErrorStackInfo_Error
      , '������ ��� ���������� ������ ('
        || ' module_id=' || rec.module_id
        || ', deployment_id=' || rec.deployment_id
        || ').'
      , true
    );
  end addAppInstallResult;



-- startAppInstall
begin
  rec.module_id           :=
    pkg_ModuleInfoInternal.getModuleId(
      svnRoot           => moduleSvnRoot
      , initialSvnPath  => moduleInitialSvnPath
      , isCreate        => 1
      , operatorId      => operatorId
    )
  ;
  rec.deployment_id       :=
    getDeployment(
      deploymentPath  => deploymentPath
      , operatorId    => operatorId
    )
  ;
  rec.install_date        := sysdate;
  rec.install_version     := installVersion;
  rec.module_version      := moduleVersion;
  rec.is_current_version  := null;
  rec.svn_path            := svnPath;
  rec.svn_version_info    := svnVersionInfo;
  rec.operator_id         := operatorId;

  clearCurrentVersion(
    moduleId        => rec.module_id
    , deploymentId  => rec.deployment_id
  );
  addAppInstallResult();
  return rec.app_install_result_id;
exception when others then
  raise_application_error(
    pkg_ModuleInfoInternal.ErrorStackInfo_Error
    , '������ ��� ���������� ���������� � ������ ��������� ����������.'
      || ' moduleSvnRoot="' || moduleSvnRoot || '"'
      || ', moduleInitialSvnPath="' || moduleInitialSvnPath || '"'
      || ', moduleVersion="' || moduleVersion || '"'
      || ', deploymentPath="' || deploymentPath || '"'
      || ', installVersion="' || installVersion || '"'
      || ', svnPath="' || svnPath || '"'
      || ', svnVersionInfo="' || svnVersionInfo || '"'
      || ').'
    , true
  );
end startAppInstall;

/* proc: finishAppInstall
  ��������� ���������� � ���������� ��������� ����������.

  ���������:
  appInstallResultId          - Id ������ � ������ ��������� ����������,
                                ������� ��� ��������� �������� <startAppInstall>
  statusCode                  - ��� ���������� ���������� ���������
                                ( 0 �������� ���������� ������, ��� ����
                                  ��������������� ������ ���������� �������)
  errorMessage                - ����� ��������� �� ������� ��� ����������
                                ���������
                                ( ����������� ������ 4000 ��������)
                                ( �� ��������� �����������)
  installDate                 - ���� ���������� ��������� ( �� ���������
                                �������)
  operatorId                  - Id ���������, ������������ ��������
                                ( �� ��������� �������)

  ���������:
  - �������� javaReturnCode �������� ���������� � �������� �������� ���
    ����������� �������������, ������ ���� ������� ������������ statusCode;
*/
procedure finishAppInstall(
  appInstallResultId integer
  , statusCode integer := null
  , errorMessage varchar2 := null
  , installDate date := null
  , operatorId integer := null
  , javaReturnCode integer := null
)
is

  -- ������� ������ ������ �� ���������
  rec mod_app_install_result%rowtype;

  -- ���� ������� ������
  isCurrentVersion mod_app_install_result.is_current_version%type;

  -- ��� ���������� ���������� ��������� ( � ������ �������������
  -- javaReturnCode)
  appStatusCode integer :=
    coalesce( statusCode, javaReturnCode)
  ;

begin
  select
    t.*
  into rec
  from
    mod_app_install_result t
  where
    t.app_install_result_id = appInstallResultId
  for update of t.status_code wait 5
  ;
  isCurrentVersion :=
    case when
        appStatusCode = 0
      then 1
    end
  ;

  -- ����� ���������� ����� ������� ������ ��������� � ���������� ���� �������
  -- ������ � ������ ������� ( ����� ���� ����������� � ������ ������������
  -- ��������� ������ ������ ����������)
  if isCurrentVersion = 1 then
    clearCurrentVersion(
      moduleId        => rec.module_id
      , deploymentId  => rec.deployment_id
    );
  end if;

  update
    mod_app_install_result t
  set
    t.install_date          = coalesce( installDate, sysdate)
    , t.is_current_version  = isCurrentVersion
    , t.status_code         = appStatusCode
    , t.error_message       = substr( errorMessage, 1, 4000)
  where
    t.app_install_result_id = appInstallResultId
  ;
exception when others then
  raise_application_error(
    pkg_ModuleInfoInternal.ErrorStackInfo_Error
    , '������ ��� ���������� ���������� � ���������� ��������� ���������� ('
      || ' appInstallResultId=' || appInstallResultId
      || ', statusCode=' || statusCode
      || ', javaReturnCode=' || javaReturnCode
      || ', substr(errorMessage,1,200):'
        || chr(10) || '"' || substr( errorMessage, 1, 200) || '"' || chr(10)
      || ', installDate=' || to_char( installDate, 'dd.mm.yyyy hh24:mi:ss')
      || ').'
    , true
  );
end finishAppInstall;

/* func: createAppInstallResult( DEPRECATED)
  ���������� �������, ����� ������� ( ������ ��� ������� ������������ ����
  ������� <startAppInstall> � <finishAppInstall>).
*/
function createAppInstallResult(
  moduleSvnRoot varchar2
  , moduleInitialSvnPath varchar2
  , moduleVersion varchar2
  , deploymentPath varchar2
  , installVersion varchar2
  , installDate date := null
  , svnPath varchar2 := null
  , svnVersionInfo varchar2 := null
  , operatorId integer := null
)
return integer
is

  -- Id ����������� ������
  appInstallResultId integer;

begin
  appInstallResultId := startAppInstall(
    moduleSvnRoot             => moduleSvnRoot
    , moduleInitialSvnPath    => moduleInitialSvnPath
    , moduleVersion           => moduleVersion
    , deploymentPath          => deploymentPath
    , installVersion          => installVersion
    , svnPath                 => svnPath
    , svnVersionInfo          => svnVersionInfo
    , operatorId              => operatorId
  );
  finishAppInstall(
    appInstallResultId        => appInstallResultId
    , javaReturnCode          => 0
    , errorMessage            => null
    , installDate             => installDate
    , operatorId              => operatorId
  );
  return appInstallResultId;
exception when others then
  raise_application_error(
    pkg_ModuleInfoInternal.ErrorStackInfo_Error
    , '������ ��� ���������� ���������� ��������� ����������.'
    , true
  );
end createAppInstallResult;

end pkg_ModuleInfo;
/
