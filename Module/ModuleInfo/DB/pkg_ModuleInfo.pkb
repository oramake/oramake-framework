create or replace package body pkg_ModuleInfo is
/* package body: pkg_ModuleInfo::body */



/* group: Функции */



/* group: Модуль в БД */

/* func: getModuleId
  Получение id модуля.


  Параметры:
  findModuleString            - строка для поиска модуля (
                                может совпадать с одним из трёх атрибутов
                                модуля: названием, путём к корневому каталогу,
                                первоначальным путём к корневому каталогу в
                                Subversion)
  moduleName                  - название модуля ( например "ModuleInfo")
  svnRoot                     - путь к корневому каталогу модуля в Subversion
                                ( начиная с имени репозитария, например
                                "Oracle/Module/ModuleInfo")
  initialSvnPath              - первоначальный путь к корневому каталогу
                                модуля в Subversion ( начиная с имени
                                репозитария и влючая номер правки, в которой
                                он был создан, например
                                "Oracle/Module/ModuleInfo@711")
  raiseExceptionFlag          - выбрасывать ли исключение если модуль не найден
                                ( по-умолчанию 1-выбрасывать);

  Возврат:
  Id модуля ( значение module_id из таблицы <mod_module>) либо null если
  запись не найдена и raiseExceptionFlag = 0.
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

  -- Найденный id модуля
  moduleId integer;

  -- Количество найденных модулей
  foundModuleCount integer;

-- getModuleId
begin
  -- Если есть поиск по первоначальному пути в SVN
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
        , 'Первоначальный путь не соответствуют строке для поиска модуля'
      );
    end if;
    moduleId := pkg_ModuleInfoInternal.getModuleId(
      svnRoot => null
      , initialSvnPath => coalesce( initialSvnPath, findModuleString)
    );
  end if;
  -- Если задан хотя бы один параметр - не первоначальный путь модуля в SVN
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
      -- Проверяем соотвествие уже найденному модулю
      (
        moduleId is not null
        and module_id = moduleId
        or
        moduleId is null
      )
      -- Проверяем имя модуля
      and (
        moduleName is not null
        and upper( module_name) = upper( moduleName)
        or
        moduleName is null
      )
      -- Проверяем корневой каталог в SVN
      and (
        svnRoot is not null
        and upper( svn_root) = upper( svnRoot)
        or
        svnRoot is null
      )
      -- Проверяем строку поиска
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
        , 'Найдено более одного модуля с указанными параметрами поиска'
      );
    end if;
  end if;
  if coalesce( raiseExceptionFlag, 1) = 1 and moduleId is null then
    raise_application_error(
      pkg_ModuleInfoInternal.ProcessError_Error
      , 'Модуль не найден'
    );
  end if;
  return
    moduleId
  ;
exception when others then
  raise_application_error(
    pkg_ModuleInfoInternal.ErrorStackInfo_Error
    , 'Ошибка получения id модуля ('
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
  Возвращает установленную в БД версию модуля.
  При определении версии учитываются только версии объектов схемы основных
  частей модулей.

  Параметры:
  svnRoot                     - путь к корневому каталогу модуля в Subversion
                                ( начиная с имени репозитария, например
                                "Oracle/Module/ModuleInfo")
  initialSvnPath              - первоначальный путь к корневому каталогу
                                модуля в Subversion ( начиная с имени
                                репозитария и влючая номер правки, в которой
                                он был создан, например
                                "Oracle/Module/ModuleInfo@711")
  mainObjectSchema            - схема, в которой расположены объекты основной
                                части модуля ( необходимо указывать в случае
                                наличия установок в разные схемы)

  Возврат:
  номер установленной версии либо null при отсутствии данных по установке.

  Замечания:
  - должен быть указано отлично от null значение svnRoot либо initialSvnPath,
    при этом в случае указания initialSvnPath значение svnRoot игнорируется;
  - регистр значений параметров несущественен;
*/
function getInstallModuleVersion(
  svnRoot varchar2 := null
  , initialSvnPath varchar2 := null
  , mainObjectSchema varchar2 := null
)
return varchar2
is

  -- Текущая версия
  currentVersion v_mod_install_module.current_version%type;

  -- Число подходящих установок
  nFound integer;

  -- Id модуля
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
      , 'Невозможно определить версию, т.к. найдено несколько установок'
        || ' модуля ('
        || ' nFound=' || nFound
        || ').'
    );
  end if;
  return currentVersion;
exception when others then
  raise_application_error(
    pkg_ModuleInfoInternal.ErrorStackInfo_Error
    , 'Ошибка при определении установленной версии модуля.'
    , true
  );
end getInstallModuleVersion;



/* group: Установка приложений */

/* ifunc: getDeployment
  Возвращает Id окружения для развертывания приложений.
  Выполняет поиск модуля в таблице <mod_deployment>, в случае отсутствия
  подходящей записи она добавляется.

  Параметры:
  deploymentPath              - путь для развертывания приложения
  operatorId                  - Id оператора, выполняющего операцию
                                ( по умолчанию текущий)

  Возврат:
  Id записи ( значение deployment_id из таблицы <mod_deployment>);
*/
function getDeployment(
  deploymentPath varchar2
  , operatorId integer := null
)
return integer
is

  -- Id записи
  deploymentId mod_deployment.deployment_id%type;



  /*
    Добавляет запись в таблицу mod_deployment.
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
      , 'Ошибка при добавлении записи.'
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
    , 'Ошибка при определении Id окружения для развертывания приложений ('
      || ' deploymentPath="' || deploymentPath || '"'
      || ').'
    , true
  );
end getDeployment;

/* func: getAppInstallVersion
  Возвращает установленную версию приложения.

  Параметры:
  deploymentPath              - путь для развертывания приложения
  svnRoot                     - путь к корневому каталогу модуля в Subversion
                                ( начиная с имени репозитария, например
                                "Oracle/Module/ModuleInfo")
  initialSvnPath              - первоначальный путь к корневому каталогу
                                модуля в Subversion ( начиная с имени
                                репозитария и влючая номер правки, в которой
                                он был создан, например
                                "Oracle/Module/ModuleInfo@711")

  Возврат:
  номер установленной версии либо null при отсутствии данных по установке.

  Замечания:
  - должен быть указано отлично от null значение svnRoot либо initialSvnPath,
    при этом в случае указания initialSvnPath значение svnRoot игнорируется;
  - регистр значений параметров несущественен;
*/
function getAppInstallVersion(
  deploymentPath varchar2
  , svnRoot varchar2 := null
  , initialSvnPath varchar2 := null
)
return varchar2
is

  -- Текущая версия
  currentVersion v_mod_app_install_version.current_version%type;

  -- Id модуля
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
    , 'Ошибка при определении установленной версии приложения.'
    , true
  );
end getAppInstallVersion;

/* iproc: clearCurrentVersion
  Сбрасывает флаг текущей версии у ранее установленной версии, при этом
  запись предварительно блокируется с ограничением времени ожидания
  блокировки.

  Параметры:
  moduleId                    - Id модуля
  deploymentId                - Id окружения для развертывания приложений
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
    , 'Ошибка при сбросе флага текущей версии у существующей записи ('
      || ' moduleId=' || moduleId
      || ', deploymentId=' || deploymentId
      || ').'
    , true
  );
end clearCurrentVersion;

/* func: startAppInstall
  Сохраняет информацию о начале установки приложения.
  Функция должна вызываться перед началом установки приложения, при этом после
  завершения установки приложения ( с успешным либо неуспешным результатом)
  должна быть вызвана функция <finishAppInstall>.

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
  deploymentPath              - путь для развертывания приложения
  installVersion              - устанавливаемая версия приложения
  svnPath                     - путь в Subversion, из которого были получены
                                файлы модуля ( начиная с имени репозитария,
                                null в случае отсутствия информации)
  svnVersionInfo              - информация о версии файлов модуля из Subversion
                                ( в формате вывода утилиты svnversion,
                                null в случае отсутствия информации)
  operatorId                  - Id оператора, выполняющего операцию
                                ( по умолчанию текущий)

  Возврат:
  Id добавленной записи ( поле app_install_result_id таблицы
  <mod_app_install_result>).

  Замечания:
  - при вызове функции очищается информация о текущей установленной версией
    приложения, т.к. считается, что ранее установленная версия приложения
    деинсталлируется перед установкой новой версии;
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

  -- Данные добавляемой записи
  rec mod_app_install_result%rowtype;



  /*
    Добавляет запись для результата установки приложения.
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
      , 'Ошибка при добавлении записи ('
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
    , 'Ошибка при сохранении информации о начале установки приложения.'
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
  Сохраняет информацию о завершении установки приложения.

  Параметры:
  appInstallResultId          - Id записи о начале установки приложения,
                                который был возвращен функцией <startAppInstall>
  statusCode                  - Код результата выполнения установки
                                ( 0 означает отсутствие ошибок, при этом
                                  устанавливаемая версия становится текущей)
  errorMessage                - Текст сообщения об ошибках при выполнении
                                установки
                                ( сохраняются первые 4000 символов)
                                ( по умолчанию отсутствует)
  installDate                 - Дата завершения установки ( по умолчанию
                                текущая)
  operatorId                  - Id оператора, выполняющего операцию
                                ( по умолчанию текущий)

  Замечания:
  - параметр javaReturnCode является устаревшим и временно сохранен для
    обеспечения совместимости, вместо него следует использовать statusCode;
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

  -- Текущие данные записи об установке
  rec mod_app_install_result%rowtype;

  -- Флаг текущей версии
  isCurrentVersion mod_app_install_result.is_current_version%type;

  -- Код результата выполнения установки ( с учетом использования
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

  -- Перед установкой флага текущей версии проверяем и сбрасываем флаг текущей
  -- версии у других записей ( может быть существенно в случае параллельной
  -- установки версии одного приложения)
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
    , 'Ошибка при сохранении информации о завершении установки приложения ('
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
  Устаревшая функция, будет удалена ( вместо нее следует использовать пару
  функций <startAppInstall> и <finishAppInstall>).
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

  -- Id добавленной записи
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
    , 'Ошибка при добавлении результата установки приложения.'
    , true
  );
end createAppInstallResult;

end pkg_ModuleInfo;
/
