-- script: oms-run.sql
-- Выполняет SQL-скрипт.
-- Предназначен для использования вместо стандартной команды SQL*Plus "@@" и
-- работает аналогично этой команде с дополнительным выводом информации о
-- выполняемом скрипте, а также игнорированием выполнения скриптов, подпадающих
-- под значение масок игнорируемых файлов <SKIP_FILE_MASK> и не подпадающих под
-- <FILE_MASK> в случае задания.
--
-- Информация о выполняемом скрипте выводится в виде строки
-- "<scriptPath>: ...", где scriptPath - путь к выполняемому скрипту
-- относительно текущего каталога ( каталог DB). Если в присутствует только имя
-- файла, то это означает, что скрипт находится в текущем каталоге ( DB), либо
-- в каталоге поиска скриптов по умолчанию ( переменная окружения SQLPATH,
-- используется для OMS-скриптов).  Если скрипт не выполняется в связи со
-- значением <SKIP_FILE_MASK>, то ничего не выводится ( точнее, выводится
-- пустая строка, которая не попадает в лог).
--
--
-- Параметры:
-- scriptFile                 - скрипт для выполнения ( без пути, если скрипт
--                              расположен в том же каталоге, что и текущий
--                              файл, либо с путем относительно текущего
--                              каталога SQL*PLus ( DB))
-- ...                        - параметры скрипта ( максимум 9 параметров)
--
-- Замечания:
--  - прикладной скрипт, предназначен для вызова из пользовательских скриптов;
--  - начальные и конечные пробелы в параметре scriptFile игнорируются, в
--    случае указания пустого значения никакие действия не выполняются
--    ( без вывода каких-либо сообщений);
--  - для запуска файлов, находящихся непосредственно в текущем каталоге
--    SQL*Plus либо в каталогах для поиска файлов по-умолчанию ( SQL-скрипты,
--    входящие в состав OMS) нужно использовать путь "./", например "@oms-run
--    ./oms-refresh-mview mv_test";
--  - если путь к выполняемому скрипту начинается с префикса "./oms-", то
--    считается, что скрипт входит в состав OMS и для его вызова явно
--    подставляется полный путь к каталогу SQL-скриптов OMS, чтобы исключить
--    вызов одноименного скрипта из текущего каталога SQL*Plus;
--  - при использовании вместо команды "@" в случае, если скрипт для
--    выполнения был указан без пути, нужно добавить путь "./", иначе скрипт
--    будет искаться в каталоге файла, из которого выполняется вызов;
--  - в случае, если данный скрипт используется из скрипта, который был запущен
--    из другого скрипта командой "@" либо "@@" с указанием пути, возникнет
--    ошибка из-за отсутствия файла ( для него будет подразумеваться каталог
--    первого выполняемого скрипта); Для исключения ошибки желательно
--    использовать данный скрипт везде вместо команд "@" и "@@".
--  - для исключения выполнения OMS-скриптов следует использовать в
--    <SKIP_FILE_MASK> маску "*/<fileName>", например "*/oms-gather-stats.sql";
--  - в случае установки в 1 значения bind-переменной oms_is_save_install_info
--    в БД автоматически сохраняется информация о вызываемых SQL-скриптах,
--    при этом в соответствующих переменных должны быть указаны параметры
--    выполняемой установки ( подробнее см. <oms-load>);
--
-- Пример: ( шаблонный файл DB/Install/Schema/N.N.N/run.sql):
-- в основном файле:
--
-- (code)
--
-- @oms-set-indexTablespace.sql
--
-- @@test_table.sql
--
-- @Install/Schema/Last/new_table.tab
-- @Install/Schema/Last/new_table.con
--
-- @oms-refresh-mview.sql test_mview
--
-- (end)
--
-- вместо стандартных команд "@@" и "@" используем
-- данный скрипт:
--
-- (code)
--
-- @oms-set-indexTablespace.sql
--
-- @oms-run.sql test_table.sql
--
-- @oms-run.sql Install/Schema/Last/new_table.tab
-- @oms-run.sql Install/Schema/Last/new_table.con
--
-- -- Добавляем "./", т.к. вызываемый скрипт расположен не в каталоге
-- -- скрипта, из которого выполняется вызов
-- @oms-run.sql ./oms-refresh-mview.sql test_mview
--
-- (end)
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

  -- Script to run ( mixed path)
  scriptFile varchar2( 1000) := trim( replace( :oms_run_script, '\', '/'));

  -- Stack of running files
  runFileStack varchar2( 4000) := :oms_run_file_stack;

  -- List of SQL-masks of files (separated by commas)
  fileMaskList varchar2( 2000) :=
    translate( :oms_file_mask, ' *?', ',%_')
  ;

  -- List of SQL masks of ignored files (separated by commas)
  skipMaskList varchar2( 2000) :=
    translate( :oms_skip_file_mask, ' *?', ',%_')
  ;


  -- The original script file (the path relative to the DB directory or
  -- SqlScript for the OMS SQL scripts), if from is different from scriptFile
  scriptSourceFile varchar2( 1000);

  -- The script refers to OMS
  isOmsScript boolean := false;



  /*
    Specifies the path to the script for execution and defines its parameters.
  */
  procedure FixScriptPath
  is

    -- The initial position of the path to the current executable file
    iStart binary_integer;

    -- Separator position after path
    iEnd binary_integer;

  begin

    -- If no path is specified, then substitute the path to the directory of
    -- the executed file
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

    -- Adding a standard extension
    if instr( scriptFile, '.') = 0 then
      scriptFile := scriptFile || '.sql';
    end if;
  end FixScriptPath;



  /*
    Specifies whether to run the file according to the file masks
    (OMS_SKIP_FILE_MASK, OMS_FILE_MASK).
  */
  function IsAllowRun
  return boolean
  is

    /*
      Specifies the name of the script to match the list of masks
    */
    function isOfMask(
      maskList varchar2
    )
    return boolean
    is

      listLen binary_integer;

      -- The initial position of the mask
      iStart binary_integer;

      -- The position of the separator after the mask
      iEnd binary_integer;

    begin

      -- Loop through skipMaskList
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
    Saves information about the beginning of the installation of the nested
    file
  */
  procedure SaveNestedFileStart
  is

    installFileId integer;

    fileObjectName varchar2(128);
    fileObjectType varchar2(30);



    /*
      Specifies the name and type of the database object to which the file
      belongs.
    */
    procedure getFileObject
    is

      -- The position of the last slash on the path to the script
      lastSlashPos pls_integer;

      -- The position of the last point in the path to the script
      lastPeriodPos pls_integer;

      -- File extension (last, without a period)
      fileExtension varchar2(30);

      -- The current position for parsing an item
      pos pls_integer;

      -- The position behind the found list item
      endPos pls_integer;



      function getNextField
      return varchar2
      is

        pos1 pls_integer;
        pos2 pls_integer;

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



    -- getFileObject
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
      , 'OMS: Error while saving from oms-run.sql information about beginning'
        || ' of installation of nested file.'
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
    -- Calling nothing doing a script to avoid SQL * Plus warnings
    :oms_run_script := :oms_script_dir || '/OmsInternal/nothing.sql';
    :oms_run_info := '';
    :oms_run_file_stack := runFileStack || ',';
  end if;
end;
/

-- Set the macro variables
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

-- Perform the shift of the arguments
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

-- Run the script
prompt &oms_run_info

@&oms_run_script


-- Restore oms_run_file_stack
set feedback off

declare



  /*
    Saves information about the finishing of the installation of the nested
    file
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
      , 'OMS: Error while saving from oms-run.sql information about finishing'
        || ' of installation of nested file.'
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
