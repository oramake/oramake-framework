-- script: OmsInternal/add-install-result.sql
-- ��������� � �� ���������� � ���������� ��������� �������� �� ���������
-- ������.
-- ��� ���������� ���������� ���������� ������� createInstallResult
-- ������ pkg_ModuleInstall ( ������ Oracle/Module/ModuleInfo).
--
-- ���������:
-- modulePartNumberList       - ������ ������� ������ ������� � ���� ������ �
--                              ������������ ":"
-- installVersion             - ��������������� ������ ������ ( �� ��������� ��
--                              oms_module_install_version)
-- installTypeCode            - ��� ���� ���������
-- isFullInstall              - ���� ������ ��������� ( 1 ��� ������ ���������,
--                              0 ��� ��������� ����������) ( �� ��������� ��
--                              oms_is_full_module_install)
-- isRevertInstall            - ���� ���������� ������ ��������� ������
-- resultVersion              - ����� ������ ������, ���������� � �� �
--                              ���������� ���������� �������� ( ��������� �
--                              ������ ������ ��������� ����������)
-- installScript              - ��������� ������������ ������ ( ���� ��������
--                              ������������� ��������� �������� ��� ���������
--                              ��������� �����������, ��������, ��� ������
--                              ����)
-- privsUser                  - ������������, ��� �������� �����������
--                              ��������� ���� ������� ( � ������ ���������
--                              ���� �������)
--
--
-- ���������:
--  - ���������� ������, ������������ ������ OMS;
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

  modulePartNumber integer;
  installResultId integer;

  -- ���������� ��� ������� ������
  iStart pls_integer := 1;
  len pls_integer;



  /*
    �������� ��������� ����� ����� ������ �� ������.
  */
  procedure setPartNumber
  is

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
  end setPartNumber;



begin
  modulePartNumberList  := '&1';
  installVersion        := '&2';
  installTypeCode       := '&3';
  isFullInstall         := to_number( trim( '&4'));
  isRevertInstall       := &5;
  resultVersion         := '&6';
  installScript         := '&7';
  privsUser             := '&8';

  if isRevertInstall = 1 and :oms_is_full_module_install = 0
      and trim( resultVersion) is null
      then
    raise_application_error(
      -20195
      , '���������� � ��������� UNINSTALL_RESULT_VERSION ������� ������ ������,'
        || ' ������� �������� � �� ����� ������ ��������� ������� ������.'
    );
  elsif installTypeCode = 'PRI' and trim( privsUser) is null then
    raise_application_error(
      -20195
      , '���������� � ��������� TO_USERNAME ������� ��� ������������ ��,'
        || ' ��� �������� ����������� ��������� ���� �������.'
    );
  end if;

  loop
    setPartNumber();
    if modulePartNumber is null then
      -- ������ ��������� �������� ���������� ���� �� ���� ���
      if installResultId is null then
        raise_application_error(
          -20195
          , '�� ������ ����� ����� ������.'
        );
      end if;
      exit;
    end if;

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
    , installVersion            => :oms_module_install_version
    , installTypeCode           => :installTypeCode
    , isFullInstall             => :oms_is_full_module_install
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
      , in coalesce( installVersion, :oms_module_install_version)
      , in installTypeCode
      , in coalesce( isFullInstall, :oms_is_full_module_install)
      , in isRevertInstall
      , in resultVersion
      , in installScript
      , in privsUser
    ;
  end loop;
exception when others then
  raise_application_error(
    -20150
    , 'OMS: ������ ��� ���������� ���������� � ���������� ��������� ('
      || ' ������ OmsInternal/add-install-result.sql'
      || ' modulePartNumberList="' || modulePartNumberList || '"'
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
