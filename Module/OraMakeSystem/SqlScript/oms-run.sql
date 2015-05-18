--script: oms-run.sql
--��������� SQL-������.
--������������ ��� ������������� ������ ����������� ������� SQL*Plus "@@" �
--�������� ���������� ���� ������� � �������������� ������� ���������� �
--����������� �������, � ����� �������������� ���������� ��������, �����������
--��� �������� ����� ������������ ������ <SKIP_FILE_MASK> � �� ����������� ���
--<FILE_MASK> � ������ �������.
--
--���������� � ����������� ������� ��������� � ���� ������
--"<scriptPath>: ...", ��� scriptPath - ���� � ������������ �������
--������������ �������� �������� ( ������� DB). ���� � ������������ ������ ���
--�����, �� ��� ��������, ��� ������ ��������� � ������� �������� ( DB), ����
--� �������� ������ �������� �� ��������� ( ���������� ��������� SQLPATH,
--������������ ��� OMS-��������).  ���� ������ �� ����������� � ����� ��
--��������� <SKIP_FILE_MASK>, �� ������ �� ��������� ( ������, ���������
--������ ������, ������� �� �������� � ���).
--
--
--���������:
--scriptFile                  - ������ ��� ���������� ( ��� ����, ���� ������
--                              ���������� � ��� �� ��������, ��� � �������
--                              ����, ���� � ����� ������������ ��������
--                              �������� SQL*PLus ( DB))
--...                         - ��������� ������� ( �������� 9 ����������)
--
--���������:
--  - ���������� ������, ������������ ��� ������ �� ���������������� ��������;
--  - ��������� � �������� ������� � ��������� scriptFile ������������, �
--    ������ �������� ������� �������� ������� �������� �� �����������
--    ( ��� ������ �����-���� ���������);
--  - ��� ������� ������, ����������� ��������������� � ������� ��������
--    SQL*Plus ���� � ��������� ��� ������ ������ ��-��������� ( SQL-�������,
--    �������� � ������ OMS) ����� ������������ ���� "./", �������� "@oms-run
--    ./oms-refresh-mview mv_test";
--  - ���� ���� � ������������ ������� ���������� � �������� "./oms-", ��
--    ���������, ��� ������ ������ � ������ OMS � ��� ��� ������ ����
--    ������������� ������ ���� � �������� SQL-�������� OMS, ����� ���������
--    ����� ������������ ������� �� �������� �������� SQL*Plus;
--  - ��� ������������� ������ ������� "@" � ������, ���� ������ ���
--    ���������� ��� ������ ��� ����, ����� �������� ���� "./", ����� ������
--    ����� �������� � �������� �����, �� �������� ����������� �����;
--  - � ������, ���� ������ ������ ������������ �� �������, ������� ��� �������
--    �� ������� ������� �������� "@" ���� "@@" � ��������� ����, ���������
--    ������ ��-�� ���������� ����� ( ��� ���� ����� ��������������� �������
--    ������� ������������ �������); ��� ���������� ������ ����������
--    ������������ ������ ������ ����� ������ ������ "@" � "@@".
--  - ��� ���������� ���������� OMS-�������� ������� ������������ �
--    <SKIP_FILE_MASK> ����� "*/<fileName>", �������� "*/oms-gather-stats.sql";
--  - � ������ ��������� � 1 �������� bind-���������� oms_is_save_install_info
--    � �� ������������� ����������� ���������� � ���������� SQL-��������,
--    ��� ���� � ��������������� ���������� ������ ���� ������� ���������
--    ����������� ��������� ( ��������� ��. <oms-load>);
--
--������: ( ��������� ���� DB/Install/Schema/N.N.N/run.sql):
--� �������� �����:
--
--(code)
--
--@oms-set-indexTablespace.sql
--
--@@test_table.sql
--
--@Install/Schema/Last/new_table.tab
--@Install/Schema/Last/new_table.con
--
--@oms-refresh-mview.sql test_mview
--
--(end)
--
--������ ����������� ������ "@@" � "@" ����������
--������ ������:
--
--(code)
--
--@oms-set-indexTablespace.sql
--
--@oms-run.sql test_table.sql
--
--@oms-run.sql Install/Schema/Last/new_table.tab
--@oms-run.sql Install/Schema/Last/new_table.con
--
--                                      --��������� "./", �.�. ����������
--                                      --������ ���������� �� � ��������
--                                      --�������, �� �������� �����������
--                                      --�����
--@oms-run.sql ./oms-refresh-mview.sql test_mview
--
--(end)
--

define oms_run_script = ""
define oms_run_info = ""

set feedback off
set heading off

var oms_run_script varchar2(1000)
var oms_run_info varchar2(1000)


begin
  :oms_run_script := '&1';
end;
/

declare

  -- ������ ��� ���������� ( mixed ����)
  scriptFile varchar2( 1000) := trim( replace( :oms_run_script, '\', '/'));

  -- ���� ����������� ������
  runFileStack varchar2( 4000) := :oms_run_file_stack;

  -- ������ SQL-����� ������ ( ����� �������)
  fileMaskList varchar2( 2000) :=
    translate( :oms_file_mask, ' *?', ',%_')
  ;

  -- ������ SQL-����� ������������ ������ ( ����� �������)
  skipMaskList varchar2( 2000) :=
    translate( :oms_skip_file_mask, ' *?', ',%_')
  ;


  -- �������� ���� ������� ( ���� ������������ �������� DB ���� SqlScript
  -- ��� SQL-�������� OMS), ���� �� ���������� �� scriptFile
  scriptSourceFile varchar2( 1000);

  -- ������ ��������� � OMS
  isOmsScript boolean := false;



  /*
    �������� ���� � ������� ��� ���������� � ���������� ��� ���������.
  */
  procedure FixScriptPath
  is

    -- ��������� ������� ���� � �������� ������������ �����
    iStart binary_integer;

    -- ������� ����������� ����� ����
    iEnd binary_integer;

  begin

    -- ���� �� ������ ����, �� ����������� ���� � �������� ������������ �����
    if instr( scriptFile, '/') = 0 then
      iStart := instr( runFileStack, ',', -1) + 1;
      iEnd := instr( runFileStack, '/', -1);
      if iEnd >= iStart then
        scriptFile :=
          substr( runFileStack, iStart, iEnd - iStart + 1)
          || scriptFile
        ;
      end if;
    elsif scriptFile like './oms-%' then
      scriptSourceFile := substr( scriptFile, 3);
      scriptFile := :oms_script_dir || '/' || scriptSourceFile;
      isOmsScript := true;
    elsif scriptFile like :oms_script_dir || '/oms-%' then
      scriptSourceFile := substr( scriptFile, length( :oms_script_dir) + 2);
      isOmsScript := true;
    elsif substr( scriptFile, 1, 2) = './' then
      scriptFile := substr( scriptFile, 3);
    end if;

    -- ��������� ����������� ����������
    if instr( scriptFile, '.') = 0 then
      scriptFile := scriptFile || '.sql';
    end if;
  end FixScriptPath;



  /*
    ���������� ������������� ���������� ����� � ������ ����� ������ (
    OMS_SKIP_FILE_MASK, OMS_FILE_MASK).
  */
  function IsAllowRun
  return boolean
  is

    /*
      ���������� ����������� ����� ������� ������ �����
    */
    function isOfMask(
      maskList varchar2
    )
    return boolean
    is
      -- ����� ������
      listLen binary_integer;

      -- ��������� ������� �����
      iStart binary_integer;

      -- ������� ����������� ����� �����
      iEnd binary_integer;

    begin
      -- ���� �� ������ skipMaskList
      iStart := 1;
      listLen := length( maskList);
      while iStart < listLen loop
        iEnd := instr( maskList, ',', iStart);
        if iEnd = 0 then
          iEnd := listLen + 1;
        end if;
        if iStart < iEnd then
          if scriptFile like substr( maskList, iStart, iEnd - iStart) then
            return true;
          end if;
        end if;
        iStart := iEnd + 1;
      end loop;
      return false;
    end isOfMask;

  begin
    return
      not isOfMask( skipMaskList)
      and
      (
        trim( fileMaskList) is null
        or isOfMask( fileMaskList)
      )
     ;
  end IsAllowRun;



  /*
    ��������� ���������� � ������ ��������� ���������� �����.
  */
  procedure SaveNestedFileStart
  is

    installFileId integer;

    fileObjectName varchar2(128);
    fileObjectType varchar2(30);



    /*
      ���������� ��� � ��� ������� ��, � �������� ��������� ����.
    */
    procedure getFileObject
    is

      -- ������� ���������� ����� � ���� � �������
      lastSlashPos pls_integer;

      -- ������� ��������� ����� � ���� � �������
      lastPeriodPos pls_integer;

      -- ���������� ����� ( ���������, ��� �����)
      fileExtension varchar2(30);

      -- ������� ������� ��� ������� ��������
      pos pls_integer;

      -- ������� �� ��������� ��������� ������
      endPos pls_integer;



      function getNextField
      return varchar2
      is

        pos1 pls_integer;
        pos2 pls_integer;

      --getNextField
      begin
        if pos >= endPos then
          return null;
        else
          pos1 := pos;
          pos2 := least( instr( :oms_file_extension_list, ':', pos1), endPos);
          if pos2 = 0 then
            pos2 := endPos;
          end if;
          pos := pos2 + 1;
          return substr( :oms_file_extension_list, pos1, pos2 - pos1);
        end if;
      end getNextField;



    --getFileObject
    begin
      lastSlashPos := instr( scriptFile, '/', -1);
      lastPeriodPos := instr( scriptFile, '.', -1);
      if lastPeriodPos > 1 and lastPeriodPos > lastSlashPos then
        fileExtension := substr( scriptFile, lastPeriodPos + 1, 10);
        pos :=
          instr(
            ',' || :oms_file_extension_list || ','
            , ',' || fileExtension || ':'
          )
          - 1
        ;
        if pos >= 0 then
          pos := pos + 2 + length( fileExtension);
          endPos := instr( :oms_file_extension_list || ',', ',', pos);
          fileObjectType := getNextField();
          if fileObjectType is not null then
            fileObjectName :=
              substr(
                scriptFile
                , lastSlashPos + 1
                , lastPeriodPos - lastSlashPos - 1
              )
            ;
            if getNextField() = 'u' then
              fileObjectName := upper( fileObjectName);
            end if;
          end if;
        end if;
      end if;
    end getFileObject;



  --SaveNestedFileStart
  begin
    if not isOmsScript then
      getFileObject;
    end if;
    execute immediate '
begin
  :installFileId := pkg_ModuleInstall.StartInstallNestedFile(
    filePath                    => :scriptSourceFile
    , fileModuleSvnRoot         => :fileModuleSvnRoot
    , fileModuleInitialSvnPath  => :fileModuleInitialSvnPath
    , fileModulePartNumber      => :oms_file_module_part_number
    , fileObjectName            => :fileObjectName
    , fileObjectType            => :fileObjectType
  );
end;
'
    using
      out installFileId
      , in coalesce( scriptSourceFile, scriptFile)
      , in case when isOmsScript then :oms_svn_root end
      , in case when isOmsScript then :oms_initial_svn_path end
      , in case when isOmsScript then 1 end
      , in fileObjectName
      , in fileObjectType
    ;
  exception when others then
    raise_application_error(
      -20001
      , 'OMS: ������ ��� ���������� �� oms-run.sql ���������� � ������'
        || ' ��������� ���������� �����.'
      , true
    );
  end SaveNestedFileStart;



begin
  FixScriptPath();
  if scriptFile is not null and IsAllowRun() then
    :oms_run_script := scriptFile;
    :oms_run_info := coalesce( scriptSourceFile, scriptFile) || ': ...';
    :oms_run_file_stack := runFileStack || ',' || scriptFile;
    if :oms_is_save_install_info = 1 then
      SaveNestedFileStart;
    end if;
  else
    -- �������� ������ �� �������� ������, ����� �������� ������ ��������������
    -- SQL*Plus
    :oms_run_script := :oms_script_dir || '/OmsInternal/nothing.sql';
    :oms_run_info := '';
    :oms_run_file_stack := runFileStack || ',';
  end if;
end;
/

-- ������������� ���������������
column oms_run_script new_value oms_run_script format A1000 noprint
column oms_run_info new_value oms_run_info format A1000 noprint

select
  :oms_run_script as oms_run_script
  , :oms_run_info as oms_run_info
from
  dual
/

column oms_run_script clear
column oms_run_info clear

set heading on
set feedback on

-- ��������� ����� ����������
define 1 = "&2"
define 2 = "&3"
define 3 = "&4"
define 4 = "&5"
define 5 = "&6"
define 6 = "&7"
define 7 = "&8"
define 8 = "&9"
define 9 = "&10"
define 10 = ""

-- ��������� ������
prompt &oms_run_info

@&oms_run_script


-- ��������������� oms_run_file_stack
set feedback off

declare



  /*
    ��������� ���������� � ���������� ��������� ���������� �����.
  */
  procedure SaveNestedFileFinish is
  begin
    execute immediate '
begin
  pkg_ModuleInstall.FinishInstallNestedFile;
end;
'
    ;
  exception when others then
    raise_application_error(
      -20001
      , 'OMS: ������ ��� ���������� �� oms-run.sql ���������� � ����������'
        || ' ��������� ���������� �����.'
      , true
    );
  end;



begin
  if substr( :oms_run_file_stack, -1) <> ','
      and :oms_is_save_install_info = 1
      then
    SaveNestedFileFinish;
  end if;
  :oms_run_file_stack :=
    substr( :oms_run_file_stack, 1, instr( :oms_run_file_stack, ',', -1) - 1)
  ;
end;
/

set feedback on



undefine oms_run_info
undefine oms_run_script
