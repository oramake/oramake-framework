-- script: OmsInternal/start-install-file.sql
-- Сохраняет информацию о начале установки файла в БД.
-- Для сохранения информации вызывается процедура StartInstallFile пакета
-- pkg_ModuleInstall ( модуль Oracle/Module/ModuleInfo).
--
-- Скрипт вызывается автоматически при загрузке файла через <oms-load> с
-- помощью SQL*Plus в случае необходимости сохранения информации об установке
-- файлов ( см. <OMS_SAVE_FILE_INSTALL_INFO>).
--
-- Замечания:
--  - внутренний скрипт, используется внутри OMS;
--

set feedback off

declare
  installFileId integer;
begin
  execute immediate '
begin
  :installFileId := pkg_ModuleInstall.StartInstallFile(
    moduleSvnRoot               => :oms_module_svn_root
    , moduleInitialSvnPath      => :oms_module_initial_svn_path
    , moduleVersion             => :oms_module_version
    , installVersion            => :oms_module_install_version
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
    , filePath                  => :oms_source_file
    , fileModuleSvnRoot         => :oms_file_module_svn_root
    , fileModuleInitialSvnPath  => :oms_file_module_initial_svn_pa
    , fileModulePartNumber      => :oms_file_module_part_number
    , fileObjectName            => :oms_file_object_name
    , fileObjectType            => :oms_file_object_type
  );
end;
'
  using
    out installFileId
    , in :oms_module_svn_root
    , in :oms_module_initial_svn_path
    , in :oms_module_version
    , in :oms_module_install_version
    , in :oms_process_start_time
    , in :oms_process_id
    , in :oms_action_goal_list
    , in :oms_action_option_list
    , in :oms_svn_file_path
    , in :oms_svn_version_info
    , in :oms_source_file
    , in :oms_file_module_svn_root
    , in :oms_file_module_initial_svn_pa
    , in :oms_file_module_part_number
    , in :oms_file_object_name
    , in :oms_file_object_type
  ;
exception when others then
  raise_application_error(
    -20001
    , 'OMS: Ошибка при сохранении информации о начале установки файла в БД'
      || ' ( скрипт OmsInternal/start-install-file.sql).'
    , true
  );
end;
/

set feedback on
