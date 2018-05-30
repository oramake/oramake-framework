-- script: OmsInternal/install-version-operation.sql
-- Проверяет возможность выполнения либо сохраняет информацию о действии по
-- установке модуля.
-- При этом вызываются соответствующие функции пакета pkg_ModuleInstall (модуль
-- Oracle/Module/ModuleInfo, checkInstallVersion для проверки,
-- createInstallResult для сохранения).
--
-- Требования:
-- установка в БД модуля ModuleInfo версии 1.3.0;
--
-- Параметры:
-- modulePartNumberList       - список номеров частей модулей в виде строки с
--                              разделителем ":"
-- installVersion             - устанавливаемая версия модуля ( по умолчанию из
--                              oms_module_install_version)
-- installTypeCode            - код типа установки
-- isFullInstall              - флаг полной установки ( 1 при полной установке,
--                              0 при установке обновления) ( по умолчанию из
--                              oms_is_full_module_install)
-- isRevertInstall            - флаг выполнения отмены установки версии
-- resultVersion              - номер версии модуля, получаемой в БД в
--                              результате выполнения действия ( требуется в
--                              случае отмены установки обновления)
-- installScript              - стартовый установочный скрипт ( если возможно
--                              использование различных скриптов для получения
--                              различных результатов, например, при выдаче
--                              прав)
-- privsUser                  - пользователь, для которого выполняется
--                              настройка прав доступа ( в случае установки
--                              прав доступа)
-- isCheckOnly                - только проверка возможности выполнения
--                              (1 проверка, иначе сохранение (по умолчанию))
--
--
-- Замечания:
--  - внутренний скрипт, используется внутри OMS;
--

set feedback off

declare
  modulePartNumberList varchar2(100);
  installVersion varchar2(30);
  installTypeCode varchar2(10);
  isFullInstall integer;
  isRevertInstall integer;
  resultVersion varchar2(100);
  installScript varchar2(255);
  privsUser varchar2(100);
  isCheckOnly integer;

  modulePartNumber integer;
  installResultId integer;

  -- variables for parsing the list
  iStart pls_integer := 1;
  len pls_integer;



  /*
    Selects the next part number of the module from the list.
  */
  procedure setPartNumber
  is

    isFirstPart boolean := iStart = 1;

    iEnd pls_integer;

  begin
    if len is null then
      len := coalesce( length( modulePartNumberList), 0);
    end if;
    if iStart <= len then
      iEnd := instr( modulePartNumberList, ':', iStart);
      if iEnd = 0 then
        iEnd := len + 1;
      end if;
      modulePartNumber := to_number(
        substr( modulePartNumberList, iStart, iEnd - iStart)
      );
      iStart := iEnd + 1;
    else
      modulePartNumber := null;
    end if;
    if isFirstPart and modulePartNumber is null then
      raise_application_error(
        -20195
        , 'Part number of module is not specified.'
      );
    end if;
  end setPartNumber;



  /*
    Execute pkg_ModuleInstall.checkInstallVersion.
  */
  procedure checkInstallVersion
  is
  begin
    execute immediate '
begin
  pkg_ModuleInstall.checkInstallVersion(
    moduleSvnRoot               => :oms_module_svn_root
    , moduleInitialSvnPath      => :oms_module_initial_svn_path
    , modulePartNumber          => :modulePartNumber
    , installVersion            => :installVersion
    , installTypeCode           => :installTypeCode
    , isFullInstall             => :isFullInstall
    , isRevertInstall           => :isRevertInstall
    , resultVersion             => :resultVersion
    , installScript             => :installScript
    , privsUser                 => :privsUser
  );
end;
'
    using
      in :oms_module_svn_root
      , in :oms_module_initial_svn_path
      , in modulePartNumber
      , in installVersion
      , in installTypeCode
      , in isFullInstall
      , in isRevertInstall
      , in resultVersion
      , in installScript
      , in privsUser
    ;
  end checkInstallVersion;



  /*
    Execute pkg_ModuleInstall.createInstallResult.
  */
  procedure createInstallResult
  is
  begin
    execute immediate '
begin
  :installResultId := pkg_ModuleInstall.createInstallResult(
    moduleSvnRoot               => :oms_module_svn_root
    , moduleInitialSvnPath      => :oms_module_initial_svn_path
    , moduleVersion             => :oms_module_version
    , hostProcessStartTime      =>
        to_timestamp_tz(
          :oms_process_start_time
          , ''yyyy-mm-dd"T"hh24:mi:sstzhtzm''
        )
    , hostProcessId             => :oms_process_id
    , actionGoalList            => :oms_action_goal_list
    , actionOptionList          => :oms_action_option_list
    , svnPath                   => :oms_svn_file_path
    , svnVersionInfo            => :oms_svn_version_info
    , modulePartNumber          => :modulePartNumber
    , installVersion            => :installVersion
    , installTypeCode           => :installTypeCode
    , isFullInstall             => :isFullInstall
    , isRevertInstall           => :isRevertInstall
    , resultVersion             => :resultVersion
    , installScript             => :installScript
    , privsUser                 => :privsUser
  );
end;
'
    using
      out installResultId
      , in :oms_module_svn_root
      , in :oms_module_initial_svn_path
      , in :oms_module_version
      , in :oms_process_start_time
      , in :oms_process_id
      , in :oms_action_goal_list
      , in :oms_action_option_list
      , in :oms_svn_file_path
      , in :oms_svn_version_info
      , in modulePartNumber
      , in installVersion
      , in installTypeCode
      , in isFullInstall
      , in isRevertInstall
      , in resultVersion
      , in installScript
      , in privsUser
    ;
  end createInstallResult;



-- main
begin
  modulePartNumberList  := '&1';
  installVersion        := coalesce( '&2', :oms_module_install_version);
  installTypeCode       := '&3';
  isFullInstall         :=
    coalesce( to_number( trim( '&4')), :oms_is_full_module_install)
  ;
  isRevertInstall       := &5;
  resultVersion         := '&6';
  installScript         := '&7';
  privsUser             := '&8';
  isCheckOnly           := '&9';

  if isRevertInstall = 1 and :oms_is_full_module_install = 0
      and trim( resultVersion) is null
      then
    raise_application_error(
      -20195
      , 'UNINSTALL_RESULT_VERSION parameter must specify version of module'
        || ' that remains in database after uninstall current version.'
    );
  elsif installTypeCode = 'PRI' and trim( privsUser) is null then
    raise_application_error(
      -20195
      , 'TO_USERNAME parameter must specify username of database'
        || ' for configuring access rights.'
    );
  end if;

  loop
    setPartNumber();
    exit when modulePartNumber is null;
    if isCheckOnly = 1 then
      checkInstallVersion();
    else
      createInstallResult();
    end if;
  end loop;
exception when others then
  raise_application_error(
    -20150
    , 'OMS: Error while '
      || case when isCheckOnly = 1 then
          'checking version'
        else
          'adding installation result information'
        end
      || ' ('
      || ' script: OmsInternal/install-version-operation.sql'
      || ', modulePartNumberList="' || modulePartNumberList || '"'
      || ', installVersion="' || installVersion || '"'
      || ', installTypeCode="' || installTypeCode || '"'
      || ', isFullInstall=' || isFullInstall
      || ', isRevertInstall=' || isRevertInstall
      || ', resultVersion="' || resultVersion || '"'
      || ', installScript="' || installScript || '"'
      || ', privsUser="' || privsUser || '"'
      || ').'
    , true
  );
end;
/

set feedback on
