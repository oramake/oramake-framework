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
        inner join v_op_role rl
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
        and rl.role_short_name in (
          pkg_OptionMain.Admin_RoleSName
          , case when opt.local_role_suffix is not null then
              'OptAdminAllOption' || opt.local_role_suffix
            end
          , case when readOnlyAccessFlag = 1 then
              pkg_OptionMain.Show_RoleSName
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
  rec opt_option%rowtype;

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
    , moduleId                    => rec.module_id
    , objectShortName             => rec.object_short_name
    , objectTypeId                => rec.object_type_id
    , optionShortName             => rec.option_short_name
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
  opt opt_option%rowtype;

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

  -- Текущие данные параметра
  opt opt_option%rowtype;

begin
  if coalesce( checkRoleFlag, 1) != 0 then
    checkRole( operatorId);
  end if;
  pkg_OptionMain.lockOption(
    rowData         => opt
    , optionId      => optionId
  );
  if opt.access_level_code != pkg_OptionMain.Full_AccessLevelCode then
    raise_application_error(
      pkg_Error.ProcessError
      , 'Удаление параметра через интерфейс запрещено ('
        || ' access_level_code="' || opt.access_level_code || '"'
        || ', optionId=' || optionId
        || ').'
    );
  end if;
  pkg_OptionMain.deleteOption(
    optionId                      => optionId
    , operatorId                  => operatorId
  );
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
  opt opt_option%rowtype;

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
  opt opt_option%rowtype;

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
  opt opt_option%rowtype;

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
      , maxRowCount    => maxRowCount
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

end pkg_Option;
/
