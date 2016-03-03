create or replace package body pkg_Option is
/* package body: pkg_Option::body */



/* group: Переменные */

/* ivar: logger
  Логер пакета.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => Module_Name
  , objectName  => 'pkg_Option'
);



/* group: Функции */

/* iproc: checkRole
  Проверяет права на доступ к параметрам на основе выданных оператору ролей.

  Параметры:
  operatorId                  - Id оператора ( если null, то текущий
                                оператор)
  readOnlyAccessFlag          - проверять права доступа только на просмотр
                                данных ( 1 да, 0 нет ( по умолчанию))
*/
procedure checkRole(
  operatorId integer
  , readOnlyAccessFlag pls_integer := null
)
is

  -- Id оператора, права которого проверяются
  checkOperatorId integer;

  -- Результат проверки
  isOk integer;

begin
  checkOperatorId := coalesce( operatorId, pkg_Operator.getCurrentUserId());
  select
    count(*)
  into isOk
  from
    dual
  where
    exists
      (
      select
        null
      from
        v_op_operator_role opr
        inner join op_role rl
          on rl.role_id = opr.role_id
        cross join
          (
          select
            max( ov.string_value) as local_role_suffix
          from
            v_opt_option_value ov
          where
            ov.module_svn_root = pkg_OptionMain.Module_SvnRoot
            and ov.object_short_name is null
            and ov.option_short_name
              = pkg_OptionMain.LocalRoleSuffix_OptionSName
          ) opt
      where
        opr.operator_id = checkOperatorId
        and rl.short_name in (
          'GlobalOptionAdmin'
          , case when opt.local_role_suffix is not null then
              'OptAdminAllOption' || opt.local_role_suffix
            end
          , case when readOnlyAccessFlag = 1 then
              'OptShowAllOption'
            end
          , case when readOnlyAccessFlag = 1
                  and opt.local_role_suffix is not null
                then
              'OptShowAllOption' || opt.local_role_suffix
            end
        )
      )
  ;
  if isOk = 0 then
    raise_application_error(
      pkg_Error.ProcessError
      , 'У оператора нет прав на'
        || case when readOnlyAccessFlag = 1 then
            ' просмотр'
          else
            ' изменение'
          end
        || ' параметров ('
        || ' checkOperatorId=' || checkOperatorId
        || ').'
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при проверке прав доступа согласно выданным ролям ('
        || ' operatorId=' || operatorId
        || ', readOnlyAccessFlag=' || readOnlyAccessFlag
        || ').'
      )
    , true
  );
end checkRole;



/* group: Настроечные параметры */

/* func: createOption
  Создает настроечный параметр и задает для него используемое в текущей БД
  значение.

  Параметры:
  moduleId                    - Id модуля, к которому относится параметр
  objectShortName             - короткое название объекта модуля
                                ( по умолчанию отсутствует)
  objectTypeId                - Id типа объекта
                                ( по умолчанию отсутствует)
  optionShortName             - короткое название параметра
  valueTypeCode               - код типа значения параметра
  valueListFlag               - флаг задания для параметра списка значений
                                указанного типа ( 1 да, 0 нет ( по умолчанию))
  encryptionFlag              - флаг хранения значений параметра в
                                зашифрованном виде
                                ( 1 да, 0 нет ( по умолчанию))
  testProdSensitiveFlag       - флаг указания для значения параметра типа базы
                                данных ( тестовая или промышленная), для
                                которого оно предназначено
                                ( 1 да, 0 нет ( по умолчанию))
  optionName                  - название параметра
  optionDescription           - описание параметра
                                ( по умолчанию отсутствует)
  dateValue                   - значение типа дата
                                ( по умолчанию отсутствует)
  numberValue                 - числовое значение
                                ( по умолчанию отсутствует)
  stringValue                 - строковое значение
                                ( по умолчанию отсутствует)
  stringListSeparator         - символ, используемый в качестве разделителя в
                                строке со списком строковых значений
                                ( по умолчанию используется ";")
  checkRoleFlag               - проверять наличие у оператора прав для
                                выполнения операции
                                ( 1 да ( по умолчанию), 0 нет)
  operatorId                  - Id оператора ( по умолчанию текущий)

  Возврат:
  Id параметра.

  Замечания:
  - в случае, если используется список значений, указанное в параметрах
    функции значение сохраняется как первое значение списка;
  - параметр checkRoleFlag используется при вызове функции из интерфейсных
    функций других модулей ( в которых реализована собственная система прав
    доступа) и не должен использоваться из интерфейса модуля;
*/
function createOption(
  moduleId integer
  , objectShortName varchar2 := null
  , objectTypeId varchar2 := null
  , optionShortName varchar2
  , valueTypeCode varchar2
  , valueListFlag integer := null
  , encryptionFlag integer := null
  , testProdSensitiveFlag integer := null
  , optionName varchar2
  , optionDescription varchar2 := null
  , dateValue date := null
  , numberValue number := null
  , stringValue varchar2 := null
  , stringListSeparator varchar2 := null
  , checkRoleFlag integer := null
  , operatorId integer := null
)
return integer
is

  -- Id созданного параметра
  optionId integer;

  -- Id созданного значения
  valueId integer;

begin
  if coalesce( checkRoleFlag, 1) != 0 then
    checkRole( operatorId);
  end if;
  optionId := pkg_OptionMain.createOption(
    moduleId                  => moduleId
    , objectShortName         => objectShortName
    , objectTypeId            => objectTypeId
    , optionShortName         => optionShortName
    , valueTypeCode           => valueTypeCode
    , valueListFlag           => valueListFlag
    , encryptionFlag          => encryptionFlag
    , testProdSensitiveFlag   => testProdSensitiveFlag
    , accessLevelCode         => pkg_OptionMain.Full_AccessLevelCode
    , optionName              => optionName
    , optionDescription       => optionDescription
    , operatorId              => operatorId
  );
  valueId := pkg_OptionMain.createValue(
    optionId                  => optionId
    , valueTypeCode           => valueTypeCode
    , prodValueFlag           =>
        case when testProdSensitiveFlag = 1 then
          pkg_Common.isProduction()
        end
    , instanceName            => null
    , usedOperatorId          => null
    , dateValue               => dateValue
    , numberValue             => numberValue
    , stringValue             => stringValue
    , valueListSeparator      => stringListSeparator
    , operatorId              => operatorId
  );
  return optionId;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при создании параметра ('
        || ' moduleId=' || moduleId
        || ', objectShortName="' || objectShortName || '"'
        || ', objectTypeId=' || objectTypeId
        || ', optionShortName="' || optionShortName || '"'
        || ').'
      )
    , true
  );
end createOption;

/* proc: updateOption
  Изменяет настроечный параметр.

  Параметры:
  optionId                    - Id параметра
  valueTypeCode               - код типа значения параметра
  valueListFlag               - флаг задания для параметра списка значений
                                указанного типа ( 1 да, 0 нет)
  encryptionFlag              - флаг хранения значений параметра в
                                зашифрованном виде ( 1 да, 0 нет)
  testProdSensitiveFlag       - флаг указания для значения параметра типа базы
                                данных ( тестовая или промышленная), для
                                которого оно предназначено
                                ( 1 да, 0 нет)
  optionName                  - название параметра
  optionDescription           - описание параметра
  checkRoleFlag               - проверять наличие у оператора прав для
                                выполнения операции
                                ( 1 да ( по умолчанию), 0 нет)
  operatorId                  - Id оператора ( по умолчанию текущий)

  Замечания:
  - значения, которые не соответствуют новым данным настроечного параметра,
    удаляются;
  - в промышленных БД при изменении знечения testProdSensitiveFlag текущее
    значение параметра сохраняется ( при этом вместо общего значения создается
    значение для промышленной БД или наоборот);
  - параметр checkRoleFlag используется при вызове функции из интерфейсных
    функций других модулей ( в которых реализована собственная система прав
    доступа) и не должен использоваться из интерфейса модуля;
*/
procedure updateOption(
  optionId integer
  , valueTypeCode varchar2
  , valueListFlag integer
  , encryptionFlag integer
  , testProdSensitiveFlag integer
  , optionName varchar2
  , optionDescription varchar2
  , checkRoleFlag integer := null
  , operatorId integer := null
)
is

  -- Текущие данные параметра
  rec opt_option_new%rowtype;

begin
  if coalesce( checkRoleFlag, 1) != 0 then
    checkRole( operatorId);
  end if;
  pkg_OptionMain.lockOption(
    rowData         => rec
    , optionId      => optionId
  );
  if rec.access_level_code != pkg_OptionMain.Full_AccessLevelCode then
    raise_application_error(
      pkg_Error.ProcessError
      , 'Изменение параметра через интерфейс запрещено ('
        || ' access_level_code="' || rec.access_level_code || '"'
        || ').'
    );
  end if;
  pkg_OptionMain.updateOption(
    optionId                      => optionId
    , valueTypeCode               => valueTypeCode
    , valueListFlag               => valueListFlag
    , encryptionFlag              => encryptionFlag
    , testProdSensitiveFlag       => testProdSensitiveFlag
    , accessLevelCode             => rec.access_level_code
    , optionName                  => optionName
    , optionDescription           => optionDescription
    , moveProdSensitiveValueFlag  => pkg_Common.isProduction()
    , deleteBadValueFlag          => 1
    , operatorId                  => operatorId
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при изменении параметра ('
        || ' optionId=' || optionId
        || ').'
      )
    , true
  );
end updateOption;

/* proc: setOptionValue
  Задает используемое в текущей БД значение настроечного параметра.

  Параметры:
  optionId                    - Id параметра
  dateValue                   - значение типа дата
                                ( по умолчанию отсутствует)
  numberValue                 - числовое значение
                                ( по умолчанию отсутствует)
  stringValue                 - строковое значение
                                ( по умолчанию отсутствует)
  valueIndex                  - индекс значения в списке значений
                                ( начиная с 1, 1 можно также указывать при
                                изменении значения параметра, не использующего
                                список значений, 0 для добавления значения в
                                начало списка, -1 для добавления значения в
                                конец списка, если индекс больше числа значений
                                в списке, то добавляются промежуточные
                                null-значения, null в случае установки всего
                                значения ( при этом в случае списка значений
                                получается список из одного указанного
                                значения))
                                ( по умолчанию null)
  checkRoleFlag               - проверять наличие у оператора прав для
                                выполнения операции
                                ( 1 да ( по умолчанию), 0 нет)
  operatorId                  - Id оператора ( по умолчанию текущий)

  Замечания:
  - параметр checkRoleFlag используется при вызове функции из интерфейсных
    функций других модулей ( в которых реализована собственная система прав
    доступа) и не должен использоваться из интерфейса модуля;
*/
procedure setOptionValue(
  optionId integer
  , dateValue date := null
  , numberValue number := null
  , stringValue varchar2 := null
  , valueIndex integer := null
  , checkRoleFlag integer := null
  , operatorId integer := null
)
is

  -- Текущие данные параметра
  opt opt_option_new%rowtype;

  -- Данные используемого значения
  vlr opt_value%rowtype;

begin
  if coalesce( checkRoleFlag, 1) != 0 then
    checkRole( operatorId);
  end if;
  pkg_OptionMain.lockOption(
    rowData         => opt
    , optionId      => optionId
  );
  if opt.access_level_code not in (
          pkg_OptionMain.Full_AccessLevelCode
          , pkg_OptionMain.Value_AccessLevelCode
        )
      then
    raise_application_error(
      pkg_Error.ProcessError
      , 'Задание значения параметра через интерфейс запрещено ('
        || ' access_level_code="' || opt.access_level_code || '"'
        || ').'
    );
  end if;
  pkg_OptionMain.getValue(
    rowData             => vlr
    , optionId          => optionId
    , usedValueFlag     => 1
    , raiseNotFoundFlag => 0
  );
  pkg_OptionMain.setValue(
    optionId                  => optionId
    , prodValueFlag           => vlr.prod_value_flag
    , instanceName            =>
        case when vlr.value_id is not null then
          vlr.instance_name
        end
    , usedOperatorId          => null
    , dateValue               => dateValue
    , numberValue             => numberValue
    , stringValue             => stringValue
    , valueIndex              => valueIndex
    , operatorId              => operatorId
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при задании используемого значения параметра ('
        || ' optionId=' || optionId
        || ').'
      )
    , true
  );
end setOptionValue;

/* proc: deleteOption
  Удаляет настроечный параметр.

  Параметры:
  optionId                    - Id параметра
  checkRoleFlag               - проверять наличие у оператора прав для
                                выполнения операции
                                ( 1 да ( по умолчанию), 0 нет)
  operatorId                  - Id оператора ( по умолчанию текущий)

  Замечания:
  - для обеспечения частичной совместимости в случае указания option_id из
    таблицы opt_option, отсутствующего в таблице opt_option_new, процедура
    выполняет удаление записей из устаревших таблиц;
  - параметр checkRoleFlag используется при вызове функции из интерфейсных
    функций других модулей ( в которых реализована собственная система прав
    доступа) и не должен использоваться из интерфейса модуля;
*/
procedure deleteOption(
  optionId integer
  , checkRoleFlag integer := null
  , operatorId integer := null
)
is

  -- Id параметра в opt_option_new
  newOptionId integer;

  -- Текущие данные параметра
  opt opt_option_new%rowtype;



  /*
    Определяет Id параметра в opt_option_new ( т.к. функция может быть
    вызвана и со значением option_id из opt_option).
  */
  procedure getNewOptionId
  is
  begin
    select
      min( t.option_id)
    into newOptionId
    from
      opt_option_new t
    where
      t.option_id = optionId
    ;
    if newOptionId is null then
      select
        min( t.option_id)
      into newOptionId
      from
        opt_option_new t
      where
        t.old_option_short_name =
          (
          select
            case when
              opt.option_short_name
                like '%_' || pkg_OptionMain.OldTestOption_Suffix
            then
              substr(
                opt.option_short_name, 1, length( opt.option_short_name) - 4
              )
            else
              opt.option_short_name
            end
            as prod_option_short_name
          from
            opt_option opt
          where
            opt.option_id = optionId
          )
      ;
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при определении Id параметра в opt_option_new.'
        )
      , true
    );
  end getNewOptionId;



  /*
    Удаление из устаревших таблиц ( оставлено для совместимости).
  */
  procedure deleteOptionOld
  is
  begin
    if operatorId is not null then
      pkg_Operator.setCurrentUserId( operatorId);
    end if;

    delete from
      opt_option_value
    where
      option_id = optionId
    ;
    delete from
      opt_option
    where
      option_id = optionId
    ;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при удалении из устаревших таблиц.'
        )
      , true
    );
  end deleteOptionOld;



-- deleteOption
begin
  if coalesce( checkRoleFlag, 1) != 0 then
    checkRole( operatorId);
  end if;
  getNewOptionId();
  if newOptionId is not null then
    pkg_OptionMain.lockOption(
      rowData         => opt
      , optionId      => newOptionId
    );
    if opt.access_level_code != pkg_OptionMain.Full_AccessLevelCode then
      raise_application_error(
        pkg_Error.ProcessError
        , 'Удаление параметра через интерфейс запрещено ('
          || ' access_level_code="' || opt.access_level_code || '"'
          || ', newOptionId=' || newOptionId
          || ').'
      );
    end if;
  end if;
  if optionId = newOptionId then
    pkg_OptionMain.deleteOption(
      optionId                      => optionId
      , operatorId                  => operatorId
    );
  else
    deleteOptionOld();
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при удалении параметра ('
        || ' optionId=' || optionId
        || ').'
      )
    , true
  );
end deleteOption;

/* func: findOption
  Поиск настроечных параметров.

  Параметры:
  optionId                    - Id параметра
  moduleId                    - Id модуля, к которому относится параметр
  objectShortName             - короткое название объекта модуля
                                ( поиск по like без учета регистра)
  objectTypeId                - Id типа объекта
  optionShortName             - короткое название параметра
                                ( поиск по like без учета регистра)
  optionName                  - название параметра
                                ( поиск по like без учета регистра)
  optionDescription           - описание параметра
                                ( поиск по like без учета регистра)
  stringValue                 - строковое значение
                                ( поиск по like без учета регистра)
  maxRowCount                 - максимальное число возвращаемых поиском записей
  checkRoleFlag               - проверять наличие у оператора прав для
                                выполнения операции
                                ( 1 да ( по умолчанию), 0 нет)
  operatorId                  - Id оператора, выполняющего операцию
                                ( по умолчанию текущий)

  Возврат ( курсор):
  option_id                   - Id параметра
  value_id                    - Id используемого значения
  module_id                   - Id модуля, к которому относится параметр
  module_name                 - Название модуля, к которому относится параметр
  module_svn_root             - Путь в Subversion к корневому каталогу модуля,
                                к кооторому относится параметр
  object_short_name           - Короткое название объекта модуля
  object_type_id              - Id типа объекта
  object_type_short_name      - Короткое название типа объекта
  object_type_name            - Название типа объекта
  option_short_name           - Короткое название параметра
  value_type_code             - Код типа значения параметра
  value_type_name             - Название типа значения параметра
  date_value                  - Значение параметра типа дата
  number_value                - Числовое значение параметра
  string_value                - Строковое значение параметра либо список
                                значений с разделителем, указанным в поле
                                list_separator ( если оно задано)
  list_separator              - символ, используемый в качестве разделителя в
                                списке значений
  value_list_flag             - Флаг задания для параметра списка значений
  encryption_flag             - Флаг хранения значений параметра в
                                зашифрованном виде
  test_prod_sensitive_flag    - Флаг указания для значения параметра типа базы
                                данных ( тестовая или промышленная), для
                                которого оно предназначено
  access_level_code           - Код уровня доступа через интерфейс
  access_level_name           - Описание уровня доступа через интерфейс
  option_name                 - Название параметра
  option_description          - Описание параметра

  Замечания:
  - параметр checkRoleFlag используется при вызове функции из интерфейсных
    функций других модулей ( в которых реализована собственная система прав
    доступа) и не должен использоваться из интерфейса модуля;
*/
function findOption(
  optionId integer := null
  , moduleId integer := null
  , objectShortName varchar2 := null
  , objectTypeId integer := null
  , optionShortName varchar2 := null
  , optionName varchar2 := null
  , optionDescription varchar2 := null
  , stringValue varchar2 := null
  , maxRowCount integer := null
  , checkRoleFlag integer := null
  , operatorId integer := null
)
return sys_refcursor
is

  -- Возвращаемый курсор
  rc sys_refcursor;

  -- Динамически формируемый текст запроса
  dsql dyn_dynamic_sql_t := dyn_dynamic_sql_t( '
select
  a.*
from
  (
  select
    t.*
  from
    (
    select
      t.option_id
      , t.value_id
      , t.module_id
      , t.module_name
      , t.module_svn_root
      , t.object_short_name
      , t.object_type_id
      , t.object_type_short_name
      , t.object_type_name
      , t.option_short_name
      , t.value_type_code
      , vt.value_type_name
      , t.date_value
      , t.number_value
      , case when t.list_separator is not null
              and t.value_type_code = '''
                || pkg_OptionMain.Date_ValueTypeCode || '''
              and t.encryption_flag = 0
            then
          -- для улучшения читабельности списка дат удаляем тривиальное время
          replace( t.string_value, '' 00:00:00'', '''')
        else
          t.string_value
        end
        as string_value
      , t.list_separator
      , t.value_list_flag
      , t.encryption_flag
      , t.test_prod_sensitive_flag
      , t.access_level_code
      , al.access_level_name
      , t.option_name
      , t.option_description
    from
      v_opt_option_value t
      inner join opt_value_type vt
        on vt.value_type_code = t.value_type_code
      inner join opt_access_level al
        on al.access_level_code = t.access_level_code
    ) t
  where
    $(condition)
  order by
    t.module_svn_root
    , t.object_short_name nulls first
    , t.object_type_short_name
    , t.object_type_id
    , t.option_short_name
  ) a
where
  $(rownumCondition)
'
  );

-- findOption
begin
  if coalesce( checkRoleFlag, 1) != 0 then
    checkRole( operatorId, readOnlyAccessFlag => 1);
  end if;
  dsql.addCondition(
    't.option_id =', optionId is null
  );
  dsql.addCondition(
    't.module_id =', moduleId is null
  );
  dsql.addCondition(
    'upper( t.object_short_name) like upper( :objectShortName)'
    , objectShortName is null
  );
  dsql.addCondition(
    't.object_type_id =', objectTypeId is null
  );
  dsql.addCondition(
    'upper( t.option_short_name) like upper( :optionShortName)'
    , optionShortName is null
  );
  dsql.addCondition(
    'upper( t.option_name) like upper( :optionName)'
    , optionName is null
  );
  dsql.addCondition(
    'upper( t.option_description) like upper( :optionDescription)'
    , optionDescription is null
  );
  dsql.addCondition(
    'upper( t.string_value) like upper( :stringValue)'
    , stringValue is null
  );
  dsql.useCondition( 'condition');
  dsql.addCondition(
    'rownum <= :maxRowCount', maxRowCount is null
  );
  dsql.useCondition( 'rownumCondition');
  open rc for
    dsql.getSqlText()
  using
    optionId
    , moduleId
    , objectShortName
    , objectTypeId
    , optionShortName
    , optionName
    , optionDescription
    , stringValue
    , maxRowCount
  ;
  return rc;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при поиске настроечных параметров.'
      )
    , true
  );
end findOption;



/* group: Значения параметров */

/* func: createValue
  Создает значение параметра.

  Параметры:
  optionId                    - Id параметра
  prodValueFlag               - флаг использования значения только в
                                промышленных ( либо тестовых) БД
                                ( 1 только в промышленных БД, 0 только в
                                  тестовых БД, null без ограничений)
  instanceName                - имя экземпляра БД, в которой может
                                использоваться значение
                                ( null без ограничений ( по умолчанию))
  usedOperatorId              - Id оператора, для которого может
                                использоваться значение
                                ( null без ограничений ( по умолчанию))
  dateValue                   - значение типа дата
                                ( по умолчанию отсутствует)
  numberValue                 - числовое значение
                                ( по умолчанию отсутствует)
  stringValue                 - строковое значение
                                ( по умолчанию отсутствует)
  stringListSeparator         - символ, используемый в качестве разделителя в
                                строке со списком строковых значений
                                ( по умолчанию используется ";")
  checkRoleFlag               - проверять наличие у оператора прав для
                                выполнения операции
                                ( 1 да ( по умолчанию), 0 нет)
  operatorId                  - Id оператора ( по умолчанию текущий)

  Возврат:
  Id значения параметра.

  Замечания:
  - в случае, если используется список значений, указанное в параметрах
    функции значение сохраняется как первое значение списка;
  - параметр checkRoleFlag используется при вызове функции из интерфейсных
    функций других модулей ( в которых реализована собственная система прав
    доступа) и не должен использоваться из интерфейса модуля;
*/
function createValue(
  optionId integer
  , prodValueFlag integer
  , instanceName varchar2 := null
  , usedOperatorId integer := null
  , dateValue date := null
  , numberValue number := null
  , stringValue varchar2 := null
  , stringListSeparator varchar2 := null
  , checkRoleFlag integer := null
  , operatorId integer := null
)
return integer
is

  -- Id созданного значения
  valueId integer;

  -- Данные параметра
  opt opt_option_new%rowtype;

begin
  if coalesce( checkRoleFlag, 1) != 0 then
    checkRole( operatorId);
  end if;
  pkg_OptionMain.lockOption(
    rowData         => opt
    , optionId      => optionId
  );
  if opt.access_level_code not in (
          pkg_OptionMain.Full_AccessLevelCode
          , pkg_OptionMain.Value_AccessLevelCode
        )
      then
    raise_application_error(
      pkg_Error.ProcessError
      , 'Задание значения параметра через интерфейс запрещено ('
        || ' access_level_code="' || opt.access_level_code || '"'
        || ').'
    );
  end if;
  valueId := pkg_OptionMain.createValue(
    optionId                  => optionId
    , valueTypeCode           => opt.value_type_code
    , prodValueFlag           => prodValueFlag
    , instanceName            => instanceName
    , usedOperatorId          => usedOperatorId
    , dateValue               => dateValue
    , numberValue             => numberValue
    , stringValue             => stringValue
    , valueListSeparator      => stringListSeparator
    , operatorId              => operatorId
  );
  return valueId;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при создании значения ('
        || ' optionId=' || optionId
        || ', prodValueFlag=' || prodValueFlag
        || ', instanceName="' || instanceName || '"'
        || ', usedOperatorId=' || usedOperatorId
        || ').'
      )
    , true
  );
end createValue;

/* proc: updateValue
  Изменяет значение параметра.

  Параметры:
  valueId                     - Id значения
  dateValue                   - значение типа дата
                                ( по умолчанию отсутствует)
  numberValue                 - числовое значение
                                ( по умолчанию отсутствует)
  stringValue                 - строковое значение
                                ( по умолчанию отсутствует)
  valueIndex                  - индекс значения в списке значений
                                ( начиная с 1, 1 можно также указывать при
                                изменении значения параметра, не использующего
                                список значений, 0 для добавления значения в
                                начало списка, -1 для добавления значения в
                                конец списка, если индекс больше числа значений
                                в списке, то добавляются промежуточные
                                null-значения, null в случае установки всего
                                значения ( при этом в случае списка значений
                                получается список из одного указанного
                                значения))
                                ( по умолчанию null)
  checkRoleFlag               - проверять наличие у оператора прав для
                                выполнения операции
                                ( 1 да ( по умолчанию), 0 нет)
  operatorId                  - Id оператора ( по умолчанию текущий)

  Замечания:
  - параметр checkRoleFlag используется при вызове функции из интерфейсных
    функций других модулей ( в которых реализована собственная система прав
    доступа) и не должен использоваться из интерфейса модуля;
*/
procedure updateValue(
  valueId integer
  , dateValue date := null
  , numberValue number := null
  , stringValue varchar2 := null
  , valueIndex integer := null
  , checkRoleFlag integer := null
  , operatorId integer := null
)
is

  -- Данные значения
  vlr opt_value%rowtype;

  -- Данные параметра
  opt opt_option_new%rowtype;

begin
  if coalesce( checkRoleFlag, 1) != 0 then
    checkRole( operatorId);
  end if;
  pkg_OptionMain.lockValue(
    rowData         => vlr
    , valueId       => valueId
  );
  pkg_OptionMain.lockOption(
    rowData         => opt
    , optionId      => vlr.option_id
  );
  if opt.access_level_code not in (
          pkg_OptionMain.Full_AccessLevelCode
          , pkg_OptionMain.Value_AccessLevelCode
        )
      then
    raise_application_error(
      pkg_Error.ProcessError
      , 'Задание значения параметра через интерфейс запрещено ('
        || ' access_level_code="' || opt.access_level_code || '"'
        || ').'
    );
  end if;
  pkg_OptionMain.updateValue(
    valueId                   => valueId
    , valueTypeCode           => opt.value_type_code
    , dateValue               => dateValue
    , numberValue             => numberValue
    , stringValue             => stringValue
    , valueIndex              => valueIndex
    , operatorId              => operatorId
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при изменении значения ('
        || ' valueId=' || valueId
        || ').'
      )
    , true
  );
end updateValue;

/* proc: deleteValue
  Удаляет значение параметра.

  Параметры:
  valueId                     - Id значения параметра
  checkRoleFlag               - проверять наличие у оператора прав для
                                выполнения операции
                                ( 1 да ( по умолчанию), 0 нет)
  operatorId                  - Id оператора ( по умолчанию текущий)

  Замечания:
  - параметр checkRoleFlag используется при вызове функции из интерфейсных
    функций других модулей ( в которых реализована собственная система прав
    доступа) и не должен использоваться из интерфейса модуля;
*/
procedure deleteValue(
  valueId integer
  , checkRoleFlag integer := null
  , operatorId integer := null
)
is

  -- Данные значения
  vlr opt_value%rowtype;

  -- Данные параметра
  opt opt_option_new%rowtype;

begin
  if coalesce( checkRoleFlag, 1) != 0 then
    checkRole( operatorId);
  end if;
  pkg_OptionMain.lockValue(
    rowData         => vlr
    , valueId       => valueId
  );
  pkg_OptionMain.lockOption(
    rowData         => opt
    , optionId      => vlr.option_id
  );
  if opt.access_level_code not in (
          pkg_OptionMain.Full_AccessLevelCode
          , pkg_OptionMain.Value_AccessLevelCode
        )
      then
    raise_application_error(
      pkg_Error.ProcessError
      , 'Удаление значения параметра через интерфейс запрещено ('
        || ' access_level_code="' || opt.access_level_code || '"'
        || ').'
    );
  end if;
  pkg_OptionMain.deleteValue(
    valueId                   => valueId
    , operatorId              => operatorId
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при удалении значения ('
        || ' valueId=' || valueId
        || ').'
      )
    , true
  );
end deleteValue;

/* func: findValue
  Поиск значений настроечных параметров.

  Параметры:
  valueId                     - Id значения
  optionId                    - Id параметра
  maxRowCount                 - максимальное число возвращаемых поиском записей
  checkRoleFlag               - проверять наличие у оператора прав для
                                выполнения операции
                                ( 1 да ( по умолчанию), 0 нет)
  operatorId                  - Id оператора, выполняющего операцию
                                ( по умолчанию текущий)

  Возврат ( курсор):
  value_id                    - Id значения
  option_id                   - Id параметра
  used_value_flag             - Флаг текущего используемого в БД значения
                                ( 1 да, иначе null)
  prod_value_flag             - Флаг использования значения только в
                                промышленных ( либо тестовых) БД ( 1 только в
                                промышленных БД, 0 только в тестовых БД, null
                                без ограничений)
  instance_name               - Имя экземпляра БД, в которой может
                                использоваться значение ( в верхнем регистре,
                                null без ограничений)
  used_operator_id            - Id оператора, для которого может
                                использоваться значение
  used_operator_name          - ФИО оператора, для которого может
                                использоваться значение
  value_type_code             - Код типа значения параметра
  value_type_name             - Название типа значения параметра
  list_separator              - символ, используемый в качестве разделителя в
                                списке значений
  encryption_flag             - Флаг хранения значений параметра в
                                зашифрованном виде
  date_value                  - Значение параметра типа дата
  number_value                - Числовое значение параметра
  string_value                - Строковое значение параметра либо список
                                значений с разделителем, указанным в поле
                                list_separator ( если оно задано)

  Замечания:
  - обязательно должно быть указано значение valueId или optionId;
  - параметр checkRoleFlag используется при вызове функции из интерфейсных
    функций других модулей ( в которых реализована собственная система прав
    доступа) и не должен использоваться из интерфейса модуля;
*/
function findValue(
  valueId integer := null
  , optionId integer := null
  , maxRowCount integer := null
  , checkRoleFlag integer := null
  , operatorId integer := null
)
return sys_refcursor
is

  -- Возвращаемый курсор
  rc sys_refcursor;

  -- Динамически формируемый текст запроса
  dsql dyn_dynamic_sql_t := dyn_dynamic_sql_t( '
select
  a.*
from
  (
  select
    t.value_id
    , t.option_id
    , case when ov.value_id is not null then 1 end
      as used_value_flag
    , t.prod_value_flag
    , t.instance_name
    , t.used_operator_id
    , uo.operator_name as used_operator_name
    , t.value_type_code
    , vt.value_type_name
    , t.list_separator
    , t.encryption_flag
    , t.date_value
    , t.number_value
    , case when t.list_separator is not null
            and t.value_type_code = '''
              || pkg_OptionMain.Date_ValueTypeCode || '''
            and t.encryption_flag = 0
          then
        -- для улучшения читабельности списка дат удаляем тривиальное время
        replace( t.string_value, '' 00:00:00'', '''')
      else
        t.string_value
      end
      as string_value
  from
    v_opt_value t
    inner join opt_value_type vt
      on vt.value_type_code = t.value_type_code
    left outer join v_opt_option_value ov
      on ov.value_id = t.value_id
    left outer join op_operator uo
      on uo.operator_id = t.used_operator_id
  where
    $(condition)
  order by
    t.option_id
    , t.prod_value_flag nulls first
    , t.instance_name nulls first
    , t.used_operator_id nulls first
    , t.value_id
  ) a
where
  $(rownumCondition)
'
  );

-- findValue
begin
  if coalesce( checkRoleFlag, 1) != 0 then
    checkRole( operatorId, readOnlyAccessFlag => 1);
  end if;
  if valueId is null and optionId is null then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Должно быть указано значение valueId или optionId.'
    );
  end if;
  dsql.addCondition(
    't.value_id =', valueId is null
  );
  dsql.addCondition(
    't.option_id =', optionId is null
  );
  dsql.useCondition( 'condition');
  dsql.addCondition(
    'rownum <= :maxRowCount', maxRowCount is null
  );
  dsql.useCondition( 'rownumCondition');
  open rc for
    dsql.getSqlText()
  using
    valueId
    , optionId
    , maxRowCount
  ;
  return rc;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при поиске значений настроечных параметров ('
        || ' valueId=' || valueId
        || ', optionId=' || optionId
        || ').'
      )
    , true
  );
end findValue;



/* group: Справочники */

/* func: getObjectType
  Возвращает типы объектов.

  Возврат ( курсор):
  object_type_id              - Id типа объекта
  object_type_short_name      - короткое название типа объекта
  object_type_name            - название типа объекта
  module_name                 - название модуля, к которому относится тип
                                объекта
  module_svn_root             - путь в Subversion к корневому каталогу модуля,
                                к кооторому относится тип объекта
  ( сортировка по object_type_name, object_type_id)
*/
function getObjectType
return sys_refcursor
is

  -- Возвращаемый курсор
  rc sys_refcursor;

begin
  open rc for
    select
      t.object_type_id
      , t.object_type_short_name
      , t.object_type_name
      , t.module_name
      , t.module_svn_root
    from
      v_opt_object_type t
    order by
      t.object_type_name
      , t.object_type_id
  ;
  return rc;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при выборке типов объектов.'
      )
    , true
  );
end getObjectType;

/* func: getValueType
  Возвращает типы значений параметров.

  Возврат ( курсор):
  value_type_code             - код типа значения параметра
  value_type_name             - название типа значения параметра

  ( сортировка по value_type_name)
*/
function getValueType
return sys_refcursor
is

  -- Возвращаемый курсор
  rc sys_refcursor;

begin
  open rc for
    select
      t.value_type_code
      , t.value_type_name
    from
      opt_value_type t
    order by
      t.value_type_name
  ;
  return rc;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при выборке типов значений параметров.'
      )
    , true
  );
end getValueType;



/* group: Справочники других модулей */

/* func: findModule
  Поиск программных модулей.

  Параметры:
  moduleId                    - Id модуля
  moduleName                  - название модуля
                                ( поиск по like без учета регистра)
  maxRowCount                 - максимальное число возвращаемых поиском записей

  Возврат ( курсор):
  module_id                   - Id модуля
  module_name                 - Название модуля
  svn_root                    - Путь в Subversion к корневому каталогу модуля,
*/
function findModule(
  moduleId integer := null
  , moduleName varchar2 := null
  , maxRowCount integer := null
)
return sys_refcursor
is

  -- Возвращаемый курсор
  rc sys_refcursor;

  -- Динамически формируемый текст запроса
  dsql dyn_dynamic_sql_t := dyn_dynamic_sql_t( '
select
  a.*
from
  (
  select
    t.module_id
    , t.module_name
    , t.svn_root
  from
    v_mod_module t
  where
    $(condition)
  order by
    t.module_name
    , t.svn_root
  ) a
where
  $(rownumCondition)
'
  );

-- findModule
begin
  dsql.addCondition(
    't.module_id =', moduleId is null
  );
  dsql.addCondition(
    'upper( t.module_name) like upper( :moduleName)'
    , moduleName is null
  );
  dsql.useCondition( 'condition');
  dsql.addCondition(
    'rownum <= :maxRowCount', maxRowCount is null
  );
  dsql.useCondition( 'rownumCondition');
  open rc for
    dsql.getSqlText()
  using
    moduleId
    , moduleName
    , maxRowCount
  ;
  return rc;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при поиске программных модулей.'
      )
    , true
  );
end findModule;

/* func: getOperator
  Получение данных по операторам.

  Параметры:
  operatorName                - ФИО оператора
                                ( поиск по like без учета регистра)
                                ( по умолчанию без ограничений)
  maxRowCount                 - максимальное число возвращаемых поиском записей
                                ( по умолчанию без ограничений)

  Возврат ( курсор):
  operator_id                 - Id оператора
  operator_name               - ФИО оператора
*/
function getOperator(
  operatorName varchar2 := null
  , maxRowCount integer := null
)
return sys_refcursor
is
begin
  return
    pkg_Operator.getOperator(
      operatorName  => operatorName
      , rowCount    => maxRowCount
    )
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при получении данных по операторам ('
        || ' operatorName="' || operatorName || '"'
        || ', maxRowCount=' || maxRowCount
        || ').'
      )
    , true
  );
end getOperator;



/* group: Устаревшие функции */

/* func: getOptionDate(optionShortName)
  Устаревшая функция, в других модулях следует использовать функции из типа
  <opt_option_list_t>.
*/
function getOptionDate(
  optionShortName varchar2
)
return date
is
  -- Значение опции
  dateValue date;
begin
  select
    datetime_value
  into
    dateValue
  from
    v_opt_option
  where
    option_short_name = optionShortName
  ;
  return
    dateValue
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка получения значения опции даты ('
        || ' optionShortName="' || optionShortName || '"'
        || ')'
      )
    , true
  );
end getOptionDate;

/* func: getOptionString(optionShortName)
  Устаревшая функция, в других модулях следует использовать функции из типа
  <opt_option_list_t>.
*/
function getOptionString(
  optionShortName varchar2
)
return varchar2
is
  -- Значение опции
  stringValue v_opt_option.string_value%type;
begin
  select
    string_value
  into
    stringValue
  from
    v_opt_option
  where
    option_short_name = optionShortName
  ;
  return
    stringValue;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка получения строкового значения опции('
        || ' optionShortName="' || optionShortName || '"'
        || ')'
      )
    , true
  );
end getOptionString;

/* func: getOptionNumber(optionShortName)
  Устаревшая функция, в других модулях следует использовать функции из типа
  <opt_option_list_t>.
*/
function getOptionNumber(
  optionShortName varchar2
)
return number
is
  -- Значение опции
  numberValue v_opt_option.integer_value%type;
begin
  select
    integer_value
  into
    numberValue
  from
    v_opt_option
  where
    option_short_name = optionShortName
  ;
  return
    numberValue;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка получения значения опции числа ('
        || ' optionShortName="' || optionShortName || '"'
        || ')'
      )
    , true
  );
end getOptionNumber;

/* proc: addOptionDate(optionShortName)
  Устаревшая функция, в других модулях следует использовать функции из типа
  <opt_option_list_t>.
*/
procedure addOptionDate(
  optionShortName varchar2
  , optionName varchar2
  , defaultDateValue varchar2 := null
)
is

  cursor optionCur is
    select
      option_id
      , option_name
      , datetime_value
    from
      v_opt_option
    where
      option_short_name = optionShortName
  ;

  optionRec optionCur%rowtype;
begin
  open optionCur;
  fetch optionCur into optionRec;
  if optionCur%found then
    logger.info(
      'Опция существует: ( '
      || 'optionShortName="' || optionShortName || '"'
      || ', optionName="' || optionRec.option_name || '"'
      || ', option_id=' || to_char( optionRec.option_id)
      || ', date_value="' || optionRec.datetime_value || '"'
      || ')'
    );
  else
    optionRec.option_id := pkg_Option.createOption(
      optionName => optionName
      , optionShortName => optionShortName
      , isGlobal => 1
      -- Дата
      , maskId => 4
      , datetimeValue => defaultDateValue
      , integerValue => null
      , stringValue => null
      , operatorId => pkg_Operator.getCurrentUserId()
    );
    logger.info(
      'Опция создана: ( '
      || 'optionShortName="' || optionShortName || '"'
      || ', optionName="' || optionName || '"'
      || ', option_id=' || to_char( optionRec.option_id)
      || ', date_value="' || defaultDateValue || '"'
      || ')'
    );
  end if;
  close optionCur;
exception when others then
  if optionCur%isopen then
    close optionCur;
  end if;
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка добавлениия опции('
        || 'optionShortName="' || optionShortName || '"'
        || ', optionName="' || optionName || '"'
        || ', defaultDateValue="' || defaultDateValue || '"'
        || ')'
      )
    , true
  );
end addOptionDate;

/* proc: addOptionNumber(optionShortName)
  Устаревшая функция, в других модулях следует использовать функции из типа
  <opt_option_list_t>.
*/
procedure addOptionNumber(
  optionShortName varchar2
  , optionName varchar2
  , defaultNumberValue varchar2 := null
)
is

  cursor optionCur is
    select
      option_id
      , option_name
      , integer_value
    from
      v_opt_option
    where
      option_short_name = optionShortName
  ;

  optionRec optionCur%rowtype;
begin
  open optionCur;
  fetch optionCur into optionRec;
  if optionCur%found then
    logger.info(
      'Опция существует: ( '
      || 'optionShortName="' || optionShortName || '"'
      || ', optionName="' || optionRec.option_name || '"'
      || ', option_id=' || to_char( optionRec.option_id)
      || ', number_value="' || optionRec.integer_value || '"'
      || ')'
    );
  else
    optionRec.option_id := pkg_Option.createOption(
      optionName => optionName
      , optionShortName => optionShortName
      , isGlobal => 1
      -- Число
      , maskId => 1
      , datetimeValue => null
      , integerValue => defaultNumberValue
      , stringValue => null
      , operatorId => pkg_Operator.getCurrentUserId()
    );
    logger.info(
      'Опция создана: ( '
      || 'optionShortName="' || optionShortName || '"'
      || ', optionName="' || optionName || '"'
      || ', option_id=' || to_char( optionRec.option_id)
      || ', number_value="' || defaultNumberValue || '"'
      || ')'
    );
  end if;
  close optionCur;
exception when others then
  if optionCur%isopen then
    close optionCur;
  end if;
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка добавлениия опции('
        || 'optionShortName="' || optionShortName || '"'
        || ', optionName="' || optionName || '"'
        || ', defaultNumberValue="' || defaultNumberValue || '"'
        || ')'
      )
    , true
  );
end addOptionNumber;

/* proc: addOptionString(optionShortName)
  Устаревшая функция, в других модулях следует использовать функции из типа
  <opt_option_list_t>.
*/
procedure addOptionString(
  optionShortName varchar2
  , optionName varchar2
  , defaultStringValue varchar2 := null
)
is

  cursor optionCur is
    select
      option_id
      , option_name
      , string_value
    from
      v_opt_option
    where
      option_short_name = optionShortName
  ;

  optionRec optionCur%rowtype;
begin
  open optionCur;
  fetch optionCur into optionRec;
  if optionCur%found then
    logger.info(
      'Опция существует: ( '
      || 'optionShortName="' || optionShortName || '"'
      || ', optionName="' || optionRec.option_name || '"'
      || ', option_id=' || to_char( optionRec.option_id)
      || ', string_value="' || optionRec.string_value || '"'
      || ')'
    );
  else
    optionRec.option_id := pkg_Option.createOption(
      optionName => optionName
      , optionShortName => optionShortName
      , isGlobal => 1
      -- Строка
      , maskId => 3
      , datetimeValue => null
      , integerValue => null
      , stringValue => defaultStringValue
      , operatorId => pkg_Operator.getCurrentUserId()
    );
    logger.info(
      'Опция создана: ( '
      || 'optionShortName="' || optionShortName || '"'
      || ', optionName="' || optionName || '"'
      || ', option_id=' || to_char( optionRec.option_id)
      || ', string_value="' || defaultStringValue || '"'
      || ')'
    );
  end if;
  close optionCur;
exception when others then
  if optionCur%isopen then
    close optionCur;
  end if;
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка добавлениия опции('
        || 'optionShortName="' || optionShortName || '"'
        || ', optionName="' || optionName || '"'
        || ', defaultStringValue="' || defaultStringValue || '"'
        || ')'
      )
    , true
  );
end addOptionString;

/* iproc: getOptionId
  Устаревшая функция.
*/
procedure getOptionId(
  optionId in opt_option_value.option_id%type
  , localOptionId out opt_option_value.option_id%type
  , globalOptionId out opt_option_value.option_id%type
)
is

IsGlobal opt_Option.Is_Global%Type;     --Признак глобального параметра
BEGIN
  begin
  select Is_Global into IsGlobal        --Если getOptionId.OptionID был
  from opt_Option                       --глобальным параметром, то IsGlobal := 1
  where Option_ID = getOptionId.OptionID;
  Exception                             --Запрашиваемого параметра в справочнике не существует
    When No_Data_Found then
    Raise_Application_Error(pkg_Error.RowNotFound,'Параметра с идентификатором '||getOptionId.OptionID||' не существует !');
  end;
if IsGlobal = 0 then
  Begin						            --Если в качестве параметра был передан
  LocalOptionID := OptionID;            --локальный параметр
    begin
    select Link_Global_Local into GlobalOptionID
    from opt_Option
    where Option_ID = getOptionId.OptionID;
    Exception                           --Соответствующего глобального параметра не существует
      When No_Data_Found then
      GlobalOptionID := null;
    end;
  End;
else
  Begin                                 --Если в качестве параметра был передан
  GlobalOptionID := OptionID;           --глобальный параметр
    begin
    select Link_Global_Local into LocalOptionID
    from opt_Option
    where Option_ID = getOptionId.OptionID;
    Exception                           --Соответствующего локальный параметра не существует
      When No_Data_Found then
      LocalOptionID := null;
    end;
  End;
End if;
end getOptionId;

/* ifunc: getOptionShortName
  Устаревшая функция.
*/
function getOptionShortName(
  moduleName varchar2
  , moduleOptionName varchar2
)
return varchar2
is
-- getOptionShortName
begin
  return
    moduleName || '.' || moduleOptionName
  ;
end getOptionShortName;

/* ifunc: readOptionLocal
  Устаревшая функция.
*/
function readOptionLocal(
  optionId in opt_option_value.option_id%type
)
return opt_option_value%rowtype
is

Result opt_Option_Value%RowType;

BEGIN
Begin
select * into Result
from opt_Option_Value ov
where	ov.Option_ID = readOptionLocal.OptionID and
		ov.Operator_ID = pkg_Operator.GetCurrentUserID and
		ov.Date_Ins = (select max(ov2.Date_Ins)
			from opt_Option_Value ov2
			where	ov2.Option_ID = ov.Option_ID and
				ov2.Operator_ID = ov.Operator_ID);
Exception                               --Оператор не определял значение опции
  When No_Data_Found then
    Result := null;
End;
RETURN Result;
end readOptionLocal;

/* ifunc: readOptionGlobal
  Устаревшая функция.
*/
function readOptionGlobal(
  optionId in opt_option_value.option_id%type
)
return opt_option_value%rowtype
is

Result opt_Option_Value%RowType;

BEGIN
Begin
select * into Result
from opt_Option_Value ov
where	ov.Option_ID = readOptionGlobal.OptionID and
		ov.Date_Ins = (select max(ov2.Date_Ins)
			from opt_Option_Value ov2
			where	ov2.Option_ID = ov.Option_ID);
Exception                               --Оператор не определял значение опции
  When No_Data_Found then
    Result := null;
End;
RETURN Result;
end readOptionGlobal;

/* func: getOptionDate(optionId)
  Устаревшая функция, в других модулях следует использовать функции из типа
  <opt_option_list_t>.
*/
function getOptionDate(
  optionId in opt_option_value.option_id%type
)
return opt_option_value.datetime_value%type
is

LocalOptionID  opt_Option.Option_ID%Type; --Номер локального параметра
GlobalOptionID opt_Option.Option_ID%Type; --Номер глобального параметра
OptionValues   opt_Option_Value%RowType;  --Одна строка из таблицы значений параметров
BEGIN                                   --Определяем номер соответствующего
                                        --локального и глобального параметра
getOptionId(OptionID,LocalOptionID,GlobalOptionID);
if LocalOptionID is not null then       --Если в справочнике есть соответствующий
                                        --локальный параметр - прочитаем его значение
  OptionValues := readOptionLocal(LocalOptionID);
end if;
if(OptionValues.DateTime_Value is null)and(GlobalOptionID is not null) then
  OptionValues := readOptionGlobal(GlobalOptionID);
end if;
RETURN OptionValues.DateTime_Value;
end getOptionDate;

/* func: getOptionInteger(optionId)
  Устаревшая функция, в других модулях следует использовать функции из типа
  <opt_option_list_t>.
*/
function getOptionInteger(
  optionId in opt_option_value.option_id%type
)
return opt_option_value.integer_value%type
is

LocalOptionID  opt_Option.Option_ID%Type; --Номер локального параметра
GlobalOptionID opt_Option.Option_ID%Type; --Номер глобального параметра
OptionValues   opt_Option_Value%RowType;  --Одна строка из таблицы значений параметров
BEGIN                                   --Определяем номер соответствующего
                                        --локального и глобального параметра
getOptionId(OptionID,LocalOptionID,GlobalOptionID);
if LocalOptionID is not null then
  OptionValues := readOptionLocal(LocalOptionID);
end if;
if(OptionValues.Integer_Value is null)and(GlobalOptionID is not null) then
  OptionValues := readOptionGlobal(GlobalOptionID);
end if;
RETURN OptionValues.Integer_Value;
end getOptionInteger;

/* func: getOptionString(optionId)
  Устаревшая функция, в других модулях следует использовать функции из типа
  <opt_option_list_t>.
*/
function getOptionString(
  optionId in opt_option_value.option_id%type
)
return opt_option_value.string_value%type
is

LocalOptionID  opt_Option.Option_ID%Type; --Номер локального параметра
GlobalOptionID opt_Option.Option_ID%Type; --Номер глобального параметра
OptionValues   opt_Option_Value%RowType;  --Одна строка из таблицы значений параметров
BEGIN                                   --Определяем номер соответствующего
                                        --локального и глобального параметра
getOptionId(OptionID,LocalOptionID,GlobalOptionID);
if LocalOptionID is not null then
  OptionValues := readOptionLocal(LocalOptionID);
end if;
if(OptionValues.String_Value is null)and(GlobalOptionID is not null) then
  OptionValues := readOptionGlobal(GlobalOptionID);
end if;
RETURN OptionValues.String_Value;
end getOptionString;

/* func: getOptionDate
  Устаревшая функция, в других модулях следует использовать функции из типа
  <opt_option_list_t>.
*/
function getOptionDate(
  moduleName varchar2
  , moduleOptionName varchar2
)
return date
is

  -- Id параметра и вид значения
  optionId integer;
  prodValueFlag integer;

  -- Данные значения
  vlr opt_value%rowtype;

begin
  pkg_OptionMain.getOptionInfoOld(
    optionId            => optionId
    , prodValueFlag     => prodValueFlag
    , moduleName        => moduleName
    , moduleOptionName  => moduleOptionName
    , raiseNotFoundFlag => 1
  );
  pkg_OptionMain.getValue(
    rowData                 => vlr
    , optionId              => optionId
    , prodValueFlag         => prodValueFlag
    , instanceName          => null
    , usedOperatorId        => null
    , valueTypeCode         => pkg_OptionMain.Date_ValueTypeCode
    , valueIndex            => null
    , raiseNotFoundFlag     => 1
  );
  return vlr.date_value;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка получения значения опции даты ('
        || ' moduleName="' || moduleName || '"'
        || ', moduleOptionName="' || moduleOptionName || '"'
        || ')'
      )
    , true
  );
end getOptionDate;

/* func: getOptionString
  Устаревшая функция, в других модулях следует использовать функции из типа
  <opt_option_list_t>.
*/
function getOptionString(
  moduleName varchar2
  , moduleOptionName varchar2
)
return varchar2
is

  -- Id параметра и вид значения
  optionId integer;
  prodValueFlag integer;

  -- Данные значения
  vlr opt_value%rowtype;

begin
  pkg_OptionMain.getOptionInfoOld(
    optionId            => optionId
    , prodValueFlag     => prodValueFlag
    , moduleName        => moduleName
    , moduleOptionName  => moduleOptionName
    , raiseNotFoundFlag => 1
  );
  pkg_OptionMain.getValue(
    rowData                 => vlr
    , optionId              => optionId
    , prodValueFlag         => prodValueFlag
    , instanceName          => null
    , usedOperatorId        => null
    , valueTypeCode         => pkg_OptionMain.String_ValueTypeCode
    , valueIndex            => null
    , raiseNotFoundFlag     => 1
  );
  return vlr.string_value;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка получения строкового значения опции('
        || ' moduleName="' || moduleName || '"'
        || ', moduleOptionName="' || moduleOptionName || '"'
        || ')'
      )
    , true
  );
end getOptionString;

/* func: getOptionNumber
  Устаревшая функция, в других модулях следует использовать функции из типа
  <opt_option_list_t>.
*/
function getOptionNumber(
  moduleName varchar2
  , moduleOptionName varchar2
)
return number
is

  -- Id параметра и вид значения
  optionId integer;
  prodValueFlag integer;

  -- Данные значения
  vlr opt_value%rowtype;

begin
  pkg_OptionMain.getOptionInfoOld(
    optionId            => optionId
    , prodValueFlag     => prodValueFlag
    , moduleName        => moduleName
    , moduleOptionName  => moduleOptionName
    , raiseNotFoundFlag => 1
  );
  pkg_OptionMain.getValue(
    rowData                 => vlr
    , optionId              => optionId
    , prodValueFlag         => prodValueFlag
    , instanceName          => null
    , usedOperatorId        => null
    , valueTypeCode         => pkg_OptionMain.Number_ValueTypeCode
    , valueIndex            => null
    , raiseNotFoundFlag     => 1
  );
  return vlr.number_value;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка получения значения опции числа ('
        || ' moduleName="' || moduleName || '"'
        || ', moduleOptionName="' || moduleOptionName || '"'
        || ')'
      )
    , true
  );
end getOptionNumber;

/* proc: setDateTime(optionId)
  Устаревшая функция, в других модулях следует использовать функции из типа
  <opt_option_list_t>.
*/
procedure setDateTime(
  optionid in opt_option_value.option_id%type
  , value in opt_option_value.datetime_value%type
)
is
BEGIN
  checkRole( operatorId => null);
insert into opt_Option_Value
(Option_ID,Datetime_Value)
values(OptionID,Value);
end setDatetime;

/* proc: setString(optionId)
  Устаревшая функция, в других модулях следует использовать функции из типа
  <opt_option_list_t>.
*/
procedure setString(
  optionid in opt_option_value.option_id%type
  , value in opt_option_value.string_value%type
)
is
BEGIN
  checkRole( operatorId => null);
insert into opt_Option_Value
(Option_ID,String_Value)
values(OptionID,Value);
end setString;

/* proc: setInteger(optionId)
  Устаревшая функция, в других модулях следует использовать функции из типа
  <opt_option_list_t>.
*/
procedure setInteger(
  optionId in opt_option_value.option_id%type
  , value in opt_option_value.integer_value%type
)
is
BEGIN
  checkRole( operatorId => null);
insert into opt_Option_Value
(Option_ID,Integer_Value)
values(OptionID,Value);
end setInteger;

/* proc: setDate
  Устаревшая функция, в других модулях следует использовать функции из типа
  <opt_option_list_t>.
*/
procedure setDate(
  moduleName varchar2
  , moduleOptionName varchar2
  , dateValue date
)
is
begin
  setDateTime(
    optionId =>
      pkg_OptionMain.getOldOptionId(
        moduleName => moduleName
        , moduleOptionName => moduleOptionName
      )
    , value => dateValue
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка установки значения параметра ('
        || ' moduleName="' || moduleName || '"'
        || ', moduleOptionName="' || moduleOptionName || '"'
        || ', dateValue={' || to_char( dateValue, 'dd.mm.yyyy hh24:mi:ss') || '}'
      )
    , true
  );
end setDate;

/* proc: setString
  Устаревшая функция, в других модулях следует использовать функции из типа
  <opt_option_list_t>.
*/
procedure setString(
  moduleName varchar2
  , moduleOptionName varchar2
  , stringValue varchar2
)
is
begin
  setString(
    optionId =>
      pkg_OptionMain.getOldOptionId(
        moduleName => moduleName
        , moduleOptionName => moduleOptionName
      )
    , value => stringValue
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка установки значения параметра ('
        || ' moduleName="' || moduleName || '"'
        || ', moduleOptionName="' || moduleOptionName || '"'
        || ', stringValue="' || stringValue || '"'
      )
    , true
  );
end setString;

/* proc: setNumber
  Устаревшая функция, в других модулях следует использовать функции из типа
  <opt_option_list_t>.
*/
procedure setNumber(
  moduleName varchar2
  , moduleOptionName varchar2
  , numberValue number
)
is
begin
  setInteger(
    optionId =>
      pkg_OptionMain.getOldOptionId(
        moduleName => moduleName
        , moduleOptionName => moduleOptionName
      )
    , value => numberValue
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка установки значения параметра ('
        || ' moduleName="' || moduleName || '"'
        || ', moduleOptionName="' || moduleOptionName || '"'
        || ', numberValue=' || to_char( numberValue)
      )
    , true
  );
end setNumber;

/* func: createOption
  Устаревшая функция, в других модулях следует использовать функции из типа
  <opt_option_list_t>.
*/
function createOption(
  optionName opt_option.option_name%type
  , optionShortName opt_option.option_short_name%type
  , isGlobal opt_option.is_global%type
  , maskId opt_option.mask_id%type
  , dateTimeValue opt_option_value.datetime_value%type
  , integerValue opt_option_value.integer_value%type
  , stringValue opt_option_value.string_value%type
  , operatorId in op_operator.operator_id%type
)
return opt_option.option_id%type
is

  OptionId opt_option.option_id%type;
begin
  checkRole( operatorId);
  insert
    into opt_option
      (option_id, option_name
      , option_short_name, is_global
      , operator_id, mask_id)
    values
      (null, OptionName
      , OptionShortName, IsGlobal
      , OperatorId, MaskId)
    returning Option_Id into OptionId;

  insert
    into opt_option_value
      (option_value_id, option_id
      , datetime_value, integer_value, string_value
      , operator_Id)
    values
      (null, OptionId
      , DatetimeValue, IntegerValue, StringValue
      , OperatorId);

  return OptionId;
exception                               --Стандартная отработка исключений
  when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , 'Возникла ошибка при создании параметра пакетной обработки данных "'
    || OptionName || '"'
    , true
  );
end createOption;

/* func: createOption
  Устаревшая функция, в других модулях следует использовать функции из типа
  <opt_option_list_t>.
*/
function createOption(
  optionName opt_option.option_name%type
  , optionShortName opt_option.option_short_name%type
  , isGlobal opt_option.is_global%type
  , maskId opt_option.mask_id%type
  , stringValue varchar2
  , operatorId op_operator.operator_id%type
)
return integer
is

  OptionId opt_option.option_id%type;
  StorageRuleId integer;
BEGIN
  begin
    select Storage_Rule_Id
    into StorageRuleId
    from doc_mask
    where Mask_Id = MaskId;
  exception when no_data_found then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , 'Не распознан тип данных (Mask_Id = '
      || to_char(MaskId) || ')'
      , true
    );
  end;

  case StorageRuleId
    when StorageRuleInteger then
      OptionId := createOption(OptionName
        , OptionShortName
        , IsGlobal
        , MaskId
        , null
        , to_number (replace (StringValue, '.', substr (to_char (0.1, 'tm9'), 1, 1)))
        , null
        , OperatorId);
    when StorageRuleString then
      OptionId := createOption(OptionName
        , OptionShortName
        , IsGlobal
        , MaskId
        , null
        , null
        , StringValue
        , OperatorId);
    when StorageRuleDate then
      OptionId := createOption(OptionName
        , OptionShortName
        , IsGlobal
        , MaskId
        , to_date(StringValue, 'dd.mm.yyyy hh24:mi:ss')
        , null
        , null
        , OperatorId);
    else
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , 'Не распознан тип данных (Mask_Id = '
        || to_char(MaskId) || ')'
        , true
      );
  end case;

  return OptionId;
exception                               --Стандартная отработка исключений
  when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , 'Возникла ошибка при создании параметра пакетной обработки данных "'
    || OptionName || '"'
    , true
  );
end createOption;

/* proc: updateOption
  Устаревшая функция, в других модулях следует использовать функции из типа
  <opt_option_list_t>.
*/
procedure updateOption(
  optionId in opt_option.option_id%type
  , dateTimeValue in opt_option_value.datetime_value%type
  , integerValue in opt_option_value.integer_value%type
  , stringValue in opt_option_value.string_value%type
  , operatorId in op_operator.operator_id%type
)
is
BEGIN
  checkRole( operatorId);
  insert into opt_Option_Value
    (Option_ID
    , Datetime_Value, Integer_Value, String_Value
    , Operator_id)
  values(OptionID
    , DateTimeValue, IntegerValue, StringValue
    , OperatorId);
exception                               --Стандартная отработка исключений
  when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , 'Возникла ошибка при редактировании параметра пакетной обработки данных (Option_Id = '
    || to_char(OptionId) || ')'
    , true
  );
end updateOption;

/* proc: updateOption
  Устаревшая функция, в других модулях следует использовать функции из типа
  <opt_option_list_t>.
*/
procedure updateOption(
  optionId in opt_option.option_id%type
  , optionName in opt_option.option_name%type
  , optionShortName in opt_option.option_short_name%type
  , isGlobal in opt_option.is_global%type
  , maskId in opt_option.mask_id%type
  , dateTimeValue in opt_option_value.datetime_value%type
  , integerValue in opt_option_value.integer_value%type
  , stringValue in opt_option_value.string_value%type
  , operatorId in op_operator.operator_id%type
)
is
begin
  checkRole( operatorId);
  if operatorId is not null then
    pkg_Operator.setCurrentUserId( operatorId);
  end if;

  update opt_option
    set
      option_name = OptionName
      , option_short_name = OptionShortName
      , is_global = IsGlobal
      , mask_id = MaskId
    where Option_Id = OptionId;

  insert into opt_Option_Value
    (Option_ID
    , Datetime_Value, Integer_Value, String_Value
    , Operator_id)
  values(OptionID
    , DateTimeValue, IntegerValue, StringValue
    , OperatorId);

exception                               --Стандартная отработка исключений
  when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , 'Возникла ошибка при редактировании общих данных параметра пакетной обработки данных "'
    || OptionName || '"'
    , true
  );
end updateOption;

/* proc: updateOption
  Устаревшая функция, в других модулях следует использовать функции из типа
  <opt_option_list_t>.
*/
procedure updateOption(
  optionId in opt_option.option_id%type
  , maskId in opt_option.mask_id%type
  , stringValue in varchar2
  , operatorId in op_operator.operator_id%type
)
is

  StorageRuleId integer;
BEGIN

  begin
    select Storage_Rule_Id
    into StorageRuleId
    from doc_mask
    where Mask_Id = MaskId;
  exception when no_data_found then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , 'Не распознан тип данных (Mask_Id = '
      || to_char(MaskId) || ')'
      , true
    );
  end;

  case StorageRuleId
    when StorageRuleInteger then
      updateOption(OptionId
        , null
        , to_number (replace (StringValue, '.', substr (to_char (0.1, 'tm9'), 1, 1)))
        , null
        , OperatorId);
    when StorageRuleString then
      updateOption(OptionId
        , null
        , null
        , StringValue
        , OperatorId);
    when StorageRuleDate then
      updateOption(OptionId
        , to_date(StringValue, 'dd.mm.yyyy hh24:mi:ss')
        , null
        , null
        , OperatorId);
    else
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , 'Не распознан тип данных (Mask_Id = '
        || to_char(MaskId) || ')'
        , true
      );
  end case;

exception                               --Стандартная отработка исключений
  when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , 'Возникла ошибка при редактировании параметра пакетной обработки данных (Option_Id = '
    || to_char(OptionId) || ', value "' || StringValue || '")'
    , true
  );
end updateOption;

/* proc: updateOption
  Устаревшая функция, в других модулях следует использовать функции из типа
  <opt_option_list_t>.
*/
procedure updateOption(
  optionId opt_option.option_id%type
  , optionName opt_option.option_name%type
  , optionShortName opt_option.option_short_name%type
  , isGlobal opt_option.is_global%type
  , maskId opt_option.mask_id%type
  , stringValue varchar2
  , operatorId op_operator.operator_id%type
)
is

  StorageRuleId integer;
BEGIN
  begin
    select Storage_Rule_Id
    into StorageRuleId
    from doc_mask
    where Mask_Id = MaskId;
  exception when no_data_found then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , 'Не распознан тип данных (Mask_Id = '
      || to_char(MaskId) || ')'
      , true
    );
  end;

  case StorageRuleId
    when StorageRuleInteger then
      updateOption(OptionId
        , OptionName
        , OptionShortName
        , IsGlobal
        , MaskId
        , null
        , to_number (replace (StringValue, '.', substr (to_char (0.1, 'tm9'), 1, 1)))
        , null
        , OperatorId);
    when StorageRuleString then
      updateOption(OptionId
        , OptionName
        , OptionShortName
        , IsGlobal
        , MaskId
        , null
        , null
        , StringValue
        , OperatorId);
    when StorageRuleDate then
      updateOption(OptionId
        , OptionName
        , OptionShortName
        , IsGlobal
        , MaskId
        , to_date(StringValue, 'dd.mm.yyyy hh24:mi:ss')
        , null
        , null
        , OperatorId);
    else
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , 'Не распознан тип данных (Mask_Id = '
        || to_char(MaskId) || ')'
        , true
      );
    end case;

exception                               --Стандартная отработка исключений
  when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , 'Возникла ошибка при редактировании общих данных параметра пакетной обработки данных "'
    || OptionName || '"'
    , true
  );
end updateOption;

/* proc: addOptionDate
  Устаревшая функция, в других модулях следует использовать функции из типа
  <opt_option_list_t>.
*/
procedure addOptionDate(
  moduleName varchar2
  , moduleOptionName varchar2
  , optionName varchar2
  , defaultDateValue varchar2 := null
)
is
begin
  pkg_OptionMain.addOptionWithValueOld(
    moduleName          => moduleName
    , moduleOptionName  => moduleOptionName
    , valueTypeCode     => pkg_OptionMain.Date_ValueTypeCode
    , optionName        => optionName
    , dateValue         => defaultDateValue
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка добавлениия опции('
        || ' moduleName="' || moduleName || '"'
        || ', moduleOptionName="' || moduleOptionName || '"'
        || ', optionName="' || optionName || '"'
        || ', defaultDateValue="' || defaultDateValue || '"'
        || ')'
      )
    , true
  );
end addOptionDate;

/* proc: addOptionNumber
  Устаревшая функция, в других модулях следует использовать функции из типа
  <opt_option_list_t>.
*/
procedure addOptionNumber(
  moduleName varchar2
  , moduleOptionName varchar2
  , optionName varchar2
  , defaultNumberValue varchar2 := null
)
is
begin
  pkg_OptionMain.addOptionWithValueOld(
    moduleName          => moduleName
    , moduleOptionName  => moduleOptionName
    , valueTypeCode     => pkg_OptionMain.Number_ValueTypeCode
    , optionName        => optionName
    , numberValue       => defaultNumberValue
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка добавлениия опции('
        || ' moduleName="' || moduleName || '"'
        || ', moduleOptionName="' || moduleOptionName || '"'
        || ', optionName="' || optionName || '"'
        || ', defaultNumberValue="' || defaultNumberValue || '"'
        || ')'
      )
    , true
  );
end addOptionNumber;

/* proc: addOptionString
  Устаревшая функция, в других модулях следует использовать функции из типа
  <opt_option_list_t>.
*/
procedure addOptionString(
  moduleName varchar2
  , moduleOptionName varchar2
  , optionName varchar2
  , defaultStringValue varchar2 := null
)
is
begin
  pkg_OptionMain.addOptionWithValueOld(
    moduleName          => moduleName
    , moduleOptionName  => moduleOptionName
    , valueTypeCode     => pkg_OptionMain.String_ValueTypeCode
    , optionName        => optionName
    , stringValue       => defaultStringValue
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка добавлениия опции('
        || ' moduleName="' || moduleName || '"'
        || ', moduleOptionName="' || moduleOptionName || '"'
        || ', optionName="' || optionName || '"'
        || ', defaultStringValue="' || defaultStringValue || '"'
        || ')'
      )
    , true
  );
end addOptionString;



/* group:	Устаревшие интерфейсные функции */

/* func: getMask
  Устаревшая функция.
*/
function getMask return sys_refcursor
is
  resultSet sys_refcursor;
begin
  open resultSet for
    select
      mask_id
    , mask_name
  from doc_mask;

  return resultSet;

end getMask;

/* func: findOption( DEPRECATED)
  Устаревшая функция.
*/
function findOption
(
    optionId        integer  := null
  , optionName	    varchar2 := null
  , optionShortName	varchar2 := null
  , batchShortName	varchar2 := null
  , isGlobal	      number   := null
  , maskId	        integer  := null
  , optionValue	    varchar2 := null
  , maxRowCount	    integer  := null
  , operatorId	    integer  := null
) return sys_refcursor
is
  -- условия поиска
  searchCondition varchar2 (4000);
  -- возвращаемый курсор
  resultSet sys_refcursor;
  -- строка с запросом
  dynamicSql dyn_dynamic_sql_t :=  dyn_dynamic_sql_t( '
    select *
    from
    (
      select
          option_id
        , option_name
        , option_short_name
        , is_global
        , mask_id
        , mask_name
        , case mask_id
            when 1 then replace (to_char (integer_value), '','', ''.'')
            when 2 then replace (to_char (integer_value), '','', ''.'')
            when 3 then string_value
            when 4 then to_char (datetime_value, ''dd.mm.yyyy hh24:mi:ss'')
          end as option_value'
|| case when batchShortName is not null then
'
        , opb.batch_short_name'
end
|| '
      from opt_option o
      inner join
      (
        select
            option_id
          , max (datetime_value) keep (dense_rank last order by date_ins) as datetime_value
          , max (integer_value) keep (dense_rank last order by date_ins) as integer_value
          , max (string_value) keep (dense_rank last order by date_ins) as string_value
        from opt_option_value
        group by option_id
      ) v using (option_id)
      inner join doc_mask m using (mask_id)'
|| case when batchShortName is not null then
'
      inner join
        (
        select
          op.option_id
          , max( b.batch_short_name) as batch_short_name
        from
          opt_option op
          , (
            select
              b.batch_short_name
              , replace(
                  replace( b.batch_short_name, ''%'',''\%'')
                  , ''_'',''\_''
                )
                || ''_%''
                as option_short_name_mask
            from
              sch_batch b
          ) b
        where
          op.option_short_name like b.option_short_name_mask escape ''\''
        group by
          op.option_id
        ) opb
        using ( option_id)'
end
|| '
    )
    where $(condition)
  ');
begin
  -- проверка прав оператора
  checkRole( operatorId, readOnlyAccessFlag => 1);

  -- формирование параметров запроса
  dynamicSql.addCondition ( 'option_id = ', optionId is null);
  dynamicSql.addCondition ( 'upper (option_name) like', false, 'option_name');
  dynamicSql.addCondition ( 'upper (option_short_name) like', false, 'option_short_name');
  dynamicSql.addCondition (
    'upper( batch_short_name) =', batchShortName is null, 'batch_short_name'
  );
  dynamicSql.addCondition ( 'is_global =', isGlobal is null);
  dynamicSql.addCondition ( 'mask_id =', maskId is null);
  dynamicSql.addCondition ( 'option_value =', optionValue is null);
  dynamicSql.addCondition ( 'rownum <=', maxRowCount is null, 'maxRowCount');
  dynamicSql.useCondition( 'condition');

  open
    resultSet
  for
    dynamicSql.getSqlText()
  using
      optionId
    , '%' || upper (optionName)      || '%'
    , '%' || upper (optionShortName) || '%'
    , upper (batchShortName)
    , isGlobal
    , maskId
    , optionValue
    , maxRowCount;

  return resultSet;

end findOption;

/* func: getStorageRule
  Устаревшая функция.
*/
function getStorageRule (maskId integer) return sys_refcursor
is
  resultSet sys_refcursor;
begin
  open resultSet for
    select
      mask_id
    , storage_rule_id
    , mask_oracle
  from doc_mask
  where mask_id = nvl (maskId, mask_id);

  return resultSet;

end getStorageRule;

end pkg_Option;
/
