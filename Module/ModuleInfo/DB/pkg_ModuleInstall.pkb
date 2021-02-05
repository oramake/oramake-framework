create or replace package body pkg_ModuleInstall is
/* package body: pkg_ModuleInstall::body */



/* group: Типы */

/* itype: TColId
  Коллекция идентификаторов.
*/
type TColId is table of integer;



/* group: Константы */

/* iconst: Main_PartNumber
  Номер основной части модуля.
*/
Main_PartNumber constant integer := 1;



/* group: Переменные */

/* ivar: currentInstallFileId
  Id записи для текущего устанавливаемого файла верхнего уровня.
*/
currentInstallFileId mod_install_file.install_file_id%type;

/* ivar: currentInstallActionId
  Id записи для текущего действия по установке.
*/
currentInstallActionId mod_install_action.install_action_id%type;

/* ivar: currentModuleId
  Id модуля, к которому относится текущее действие по установке.
*/
currentModuleId mod_module.module_id%type;

/* ivar: currentFileModulePartNumber
  Номер части модуля, к которому относится текущий устанавливаемый файл
  верхнего уровня.
*/
currentFileModulePartNumber mod_module_part.part_number%type;

/* ivar: currentFileRunLevel
  Текущий вложенности текущего устанавливаемого файла.
*/
currentFileRunLevel mod_install_file.run_level%type;

/* ivar: colNestedInstallFileId
  Коллекция Id записей для текущих устанавливаемых вложенных файлов.
*/
colNestedInstallFileId TColId := TColId();




/* group: Функции */



/* group: Вспомогательные функции */

/* ifunc: getModulePart
  Возвращает Id части прикладного модуля.
  Выполняет поиск в таблице <mod_module_part>, в случае отсутствия подходящей
  записи она добавляется.

  Параметры:
  moduleId                    - Id модуля
  partNumber                  - номер части модуля
  isCreate                    - создать запись в случае отсутствия подходящей
                                ( 1 да, 0 нет ( по умолчанию))

  Возврат:
  Id части модуля
*/
function getModulePart(
  moduleId integer
  , partNumber integer
  , isCreate integer := null
)
return integer
is

  -- Id части модуля
  modulePartId mod_module_part.module_part_id%type;



  /*
    Создает запись для части модуля в таблице mod_module_part.
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
      , 'Ошибка при создании записи для части модуля.'
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
    , 'Ошибка при определении Id части модуля ('
      || ' moduleId=' || to_char( moduleId)
      || ' , partNumber=' || to_char( partNumber)
      || ').'
    , true
  );
end getModulePart;

/* ifunc: getInstallAction
  Возвращает Id действия по установке.
  Выполняет поиск в таблице <mod_install_action>, в случае отсутствия
  подходящей записи добавляет ее.

  Параметры:
  hostProcessStartTime        - время начала выполнения процесса, в котором
                                выполнялось действие ( указывается локальное
                                время на хосте)
  hostProcessId               - идентификатор процесса на хосте, в котором
                                выполнялось действие
  moduleId                    - Id модуля
  moduleVersion               - версия модуля ( например, "1.1.0")
  installVersion              - устанавливаемая версия модуля
  actionGoalList              - цели выполнения действия по установке модуля
                                ( список с пробелами в качестве разделителя)
  actionOptionList            - параметры действия по установке модуля
                                ( список с пробелами в качестве разделителя)
  svnPath                     - путь в Subversion, из которого были получены
                                файлы модуля ( начиная с имени репозитария)
  svnVersionInfo              - информация о версии файлов модуля из Subversion
                                ( в формате вывода утилиты svnversion)

  Возврат:
  Id действия по установке ( значение install_action_id из таблицы
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

  -- Id действия по установке
  installActionId mod_install_action.install_action_id%type;

  -- Хост текущей сессии
  sessionHost mod_install_action.host%type;



  /*
    Создает запись для действия по установке.
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
      , 'Ошибка при создании записи для действия по установке.'
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
    , 'Ошибка при определении Id действия по установке ('
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
  Возвращает Id исходного файла.
  Выполняет поиск в таблице <mod_source_file>, в случае отсутствия
  подходящей записи добавляет ее.

  Параметры:
  moduleId                    - Id модуля
  filePath                    - путь к файлу
  modulePartNumber            - номер части модуля, к которой относится файл
                                ( по умолчанию не изменяется, а при добавлении
                                записи относится к основной части)
  objectName                  - имя объекта в БД, которому соответствует файл
  objectType                  - тип объекта в БД, которому соответствует файл

  Возврат:
  Id исходного файла ( значение source_file_id из таблицы <mod_source_file>).
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

  -- Id части модуля, к которой относится файл
  modulePartId mod_module_part.module_part_id%type;

  -- Id исходного файла
  sourceFileId mod_source_file.source_file_id%type;

  -- Id части модуля для файла, указанное в таблице
  lastModulePartId mod_source_file.module_part_id%type;

  -- Имя объекта для файла, указанное в таблице
  lastObjectName mod_source_file.object_name%type;

  -- Тип объекта для файла, указанный в таблице
  lastObjectType mod_source_file.object_type%type;



  /*
    Создает запись для исходного файла.
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
      , 'Ошибка при создании записи для исходного файла.'
      , true
    );
  end createSourceFile;



  /*
    Обновляет параметры файла.
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
        , 'Запись не найдена.'
      );
    end if;
  exception when others then
    raise_application_error(
      pkg_ModuleInfoInternal.ErrorStackInfo_Error
      , 'Ошибка при обновлении названия и типа объекта для файла ('
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
    , 'Ошибка при определении Id исходного файла ('
      || ' moduleId=' || to_char( moduleId)
      || ', filePath="' || filePath || '"'
      || ', objectName="' || objectName || '"'
      || ', objectType="' || objectType || '"'
      || ').'
    , true
  );
end getSourceFile;

/* iproc: checkUserExists
  Проверяет наличие пользователя в БД, если указано имя пользователя.

  Параметры:
  checkUserName             - имя пользователя ( без учета регистра)
  parameterName             - имя параметра функции ( для указания в
                              сообщении об ошибке).
*/
procedure checkUserExists(
  checkUserName varchar2
  , parameterName varchar2
)
is

  -- Флаг наличия пользователя
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
        , 'Указан несуществующий пользователь БД ('
          || ' ' || parameterName || '="' || checkUserName || '"'
          || ').'
      );
    end if;
  end if;
end checkUserExists;



/* group: Установка файлов */

/* ifunc: createInstallFile
  Создает запись об установке исходного файла.

  Параметры:
  installActionId             - Id действия по установке
  sourceFileId                - Id исходного файла
  runLevel                    - уровень вложенности выполняемого файла
                                ( 1 для файла верхнего уровня)

  Возврат:
  Id записи об установке файла.
*/
function createInstallFile(
  installActionId integer
  , sourceFileId integer
  , runLevel integer
)
return integer
is

  -- Id записи об установке файла
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
    , 'Ошибка при создании записи об установке файла ('
      || ' installActionId=' || to_char( installActionId)
      || ', sourceFileId=' || to_char( sourceFileId)
      || ', runLevel=' || to_char( runLevel)
      || ').'
    , true
  );
end createInstallFile;

/* func: startInstallFile
  Фиксирует начало установки файла.
  Вызывается перед установкой файла в той же сессии.

  Параметры:
  moduleSvnRoot               - путь к корневому каталогу устанавливаемого
                                модуля в Subversion ( начиная с имени
                                репозитария, например
                                "Oracle/Module/ModuleInfo")
  moduleInitialSvnPath        - первоначальный путь к корневому каталогу
                                устанавливаемого модуля в Subversion ( начиная
                                с имени репозитария и влючая номер правки, в
                                которой он был создан, например
                                "Oracle/Module/ModuleInfo@711")
  moduleVersion               - версия модуля ( например, "1.1.0")
  installVersion              - устанавливаемая версия модуля
  hostProcessStartTime        - время начала выполнения процесса, в котором
                                выполнялось действие ( указывается локальное
                                время на хосте)
  hostProcessId               - идентификатор процесса на хосте, в котором
                                выполнялось действие
  actionGoalList              - цели выполнения действия по установке модуля
                                ( список с пробелами в качестве разделителя)
  actionOptionList            - параметры действия по установке модуля
                                ( список с пробелами в качестве разделителя)
  svnPath                     - путь в Subversion, из которого были получены
                                файлы модуля ( начиная с имени репозитария,
                                null в случае отсутствия информации)
  svnVersionInfo              - информация о версии файлов модуля из Subversion
                                ( в формате вывода утилиты svnversion,
                                null в случае отсутствия информации)
  filePath                    - путь к устанавливаемому файлу
  fileModuleSvnRoot           - путь к корневому каталогу модуля, к которому
                                относится устанавливаемый файл, в Subversion
                                ( формат аналогичен параметру moduleSvnRoot,
                                по умолчанию считается, что файл относится к
                                устанавливаемому модулю)
  fileModuleInitialSvnPath    - первоначальный путь к корневому каталогу
                                модуля, к которому относится устанавливаемый
                                файл, в Subversion ( формат аналогичен
                                параметру moduleInitialSvnPath, по умолчанию
                                считается, что файл относится к
                                устанавливаемому модулю)
  fileModulePartNumber        - номер части модуля, к которой относится файл
                                ( по умолчанию не изменяется при наличии
                                записи в <mod_source_file>, а для новой
                                записи используется номер основной части)
  fileObjectName              - имя объекта в БД, которому соответствует файл
                                ( по умолчанию не соответствует объекту)
  fileObjectType              - тип объекта в БД, которому соответствует файл
                                ( по умолчанию не соответствует объекту)

  Возврат:
  Id для выполняемой установки файла ( значение install_file_id из таблицы
  <mod_install_file>).

  Замечания:
  - функция выполняется в автономной транзакции;
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

  -- Id устанавливаемого модуля
  moduleId mod_module.module_id%type;

  -- Id модуля устанавливаемого файла
  fileModuleId mod_module.module_id%type;

  -- Id действия по установке
  installActionId mod_install_action.install_action_id%type;

  -- Id установки файла
  installFileId mod_install_file.install_file_id%type;

--startInstallFile
begin
  if currentInstallFileId is not null then
    raise_application_error(
      pkg_ModuleInfoInternal.IllegalArgument_Error
      , 'В сессии уже выполняется установка другого файла ('
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
    , 'Ошибка при фиксации начала установки файла.'
    , true
  );
end startInstallFile;

/* iproc: UpdateInstallFile
  Обновляет данные об установке файле.

  Параметры:
  installFileId               - Id установки файла
  finishDate                  - дата завершения установки
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
      , 'Запись не найдена.'
    );
  end if;
exception when others then
  raise_application_error(
    pkg_ModuleInfoInternal.ErrorStackInfo_Error
    , 'Ошибка при обновлении данных об установке файла ('
      || ' installFileId=' || to_char( installFileId)
      || ').'
    , true
  );
end UpdateInstallFile;

/* proc: finishInstallFile
  Фиксирует завершение установки файла.
  Вызывается после завершения установки файла в той же сессии, при этом
  перед установкой должна быть вызвана процедура <startInstallFile>.

  Параметры:
  installFileId               - Id установки файла ( по умолчанию текущая)

  Замечания:
  - процедура выполняется в автономной транзакции;
*/
procedure finishInstallFile(
  installFileId integer := null
)
is

  pragma autonomous_transaction;

  -- Используемый Id установки файла
  usedInstallFileId integer := coalesce( installFileId, currentInstallFileId);

--finishInstallFile
begin
  if usedInstallFileId is null then
    raise_application_error(
      pkg_ModuleInfoInternal.ProcessError_Error
      , 'Нет данных по текущему устанавливаемому файлу.'
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
    , 'Ошибка при фиксации завершения установки файла ('
      || ' installFileId=' || to_char( installFileId)
      || ').'
    , true
  );
end finishInstallFile;

/* func: startInstallNestedFile
  Фиксирует начало установки вложенного файла.
  Предварительно в той же сессии должно быть зафиксировано начало установки
  файла верхнего уровня с помощью вызова функции <startInstallFile>.

  Параметры:
  filePath                    - путь к выполняемому файлу
  fileModuleSvnRoot           - путь к корневому каталогу модуля, к которому
                                относится выполняемый файл, в Subversion
                                ( формат аналогичен параметру moduleSvnRoot,
                                по умолчанию считается, что файл относится к
                                устанавливаемому модулю)
  fileModuleInitialSvnPath    - первоначальный путь к корневому каталогу
                                модуля, к которому относится выполняемый
                                файл, в Subversion ( формат аналогичен
                                параметру moduleInitialSvnPath, по умолчанию
                                считается, что файл относится к
                                устанавливаемому модулю)
  fileModulePartNumber        - номер части модуля, к которой относится файл
                                ( по умолчанию не изменяется при наличии
                                записи в <mod_source_file>, а для новой
                                записи используется номер части
                                устанавливаемого файла верхнего уровня если
                                он относится к тому же модулю, иначе номер
                                основной части)
  fileObjectName              - имя объекта в БД, которому соответствует файл
                                ( по умолчанию не соответствует объекту)
  fileObjectType              - тип объекта в БД, которому соответствует файл
                                ( по умолчанию не соответствует объекту)

  Возврат:
  Id записи, фиксирующей начало установки файла ( значение install_file_id из
  таблицы <mod_install_file>).

  Замечания:
  - функция выполняется в автономной транзакции;
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

  -- Id установки файла
  installFileId mod_install_file.install_file_id%type;

  -- Id модуля устанавливаемого файла
  fileModuleId mod_module.module_id%type;

--startInstallNestedFile
begin
  if currentInstallFileId is null then
    raise_application_error(
      pkg_ModuleInfoInternal.IllegalArgument_Error
      , 'В сессии не была начата установка файла верхнего уровня.'
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
    , 'Ошибка при фиксации начала установки вложенного файла.'
    , true
  );
end startInstallNestedFile;

/* proc: finishInstallNestedFile
  Фиксирует завершение установки вложенного файла.
  Вызывается после завершения установки вложенного файла в той же сессии, при
  этом перед началом выполнения вложенного файла должна быть вызвана функция
  <startInstallNestedFile>.

  Замечания:
  - процедура выполняется в автономной транзакции;
*/
procedure finishInstallNestedFile
is

  pragma autonomous_transaction;

--finishInstallNestedFile
begin
  if coalesce( currentFileRunLevel, 0) < 2 then
    raise_application_error(
      pkg_ModuleInfoInternal.ProcessError_Error
      , 'Нет данных по текущему устанавливаемому вложенному файлу.'
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
    , 'Ошибка при фиксации завершения установки вложенного файла.'
    , true
  );
end finishInstallNestedFile;



/* group: Результат установки */

/* iproc: fillInstallResult
  Заполняет основные поля записи о результате установки.

  Параметры:
  rec                         - данные записи
                                (возврат)
  moduleSvnRoot               - путь к корневому каталогу устанавливаемого
                                модуля в Subversion ( начиная с имени
                                репозитария, например
                                "Oracle/Module/ModuleInfo")
  moduleInitialSvnPath        - первоначальный путь к корневому каталогу
                                устанавливаемого модуля в Subversion ( начиная
                                с имени репозитария и влючая номер правки, в
                                которой он был создан, например
                                "Oracle/Module/ModuleInfo@711")
  modulePartNumber            - номер устанавливаемой части модуля
                                ( по умолчанию номер основной части)
  installVersion              - устанавливаемая версия
  installTypeCode             - код типа установки
  isFullInstall               - флаг полной установки ( 1 при полной установке,
                                0 при установке обновления)
  isRevertInstall             - флаг выполнения отмены установки версии
                                ( 1 отмена установки версии, 0 установка версии
                                ( по умолчанию))
  installUser                 - имя пользователя, под которым выполнялась
                                установка ( по умолчанию текущий)
  objectSchema                - схема, в которой расположены объекты данной
                                части модуля ( по умолчанию совпадает с
                                installUser, null если в нем указаны sys или
                                system)
  privsUser                   - имя пользователя или роли, для которой
                                выполнялась настройка прав доступа ( значение
                                должно быть указано только при установке прав
                                доступа)
  installScript               - стартовый установочный скрипт ( может
                                отсутствовать, если использовался тривиальный
                                вариант, например run.sql)
  resultVersion               - версия, получившаяся результате выполнения
                                установки, должна быть обязательно указана при
                                отмене установки обновления ( по умолчанию
                                installVersion в случае установки, null в
                                случае отмены полной установки)
  isCreateModule              - создать записи о модуле и части модуля в
                                случае отсутствия подходящих
                                ( 1 да, 0 нет ( по умолчанию))
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
    , 'Ошибка при заполнении записи с результатом установки.'
    , true
  );
end fillInstallResult;

/* func: checkInstallVersion
  Проверяет возможность установки на основе данных об установленной версии
  модуля.

  Параметры:
  moduleSvnRoot               - путь к корневому каталогу устанавливаемого
                                модуля в Subversion ( начиная с имени
                                репозитария, например
                                "Oracle/Module/ModuleInfo")
  moduleInitialSvnPath        - первоначальный путь к корневому каталогу
                                устанавливаемого модуля в Subversion ( начиная
                                с имени репозитария и влючая номер правки, в
                                которой он был создан, например
                                "Oracle/Module/ModuleInfo@711")
  modulePartNumber            - номер устанавливаемой части модуля
                                ( по умолчанию номер основной части)
  installVersion              - устанавливаемая версия
  installTypeCode             - код типа установки
  isFullInstall               - флаг полной установки ( 1 при полной установке,
                                0 при установке обновления)
  isRevertInstall             - флаг выполнения отмены установки версии
                                ( 1 отмена установки версии, 0 установка версии
                                ( по умолчанию))
  installUser                 - имя пользователя, под которым выполнялась
                                установка ( по умолчанию текущий)
  objectSchema                - схема, в которой расположены объекты данной
                                части модуля ( по умолчанию совпадает с
                                installUser, null если в нем указаны sys или
                                system)
  privsUser                   - имя пользователя или роли, для которой
                                выполнялась настройка прав доступа ( значение
                                должно быть указано только при установке прав
                                доступа)
  installScript               - стартовый установочный скрипт ( может
                                отсутствовать, если использовался тривиальный
                                вариант, например run.sql)
  resultVersion               - версия, получившаяся в результате выполнения
                                установки, должна быть обязательно указана при
                                отмене установки обновления ( по умолчанию
                                installVersion в случае установки, null в
                                случае отмены полной установки)
  overwriteCurrentVersionFlag - признак возможности перезаписи уже установленной текущей версии
                                (1 - да (по-умолчанию), 0 - нет)
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

  -- Данные версии для установки
  rec mod_install_result%rowtype;

  -- Текущая версия
  currentVersion mod_install_result.result_version%type;
  currentInstallResultId integer;

  -- Сообщение об ошибке
  erm varchar2(1000);

  -- Направление изменения версии в результате установки
  -- ( 1 - итоговая версия старше текущий, -1 - младше, 0 - та же)
  resultDirection integer;



  /*
    Получает информацию о текущей версии.
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
      , 'Ошибка при получении информации о текущей версии.'
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
        'Нет установленной версии '
        || case when rec.is_revert_install = 0 then
            'для обновления'
          else
            'для отката'
          end
      ;
    end if;
  elsif rec.is_revert_install = 1
        and rec.install_version <> currentVersion
        -- разрешаем откат к текущей версии
        and rec.result_version <> currentVersion
      then
    erm := 'Отменяемая версия не соответствует установленной';
  else
    resultDirection := pkg_ModuleInfoInternal.compareVersion(
      rec.result_version
      , currentVersion
    );
    erm := case
      when rec.is_revert_install = 0 and resultDirection = -1 then
        'Устанавливаемая версия младше, чем установленная ранее'
      when rec.is_revert_install = 0 and resultDirection = 0 and overwriteCurrentVersionFlag = 0 then
        'Запрошенная версия уже была установлена ранее'
      when rec.is_revert_install = 1 and resultDirection = 1 then
        'После отмены установки версии не можеть остаться более'
        || ' старшая версия'
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
      , 'Ошибка при проверке версии для установки.'
      , true
    );
  end if;
end checkInstallVersion;


/* func: createInstallResult
  Добавляет результат установки для действия по установке модуля.

  Параметры:
  moduleSvnRoot               - путь к корневому каталогу устанавливаемого
                                модуля в Subversion ( начиная с имени
                                репозитария, например
                                "Oracle/Module/ModuleInfo")
  moduleInitialSvnPath        - первоначальный путь к корневому каталогу
                                устанавливаемого модуля в Subversion ( начиная
                                с имени репозитария и влючая номер правки, в
                                которой он был создан, например
                                "Oracle/Module/ModuleInfo@711")
  hostProcessStartTime        - время начала выполнения процесса, в котором
                                выполнялось действие ( указывается локальное
                                время на хосте)
  hostProcessId               - идентификатор процесса на хосте, в котором
                                выполнялось действие
  moduleVersion               - версия модуля ( например, "1.1.0")
  actionGoalList              - цели выполнения действия по установке модуля
                                ( список с пробелами в качестве разделителя)
  actionOptionList            - параметры действия по установке модуля
                                ( список с пробелами в качестве разделителя)
  svnPath                     - путь в Subversion, из которого были получены
                                файлы модуля ( начиная с имени репозитария,
                                null в случае отсутствия информации)
  svnVersionInfo              - информация о версии файлов модуля из Subversion
                                ( в формате вывода утилиты svnversion,
                                null в случае отсутствия информации)
  modulePartNumber            - номер устанавливаемой части модуля
                                ( по умолчанию номер основной части)
  installVersion              - устанавливаемая версия
  installTypeCode             - код типа установки
  isFullInstall               - флаг полной установки ( 1 при полной установке,
                                0 при установке обновления)
  isRevertInstall             - флаг выполнения отмены установки версии
                                ( 1 отмена установки версии, 0 установка версии
                                ( по умолчанию))
  installUser                 - имя пользователя, под которым выполнялась
                                установка ( по умолчанию текущий)
  installDate                 - дата завершения установки ( по умолчанию
                                текущая)
  objectSchema                - схема, в которой расположены объекты данной
                                части модуля ( по умолчанию совпадает с
                                installUser, null если в нем указаны sys или
                                system)
  privsUser                   - имя пользователя или роли, для которой
                                выполнялась настройка прав доступа ( значение
                                должно быть указано только при установке прав
                                доступа)
  installScript               - стартовый установочный скрипт ( может
                                отсутствовать, если использовался тривиальный
                                вариант, например run.sql)
  resultVersion               - версия, получившаяся результате выполнения
                                установки, должна быть обязательно указана при
                                отмене установки обновления ( по умолчанию
                                installVersion в случае установки, null в
                                случае отмены полной установки)

  Возврат:
  Id добавленной записи ( поле install_result_id таблицы <mod_install_result>).

  Замечания:
  - версия, указанная в resultVersion, становится текущей установленной
    версией;
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

  -- Данные добавляемой записи
  rec mod_install_result%rowtype;



  /*
    Сбрасывает флаг текущей версии у ранее установленной версии, при этом
    запись предварительно блокируется с ограничением времени ожидания
    блокировки.
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
      , 'Ошибка при сбросе флага текущей версии у существующей записи.'
      , true
    );
  end clearCurrentVersion;



  /*
    Добавляет запись для результата установки.
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
      , 'Ошибка при добавлении записи для результата установки.'
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
