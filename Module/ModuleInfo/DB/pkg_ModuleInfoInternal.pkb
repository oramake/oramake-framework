create or replace package body pkg_ModuleInfoInternal is
/* package body: pkg_ModuleInfoInternal::body */



/* group: Переменные */

/* ivar: isAccessOperatorFound
  Признак доступности модуля AccessOperator.
*/
isAccessOperatorFound boolean := null;



/* group: Функции */

/* func: compareVersion
  Сравнивает номера версий.

  Параметры:
  version1                    - Первый номер версии
  version2                    - Второй номер версии

  Возврат:
  -  -1 если version1 < version2
  -   0 если version1 = version2
  -   1 если version1 > version2
  - null если version1 или version2 имеют значение null

  Замечания:
  - номера версий, отличающиеся лишь нулевыми подномерами, считаются равными,
    например, "1.0" и "1.00" и "1.0.0" равны;
*/
function compareVersion(
  version1 varchar2
  , version2 varchar2
)
return integer
is

  -- Длина строк с версиями
  len1 integer := length( version1);
  len2 integer := length( version2);
  maxLength integer := greatest( len1, len2);

  -- Результат сравнения
  res integer;

  beg1 integer := 1;
  end1 integer;
  beg2 integer := 1;
  end2 integer;



  /*
    Сравнивает две строки.
  */
  function compareString(
    str1 varchar2
    , str2 varchar2
  )
  return integer
  is
  begin
    return
      case
        when str1 < str2 then
         -1
        when str1 > str2 then
          1
        else
          0
      end
    ;
  end compareString;



-- compareVersion
begin
  if maxLength is not null then
    res := 0;
    loop
      end1 := instr( version1 || '.', '.', beg1);
      end2 := instr( version2 || '.', '.', beg2);
      res := compareString(
        lpad(
            coalesce( substr( version1, beg1, end1 - beg1), '0')
            , maxLength
            , '0'
          )
        , lpad(
            coalesce( substr( version2, beg2, end2 - beg2), '0')
            , maxLength
            , '0'
          )
      );
      exit when res != 0;
      beg1 := end1 + 1;
      beg2 := end2 + 1;
      if beg1 > len1 or beg2 > len2 then
        res :=
          case
            when beg2 <= len2
                and ltrim( substr( version2, beg2), '.0') is not null
              then -1
            when beg1 <= len1
                and ltrim( substr( version1, beg1), '.0') is not null
              then 1
            else
              0
          end
        ;
        exit;
      end if;
    end loop;
  end if;
  return res;
exception when others then
  raise_application_error(
    pkg_ModuleInfoInternal.ErrorStackInfo_Error
    , 'Ошибка при сравнении версий ('
      || ' version1="' || version1 || '"'
      || ', version2="' || version2 || '"'
      || ').'
    , true
  );
end compareVersion;

/* func: getCurrentOperatorId
  Возвращает Id текущего зарегистрированного оператора при доступности модуля
  AccessOperator.

  Возврат:
  Id текущего оператора либо null в случае недоступности модуля AccessOperator.

  Замечания:
  - в случае доступности модуля AccessOperator и отсутствия текущего
    зарегистрированного оператора выбрасывается исключение;
*/
function getCurrentOperatorId
return integer
is

  -- Id текущего оператора
  operatorId integer := null;

--getCurrentOperatorId
begin
  if coalesce( isAccessOperatorFound, true) then
    execute immediate
      'begin :operatorId := pkg_Operator.getCurrentUserId; end;'
    using
      out operatorId
    ;
  end if;
  return operatorId;
exception when others then
  if isAccessOperatorFound is null
      and (
        -- PLS-00201: identifier 'PKG_OPERATOR' must be declared
        sqlerrm like
          '%PLS-00201: % ''PKG_OPERATOR'' %'
        -- PLS-00201: identifier 'PKG_OPERATOR.%' must be declared
        or sqlerrm like
          '%PLS-00201: % ''PKG_OPERATOR.%'' %'
        -- PLS-00904: insufficient privilege to access object %.PKG_OPERATOR%
        or sqlerrm like
          '%PLS-00904: % %.PKG_OPERATOR%'
        -- ORA-06508: PL/SQL: could not find program unit being called:%
        or sqlerrm like
          '%ORA-06508: %:%'
        -- PLS-00302: component 'GETCURRENTUSERID' must be declared
        or sqlerrm like
          '%PLS-00302: % ''GETCURRENTUSERID'' %'
      )
      then
    isAccessOperatorFound := false;
    return null;
  else
    raise_application_error(
      ErrorStackInfo_Error
      , 'Ошибка при определении Id текущего зарегистрированного оператора.'
      , true
    );
  end if;
end getCurrentOperatorId;

/* func: getModuleId
  Возвращает Id модуля.

  Параметры:
  svnRoot                     - путь к корневому каталогу модуля в Subversion
                                ( начиная с имени репозитария, например
                                "Oracle/Module/ModuleInfo")
  initialSvnPath              - первоначальный путь к корневому каталогу
                                модуля в Subversion ( начиная с имени
                                репозитария и влючая номер правки, в которой
                                он был создан, например
                                "Oracle/Module/ModuleInfo@711")
  isCreate                    - создать запись в случае отсутствия подходящей
                                ( 1 да, 0 нет ( по умолчанию))
  operatorId                  - Id оператора, выполняющего операцию
                                ( по умолчанию текущий)

  Возврат:
  Id модуля ( значение module_id из таблицы <mod_module>) либо null если
  запись не найдена и не указан isCreate = 1.

  Замечания:
  - для поиска модуля должно быть указано отличное от null значение svnRoot
    либо initialSvnPath, при этом в случае указания initialSvnPath значение
    svnRoot игнорируется, регистр значений указанных параметров для поиска
    несущественен;
*/
function getModuleId(
  svnRoot varchar2
  , initialSvnPath varchar2
  , isCreate integer := null
  , operatorId integer := null
)
return integer
is

  -- Id модуля
  moduleId mod_module.module_id%type;

  -- Первоначальный корневой каталог
  initialSvnRoot mod_module.initial_svn_root%type;

  -- Правка, в которой был создан первоначальный каталог
  initialSvnRevision mod_module.initial_svn_revision%type;

  -- Путь к корневому каталогу модуля, указанный в таблице
  moduleSvnRoot mod_module.svn_root%type;



  /*
    Выполняет разбор значения параметра initialSvnPath.
  */
  procedure parseInitialSvnPath
  is

    -- Позиция разделителя в пути
    iSplit pls_integer;

  begin
    if initialSvnPath is not null then
      iSplit := instr( initialSvnPath, '@');
      if iSplit > 1 then
        initialSvnRoot := substr( initialSvnPath, 1, iSplit - 1);
        initialSvnRevision := to_number( substr( initialSvnPath, iSplit + 1));
      end if;
      if initialSvnRoot is null or initialSvnRevision is null then
        raise_application_error(
          pkg_ModuleInfoInternal.IllegalArgument_Error
          , 'Некорректный первоначальный путь к корневому каталогу модуля,'
            || ' нужно указать значение в формате'
            || ' "<repositoryName>/<path>@<revision>".'
        );
      end if;
    end if;
  exception when others then
    raise_application_error(
      pkg_ModuleInfoInternal.ErrorStackInfo_Error
      , 'Ошибка при разборе значения параметра initialSvnPath.'
      , true
    );
  end parseInitialSvnPath;



  /*
    Выполняет поиск модуля.
  */
  procedure findModule
  is
  begin
    if coalesce( svnRoot, initialSvnPath) is null then
      raise_application_error(
        pkg_ModuleInfoInternal.IllegalArgument_Error
        , 'Не указаны параметры модуля.'
      );
    end if;

    select
      max( md.module_id)
      , max( md.svn_root)
    into moduleId, moduleSvnRoot
    from
      mod_module md
    where
      initialSvnPath is not null
        and upper( md.initial_svn_root) = upper( initialSvnRoot)
        and md.initial_svn_revision = initialSvnRevision
      or initialSvnPath is null
        and upper( md.svn_root) = upper( svnRoot)
    ;

    -- Поиск по initial_svn_root на случай переименования модуля
    -- ( если нет неоднозначности)
    if moduleId is null and initialSvnPath is null then
      select
        max( md.module_id)
        , max( md.svn_root)
      into moduleId, moduleSvnRoot
      from
        mod_module md
      where
        upper( md.initial_svn_root) = upper( svnRoot)
      having
        count(*) = 1
      ;
    end if;
  exception when others then
    raise_application_error(
      pkg_ModuleInfoInternal.ErrorStackInfo_Error
      , 'Ошибка при поиске модуля.'
      , true
    );
  end findModule;



  /*
    Создает запись для модуля в таблице mod_module.
  */
  procedure createModule
  is
  begin
    insert into
      mod_module
    (
      svn_root
      , initial_svn_root
      , initial_svn_revision
      , operator_id
    )
    values
    (
      coalesce( svnRoot, initialSvnRoot)
      , initialSvnRoot
      , initialSvnRevision
      , operatorId
    )
    returning module_id into moduleId;
  exception when others then
    raise_application_error(
      pkg_ModuleInfoInternal.ErrorStackInfo_Error
      , 'Ошибка при создании записи для модуля ('
        || ' initialSvnRoot="' || initialSvnRoot || '"'
        || ', initialSvnRevision=' || to_char( initialSvnRevision)
        || ').'
      , true
    );
  end createModule;



  /*
    Обновляет корневой каталог модуля в таблице mod_module.
  */
  procedure updateSvnRoot
  is
  begin
    update
      mod_module md
    set
      md.svn_root = svnRoot
    where
      md.module_id = moduleId
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
      , 'Ошибка при обновлении корневого каталога в записи для модуля ('
        || ' module_id=' || to_char( moduleId)
        || ').'
      , true
    );
  end updateSvnRoot;



--getModuleId
begin
  parseInitialSvnPath();
  findModule();
  if isCreate = 1 then
    if moduleId is null then
      createModule();
    elsif initialSvnPath is not null
        and nullif( svnRoot, moduleSvnRoot) is not null
        then
      updateSvnRoot();
    end if;
  end if;
  return moduleId;
exception when others then
  raise_application_error(
    pkg_ModuleInfoInternal.ErrorStackInfo_Error
    , 'Ошибка при определении Id прикладного модуля ('
      || ' svnRoot="' || svnRoot || '"'
      || ', initialSvnPath="' || initialSvnPath || '"'
      || case when isCreate is not null then
          ', isCreate=' || isCreate
        end
      || ').'
    , true
  );
end getModuleId;

end pkg_ModuleInfoInternal;
/
