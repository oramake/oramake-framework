--script: oms-run.sql
--Выполняет SQL-скрипт.
--Предназначен для использования вместо стандартной команды SQL*Plus "@@" и
--работает аналогично этой команде с дополнительным выводом информации о
--выполняемом скрипте, а также игнорированием выполнения скриптов, подпадающих
--под значение масок игнорируемых файлов <SKIP_FILE_MASK> и не подпадающих под
--<FILE_MASK> в случае задания.
--
--Информация о выполняемом скрипте выводится в виде строки
--"<scriptPath>: ...", где scriptPath - путь к выполняемому скрипту
--относительно текущего каталога ( каталог DB). Если в присутствует только имя
--файла, то это означает, что скрипт находится в текущем каталоге ( DB), либо
--в каталоге поиска скриптов по умолчанию ( переменная окружения SQLPATH,
--используется для OMS-скриптов).  Если скрипт не выполняется в связи со
--значением <SKIP_FILE_MASK>, то ничего не выводится ( точнее, выводится
--пустая строка, которая не попадает в лог).
--
--
--Параметры:
--scriptFile                  - скрипт для выполнения ( без пути, если скрипт
--                              расположен в том же каталоге, что и текущий
--                              файл, либо с путем относительно текущего
--                              каталога SQL*PLus ( DB))
--...                         - параметры скрипта ( максимум 9 параметров)
--
--Замечания:
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
--Пример: ( шаблонный файл DB/Install/Schema/N.N.N/run.sql):
--в основном файле:
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
--вместо стандартных команд "@@" и "@" используем
--данный скрипт:
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
--                                      --Добавляем "./", т.к. вызываемый
--                                      --скрипт расположен не в каталоге
--                                      --скрипта, из которого выполняется
--                                      --вызов
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

  -- Скрипт для выполнения ( mixed путь)
  scriptFile varchar2( 1000) := trim( replace( :oms_run_script, '\', '/'));

  -- Стек выполняемых файлов
  runFileStack varchar2( 4000) := :oms_run_file_stack;

  -- Список SQL-масок файлов ( через запятую)
  fileMaskList varchar2( 2000) :=
    translate( :oms_file_mask, ' *?', ',%_')
  ;

  -- Список SQL-масок игнорируемых файлов ( через запятую)
  skipMaskList varchar2( 2000) :=
    translate( :oms_skip_file_mask, ' *?', ',%_')
  ;


  -- Исходный файл скрипта ( путь относительно каталога DB либо SqlScript
  -- для SQL-скриптов OMS), если от отличается от scriptFile
  scriptSourceFile varchar2( 1000);

  -- Скрипт относится к OMS
  isOmsScript boolean := false;



  /*
    Уточняет путь к скрипту для выполнения и определяет его параметры.
  */
  procedure FixScriptPath
  is

    -- Начальная позиция пути к текущему выполняемому файлу
    iStart binary_integer;

    -- Позиция разделителя после пути
    iEnd binary_integer;

  begin

    -- Если не указан путь, то подставляем путь к каталогу загружаемого файла
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

    -- Добавляем стандартное расширение
    if instr( scriptFile, '.') = 0 then
      scriptFile := scriptFile || '.sql';
    end if;
  end FixScriptPath;



  /*
    Определяет необходимость выполнения файла с учетом масок файлов (
    OMS_SKIP_FILE_MASK, OMS_FILE_MASK).
  */
  function IsAllowRun
  return boolean
  is

    /*
      Определяет соотвествие имени скрипта списку масок
    */
    function isOfMask(
      maskList varchar2
    )
    return boolean
    is
      -- Длина списка
      listLen binary_integer;

      -- Начальная позиция маски
      iStart binary_integer;

      -- Позиция разделителя после маски
      iEnd binary_integer;

    begin
      -- Цикл по маскам skipMaskList
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
    Сохраняет информацию о начале установки вложенного файла.
  */
  procedure SaveNestedFileStart
  is

    installFileId integer;

    fileObjectName varchar2(128);
    fileObjectType varchar2(30);



    /*
      Определяет имя и тип объекта БД, к которому относится файл.
    */
    procedure getFileObject
    is

      -- Позиция последнего слэша в пути к скрипту
      lastSlashPos pls_integer;

      -- Позиция последней точки в пути к скрипту
      lastPeriodPos pls_integer;

      -- Расширение файла ( последнее, без точки)
      fileExtension varchar2(30);

      -- Текущая позиция для разбора элемента
      pos pls_integer;

      -- Позиция за найденным элементом списка
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
      , 'OMS: Ошибка при сохранении из oms-run.sql информации о начале'
        || ' установки вложенного файла.'
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
    -- Вызываем ничего не делающий скрипт, чтобы избежать вывода предупреждения
    -- SQL*Plus
    :oms_run_script := :oms_script_dir || '/OmsInternal/nothing.sql';
    :oms_run_info := '';
    :oms_run_file_stack := runFileStack || ',';
  end if;
end;
/

-- Устанавливаем макропеременные
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

-- Выполняем сдвиг аргументов
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

-- Выполняем скрипт
prompt &oms_run_info

@&oms_run_script


-- Восстанавливаем oms_run_file_stack
set feedback off

declare



  /*
    Сохраняет информацию о завершении установки вложенного файла.
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
      , 'OMS: Ошибка при сохранении из oms-run.sql информации о завершении'
        || ' установки вложенного файла.'
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
