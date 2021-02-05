create or replace package body pkg_ModuleInstall is
/* package body: pkg_ModuleInstall::body */



/* group: ���� */

/* itype: TColId
  ��������� ���������������.
*/
type TColId is table of integer;



/* group: ��������� */

/* iconst: Main_PartNumber
  ����� �������� ����� ������.
*/
Main_PartNumber constant integer := 1;



/* group: ���������� */

/* ivar: currentInstallFileId
  Id ������ ��� �������� ���������������� ����� �������� ������.
*/
currentInstallFileId mod_install_file.install_file_id%type;

/* ivar: currentInstallActionId
  Id ������ ��� �������� �������� �� ���������.
*/
currentInstallActionId mod_install_action.install_action_id%type;

/* ivar: currentModuleId
  Id ������, � �������� ��������� ������� �������� �� ���������.
*/
currentModuleId mod_module.module_id%type;

/* ivar: currentFileModulePartNumber
  ����� ����� ������, � �������� ��������� ������� ��������������� ����
  �������� ������.
*/
currentFileModulePartNumber mod_module_part.part_number%type;

/* ivar: currentFileRunLevel
  ������� ����������� �������� ���������������� �����.
*/
currentFileRunLevel mod_install_file.run_level%type;

/* ivar: colNestedInstallFileId
  ��������� Id ������� ��� ������� ��������������� ��������� ������.
*/
colNestedInstallFileId TColId := TColId();




/* group: ������� */



/* group: ��������������� ������� */

/* ifunc: getModulePart
  ���������� Id ����� ����������� ������.
  ��������� ����� � ������� <mod_module_part>, � ������ ���������� ����������
  ������ ��� �����������.

  ���������:
  moduleId                    - Id ������
  partNumber                  - ����� ����� ������
  isCreate                    - ������� ������ � ������ ���������� ����������
                                ( 1 ��, 0 ��� ( �� ���������))

  �������:
  Id ����� ������
*/
function getModulePart(
  moduleId integer
  , partNumber integer
  , isCreate integer := null
)
return integer
is

  -- Id ����� ������
  modulePartId mod_module_part.module_part_id%type;



  /*
    ������� ������ ��� ����� ������ � ������� mod_module_part.
  */
  procedure createModulePart
  is
  begin
    insert into
      mod_module_part
    (
      module_id
      , part_number
    )
    values
    (
      moduleId
      , coalesce( partNumber, Main_PartNumber)
    )
    returning module_part_id into modulePartId;
  exception when others then
    raise_application_error(
      pkg_ModuleInfoInternal.ErrorStackInfo_Error
      , '������ ��� �������� ������ ��� ����� ������.'
      , true
    );
  end createModulePart;



--getModulePart
begin
  select
    max( mp.module_part_id)
  into modulePartId
  from
    mod_module_part mp
  where
    mp.module_id = moduleId
    and mp.part_number = coalesce( partNumber, Main_PartNumber)
  ;
  if modulePartId is null and isCreate = 1 then
    createModulePart();
  end if;
  return modulePartId;
exception when others then
  raise_application_error(
    pkg_ModuleInfoInternal.ErrorStackInfo_Error
    , '������ ��� ����������� Id ����� ������ ('
      || ' moduleId=' || to_char( moduleId)
      || ' , partNumber=' || to_char( partNumber)
      || ').'
    , true
  );
end getModulePart;

/* ifunc: getInstallAction
  ���������� Id �������� �� ���������.
  ��������� ����� � ������� <mod_install_action>, � ������ ����������
  ���������� ������ ��������� ��.

  ���������:
  hostProcessStartTime        - ����� ������ ���������� ��������, � �������
                                ����������� �������� ( ����������� ���������
                                ����� �� �����)
  hostProcessId               - ������������� �������� �� �����, � �������
                                ����������� ��������
  moduleId                    - Id ������
  moduleVersion               - ������ ������ ( ��������, "1.1.0")
  installVersion              - ��������������� ������ ������
  actionGoalList              - ���� ���������� �������� �� ��������� ������
                                ( ������ � ��������� � �������� �����������)
  actionOptionList            - ��������� �������� �� ��������� ������
                                ( ������ � ��������� � �������� �����������)
  svnPath                     - ���� � Subversion, �� �������� ���� ��������
                                ����� ������ ( ������� � ����� �����������)
  svnVersionInfo              - ���������� � ������ ������ ������ �� Subversion
                                ( � ������� ������ ������� svnversion)

  �������:
  Id �������� �� ��������� ( �������� install_action_id �� �������
  <mod_install_action>).
*/
function getInstallAction(
  hostProcessStartTime timestamp with time zone
  , hostProcessId integer
  , moduleId integer
  , moduleVersion varchar2
  , installVersion varchar2
  , actionGoalList varchar2
  , actionOptionList varchar2
  , svnPath varchar2
  , svnVersionInfo varchar2
)
return integer
is

  -- Id �������� �� ���������
  installActionId mod_install_action.install_action_id%type;

  -- ���� ������� ������
  sessionHost mod_install_action.host%type;



  /*
    ������� ������ ��� �������� �� ���������.
  */
  procedure createInstallAction
  is
  begin
    insert into
      mod_install_action
    (
      host
      , host_process_start_time
      , host_process_id
      , os_user
      , module_id
      , module_version
      , install_version
      , action_goal_list
      , action_option_list
      , svn_path
      , svn_version_info
    )
    values
    (
      sessionHost
      , hostProcessStartTime
      , hostProcessId
      , sys_context( 'USERENV', 'OS_USER')
      , moduleId
      , moduleVersion
      , installVersion
      , actionGoalList
      , actionOptionList
      , svnPath
      , svnVersionInfo
    )
    returning install_action_id into installActionId;
  exception when others then
    raise_application_error(
      pkg_ModuleInfoInternal.ErrorStackInfo_Error
      , '������ ��� �������� ������ ��� �������� �� ���������.'
      , true
    );
  end createInstallAction;



--getInstallAction
begin
  sessionHost := sys_context( 'USERENV', 'HOST');
  select
    max( ia.install_action_id)
  into installActionId
  from
    mod_install_action ia
  where
    ia.host = sessionHost
    and ia.host_process_start_time = hostProcessStartTime
    and ia.host_process_id = hostProcessId
  ;
  if installActionId is null then
    createInstallAction();
  end if;
  return installActionId;
exception when others then
  raise_application_error(
    pkg_ModuleInfoInternal.ErrorStackInfo_Error
    , '������ ��� ����������� Id �������� �� ��������� ('
      || ' hostProcessStartTime='
        || to_char( hostProcessStartTime, 'dd.mm.yyyy hh24:mi:ss tzh:tzm')
      || ', hostProcessId=' || to_char( hostProcessId)
      || ', moduleId=' || to_char( moduleId)
      || ', installVersion="' || installVersion || '"'
      || ', moduleVersion="' || moduleVersion || '"'
      || ').'
    , true
  );
end getInstallAction;

/* ifunc: getSourceFile
  ���������� Id ��������� �����.
  ��������� ����� � ������� <mod_source_file>, � ������ ����������
  ���������� ������ ��������� ��.

  ���������:
  moduleId                    - Id ������
  filePath                    - ���� � �����
  modulePartNumber            - ����� ����� ������, � ������� ��������� ����
                                ( �� ��������� �� ����������, � ��� ����������
                                ������ ��������� � �������� �����)
  objectName                  - ��� ������� � ��, �������� ������������� ����
  objectType                  - ��� ������� � ��, �������� ������������� ����

  �������:
  Id ��������� ����� ( �������� source_file_id �� ������� <mod_source_file>).
*/
function getSourceFile(
  moduleId integer
  , filePath varchar2
  , modulePartNumber integer
  , objectName varchar2
  , objectType varchar2
)
return integer
is

  -- Id ����� ������, � ������� ��������� ����
  modulePartId mod_module_part.module_part_id%type;

  -- Id ��������� �����
  sourceFileId mod_source_file.source_file_id%type;

  -- Id ����� ������ ��� �����, ��������� � �������
  lastModulePartId mod_source_file.module_part_id%type;

  -- ��� ������� ��� �����, ��������� � �������
  lastObjectName mod_source_file.object_name%type;

  -- ��� ������� ��� �����, ��������� � �������
  lastObjectType mod_source_file.object_type%type;



  /*
    ������� ������ ��� ��������� �����.
  */
  procedure createSourceFile
  is
  begin
    insert into
      mod_source_file
    (
      module_id
      , file_path
      , module_part_id
      , object_name
      , object_type
    )
    values
    (
      moduleId
      , filePath
      , modulePartId
      , objectName
      , objectType
    )
    returning source_file_id into sourceFileId;
  exception when others then
    raise_application_error(
      pkg_ModuleInfoInternal.ErrorStackInfo_Error
      , '������ ��� �������� ������ ��� ��������� �����.'
      , true
    );
  end createSourceFile;



  /*
    ��������� ��������� �����.
  */
  procedure UpdateFileObject
  is
  begin
    update
      mod_source_file sf
    set
      sf.module_part_id = coalesce( modulePartId, sf.module_part_id)
      , sf.object_name = objectName
      , sf.object_type = objectType
    where
      sf.source_file_id = sourceFileId
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
      , '������ ��� ���������� �������� � ���� ������� ��� ����� ('
        || ' sourceFileId=' || to_char( sourceFileId)
        || ').'
      , true
    );
  end UpdateFileObject;



--getSourceFile
begin
  select
    max( sf.source_file_id)
    , max( sf.module_part_id)
    , max( sf.object_name)
    , max( sf.object_type)
  into sourceFileId, lastModulePartId, lastObjectName, lastObjectType
  from
    mod_source_file sf
  where
    sf.module_id = moduleId
    and sf.file_path = filePath
  ;
  if sourceFileId is null or modulePartNumber is not null then
    modulePartId := getModulePart(
      moduleId      => moduleId
      , partNumber  => modulePartNumber
      , isCreate    => 1
    );
  end if;
  if sourceFileId is null then
    createSourceFile();
  elsif not (
        ( modulePartId is null or lastModulePartId = modulePartId)
        and coalesce(
            lastObjectName = objectName
            , coalesce( lastObjectName, objectName) is null
          )
        and coalesce(
            lastObjectType = objectType
            , coalesce( lastObjectType, objectType) is null
          )
      )
      then
    UpdateFileObject();
  end if;
  return sourceFileId;
exception when others then
  raise_application_error(
    pkg_ModuleInfoInternal.ErrorStackInfo_Error
    , '������ ��� ����������� Id ��������� ����� ('
      || ' moduleId=' || to_char( moduleId)
      || ', filePath="' || filePath || '"'
      || ', objectName="' || objectName || '"'
      || ', objectType="' || objectType || '"'
      || ').'
    , true
  );
end getSourceFile;

/* iproc: checkUserExists
  ��������� ������� ������������ � ��, ���� ������� ��� ������������.

  ���������:
  checkUserName             - ��� ������������ ( ��� ����� ��������)
  parameterName             - ��� ��������� ������� ( ��� �������� �
                              ��������� �� ������).
*/
procedure checkUserExists(
  checkUserName varchar2
  , parameterName varchar2
)
is

  -- ���� ������� ������������
  isExists integer;

begin
  if checkUserName is not null then
    select
      count(*)
    into isExists
    from
      all_users us
    where
      us.username = upper( checkUserName)
      and rownum <= 1
    ;
    if isExists = 0 then
      raise_application_error(
        pkg_ModuleInfoInternal.IllegalArgument_Error
        , '������ �������������� ������������ �� ('
          || ' ' || parameterName || '="' || checkUserName || '"'
          || ').'
      );
    end if;
  end if;
end checkUserExists;



/* group: ��������� ������ */

/* ifunc: createInstallFile
  ������� ������ �� ��������� ��������� �����.

  ���������:
  installActionId             - Id �������� �� ���������
  sourceFileId                - Id ��������� �����
  runLevel                    - ������� ����������� ������������ �����
                                ( 1 ��� ����� �������� ������)

  �������:
  Id ������ �� ��������� �����.
*/
function createInstallFile(
  installActionId integer
  , sourceFileId integer
  , runLevel integer
)
return integer
is

  -- Id ������ �� ��������� �����
  installFileId mod_install_file.install_file_id%type;

--createInstallFile
begin
  insert into
    mod_install_file
  (
    install_action_id
    , source_file_id
    , run_level
    , start_date
  )
  values
  (
    installActionId
    , sourceFileId
    , runLevel
    , sysdate
  )
  returning install_file_id into installFileId;
  return installFileId;
exception when others then
  raise_application_error(
    pkg_ModuleInfoInternal.ErrorStackInfo_Error
    , '������ ��� �������� ������ �� ��������� ����� ('
      || ' installActionId=' || to_char( installActionId)
      || ', sourceFileId=' || to_char( sourceFileId)
      || ', runLevel=' || to_char( runLevel)
      || ').'
    , true
  );
end createInstallFile;

/* func: startInstallFile
  ��������� ������ ��������� �����.
  ���������� ����� ���������� ����� � ��� �� ������.

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
  installVersion              - ��������������� ������ ������
  hostProcessStartTime        - ����� ������ ���������� ��������, � �������
                                ����������� �������� ( ����������� ���������
                                ����� �� �����)
  hostProcessId               - ������������� �������� �� �����, � �������
                                ����������� ��������
  actionGoalList              - ���� ���������� �������� �� ��������� ������
                                ( ������ � ��������� � �������� �����������)
  actionOptionList            - ��������� �������� �� ��������� ������
                                ( ������ � ��������� � �������� �����������)
  svnPath                     - ���� � Subversion, �� �������� ���� ��������
                                ����� ������ ( ������� � ����� �����������,
                                null � ������ ���������� ����������)
  svnVersionInfo              - ���������� � ������ ������ ������ �� Subversion
                                ( � ������� ������ ������� svnversion,
                                null � ������ ���������� ����������)
  filePath                    - ���� � ���������������� �����
  fileModuleSvnRoot           - ���� � ��������� �������� ������, � ��������
                                ��������� ��������������� ����, � Subversion
                                ( ������ ���������� ��������� moduleSvnRoot,
                                �� ��������� ���������, ��� ���� ��������� �
                                ���������������� ������)
  fileModuleInitialSvnPath    - �������������� ���� � ��������� ��������
                                ������, � �������� ��������� ���������������
                                ����, � Subversion ( ������ ����������
                                ��������� moduleInitialSvnPath, �� ���������
                                ���������, ��� ���� ��������� �
                                ���������������� ������)
  fileModulePartNumber        - ����� ����� ������, � ������� ��������� ����
                                ( �� ��������� �� ���������� ��� �������
                                ������ � <mod_source_file>, � ��� �����
                                ������ ������������ ����� �������� �����)
  fileObjectName              - ��� ������� � ��, �������� ������������� ����
                                ( �� ��������� �� ������������� �������)
  fileObjectType              - ��� ������� � ��, �������� ������������� ����
                                ( �� ��������� �� ������������� �������)

  �������:
  Id ��� ����������� ��������� ����� ( �������� install_file_id �� �������
  <mod_install_file>).

  ���������:
  - ������� ����������� � ���������� ����������;
*/
function startInstallFile(
  moduleSvnRoot varchar2
  , moduleInitialSvnPath varchar2
  , moduleVersion varchar2
  , installVersion varchar2 := null
  , hostProcessStartTime timestamp with time zone
  , hostProcessId integer
  , actionGoalList varchar2
  , actionOptionList varchar2
  , svnPath varchar2 := null
  , svnVersionInfo varchar2 := null
  , filePath varchar2
  , fileModuleSvnRoot varchar2 := null
  , fileModuleInitialSvnPath varchar2 := null
  , fileModulePartNumber integer := null
  , fileObjectName varchar2 := null
  , fileObjectType varchar2 := null
)
return integer
is

  pragma autonomous_transaction;

  -- Id ���������������� ������
  moduleId mod_module.module_id%type;

  -- Id ������ ���������������� �����
  fileModuleId mod_module.module_id%type;

  -- Id �������� �� ���������
  installActionId mod_install_action.install_action_id%type;

  -- Id ��������� �����
  installFileId mod_install_file.install_file_id%type;

--startInstallFile
begin
  if currentInstallFileId is not null then
    raise_application_error(
      pkg_ModuleInfoInternal.IllegalArgument_Error
      , '� ������ ��� ����������� ��������� ������� ����� ('
        || ' install_file_id=' || to_char( currentInstallFileId)
        || ').'
    );
  end if;
  moduleId := pkg_ModuleInfoInternal.getModuleId(
    svnRoot           => moduleSvnRoot
    , initialSvnPath  => moduleInitialSvnPath
    , isCreate        => 1
  );
  fileModuleId :=
    case when fileModuleSvnRoot is not null
          or fileModuleInitialSvnPath is not null
        then
      pkg_ModuleInfoInternal.getModuleId(
        svnRoot           => fileModuleSvnRoot
        , initialSvnPath  => fileModuleInitialSvnPath
        , isCreate        => 1
      )
    else
      moduleId
    end
  ;
  installActionId := getInstallAction(
    hostProcessStartTime  => hostProcessStartTime
    , hostProcessId       => hostProcessId
    , moduleId            => moduleId
    , moduleVersion       => moduleVersion
    , installVersion      => installVersion
    , actionGoalList      => actionGoalList
    , actionOptionList    => actionOptionList
    , svnPath             => svnPath
    , svnVersionInfo      => svnVersionInfo
  );
  installFileId := createInstallFile(
    installActionId     => installActionId
    , sourceFileId      => getSourceFile(
        moduleId            => fileModuleId
        , filePath          => filePath
        , modulePartNumber  => fileModulePartNumber
        , objectName        => fileObjectName
        , objectType        => fileObjectType
      )
    , runLevel          => 1
  );
  commit;
  currentInstallFileId        := installFileId;
  currentInstallActionId      := installActionId;
  currentModuleId             := moduleId;
  currentFileModulePartNumber := fileModulePartNumber;
  currentFileRunLevel         := 1;
  return currentInstallFileId;
exception when others then
  raise_application_error(
    pkg_ModuleInfoInternal.ErrorStackInfo_Error
    , '������ ��� �������� ������ ��������� �����.'
    , true
  );
end startInstallFile;

/* iproc: UpdateInstallFile
  ��������� ������ �� ��������� �����.

  ���������:
  installFileId               - Id ��������� �����
  finishDate                  - ���� ���������� ���������
*/
procedure UpdateInstallFile(
  installFileId integer
  , finishDate date
)
is
--UpdateInstallFile
begin
  update
    mod_install_file d
  set
    d.finish_date = sysdate
  where
    d.install_file_id = installFileId
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
    , '������ ��� ���������� ������ �� ��������� ����� ('
      || ' installFileId=' || to_char( installFileId)
      || ').'
    , true
  );
end UpdateInstallFile;

/* proc: finishInstallFile
  ��������� ���������� ��������� �����.
  ���������� ����� ���������� ��������� ����� � ��� �� ������, ��� ����
  ����� ���������� ������ ���� ������� ��������� <startInstallFile>.

  ���������:
  installFileId               - Id ��������� ����� ( �� ��������� �������)

  ���������:
  - ��������� ����������� � ���������� ����������;
*/
procedure finishInstallFile(
  installFileId integer := null
)
is

  pragma autonomous_transaction;

  -- ������������ Id ��������� �����
  usedInstallFileId integer := coalesce( installFileId, currentInstallFileId);

--finishInstallFile
begin
  if usedInstallFileId is null then
    raise_application_error(
      pkg_ModuleInfoInternal.ProcessError_Error
      , '��� ������ �� �������� ���������������� �����.'
    );
  end if;
  UpdateInstallFile(
    installFileId     => usedInstallFileId
    , finishDate      => sysdate
  );
  commit;
  if currentInstallFileId = usedInstallFileId then
    currentInstallFileId    := null;
    currentInstallActionId  := null;
    currentModuleId         := null;
    currentFileModulePartNumber := null;
    currentFileRunLevel     := null;
  end if;
exception when others then
  raise_application_error(
    pkg_ModuleInfoInternal.ErrorStackInfo_Error
    , '������ ��� �������� ���������� ��������� ����� ('
      || ' installFileId=' || to_char( installFileId)
      || ').'
    , true
  );
end finishInstallFile;

/* func: startInstallNestedFile
  ��������� ������ ��������� ���������� �����.
  �������������� � ��� �� ������ ������ ���� ������������� ������ ���������
  ����� �������� ������ � ������� ������ ������� <startInstallFile>.

  ���������:
  filePath                    - ���� � ������������ �����
  fileModuleSvnRoot           - ���� � ��������� �������� ������, � ��������
                                ��������� ����������� ����, � Subversion
                                ( ������ ���������� ��������� moduleSvnRoot,
                                �� ��������� ���������, ��� ���� ��������� �
                                ���������������� ������)
  fileModuleInitialSvnPath    - �������������� ���� � ��������� ��������
                                ������, � �������� ��������� �����������
                                ����, � Subversion ( ������ ����������
                                ��������� moduleInitialSvnPath, �� ���������
                                ���������, ��� ���� ��������� �
                                ���������������� ������)
  fileModulePartNumber        - ����� ����� ������, � ������� ��������� ����
                                ( �� ��������� �� ���������� ��� �������
                                ������ � <mod_source_file>, � ��� �����
                                ������ ������������ ����� �����
                                ���������������� ����� �������� ������ ����
                                �� ��������� � ���� �� ������, ����� �����
                                �������� �����)
  fileObjectName              - ��� ������� � ��, �������� ������������� ����
                                ( �� ��������� �� ������������� �������)
  fileObjectType              - ��� ������� � ��, �������� ������������� ����
                                ( �� ��������� �� ������������� �������)

  �������:
  Id ������, ����������� ������ ��������� ����� ( �������� install_file_id ��
  ������� <mod_install_file>).

  ���������:
  - ������� ����������� � ���������� ����������;
*/
function startInstallNestedFile(
  filePath varchar2
  , fileModuleSvnRoot varchar2 := null
  , fileModuleInitialSvnPath varchar2 := null
  , fileModulePartNumber integer := null
  , fileObjectName varchar2 := null
  , fileObjectType varchar2 := null
)
return integer
is

  pragma autonomous_transaction;

  -- Id ��������� �����
  installFileId mod_install_file.install_file_id%type;

  -- Id ������ ���������������� �����
  fileModuleId mod_module.module_id%type;

--startInstallNestedFile
begin
  if currentInstallFileId is null then
    raise_application_error(
      pkg_ModuleInfoInternal.IllegalArgument_Error
      , '� ������ �� ���� ������ ��������� ����� �������� ������.'
    );
  end if;
  fileModuleId :=
    case when fileModuleSvnRoot is not null
          or fileModuleInitialSvnPath is not null
        then
      pkg_ModuleInfoInternal.getModuleId(
        svnRoot           => fileModuleSvnRoot
        , initialSvnPath  => fileModuleInitialSvnPath
        , isCreate        => 1
      )
    else
      currentModuleId
    end
  ;
  installFileId := createInstallFile(
    installActionId     => currentInstallActionId
    , sourceFileId      => getSourceFile(
        moduleId            => fileModuleId
        , filePath          => filePath
        , modulePartNumber  =>
            coalesce(
              fileModulePartNumber
              , case when fileModuleId = currentModuleId then
                  currentFileModulePartNumber
                end
            )
        , objectName        => fileObjectName
        , objectType        => fileObjectType
      )
    , runLevel          => currentFileRunLevel + 1
  );
  commit;
  colNestedInstallFileId.extend( 1);
  colNestedInstallFileId( currentFileRunLevel) := installFileId;
  currentFileRunLevel         := currentFileRunLevel + 1;
  return installFileId;
exception when others then
  raise_application_error(
    pkg_ModuleInfoInternal.ErrorStackInfo_Error
    , '������ ��� �������� ������ ��������� ���������� �����.'
    , true
  );
end startInstallNestedFile;

/* proc: finishInstallNestedFile
  ��������� ���������� ��������� ���������� �����.
  ���������� ����� ���������� ��������� ���������� ����� � ��� �� ������, ���
  ���� ����� ������� ���������� ���������� ����� ������ ���� ������� �������
  <startInstallNestedFile>.

  ���������:
  - ��������� ����������� � ���������� ����������;
*/
procedure finishInstallNestedFile
is

  pragma autonomous_transaction;

--finishInstallNestedFile
begin
  if coalesce( currentFileRunLevel, 0) < 2 then
    raise_application_error(
      pkg_ModuleInfoInternal.ProcessError_Error
      , '��� ������ �� �������� ���������������� ���������� �����.'
    );
  end if;
  UpdateInstallFile(
    installFileId     => colNestedInstallFileId( currentFileRunLevel - 1)
    , finishDate      => sysdate
  );
  commit;
  colNestedInstallFileId.trim( 1);
  currentFileRunLevel := currentFileRunLevel - 1;
exception when others then
  raise_application_error(
    pkg_ModuleInfoInternal.ErrorStackInfo_Error
    , '������ ��� �������� ���������� ��������� ���������� �����.'
    , true
  );
end finishInstallNestedFile;



/* group: ��������� ��������� */

/* iproc: fillInstallResult
  ��������� �������� ���� ������ � ���������� ���������.

  ���������:
  rec                         - ������ ������
                                (�������)
  moduleSvnRoot               - ���� � ��������� �������� ����������������
                                ������ � Subversion ( ������� � �����
                                �����������, ��������
                                "Oracle/Module/ModuleInfo")
  moduleInitialSvnPath        - �������������� ���� � ��������� ��������
                                ���������������� ������ � Subversion ( �������
                                � ����� ����������� � ������ ����� ������, �
                                ������� �� ��� ������, ��������
                                "Oracle/Module/ModuleInfo@711")
  modulePartNumber            - ����� ��������������� ����� ������
                                ( �� ��������� ����� �������� �����)
  installVersion              - ��������������� ������
  installTypeCode             - ��� ���� ���������
  isFullInstall               - ���� ������ ��������� ( 1 ��� ������ ���������,
                                0 ��� ��������� ����������)
  isRevertInstall             - ���� ���������� ������ ��������� ������
                                ( 1 ������ ��������� ������, 0 ��������� ������
                                ( �� ���������))
  installUser                 - ��� ������������, ��� ������� �����������
                                ��������� ( �� ��������� �������)
  objectSchema                - �����, � ������� ����������� ������� ������
                                ����� ������ ( �� ��������� ��������� �
                                installUser, null ���� � ��� ������� sys ���
                                system)
  privsUser                   - ��� ������������ ��� ����, ��� �������
                                ����������� ��������� ���� ������� ( ��������
                                ������ ���� ������� ������ ��� ��������� ����
                                �������)
  installScript               - ��������� ������������ ������ ( �����
                                �������������, ���� ������������� �����������
                                �������, �������� run.sql)
  resultVersion               - ������, ������������ ���������� ����������
                                ���������, ������ ���� ����������� ������� ���
                                ������ ��������� ���������� ( �� ���������
                                installVersion � ������ ���������, null �
                                ������ ������ ������ ���������)
  isCreateModule              - ������� ������ � ������ � ����� ������ �
                                ������ ���������� ����������
                                ( 1 ��, 0 ��� ( �� ���������))
*/
procedure fillInstallResult(
  rec out nocopy mod_install_result%rowtype
  , moduleSvnRoot varchar2
  , moduleInitialSvnPath varchar2
  , modulePartNumber integer
  , installVersion varchar2
  , installTypeCode varchar2
  , isFullInstall integer
  , isRevertInstall integer
  , installUser varchar2
  , objectSchema varchar2
  , privsUser varchar2
  , installScript varchar2
  , resultVersion varchar2
  , isCreateModule integer := null
)
is
begin
  checkUserExists(
    checkUserName => installUser
    , parameterName => 'installUser'
  );
  if nullif( objectSchema, installUser) is not null then
    checkUserExists(
      checkUserName => objectSchema
      , parameterName => 'objectSchema'
    );
  end if;
  rec.install_user := upper( coalesce( installUser, user));
  rec.install_version := installVersion;
  rec.install_type_code := installTypeCode;
  rec.is_full_install := isFullInstall;
  rec.is_revert_install := coalesce( isRevertInstall, 0);
  rec.object_schema := coalesce(
    upper( objectSchema)
    , nullif( nullif( rec.install_user, 'SYS'), 'SYSTEM')
  );
  rec.privs_user := upper( privsUser);
  rec.install_script := installScript;
  rec.result_version := coalesce(
    resultVersion
    , case when rec.is_revert_install = 0 then rec.install_version end
  );
  rec.module_id := pkg_ModuleInfoInternal.getModuleId(
    svnRoot           => moduleSvnRoot
    , initialSvnPath  => moduleInitialSvnPath
    , isCreate        => coalesce( isCreateModule, 0)
  );
  if rec.module_id is not null then
    rec.module_part_id := getModulePart(
      moduleId      => rec.module_id
      , partNumber  => modulePartNumber
      , isCreate    => coalesce( isCreateModule, 0)
    );
  end if;
exception when others then
  raise_application_error(
    pkg_ModuleInfoInternal.ErrorStackInfo_Error
    , '������ ��� ���������� ������ � ����������� ���������.'
    , true
  );
end fillInstallResult;

/* func: checkInstallVersion
  ��������� ����������� ��������� �� ������ ������ �� ������������� ������
  ������.

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
  modulePartNumber            - ����� ��������������� ����� ������
                                ( �� ��������� ����� �������� �����)
  installVersion              - ��������������� ������
  installTypeCode             - ��� ���� ���������
  isFullInstall               - ���� ������ ��������� ( 1 ��� ������ ���������,
                                0 ��� ��������� ����������)
  isRevertInstall             - ���� ���������� ������ ��������� ������
                                ( 1 ������ ��������� ������, 0 ��������� ������
                                ( �� ���������))
  installUser                 - ��� ������������, ��� ������� �����������
                                ��������� ( �� ��������� �������)
  objectSchema                - �����, � ������� ����������� ������� ������
                                ����� ������ ( �� ��������� ��������� �
                                installUser, null ���� � ��� ������� sys ���
                                system)
  privsUser                   - ��� ������������ ��� ����, ��� �������
                                ����������� ��������� ���� ������� ( ��������
                                ������ ���� ������� ������ ��� ��������� ����
                                �������)
  installScript               - ��������� ������������ ������ ( �����
                                �������������, ���� ������������� �����������
                                �������, �������� run.sql)
  resultVersion               - ������, ������������ � ���������� ����������
                                ���������, ������ ���� ����������� ������� ���
                                ������ ��������� ���������� ( �� ���������
                                installVersion � ������ ���������, null �
                                ������ ������ ������ ���������)
  overwriteCurrentVersionFlag - ������� ����������� ���������� ��� ������������� ������� ������
                                (1 - �� (��-���������), 0 - ���)
*/
procedure checkInstallVersion(
  moduleSvnRoot varchar2
  , moduleInitialSvnPath varchar2
  , modulePartNumber integer
  , installVersion varchar2
  , installTypeCode varchar2
  , isFullInstall integer
  , isRevertInstall integer := null
  , installUser varchar2 := null
  , objectSchema varchar2 := null
  , privsUser varchar2 := null
  , installScript varchar2 := null
  , resultVersion varchar2 := null
  , overwriteCurrentVersionFlag integer := null
)
is

  -- ������ ������ ��� ���������
  rec mod_install_result%rowtype;

  -- ������� ������
  currentVersion mod_install_result.result_version%type;
  currentInstallResultId integer;

  -- ��������� �� ������
  erm varchar2(1000);

  -- ����������� ��������� ������ � ���������� ���������
  -- ( 1 - �������� ������ ������ �������, -1 - ������, 0 - �� ��)
  resultDirection integer;



  /*
    �������� ���������� � ������� ������.
  */
  procedure getCurrentVersionInfo
  is
  begin
    select
      max(
          case when
            ir.install_type_code = rec.install_type_code
          then
            ir.result_version
          end
        )
        as current_version
      , max(
          case when
            ir.install_type_code = rec.install_type_code
          then
            ir.install_result_id
          end
        )
        as current_install_result_id
    into currentVersion, currentInstallResultId
    from
      mod_install_result ir
    where
      ir.is_current_version = 1
      and ir.module_part_id = rec.module_part_id
      and ir.install_type_code = rec.install_type_code
      and (
        coalesce( ir.object_schema, rec.object_schema) is null
        or ir.object_schema is not null
          and rec.object_schema is not null
          and ir.object_schema = rec.object_schema
        )
      and (
        coalesce( ir.privs_user, rec.privs_user) is null
        or ir.privs_user is not null
          and rec.privs_user is not null
          and ir.privs_user = rec.privs_user
        )
    ;
  exception when others then
    raise_application_error(
      pkg_ModuleInfoInternal.ErrorStackInfo_Error
      , '������ ��� ��������� ���������� � ������� ������.'
      , true
    );
  end getCurrentVersionInfo;



-- checkInstallVersion
begin
  fillInstallResult(
    rec                       => rec
    , moduleSvnRoot           => moduleSvnRoot
    , moduleInitialSvnPath    => moduleInitialSvnPath
    , modulePartNumber        => modulePartNumber
    , installVersion          => installVersion
    , installTypeCode         => installTypeCode
    , isFullInstall           => isFullInstall
    , isRevertInstall         => isRevertInstall
    , installUser             => installUser
    , objectSchema            => objectSchema
    , privsUser               => privsUser
    , installScript           => installScript
    , resultVersion           => resultVersion
    , isCreateModule          => 0
  );
  if rec.module_part_id is not null then
    getCurrentVersionInfo();
  end if;

  if currentVersion is null then
    if rec.is_full_install = 0 then
      erm :=
        '��� ������������� ������ '
        || case when rec.is_revert_install = 0 then
            '��� ����������'
          else
            '��� ������'
          end
      ;
    end if;
  elsif rec.is_revert_install = 1
        and rec.install_version <> currentVersion
        -- ��������� ����� � ������� ������
        and rec.result_version <> currentVersion
      then
    erm := '���������� ������ �� ������������� �������������';
  else
    resultDirection := pkg_ModuleInfoInternal.compareVersion(
      rec.result_version
      , currentVersion
    );
    erm := case
      when rec.is_revert_install = 0 and resultDirection = -1 then
        '��������������� ������ ������, ��� ������������� �����'
      when rec.is_revert_install = 0 and resultDirection = 0 and overwriteCurrentVersionFlag = 0 then
        '����������� ������ ��� ���� ����������� �����'
      when rec.is_revert_install = 1 and resultDirection = 1 then
        '����� ������ ��������� ������ �� ������ �������� �����'
        || ' ������� ������'
      end
    ;

  end if;
  if erm is not null then
    raise_application_error(
      pkg_ModuleInfoInternal.IllegalArgument_Error
      , erm || ' ('
        || 'modulePartNumber=' || modulePartNumber
        || ', objectSchema="' || rec.object_schema || '"'
        || case when rec.privs_user is not null then
            ', privsUser="' || rec.privs_user || '"'
          end
        || ', currentVersion="' || currentVersion || '"'
        || ', installVersion="' || rec.install_version || '"'
        || ', isRevertInstall=' || rec.is_revert_install
        || ', isFullInstall=' || rec.is_full_install
        || case when rec.is_revert_install = 1 then
            ', resultVersion="' || rec.result_version || '"'
          end
        || ', install_result_id=' || currentInstallResultId
        || ').'
    );
  end if;
exception when others then
  if sqlcode = pkg_ModuleInfoInternal.IllegalArgument_Error then
    raise;
  else
    raise_application_error(
      pkg_ModuleInfoInternal.ErrorStackInfo_Error
      , '������ ��� �������� ������ ��� ���������.'
      , true
    );
  end if;
end checkInstallVersion;


/* func: createInstallResult
  ��������� ��������� ��������� ��� �������� �� ��������� ������.

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
  hostProcessStartTime        - ����� ������ ���������� ��������, � �������
                                ����������� �������� ( ����������� ���������
                                ����� �� �����)
  hostProcessId               - ������������� �������� �� �����, � �������
                                ����������� ��������
  moduleVersion               - ������ ������ ( ��������, "1.1.0")
  actionGoalList              - ���� ���������� �������� �� ��������� ������
                                ( ������ � ��������� � �������� �����������)
  actionOptionList            - ��������� �������� �� ��������� ������
                                ( ������ � ��������� � �������� �����������)
  svnPath                     - ���� � Subversion, �� �������� ���� ��������
                                ����� ������ ( ������� � ����� �����������,
                                null � ������ ���������� ����������)
  svnVersionInfo              - ���������� � ������ ������ ������ �� Subversion
                                ( � ������� ������ ������� svnversion,
                                null � ������ ���������� ����������)
  modulePartNumber            - ����� ��������������� ����� ������
                                ( �� ��������� ����� �������� �����)
  installVersion              - ��������������� ������
  installTypeCode             - ��� ���� ���������
  isFullInstall               - ���� ������ ��������� ( 1 ��� ������ ���������,
                                0 ��� ��������� ����������)
  isRevertInstall             - ���� ���������� ������ ��������� ������
                                ( 1 ������ ��������� ������, 0 ��������� ������
                                ( �� ���������))
  installUser                 - ��� ������������, ��� ������� �����������
                                ��������� ( �� ��������� �������)
  installDate                 - ���� ���������� ��������� ( �� ���������
                                �������)
  objectSchema                - �����, � ������� ����������� ������� ������
                                ����� ������ ( �� ��������� ��������� �
                                installUser, null ���� � ��� ������� sys ���
                                system)
  privsUser                   - ��� ������������ ��� ����, ��� �������
                                ����������� ��������� ���� ������� ( ��������
                                ������ ���� ������� ������ ��� ��������� ����
                                �������)
  installScript               - ��������� ������������ ������ ( �����
                                �������������, ���� ������������� �����������
                                �������, �������� run.sql)
  resultVersion               - ������, ������������ ���������� ����������
                                ���������, ������ ���� ����������� ������� ���
                                ������ ��������� ���������� ( �� ���������
                                installVersion � ������ ���������, null �
                                ������ ������ ������ ���������)

  �������:
  Id ����������� ������ ( ���� install_result_id ������� <mod_install_result>).

  ���������:
  - ������, ��������� � resultVersion, ���������� ������� �������������
    �������;
*/
function createInstallResult(
  moduleSvnRoot varchar2
  , moduleInitialSvnPath varchar2
  , hostProcessStartTime timestamp with time zone
  , hostProcessId integer
  , moduleVersion varchar2
  , actionGoalList varchar2
  , actionOptionList varchar2
  , svnPath varchar2 := null
  , svnVersionInfo varchar2 := null
  , modulePartNumber integer
  , installVersion varchar2
  , installTypeCode varchar2
  , isFullInstall integer
  , isRevertInstall integer := null
  , installUser varchar2 := null
  , installDate date := null
  , objectSchema varchar2 := null
  , privsUser varchar2 := null
  , installScript varchar2 := null
  , resultVersion varchar2 := null
)
return integer
is

  -- ������ ����������� ������
  rec mod_install_result%rowtype;



  /*
    ���������� ���� ������� ������ � ����� ������������� ������, ��� ����
    ������ �������������� ����������� � ������������ ������� ��������
    ����������.
  */
  procedure clearCurrentVersion
  is

    cursor curCurrentVersion is
      select
        ir.is_current_version
      from
        mod_install_result ir
      where
        ir.is_current_version = 1
        and ir.module_part_id = rec.module_part_id
        and ir.install_type_code = rec.install_type_code
        and (
          coalesce( ir.object_schema, rec.object_schema) is null
          or ir.object_schema is not null
            and rec.object_schema is not null
            and ir.object_schema = rec.object_schema
          )
        and (
          coalesce( ir.privs_user, rec.privs_user) is null
          or ir.privs_user is not null
            and rec.privs_user is not null
            and ir.privs_user = rec.privs_user
          )
      for update of ir.is_current_version wait 5
    ;

  --clearCurrentVersion
  begin
    for cv in curCurrentVersion loop
      update
        mod_install_result ir
      set
        ir.is_current_version = 0
      where current of curCurrentVersion;
    end loop;
  exception when others then
    raise_application_error(
      pkg_ModuleInfoInternal.ErrorStackInfo_Error
      , '������ ��� ������ ����� ������� ������ � ������������ ������.'
      , true
    );
  end clearCurrentVersion;



  /*
    ��������� ������ ��� ���������� ���������.
  */
  procedure addInstallResult
  is
  begin
    insert into
      mod_install_result
    values
      rec
    returning install_result_id into rec.install_result_id;
  exception when others then
    raise_application_error(
      pkg_ModuleInfoInternal.ErrorStackInfo_Error
      , '������ ��� ���������� ������ ��� ���������� ���������.'
      , true
    );
  end addInstallResult;



-- createInstallResult
begin
  fillInstallResult(
    rec                       => rec
    , moduleSvnRoot           => moduleSvnRoot
    , moduleInitialSvnPath    => moduleInitialSvnPath
    , modulePartNumber        => modulePartNumber
    , installVersion          => installVersion
    , installTypeCode         => installTypeCode
    , isFullInstall           => isFullInstall
    , isRevertInstall         => isRevertInstall
    , installUser             => installUser
    , objectSchema            => objectSchema
    , privsUser               => privsUser
    , installScript           => installScript
    , resultVersion           => resultVersion
    , isCreateModule          => 1
  );
  rec.install_date := coalesce( installDate, sysdate);
  rec.is_current_version := 1;
  if hostProcessStartTime is not null or hostProcessId is not null
      or moduleVersion is not null or actionGoalList is not null
      or actionOptionList is not null
      or svnPath is not null or svnVersionInfo is not null
      then
    rec.install_action_id := getInstallAction(
      hostProcessStartTime  => hostProcessStartTime
      , hostProcessId       => hostProcessId
      , moduleId            => rec.module_id
      , moduleVersion       => moduleVersion
      , installVersion      => installVersion
      , actionGoalList      => actionGoalList
      , actionOptionList    => actionOptionList
      , svnPath             => svnPath
      , svnVersionInfo      => svnVersionInfo
    );
    rec.install_action_module_id := rec.module_id;
  end if;
  clearCurrentVersion();
  addInstallResult();
  return rec.install_result_id;
end createInstallResult;

end pkg_ModuleInstall;
/
