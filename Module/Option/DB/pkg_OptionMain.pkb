create or replace package body pkg_OptionMain is
/* package body: pkg_OptionMain::body */



/* group: Константы */

/* iconst: OldTestOptionName_Suffix
  Стандартный суффикс, с помощью которого строится название тестового
  параметра в устаревшей таблице opt_option.
*/
OldTestOptionName_Suffix varchar2(10) := ' (тест)';

/* iconst: ListSeparator_Default
  Символ, используемый по умолчанию в качестве разделителя в списке значений
  параметра строкового типа, а тажке для списка значений параметра числового
  типа и типа дата.
*/
ListSeparator_Default constant varchar2(1) := ';';

/* iconst: DateValue_ListFormat
  Формат хранения значения типа дата в списке значений.
  Модификатор "fx" указан, чтобы избежать некорректного преобразования строки
  с датой, например "01.10.2011" в дату "20.10.0001 11:00:00".
  В связи с этим для возможности успешного преобразования даты без времени
  при необходимости добавляется время " 00:00:00".
*/
DateValue_ListFormat constant varchar2(30) := 'fxyyyy-mm-dd hh24:mi:ss';

/* iconst: NumberValue_ListFormat
  Формат хранения числового значения в списке значений.
*/
NumberValue_ListFormat constant varchar2(10) := 'tm9';

/* iconst: Number_ListDecimalChar
  Символ десятичного разделителя, используемый при хранении числового значения
  в списке значений.
*/
Number_ListDecimalChar constant varchar2(1) := '.';




/* group: Переменные */

/* ivar: logger
  Логер пакета.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => Module_Name
  , objectName  => 'pkg_OptionMain'
);

/* ivar: saveValueHistoryFlag
  Флаг добавления исторических записей в таблицу <opt_value_history>
  при изменении данных в таблице <opt_value> ( 1 да ( по умолчанию), 0 нет).
*/
saveValueHistoryFlag integer := null;

/* ivar: currentUsedOperatorId
  Текущий установленный Id оператора, для которого может использоваться
  значение, для использования в представлении <v_opt_option_value>.
*/
currentUsedOperatorId integer := null;



/* group: Поддержка устаревших объектов */

/* itype: IdListT
  Список Id записей.
*/
type IdListT is table of integer;

/* itype: OptionSNameListT
  Список коротких названий записей.
*/
type OptionSNameListT is table of opt_option.option_short_name%type;

/* iconst: BatchLoader_ModuleName
  Имя модуля BatchLoader.
*/
BatchLoader_ModuleName constant varchar2(50) := 'BatchLoader';

/* iconst: Scheduler_SvnRoot
  Путь в SVN к корневому каталогу модуля Scheduler.
*/
Scheduler_SvnRoot constant varchar2(100) := 'Oracle/Module/Scheduler';

/* iconst: Batch_ObjectTypeShortName
  Короткое название типа объекта для пакетных заданий модуля Scheduler.
*/
Batch_ObjectTypeShortName constant varchar2(30) := 'batch';

/* ivar: isCopyNew2OldChange
  Признак копирования изменений, вносимых в новые таблицы, в устаревшие
  таблицы.
*/
isCopyNew2OldChange boolean := true;

/* ivar: isCopyOld2NewChange
  Признак копирования изменений, вносимых в устаревшие таблицы, в новые
  таблицы.
*/
isCopyOld2NewChange boolean := true;

/* ivar: isSkipCheckNew2OldSync
  Признак пропуска проверки отсутствие расхождений между значениями параметров
  в новых и устаревших таблицах при выполнении процедуры <checkNew2OldSync>
  ( по умолчанию не пропускать).
*/
isSkipCheckNew2OldSync boolean := false;

/* ivar: onChangeTableName
  Имя таблицы, над которой выполняется DML ( OPT_OPTION / OPT_OPTION_VALUE).
*/
onChangeTableName varchar2(30);

/* ivar: onChangeStatementType
  Тип DML, выполняемого над таблицей ( INSERT / UPDATE / DELETE).
*/
onChangeStatementType varchar2(30);

/* ivar: onChangeIdList
  Список Id измененных записей.
*/
onChangeIdList IdListT;

/* ivar: onDeleteOptionSNameList
  Список значений названий параметров ( поле option_short_name) для удаляемых
  из <opt_option> записей.
*/
onDeleteOptionSNameList OptionSNameListT;

/* ivar: schedulerExistsInfo
  Информация по наличии модуля Scheduler в своей схеме
  ( null неизвестно, 0 отсутствует, 1 присутствует без поля module_id,
    2 присутствует с полем module_id)
*/
schedulerExistsInfo number(1) := null;



/* group: Функции */

procedure checkNew2OldSync;

/* func: getCurrentUsedOperatorId
  Возвращает текущий установленный Id оператора, для которого может
  использоваться значение, для использования в представлении
  <v_opt_option_value>.
*/
function getCurrentUsedOperatorId
return integer
is
begin
  return currentUsedOperatorId;
end getCurrentUsedOperatorId;



/* group: Типы объектов */

/* func: getObjectTypeId
  Возвращает Id типа объекта.

  Параметры:
  moduleId                    - Id модуля, к которому относится тип объекта
  objectTypeShortName         - короткое название типа объекта
  raiseNotFoundFlag           - выбрасывать ли исключение в случае отсутствия
                                записи ( 1 да ( по умолчанию), 0 нет)

  Возврат:
  Id типа объекта ( из таблицы <opt_object_type>) либо null, если запись не
  найдена и значение raiseNotFoundFlag равно 0.
*/
function getObjectTypeId(
  moduleId integer
  , objectTypeShortName varchar2
  , raiseNotFoundFlag integer := null
)
return integer
is

  -- Id типа объекта
  objectTypeId integer;

begin
  select
    min( t.object_type_id)
  into objectTypeId
  from
    opt_object_type t
  where
    t.module_id = moduleId
    and t.object_type_short_name = objectTypeShortName
    and t.deleted = 0
  ;
  if objectTypeId is null and coalesce( raiseNotFoundFlag, 1) != 0 then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Тип объекта не найден.'
    );
  end if;
  return objectTypeId;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при определении Id типа объекта ('
        || ' moduleId=' || moduleId
        || ', objectTypeShortName="' || objectTypeShortName || '"'
        || ', raiseNotFoundFlag=' || raiseNotFoundFlag
        || ').'
      )
    , true
  );
end getObjectTypeId;

/* func: createObjectType
  Создает тип объекта.

  Параметры:
  moduleId                    - Id модуля, к которому относится тип объекта
  objectTypeShortName         - короткое название типа объекта
  objectTypeName              - название типа объекта
  operatorId                  - Id оператора ( по умолчанию текущий)

  Возврат:
  Id типа объекта.
*/
function createObjectType(
  moduleId integer
  , objectTypeShortName varchar2
  , objectTypeName varchar2
  , operatorId integer := null
)
return integer
is

  -- Id типа объекта
  objectTypeId integer;

begin
  insert into
    opt_object_type
  (
    module_id
    , object_type_short_name
    , object_type_name
    , operator_id
  )
  values
  (
    moduleId
    , objectTypeShortName
    , objectTypeName
    , operatorId
  )
  returning
    object_type_id
  into
    objectTypeId
  ;
  return objectTypeId;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при создании типа объекта ('
        || ' moduleId=' || moduleId
        || ', objectTypeShortName="' || objectTypeShortName || '"'
        || ').'
      )
    , true
  );
end createObjectType;

/* func: mergeObjectType
  Создает или обновляет тип объекта.

  Параметры:
  moduleId                    - Id модуля, к которому относится тип объекта
  objectTypeShortName         - короткое название типа объекта
  objectTypeName              - название типа объекта
  operatorId                  - Id оператора ( по умолчанию текущий)

  Возврат:
  - флаг внесения изменений ( 0 нет изменений, 1 если изменения внесены)
*/
function mergeObjectType(
  moduleId integer
  , objectTypeShortName varchar2
  , objectTypeName varchar2
  , operatorId integer := null
)
return integer
is

  -- Флаг внесения изменений
  isChanged integer := 0;

begin
  merge into
    opt_object_type d
  using
    (
    select
      moduleId as module_id
      , objectTypeShortName as object_type_short_name
      , objectTypeName as object_type_name
      , 0 as deleted
    from
      dual
    minus
    select
      t.module_id
      , t.object_type_short_name
      , t.object_type_name
      , t.deleted
    from
      opt_object_type t
    ) s
  on (
    d.module_id = s.module_id
    and d.object_type_short_name = s.object_type_short_name
    )
  when not matched then
    insert
    (
      module_id
      , object_type_short_name
      , object_type_name
      , deleted
      , operator_id
    )
    values
    (
      s.module_id
      , s.object_type_short_name
      , s.object_type_name
      , s.deleted
      , operatorId
    )
  when matched then
    update set
      d.object_type_name            = s.object_type_name
      , d.deleted                   = s.deleted
  ;
  isChanged := sql%rowcount;
  return isChanged;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при создании или обновлении типа объекта ('
        || ' moduleId=' || moduleId
        || ',  objectTypeShortName="' || objectTypeShortName || '"'
        || ').'
      )
    , true
  );
end mergeObjectType;

/* proc: deleteObjectType
  Удаляет тип объекта.

  Параметры:
  moduleId                    - Id модуля, к которому относится тип объекта
  objectTypeShortName         - короткое название типа объекта
  operatorId                  - Id оператора, выполняющего операцию ( по
                                умолчанию текущий)

  Замечания:
  - в случае использования типа в актуальных данных выбрасывается исключение;
  - при отсутствии использования запись удаляется физически, иначе ставится
    флаг логического удаления;
*/
procedure deleteObjectType(
  moduleId integer
  , objectTypeShortName varchar2
  , operatorId integer := null
)
is

  -- Флаг использования ( 1 - в действующих записях, 0 - только в логически
  -- удаленных, null - не используется)
  usedFlag integer;



  /*
    Блокирует запись по типу объекта.
  */
  procedure lockObjectType
  is
  begin
    select
      coalesce(
        (
        select
          1 - min( t.deleted) as used_flag
        from
          opt_option_new t
        where
          t.object_type_id = d.object_type_id
        )
        , (
          select
            0 as used_flag
          from
            opt_option_history t
          where
            t.object_type_id = d.object_type_id
            and rownum <= 1
          )
      )
    into usedFlag
    from
      opt_object_type d
    where
      d.module_id = moduleId
      and d.object_type_short_name = objectTypeShortName
      and d.deleted = 0
    for update of d.deleted nowait
    ;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при блокировке записи.'
        )
      , true
    );
  end lockObjectType;



-- deleteObjectType
begin
  lockObjectType();
  if usedFlag is null then
    delete
      opt_object_type d
    where
      d.module_id = moduleId
      and d.object_type_short_name = objectTypeShortName
    ;
  elsif usedFlag = 0 then
    update
      opt_object_type d
    set
      d.deleted = 1
    where
      d.module_id = moduleId
      and d.object_type_short_name = objectTypeShortName
    ;
  else
    raise_application_error(
      pkg_Error.ProcessError
      , 'Есть действующие настроечные параметры, относящиеся к объектам'
        || ' указанного типа.'
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при удалении типа объекта ('
        || ' moduleId=' || moduleId
        || ', objectTypeShortName="' || objectTypeShortName || '"'
        || ').'
      )
    , true
  );
end deleteObjectType;



/* group: Настроечные параметры */

/* func: getDecryptValue
  Возвращает значение или список значений в расшифрованном виде.

  Параметры:
  stringValue                 - строка с зашифрованным значением либо со
                                списком зашифрованных значений
  listSeparator               - символ, используемый в качестве разделителя в
                                списке значений
                                ( null если список не используется)

  Возврат:
  строка с расшифрованным значением либо списком расшифрованных значений
  ( с разделителем listSeparator)
*/
function getDecryptValue(
  stringValue varchar2
  , listSeparator varchar2
)
return varchar2
is

  -- Строка с расшифрованным значением либо списком расшифрованных значений
  outString opt_value.string_value%type;

  -- Индекс значения в списке ( начиная с 1)
  valueIndex pls_integer := 0;

  -- Позиция первого символа значения в строке
  beginPos pls_integer := 1;

  -- Позиция за последним символом значения в строке
  endPos pls_integer := 1;

  -- Длина строки
  len pls_integer;

begin
  logger.trace( 'getDecryptValue: stringValue="' || stringValue || '"');
  len := coalesce( length( stringValue), 0);
  while endPos <= len loop
    valueIndex := valueIndex + 1;
    endPos :=
      case when listSeparator is not null then
        instr( stringValue , listSeparator, beginPos)
      else
        0
      end
    ;
    if endPos = 0 then
      endPos := len + 1;
    end if;
    outString :=
      outString
      || case when valueIndex > 1 then listSeparator end
      || case when endPos > beginPos then
          pkg_OptionCrypto.decrypt(
            substr( stringValue, beginPos, endPos - beginPos)
          )
        end
    ;
    beginPos := endPos + 1;
  end loop;
  return outString;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при расшифровке строки со значением.'
      )
    , true
  );
end getDecryptValue;

/* func: getOldOptionId
  Получение id опции из устаревшей таблицы <opt_option> по имени модуля и
  короткому наименованию, которые используются для формирования значения
  option_short_name.
  Функция создана вместо ранее существовавшей в пакете pkg_Option внутренней
  функции getOptionId и отличается от нее:
  - добавлением параметра raiseNotFoundFlag;
  - выполнением поиска по opt_option вместо v_opt_option, что обеспечивает
    успешное выполнение при отсутствии ранее заданного значения;

  Параметры:
  moduleName                  - имя модуля
  moduleOptionName            - имя опции уникальное в пределах модуля
  raiseNotFoundFlag           - выбрасывать ли исключение в случае отсутствия
                                значения ( 1 да ( по умолчанию), 0 нет)
*/
function getOldOptionId(
  moduleName varchar2
  , moduleOptionName varchar2
  , raiseNotFoundFlag integer := null
)
return integer
is

  -- Id опции
  optionId v_opt_option.option_id%type;

  -- Короткое наименование опции
  optionShortName v_opt_option.option_short_name%type
    -- функция getOptionShortName( moduleName, moduleOptionName) в pkg_Option
    := moduleName || '.' || moduleOptionName
  ;

-- getOldOptionId
begin
  select
    option_id
  into
    optionId
  from
    opt_option
  where
    option_short_name = optionShortName
  ;
  return
    optionId
  ;
exception when others then
  if raiseNotFoundFlag = 0 and sqlcode = pkg_Error.NoDataFound then
    logger.clearErrorStack();
    return null;
  else
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка получения id опции ('
          || ' moduleName="' || moduleName || '"'
          || ', moduleOptionName="' || moduleOptionName || '"'
          || ', raiseNotFoundFlag=' || raiseNotFoundFlag
          || ')'
        )
      , true
    );
  end if;
end getOldOptionId;

/* proc: getOptionInfoOld
  Возвращает Id настроечного параметра и флаг указания для параметра типа БД
  по названию из устаревшей таблицы.

  Параметры:
  optionId                    - Id параметра ( из таблицы <opt_option_new>)
                                ( возврат)
  prodValueFlag               - флаг использования значения только в
                                промышленных ( либо тестовых) БД
                                ( 1 только в промышленных БД, 0 только в
                                тестовых БД, null без ограничений)
                                ( возврат)
  moduleName                  - имя модуля
  moduleOptionName            - имя опции уникальное в пределах модуля
  raiseNotFoundFlag           - выбрасывать ли исключение в случае отсутствия
                                параметра ( 1 да ( по умолчанию), 0 нет)

  Замечания:
  - если параметр не найден и значение raiseNotFoundFlag равно 0, то в
    параметрах optionId и prodValueFlag возвращается null;
*/
procedure getOptionInfoOld(
  optionId out integer
  , prodValueFlag out integer
  , moduleName varchar2
  , moduleOptionName varchar2
  , raiseNotFoundFlag integer := null
)
is

  -- Короткое наименование опции
  optionShortName v_opt_option.option_short_name%type
    -- функция getOptionShortName( moduleName, moduleOptionName) в pkg_Option
    := moduleName || '.' || moduleOptionName
  ;

begin
  select
    min( opn.option_id) as option_id
    , min(
        case when opn.test_prod_sensitive_flag = 1 then
          case when
              moduleOptionName like '%_' || OldTestOption_Suffix
            then 0
            else 1
          end
        end
      )
      as prod_value_flag
  into optionId, prodValueFlag
  from
    opt_option_new opn
  where
    opn.old_option_short_name =
      (
      select
        case when
          opt.option_short_name like '%_' || OldTestOption_Suffix
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
        opt.option_short_name = optionShortName
      )
    and opn.deleted = 0
  ;
  if optionId is null and coalesce( raiseNotFoundFlag, 1) != 0 then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Настроечный параметр не найден.'
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при определении Id параметра по устаревшему названию ('
        || ' moduleName="' || moduleName || '"'
        || ', moduleOptionName="' || moduleOptionName || '"'
        || ', raiseNotFoundFlag=' || raiseNotFoundFlag
        || ').'
      )
    , true
  );
end getOptionInfoOld;

/* iproc: insertOptionOld( BASE)
  Добавляет запись для настроечного параметра в устаревшую таблицу <opt_option>.

  Параметры:
  rowData                     - данные записи ( возврат)
  oldOptionShortName          - короткое название параметра в таблице
                                opt_option
  storageValueTypeCode        - код типа для хранения значения параметра
  oldOptionName               - название параметра в таблице opt_option
  optionId                    - Id добавляемой записи
                                ( по умолчанию формируется автоматически)
  operatorId                  - Id оператора ( по умолчанию текущий)

  Замечания:
  - значение переменной isCopyOld2NewChange при выполнении процедуры не
    изменяется;
*/
procedure insertOptionOld(
  rowData out nocopy opt_option%rowtype
  , oldOptionShortName varchar2
  , storageValueTypeCode varchar2
  , oldOptionName varchar2
  , optionId integer := null
  , operatorId integer
)
is



  /*
    Заполнение полей записи.
  */
  procedure fillData
  is
  begin
    rowData.option_id := optionId;
    rowData.option_short_name := oldOptionShortName;
    rowData.option_name := oldOptionName;
    rowData.is_global := 1;
    rowData.mask_id :=
      case storageValueTypeCode
        when Date_ValueTypeCode    then 4
        when Number_ValueTypeCode  then 1
        when String_ValueTypeCode  then 3
      end
    ;
    rowData.operator_id := operatorId;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при заполнении полей записи.'
        )
      , true
    );
  end fillData;



  /*
    Вставка записи в opt_option.
  */
  procedure insertRecord
  is
  begin
    insert into
      opt_option
    values
      rowData
    returning
      option_id
      , date_ins
    into
      rowData.option_id
      , rowData.date_ins
    ;
    logger.trace(
      'insertOptionOld: opt_option inserted: option_id=' || rowData.option_id
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при вставке записи в opt_option ('
          || ' option_short_name="' || rowData.option_short_name || '"'
          || ', mask_id=' || rowData.mask_id
          || ').'
        )
      , true
    );
  end insertRecord;



-- insertOptionOld
begin
  fillData();
  insertRecord();
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при добавлении записи в устаревшую таблицу opt_option ('
        || ' oldOptionShortName="' || oldOptionShortName || '"'
        || ', storageValueTypeCode="' || storageValueTypeCode || '"'
        || ').'
      )
    , true
  );
end insertOptionOld;

/* iproc: insertOptionOld
  Добавляет запись для настроечного параметра в устаревшую таблицу <opt_option>.

  Параметры:
  rowData                     - данные записи ( возврат)
  moduleId                    - Id модуля, к которому относится параметр
  objectShortName             - короткое название объекта модуля
  objectTypeId                - Id типа объекта
  optionShortName             - короткое название параметра
                                ( в таблице opt_option_new)
  storageValueTypeCode        - код типа для хранения значения параметра
  optionName                  - название параметра
                                ( в таблице opt_option_new)
  testOptionFlag              - флаг добавления тестового параметра
                                ( 1 да, 0 нет)
  optionId                    - Id добавляемой записи
                                ( по умолчанию формируется автоматически)
  prodOldOptionShortName      - короткое название промышленного параметра в
                                таблице opt_option
                                ( по умолчанию формируется автоматически)
  operatorId                  - Id оператора
*/
procedure insertOptionOld(
  rowData out nocopy opt_option%rowtype
  , moduleId integer
  , objectShortName varchar2
  , objectTypeId integer
  , optionShortName varchar2
  , storageValueTypeCode varchar2
  , optionName varchar2
  , testOptionFlag integer
  , optionId integer := null
  , prodOldOptionShortName varchar2 := null
  , operatorId integer
)
is

  -- Старое значение признака копирования в новые таблицы
  isCopyOld2NewChangeOld boolean := isCopyOld2NewChange;

  -- Значения полей добавляемой записи
  oldOptionShortName opt_option.option_short_name%type;
  oldOptionName opt_option.option_name%type;


  /*
    Заполнение полей записи.
  */
  procedure fillData
  is
  begin
    if prodOldOptionShortName is null then
      select
        md.module_name
        || case when objectShortName is not null then
            '.' || objectShortName
          end
        || '.'
        || optionShortName
        || case when testOptionFlag = 1 then
            OldTestOption_Suffix
          end
      into oldOptionShortName
      from
        v_mod_module md
        left outer join opt_object_type ot
          on ot.object_type_id = objectTypeId
      where
        md.module_id = moduleId
      ;
      oldOptionName :=
        optionName
        || case when testOptionFlag = 1 then
            OldTestOptionName_Suffix
          end
      ;
    else
      oldOptionShortName :=
        prodOldOptionShortName
        || case when testOptionFlag = 1 then
            OldTestOption_Suffix
          end
      ;
    end if;
    oldOptionName :=
      optionName
      || case when testOptionFlag = 1 then
          OldTestOptionName_Suffix
        end
    ;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при заполнении полей записи.'
        )
      , true
    );
  end fillData;



-- insertOptionOld
begin

  -- Исключаем обратное копирование изменений триггерами
  isCopyOld2NewChange := false;

  fillData();
  insertOptionOld(
    rowData                 => rowData
    , oldOptionShortName    => oldOptionShortName
    , storageValueTypeCode  => storageValueTypeCode
    , oldOptionName         => oldOptionName
    , optionId              => optionId
    , operatorId            => operatorId
  );

  isCopyOld2NewChange := isCopyOld2NewChangeOld;
exception when others then
  isCopyOld2NewChange := isCopyOld2NewChangeOld;
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при добавлении записи в устаревшую таблицу opt_option ('
        || ' moduleId=' || moduleId
        || ', objectShortName="' || objectShortName || '"'
        || ', objectTypeId=' || objectTypeId
        || ', optionShortName="' || optionShortName || '"'
        || ', storageValueTypeCode="' || storageValueTypeCode || '"'
        || ').'
      )
    , true
  );
end insertOptionOld;

/* iproc: updateOptionOld
  Обновляет данные параметра в записях устаревшей таблицы <opt_option>.

  Параметры:
  optionId                    - Id параметра ( в таблице opt_option_new)
  testProdSensitiveFlag       - флаг указания для значения параметра типа базы
                                данных ( тестовая или промышленная), для
                                которого оно предназначено
                                ( 1 да, 0 нет)
  storageValueTypeCode        - код типа для хранения значения параметра
  optionName                  - название параметра
                                ( в таблице opt_option_new)
  oldMaskId                   - Id маски для значения параметра
*/
procedure updateOptionOld(
  optionId integer
  , testProdSensitiveFlag integer
  , storageValueTypeCode varchar2
  , optionName varchar2
  , oldMaskId integer
)
is

  -- Старое значение признака копирования в новые таблицы
  isCopyOld2NewChangeOld boolean := isCopyOld2NewChange;



  /*
    Изменяет данные параметра.
  */
  procedure updateOptionData(
    prodValueFlag integer
  )
  is
  begin
    update
      opt_option d
    set
      d.mask_id = oldMaskId
      , d.option_name =
        optionName
        || case when prodValueFlag = 0 then OldTestOptionName_Suffix end
    where
      d.option_id in
        (
        select distinct
          vlh.old_option_id
        from
          v_opt_value_history vlh
        where
          vlh.old_option_value_del_date is null
          and vlh.deleted = 0
          and vlh.value_id in
            (
            select
              vl.value_id
            from
              opt_value vl
            where
              vl.option_id = optionId
              and vl.deleted = 0
              and (
                vl.prod_value_flag = prodValueFlag
                or prodValueFlag is null
                  and vl.prod_value_flag is null
              )
              and vl.storage_value_type_code = storageValueTypeCode
              -- возможность задания значений для конкретной БД / оператора не
              -- поддерживается для устаревших объектов
              and vl.instance_name is null
              and vl.used_operator_id is null
            )
        )
      or nullif( prodValueFlag, 1) is null
        and d.option_id = optionId
    ;
    logger.trace(
      'updateOptionOld: opt_option updated:'
      || ' for new option_id=' || optionId
      || ', prodValueFlag=' || prodValueFlag
      || ': ' || sql%rowcount || ' rows'
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при изменении названия параметра ('
          || ' prodValueFlag=' || prodValueFlag
          || ').'
        )
      , true
    );
  end updateOptionData;



-- updateOptionOld
begin

  -- Исключаем обратное копирование изменений триггерами
  isCopyOld2NewChange := false;

  updateOptionData( prodValueFlag => nullif( testProdSensitiveFlag, 0));
  if testProdSensitiveFlag = 1 then
    updateOptionData( prodValueFlag => 0);
  end if;

  isCopyOld2NewChange := isCopyOld2NewChangeOld;
exception when others then
  isCopyOld2NewChange := isCopyOld2NewChangeOld;
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при обновлении данных параметра'
        || ' в устаревшей таблице opt_option ('
        || ' optionId=' || optionId
        || ', testProdSensitiveFlag=' || testProdSensitiveFlag
        || ', storageValueTypeCode="' || storageValueTypeCode || '"'
        || ').'
      )
    , true
  );
end updateOptionOld;

/* iproc: setOldDelDate
  Устанавливает даты удаления записей из устаревших таблиц.

  Параметры:
  valueId                     - Id значения
  valueHistoryId              - Id исторической записи ( null если обновление
                                нужно выполнить в таблице opt_value)
  oldOptionValueDelDate       - устанавливаемая дата удаления из
                                opt_option_value
                                ( по умолчанию не менять)
  oldOptionDelDate            - устанавливаемая дата удаления из opt_option
                                ( по умолчанию не менять)

  Замечания:
  - в случае обновления таблицы opt_option исключается создание новой
    исторической записи;
*/
procedure setOldDelDate(
  valueId integer
  , valueHistoryId integer
  , oldOptionValueDelDate date := null
  , oldOptionDelDate date := null
)
is

  -- Текущее значение флага сохранения истории значений
  oldSaveValueHistoryFlag integer := saveValueHistoryFlag;

begin
  if valueHistoryId is not null then
    update
      opt_value_history t
    set
      t.old_option_value_del_date =
          coalesce( oldOptionValueDelDate, t.old_option_value_del_date)
      , t.old_option_del_date =
          coalesce( oldOptionDelDate, t.old_option_del_date)
    where
      t.value_history_id = valueHistoryId
      and t.value_id = valueId
    ;
  else
    saveValueHistoryFlag := 0;
    update
      opt_value t
    set
      t.old_option_value_del_date =
          coalesce( oldOptionValueDelDate, t.old_option_value_del_date)
      , t.old_option_del_date =
          coalesce( oldOptionDelDate, t.old_option_del_date)
    where
      t.value_id = valueId
    ;
    saveValueHistoryFlag := oldSaveValueHistoryFlag;
  end if;
  logger.trace(
    'setOldDelDate:'
    || case when valueHistoryId is not null then
        ' opt_value_history updated:'
        || ' value_history_id=' || valueHistoryId
        || ','
      else
        ' opt_value updated ( without save history):'
      end
    || ' value_id=' || valueId
    || case when oldOptionValueDelDate is not null then
        ', old_option_value_del_date='
        || to_char( oldOptionValueDelDate, 'dd.mm.yyyy hh24:mi:ss')
      end
    || case when oldOptionDelDate is not null then
        ', old_option_del_date='
        || to_char( oldOptionDelDate, 'dd.mm.yyyy hh24:mi:ss')
      end
  );
exception when others then
  saveValueHistoryFlag := oldSaveValueHistoryFlag;
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при установке дат удаления записей из устаревших таблиц ('
        || ' value_id=' || valueId
        || ', value_history_id=' || valueHistoryId
        || ').'
      )
    , true
  );
end setOldDelDate;

/* iproc: deleteOptionOld( BASE)
  Удаляет записи из устаревшей таблицы opt_option.

  Параметры:
  oldOptionId                 - Id удаляемой записи
*/
procedure deleteOptionOld(
  oldOptionId integer
)
is

  -- Старое значение признака копирования в новые таблицы
  isCopyOld2NewChangeOld boolean := isCopyOld2NewChange;

-- deleteOptionOld
begin

  -- Исключаем обратное копирование изменений триггерами
  isCopyOld2NewChange := false;

  delete
    opt_option d
  where
    d.option_id = oldOptionId
  ;
  if sql%rowcount = 0 then
    raise_application_error(
      pkg_Error.ProcessError
      , 'Запись не найдена.'
    );
  end if;
  logger.trace(
    'deleteOptionOld: opt_option deleted: option_id='
    || oldOptionId
  );

  isCopyOld2NewChange := isCopyOld2NewChangeOld;
exception when others then
  isCopyOld2NewChange := isCopyOld2NewChangeOld;
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при удалении записи из opt_option ('
        || ' oldOptionId=' || oldOptionId
        || ').'
      )
    , true
  );
end deleteOptionOld;

/* iproc: deleteOptionOld
  Удаляет записи из устаревшей таблицы opt_option.

  Параметры:
  valueId                     - Id значения если нужно удалить все связанные
                                с этим значением записи кроме основной
  optionId                    - Id параметра в opt_option_new если нужно
                                удалить только основную запись по параметру
  oldOptionDelDate            - дата удаления для сохранение в поле
                                old_option_del_date
*/
procedure deleteOptionOld(
  valueId integer := null
  , optionId integer := null
  , oldOptionDelDate date
)
is

  cursor dataCur is
    select
      a.old_option_id
      , a.value_id
      , a.value_history_id
    from
      (
      select
        t.old_option_id
        , t.value_id
        , max( t.value_history_id)
          keep ( dense_rank last order by t.change_number)
          as value_history_id
        , max( t.old_option_del_date)
          keep ( dense_rank last order by t.change_number)
          as old_option_del_date
      from
        v_opt_value_history t
      where
        t.value_id in
          (
          select
            vl.value_id
          from
            opt_value vl
          where
            vl.value_id = valueId
            or vl.option_id = optionId
              and vl.instance_name is null
              and vl.used_operator_id is null
              and nullif( vl.prod_value_flag, 1) is null
          )
        and t.deleted = 0
        and t.old_option_id is not null
        and (
          valueId is not null
            and t.old_option_id != t.option_id
          or optionId is not null
            and t.old_option_id = t.option_id
        )
      group by
        t.old_option_id
        , t.value_id
      ) a
    where
      a.old_option_del_date is null
    -- на случай отсутствия значений
    union all
    select
      opt.option_id as old_option_id
      , null as value_id
      , null as value_history_id
    from
      opt_option opt
    where
      opt.option_id = optionId
    order by
      1, 2
  ;

  -- Старое значение признака копирования в новые таблицы
  isCopyOld2NewChangeOld boolean := isCopyOld2NewChange;

  -- Флаг успешного удаления основной записи
  isMainDeleted boolean := false;

-- deleteOptionOld
begin

  -- Исключаем обратное копирование изменений триггерами
  isCopyOld2NewChange := false;

  for rec in dataCur loop
    begin
      if optionId is null or not isMainDeleted then
        deleteOptionOld(
          oldOptionId => rec.old_option_id
        );
        if rec.old_option_id = optionId then
          isMainDeleted := true;
        end if;
      end if;
      if rec.value_id is not null then
        setOldDelDate(
          valueId                 => rec.value_id
          , valueHistoryId        => rec.value_history_id
          , oldOptionDelDate      => oldOptionDelDate
        );
      end if;
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.errorStack(
            'Ошибка при обработке записи ('
            || ' option_id=' || rec.old_option_id
            || ', value_history_id=' || rec.value_history_id
            || ', value_id=' || rec.value_id
            || ').'
          )
        , true
      );
    end;
  end loop;

  isCopyOld2NewChange := isCopyOld2NewChangeOld;
exception when others then
  isCopyOld2NewChange := isCopyOld2NewChangeOld;
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при удалении записей из устаревшей таблицы opt_option ('
        || ' valueId=' || valueId
        || ', optionId=' || optionId
        || ').'
      )
    , true
  );
end deleteOptionOld;

/* func: getOptionId
  Возвращает Id настроечного параметра.

  Параметры:
  moduleId                    - Id модуля, к которому относится параметр
  objectShortName             - короткое название объекта модуля
  objectTypeId                - Id типа объекта
  optionShortName             - короткое название параметра
  raiseNotFoundFlag           - выбрасывать ли исключение в случае отсутствия
                                параметра ( 1 да ( по умолчанию), 0 нет)

  Возврат:
  Id параметра ( из таблицы <opt_option_new>) либо null, если параметр не
  найден и значение raiseNotFoundFlag равно 0.
*/
function getOptionId(
  moduleId integer
  , objectShortName varchar2
  , objectTypeId integer
  , optionShortName varchar2
  , raiseNotFoundFlag integer := null
)
return integer
is

  -- Id параметра
  optionId integer;

begin
  if objectShortName is not null and objectTypeId is null then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Не указан Id типа объекта.'
    );
  end if;
  select
    min( t.option_id)
  into optionId
  from
    opt_option_new t
  where
    t.module_id = moduleId
    and (
      objectShortName is null
        and t.object_short_name is null
        and t.object_type_id is null
      or objectShortName is not null
        and t.object_short_name = objectShortName
        and t.object_type_id = objectTypeId
    )
    and t.option_short_name = optionShortName
    and t.deleted = 0
  ;
  if optionId is null and coalesce( raiseNotFoundFlag, 1) != 0 then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Настроечный параметр не найден.'
    );
  end if;
  return optionId;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при определении Id параметра ('
        || ' moduleId=' || moduleId
        || ', objectShortName="' || objectShortName || '"'
        || ', objectTypeId=' || objectTypeId
        || ', optionShortName="' || optionShortName || '"'
        || ', raiseNotFoundFlag=' || raiseNotFoundFlag
        || ').'
      )
    , true
  );
end getOptionId;

/* proc: lockOption
  Блокирует и возвращает данные параметра.

  Параметры:
  rowData                     - данные записи ( возврат)
  optionId                    - Id параметра

  Замечания:
  - в случае, если запись была логически удалена, выбрасывается исключение;
*/
procedure lockOption(
  rowData out nocopy opt_option_new%rowtype
  , optionId integer
)
is
begin
  select
    t.*
  into rowData
  from
    opt_option_new t
  where
    t.option_id = optionId
  for update nowait;

  if rowData.deleted = 1 then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Запись не найдена ( была логически удалена).'
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при блокировке параметра ('
        || ' optionId=' || optionId
        || ').'
      )
    , true
  );
end lockOption;

/* func: createOption
  Создает настроечный параметр.

  Параметры:
  moduleId                    - Id модуля, к которому относится параметр
  optionShortName             - короткое название параметра
  valueTypeCode               - код типа значения параметра
  optionName                  - название параметра
  objectShortName             - короткое название объекта модуля
                                ( по умолчанию отсутствует)
  objectTypeId                - Id типа объекта
                                ( по умолчанию отсутствует)
  valueListFlag               - флаг задания для параметра списка значений
                                указанного типа ( 1 да, 0 нет ( по умолчанию))
  encryptionFlag              - флаг хранения значений параметра в
                                зашифрованном виде
                                ( 1 да, 0 нет ( по умолчанию))
  testProdSensitiveFlag       - флаг указания для значения параметра типа базы
                                данных ( тестовая или промышленная), для
                                которого оно предназначено
                                ( 1 да, 0 нет ( по умолчанию))
  accessLevelCode             - код уровня доступа к параметру через
                                пользовательский интерфейс
                                ( по умолчанию только изменение значения в
                                  случае хранения значений в зашифрованном
                                  виде, иначе полный доступ)
  optionDescription           - описание параметра
                                ( по умолчанию отсутствует)
  optionId                    - Id создаваемого параметра
                                ( по умолчанию формируется автоматически)
  oldOptionShortName          - короткое название параметра в таблице
                                opt_option
                                ( по умолчанию формируется автоматически)
  oldMaskId                   - Id маски для значения параметра
                                ( по умолчанию формируется автоматически)
  oldOptionNameTest           - название тестового параметра в таблице
                                opt_option
                                ( по умолчанию отсутствует)
  operatorId                  - Id оператора ( по умолчанию текущий)

  Возврат:
  Id параметра.

  Замечания:
  - если в пакете установлен признак <body::isCopyNew2OldChange>, то также
    добавляется запись в устаревшую таблицу opt_option с тем же значением
    option_id;
*/
function createOption(
  moduleId integer
  , optionShortName varchar2
  , valueTypeCode varchar2
  , optionName varchar2
  , objectShortName varchar2 := null
  , objectTypeId integer := null
  , valueListFlag integer := null
  , encryptionFlag integer := null
  , testProdSensitiveFlag integer := null
  , accessLevelCode varchar2 := null
  , optionDescription varchar2 := null
  , optionId integer := null
  , oldOptionShortName varchar2 := null
  , oldMaskId integer := null
  , oldOptionNameTest varchar2 := null
  , operatorId integer := null
)
return integer
is

  -- Данные в виде записи
  rec opt_option_new%rowtype;



  /*
    Заполняет поля записи.
  */
  procedure fillData
  is
  begin
    rec.module_id                 := moduleId;
    rec.option_short_name         := optionShortName;
    rec.value_type_code           := valueTypeCode;
    rec.option_name               := optionName;
    rec.object_short_name         := objectShortName;
    rec.object_type_id            := objectTypeId;
    rec.value_list_flag           := coalesce( valueListFlag, 0);
    rec.encryption_flag           := coalesce( encryptionFlag, 0);
    rec.test_prod_sensitive_flag  := coalesce( testProdSensitiveFlag, 0);
    rec.access_level_code         := coalesce(
      accessLevelCode
      , case when encryptionFlag = 1 then
          Value_AccessLevelCode
        else
          Full_AccessLevelCode
        end
    );
    rec.option_description        := optionDescription;
    rec.option_id                 := optionId;
    rec.old_option_short_name     := oldOptionShortName;
    rec.old_mask_id               := oldMaskId;
    rec.old_option_name_test      := oldOptionNameTest;
    rec.operator_id               := operatorId;

    -- Исключаем ввод тривиального значения в old_option_name_test
    rec.old_option_name_test :=
      nullif(
        rec.old_option_name_test
        , rec.option_name || OldTestOptionName_Suffix
      )
    ;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при заполнении полей записи.'
        )
      , true
    );
  end fillData;



  /*
    Добавляет запись в устаревшую таблицу.
  */
  procedure insertOld
  is

    oldRec opt_option%rowtype;

  begin
    insertOptionOld(
      rowData                 => oldRec
      , moduleId              => rec.module_id
      , objectShortName       => rec.object_short_name
      , objectTypeId          => rec.object_type_id
      , optionShortName       => rec.option_short_name
      , storageValueTypeCode  =>
          case when rec.value_list_flag = 1 then
            String_ValueTypeCode
          else
            rec.value_type_code
          end
      , optionName            => rec.option_name
      , testOptionFlag        => 0
        -- используется при восстановлении ранее удаленного параметра
      , optionId              => rec.option_id
      , prodOldOptionShortName => rec.old_option_short_name
      , operatorId            => rec.operator_id
    );

    rec.option_id             := oldRec.option_id;
    rec.old_option_short_name := oldRec.option_short_name;
    rec.old_mask_id           := oldRec.mask_id;
    rec.old_option_name_test  := null;
  end insertOld;



  /*
    Вставляет запись в таблицу opt_option_new и возвращает результат ( true в
    случае успеха, false в случае ошибки из-за нарушения уникальности).
  */
  function insertRecord
  return boolean
  is
  begin
    insert into
      opt_option_new
    values
      rec
    returning
      option_id
    into
      rec.option_id
    ;
    logger.trace(
      'createOption: opt_option_new inserted:'
      || ' option_id=' || rec.option_id
      || ', value_type_code="' || rec.value_type_code || '"'
      || ', value_list_flag=' || rec.value_list_flag
      || ', test_prod_sensitive_flag=' || rec.test_prod_sensitive_flag
      || ', old_option_short_name="' || rec.old_option_short_name || '"'
    );
    return true;
  exception
    when DUP_VAL_ON_INDEX then
      logger.trace(
        'createOption: insertRecord: DUP_VAL_ON_INDEX error: ' || SQLERRM
      );
      logger.clearErrorStack();
      return false;
    when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.errorStack(
            'Ошибка при вставке записи в таблицу opt_option_new.'
          )
        , true
      );
  end insertRecord;



  /*
    Восстанавливаем ранее удаленную запись.
  */
  procedure restoreDeleted
  is
  begin
    select
      d.option_id
      , d.deleted
    into rec.option_id, rec.deleted
    from
      opt_option_new d
    where
      d.module_id = rec.module_id
      and d.option_short_name = rec.option_short_name
      and (
        rec.object_short_name is null
          and d.object_short_name is null
        or d.object_short_name = rec.object_short_name
          and d.object_type_id = rec.object_type_id
      )
    for update nowait;

    if rec.deleted = 0 then
      raise_application_error(
        pkg_Error.IllegalArgument
        , 'Параметр был создан ранее ('
          || ' option_id=' || rec.option_id
          || ').'
      );
    end if;

    if isCopyNew2OldChange then
      insertOld();
    end if;
    update
      opt_option_new d
    set
      d.value_type_code             = rec.value_type_code
      , d.value_list_flag           = rec.value_list_flag
      , d.encryption_flag           = rec.encryption_flag
      , d.test_prod_sensitive_flag  = rec.test_prod_sensitive_flag
      , d.access_level_code         = rec.access_level_code
      , d.option_name               = rec.option_name
      , d.option_description        = rec.option_description
      , d.old_option_short_name     = rec.old_option_short_name
      , d.old_mask_id               = rec.old_mask_id
      , d.old_option_name_test      = rec.old_option_name_test
      , d.deleted                   = 0
      , d.change_operator_id        = rec.operator_id
    where
      d.option_id = rec.option_id
    ;
    logger.trace(
      'createOption: restore deleted: opt_option_new updated:'
      || ' option_id=' || rec.option_id
      || ', value_type_code="' || rec.value_type_code || '"'
      || ', value_list_flag=' || rec.value_list_flag
      || ', test_prod_sensitive_flag=' || rec.test_prod_sensitive_flag
      || ', old_option_short_name="' || rec.old_option_short_name || '"'
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при восстановлении ранее удаленной записи.'
        )
      , true
    );
  end restoreDeleted;



-- createOption
begin
  if objectShortName is not null and objectTypeId is null then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Не указан Id типа объекта.'
    );
  end if;
  if encryptionFlag = 1 and valueTypeCode != String_ValueTypeCode then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Шифрование реализовано только для значений строкового типа.'
    );
  end if;
  fillData();
  if isCopyNew2OldChange then
    rec.option_id := null;
    insertOld();
  end if;
  if not insertRecord() then
    if isCopyNew2OldChange then
      deleteOptionOld( oldOptionId => rec.option_id);
      rec.option_id := null;
    end if;
    restoreDeleted();
  end if;
  if isCopyNew2OldChange then
    checkNew2OldSync();
  end if;
  return rec.option_id;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при создании параметра ('
        || ' moduleId=' || moduleId
        || ', objectShortName="' || objectShortName || '"'
        || ', objectTypeId=' || objectTypeId
        || ', optionShortName="' || optionShortName || '"'
        || ', optionId=' || optionId
        || ', oldOptionShortName="' || oldOptionShortName || '"'
        || ', old_option_short_name="' || rec.old_option_short_name || '"'
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
  accessLevelCode             - код уровня доступа к параметру через
                                пользовательский интерфейс
  optionName                  - название параметра
  optionDescription           - описание параметра
  moveProdSensitiveValueFlag  - при изменении значения флага
                                testProdSensitiveFlag переносить существующие
                                значения параметра ( общие в промышленные либо
                                промышленные в общие)
                                ( 1 да, 0 нет ( выбрасывать исключение))
                                ( по умолчанию 0)
  deleteBadValueFlag          - удалять значения, которые не соответствуют
                                новым данным настроечного параметра
                                ( 1 да, 0 нет ( выбрасывать исключение))
                                ( по умолчанию 0)
  oldOptionNameTest           - название тестового параметра в таблице
                                opt_option
                                ( используется только при внутренней
                                  синхронизации изменений)
                                ( по умолчанию текущее значение)
  operatorId                  - Id оператора ( по умолчанию текущий)

  Замечания:
  - использование deleteBadValueFlag совместно с moveProdSensitiveValueFlag
    обеспечивает удаление тестовых значений в случае установки
    для параметра значения testProdSensitiveFlag равным в 0
    ( в противном случае при наличии тестовых значений было бы выброшено
      исключение);
*/
procedure updateOption(
  optionId integer
  , valueTypeCode varchar2
  , valueListFlag integer
  , encryptionFlag integer
  , testProdSensitiveFlag integer
  , accessLevelCode varchar2
  , optionName varchar2
  , optionDescription varchar2
  , moveProdSensitiveValueFlag integer := null
  , deleteBadValueFlag integer := null
  , oldOptionNameTest varchar2 := null
  , operatorId integer := null
)
is

  -- Текущие данные
  rec opt_option_new%rowtype;

  -- Id маски для значения параметра
  oldMaskId opt_option_new.old_mask_id%type;

  -- Название тестового параметра в устаревшей таблице ( новое значение)
  newOldOptionNameTest opt_option_new.old_option_name_test%type;



  /*
    Проверяет корректность значений параметра.
  */
  procedure checkValue(
    isSensitiveChanged boolean
  )
  is

    cursor valueCur is
      select
        b.*
      from
        (
        select
          a.*
        from
          (
          select
            vl.*
            , case when
                  vl.value_type_code = valueTypeCode
                  and vl.value_list_flag = valueListFlag
                then 0 else 1
              end
              as is_type_bad
            , case when
                  testProdSensitiveFlag = 0
                    and vl.prod_value_flag is null
                  or testProdSensitiveFlag = 1
                    and vl.prod_value_flag is not null
                then 0 else 1
              end
              as is_test_prod_bad
            , case when
                  vl.date_value is null
                  and vl.number_value is null
                  and vl.string_value is null
                then 0 else 1
              end
              as is_value_exists
          from
            (
            select
              v.*
              , case when v.list_separator is not null then 1 else 0 end
                as value_list_flag
            from
              opt_value v
            where
              v.deleted = 0
            ) vl
          where
            vl.option_id = optionId
          ) a
        ) b
      where
        b.is_type_bad + b.is_test_prod_bad > 0
      order by
        b.value_id
    ;

    -- Признак недопустимого значения
    isBadValue boolean;

    -- Признак необходимости переноса значения при изменении
    -- test_prod_sensitive_flag
    isMoveValue boolean;

    -- Id значения, созданного переносе существующего значения
    moveValueId integer;

  -- checkValue
  begin
    for vr in valueCur loop
      begin
        isBadValue :=
          vr.is_type_bad + vr.is_test_prod_bad > 0
        ;
        isMoveValue :=
          isSensitiveChanged
          and moveProdSensitiveValueFlag = 1
          and vr.is_test_prod_bad = 1
          and vr.is_type_bad = 0
          and (
            testProdSensitiveFlag = 1 and vr.prod_value_flag is null
            or testProdSensitiveFlag = 0 and vr.prod_value_flag = 1
          )
        ;
        if isBadValue then
          if deleteBadValueFlag = 1 or isMoveValue then
            deleteValue(
              valueId             => vr.value_id
              , operatorId        => operatorId
            );

            -- Копируем после удаления, чтобы не нарушить ограничения
            -- уникальности
            if isMoveValue then
              moveValueId := createValue(
                optionId                => optionId
                , prodValueFlag         =>
                    case
                      when vr.prod_value_flag is null then 1
                      when vr.prod_value_flag = 1 then null
                      -- ошибка в алгоритме, обеспечиваем исключение
                      else -1
                    end
                , instanceName          => vr.instance_name
                , usedOperatorId        => vr.used_operator_id
                , valueTypeCode         => vr.value_type_code
                , dateValue             => vr.date_value
                , numberValue           => vr.number_value
                , stringValue           =>
                    case when vr.encryption_flag = 1 then
                      getDecryptValue(
                        stringValue     => vr.string_value
                        , listSeparator => vr.list_separator
                      )
                    else
                      vr.string_value
                    end
                , setValueListFlag    =>
                    case when vr.list_separator is not null then 1 else 0 end
                , valueListSeparator    => vr.list_separator
                , oldOptionValueId      =>
                    case when not isCopyNew2OldChange then
                      vr.old_option_value_id
                    end
                , oldOptionId           => vr.old_option_id
                , oldOptionValueDelDate =>
                    case when not isCopyNew2OldChange then
                      vr.old_option_value_del_date
                    end
                , oldOptionDelDate      => vr.old_option_del_date
                , ignoreTestProdSensitiveFlag => 1
                , fillIdFromOldFlag     => 0
                , operatorId            => operatorId
              );
            end if;
          else
            raise_application_error(
              pkg_Error.ProcessError
              , case
                  when vr.is_type_bad = 1 then
                    'Для параметра ранее было задано значение другого вида ('
                    || ' value_type_code="' || vr.value_type_code || '"'
                    || ', value_list_flag=' || vr.value_list_flag
                    || ').'
                  when vr.is_test_prod_bad = 1 then
                    'Для параметра ранее было задано значение '
                    || case vr.prod_value_flag
                        when 0 then 'для тестовой БД.'
                        when 1 then 'для промышленной БД.'
                        else 'без указания типа БД.'
                      end
                  else
                    'Некорректное значение параметра.'
                end
            );
          end if;
        end if;
      exception when others then
        raise_application_error(
          pkg_Error.ErrorStackInfo
          , logger.errorStack(
              'Ошибка при проверке значения ('
              || ' value_id=' || vr.value_id
              || ').'
            )
          , true
        );
      end;
    end loop;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при проверке существующих значений ('
          || ' valueTypeCode="' || valueTypeCode || '"'
          || ', valueListFlag=' || valueListFlag
          || ', testProdSensitiveFlag=' || testProdSensitiveFlag
          || ').'
        )
      , true
    );
  end checkValue;



  /*
    Изменяет состояние шифрования значений параметра.
  */
  procedure changeValueEncryption
  is

    cursor valueCur is
      select
        vl.*
      from
        opt_value vl
      where
        vl.option_id = optionId
        and vl.deleted = 0
      order by
        vl.value_id
    ;

  begin

    -- Отключаем проверку различий, т.к. они могут быть в случае
    -- одновременного изменения других полей ( например, option_name)
    isSkipCheckNew2OldSync := true;

    for vr in valueCur loop
      -- Обновляем значение, при этом шифрование/дешифрование будет выполнено
      -- в соответствии с настройкой для параметра
      updateValue(
        valueId               => vr.value_id
        , valueTypeCode       => vr.value_type_code
        , dateValue           => vr.date_value
        , numberValue         => vr.number_value
        , stringValue         =>
            case when vr.encryption_flag = 1 then
              getDecryptValue(
                stringValue     => vr.string_value
                , listSeparator => vr.list_separator
              )
            else
              vr.string_value
            end
        , setValueListFlag    =>
            case when vr.list_separator is not null then 1 else 0 end
        , valueListSeparator  => vr.list_separator
        , operatorId          => vr.operator_id
      );
    end loop;
    isSkipCheckNew2OldSync := false;
  exception when others then
    isSkipCheckNew2OldSync := false;
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при изменении шифрования значений ('
          || ' encryptionFlag=' || encryptionFlag
          || ').'
        )
      , true
    );
  end changeValueEncryption;



-- updateOption
begin
  if isCopyNew2OldChange and oldOptionNameTest is not null then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Параметр oldOptionNameTest должен использоваться только внутри пакета.'
    );
  end if;
  if encryptionFlag = 1 and valueTypeCode != String_ValueTypeCode then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Шифрование реализовано только для значений строкового типа.'
    );
  end if;
  lockOption( rec, optionId => optionId);
  if rec.value_type_code != valueTypeCode
        or rec.value_list_flag != valueListFlag
        or rec.test_prod_sensitive_flag != testProdSensitiveFlag
      then
    checkValue(
      isSensitiveChanged =>
        rec.test_prod_sensitive_flag != testProdSensitiveFlag
    );
  end if;
  newOldOptionNameTest :=
    case
      when isCopyNew2OldChange then
        null
      else
        nullif(
          coalesce( oldOptionNameTest, rec.old_option_name_test)
          , optionName || OldTestOptionName_Suffix
        )
    end
  ;
  oldMaskId :=
    case when
      rec.value_type_code != valueTypeCode
        or rec.value_list_flag != valueListFlag
    then
      case
          case when valueListFlag = 1 then
            String_ValueTypeCode
          else
            valueTypeCode
          end
        when Date_ValueTypeCode    then 4
        when Number_ValueTypeCode  then 1
        when String_ValueTypeCode  then 3
      end
    else
      rec.old_mask_id
    end
  ;
  update
    opt_option_new d
  set
    d.value_type_code             = valueTypeCode
    , d.value_list_flag           = valueListFlag
    , d.encryption_flag           = encryptionFlag
    , d.test_prod_sensitive_flag  = testProdSensitiveFlag
    , d.access_level_code         = accessLevelCode
    , d.option_name               = optionName
    , d.option_description        = optionDescription
    , d.old_mask_id               = oldMaskId
    , d.old_option_name_test      = newOldOptionNameTest
    , d.change_operator_id        = operatorId
  where
    d.option_id = optionId
  ;
  logger.trace(
    'updateOption: opt_option_new updated: option_id=' || optionId
  );
  if rec.encryption_flag != encryptionFlag then
    changeValueEncryption();
  end if;
  if isCopyNew2OldChange then
    if coalesce(
              nullif( rec.old_mask_id, oldMaskId)
              , nullif( oldMaskId, rec.old_mask_id)
            )
            is not null
          or rec.option_name != optionName
          -- установили стандартное название тестового параметра
          or newOldOptionNameTest is null
            and rec.old_option_name_test is not null
        then
      updateOptionOld(
        optionId                => optionId
        , testProdSensitiveFlag => testProdSensitiveFlag
        , storageValueTypeCode  =>
            case when valueListFlag = 1 then
              String_ValueTypeCode
            else
              valueTypeCode
            end
        , optionName            => optionName
        , oldMaskId             => oldMaskId
      );
    end if;
    checkNew2OldSync();
  end if;
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

/* proc: deleteOption
  Удаляет настроечный параметр.

  Параметры:
  optionId                    - Id параметра
  operatorId                  - Id оператора ( по умолчанию текущий)

  Замечания:
  - при удалении параметра автоматически удаляются относящиеся к нему значения;
*/
procedure deleteOption(
  optionId integer
  , operatorId integer := null
)
is

  cursor valueCur is
    select
      vl.*
    from
      opt_value vl
    where
      vl.option_id = optionId
      and vl.deleted = 0
    order by
      vl.value_id
  ;

  -- Текущие данные
  rec opt_option_new%rowtype;

-- deleteOption
begin
  lockOption( rec, optionId => optionId);
  for vr in valueCur loop
    deleteValue(
      valueId       => vr.value_id
      , operatorId  => operatorId
    );
  end loop;
  update
    opt_option_new d
  set
    d.deleted = 1
    , d.change_operator_id = operatorId
  where
    d.option_id = optionId
  ;
  logger.trace(
    'deleteOption: opt_option_new set deleted: option_id=' || optionId
  );
  if isCopyNew2OldChange then
    deleteOptionOld(
      optionId            => optionId
      , oldOptionDelDate  => sysdate
    );
    checkNew2OldSync();
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



/* group: Значения параметров */

/* ifunc: insertOptionValueOld
  Добавляет запись для значения параметра в устаревшую таблицу
  <opt_option_value>.

  Параметры:
  oldOptionId                 - Id параметра в таблице opt_option
  dateValue                   - значение типа дата
  numberValue                 - числовое значение
  stringValue                 - строковое значение
  operatorId                  - Id оператора
  copyOld2NewChange           - необходимость копирования изменений в новые
                                таблицы
                                ( по умолчанию нет)

  Возврат:
  Id добавленной записи.
*/
function insertOptionValueOld(
  oldOptionId integer
  , dateValue date
  , numberValue number
  , stringValue varchar2
  , operatorId integer
  , copyOld2NewChange boolean := null
)
return integer
is

  -- Старое значение признака копирования в новые таблицы
  isCopyOld2NewChangeOld boolean := isCopyOld2NewChange;

  -- Id созданной записи
  optionValueId integer;

begin

  -- Настраиваем обратное копирование изменений триггерами
  isCopyOld2NewChange := coalesce( copyOld2NewChange, false);

  insert into
    opt_option_value
  (
    option_id
    , datetime_value
    , integer_value
    , string_value
    , operator_id
  )
  values
  (
    oldOptionId
    , dateValue
    , numberValue
    , stringValue
    , operatorId
  )
  returning
    option_value_id
  into
    optionValueId
  ;
  logger.trace(
    'insertOptionValueOld: opt_option_value inserted:'
    || ' option_id=' || oldOptionId
    || ', option_value_id=' || optionValueId
  );

  isCopyOld2NewChange := isCopyOld2NewChangeOld;

  return optionValueId;
exception when others then
  isCopyOld2NewChange := isCopyOld2NewChangeOld;
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при добавлении записи в устаревшую таблицу opt_option_value ('
        || ' oldOptionId=' || oldOptionId
        || ').'
      )
    , true
  );
end insertOptionValueOld;

/* ifunc: toNumber
  Конвертирует строку с числом в число.

  Параметры:
  valueString                 - строка с числом
  decimalChar                 - десятичный разделитель, используемый в строке
                                ( по умолчанию <Number_ListDecimalChar>)

  Замечания:
  - использовать to_number с указанием десятичного разделителя с помощью
    NLS_NUMERIC_CHARACTERS не получается, т.к. непонятно, какой формат
    указывать во 2-м аргументе, чтобы преобразование работало максимально
    универсально;
*/
function toNumber(
  valueString varchar2
  , decimalChar varchar2 := null
)
return number
is

  -- Используемый в строке десятичный разделитель
  oldDecimalChar varchar2(1);

  -- Десятичный разделитель для to_number ( null если совпадает с
  -- используемым)
  newDecimalChar varchar2(1);

-- toNumber
begin

  -- Определяем необходимость изменения разделителя
  oldDecimalChar := coalesce( decimalChar, Number_ListDecimalChar);
  newDecimalChar := nullif(
    substr( to_char( 0.1, 'tm9'), 1, 1)
    , oldDecimalChar
  );

  if newDecimalChar is not null
      and instr( valueString, newDecimalChar) > 0
      then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'В строке не по назначению используется символ, являющийся'
        || ' десятичным разделителем в сессии ('
        || ' session decimal char="' || newDecimalChar || '"'
        || ' string decimal char="' || oldDecimalChar || '"'
        || ').'
    );
  end if;

  return
    to_number(
      case when newDecimalChar is null then
        valueString
      else
        replace( valueString, oldDecimalChar, newDecimalChar)
      end
    )
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при конвертации строки в число ('
        || ' valueString="' || valueString || '"'
        || ', decimalChar="' || decimalChar || '"'
        || ').'
      )
    , true
  );
end toNumber;

/* ifunc: formatValueString
  Проверяет корректность и форматирует значение в виде строки.

  Параметры:
  valueTypeCode               - код типа значения параметра
  valueString                 - исходная строка со значением
  sourceValueFormat           - формат значения типа дата в исходной строке
                                ( по умолчанию используется "yyyy-mm-dd
                                  hh24:mi:ss" с опциональным указанием
                                  времени)
  sourceDecimalChar           - десятичный разделитель для числового значения
                                в исходной строке
                                ( по умолчанию используется точка)
  encryptionFlag              - флаг шифрования строкового значения
                                ( 1 да, 0 нет ( по умолчанию))
  forbiddenChar               - запрещенный для использования символ
                                ( по умолчанию без ограничений)

  Возврат:
  - отформатированная строка со значением.
*/
function formatValueString(
  valueTypeCode varchar2
  , valueString varchar2
  , sourceValueFormat varchar2 := null
  , sourceDecimalChar varchar2 := null
  , encryptionFlag varchar2 := null
  , forbiddenChar varchar2 := null
)
return varchar2
is

  -- Используемый формат для даты
  valueFormat varchar2(100);

begin
  case valueTypeCode
    when Date_ValueTypeCode then
      valueFormat := coalesce( sourceValueFormat, DateValue_ListFormat);
      return
        to_char(
          to_date(
              valueString
                -- обеспечиваем возможность преобразования даты без времени
                -- при отсутствии явно указанного формата
                || case when
                    valueFormat = 'fxyyyy-mm-dd hh24:mi:ss'
                    and sourceValueFormat is null
                    and valueString like '____-__-__'
                  then
                    ' 00:00:00'
                  end
              , valueFormat
            )
          , DateValue_ListFormat
        )
      ;
    when Number_ValueTypeCode then
      return
        to_char(
          toNumber(
            valueString   => valueString
            , decimalChar => sourceDecimalChar
          )
          , NumberValue_ListFormat
          , 'NLS_NUMERIC_CHARACTERS = ''' || Number_ListDecimalChar || ' '''
        )
      ;
    when String_ValueTypeCode then
      return
        case when encryptionFlag = 1 then
          pkg_OptionCrypto.encrypt(
            valueString
            , forbiddenChar => forbiddenChar
          )
        else
          valueString
        end
      ;
  end case;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при форматировании значения ('
        || ' valueTypeCode="' || valueTypeCode || '"'
        || ', valueString="' || valueString || '"'
        || case when valueFormat is not null then
            ', valueFormat="' || valueFormat || '"'
          end
        || ').'
      )
    , true
  );
end formatValueString;

/* func: formatValueList
  Возвращает список значений в стандартном формате.

  Параметры:
  valueTypeCode               - код типа значения параметра
  listSeparator               - символ, используемый в качестве разделителя
                                в возвращаемом списке
  valueList                   - исходный список значений
  valueListSeparator          - символ, используемый в качестве разделителя
                                в строке со списком значений
                                ( по умолчанию используется ";")
  valueListItemFormat         - формат элементов в строке со списком значений
                                типа дата ( по умолчанию используется
                                "yyyy-mm-dd hh24:mi:ss" с опциональным
                                указанием времени)
  valueListDecimalChar        - десятичный разделитель для строки со списком
                                числовых значений
                                ( по умолчанию используется точка)
  encryptionFlag              - флаг шифрования строковых значений в
                                возвращаемом списке
                                ( 1 да, 0 нет ( по умолчанию))

  Возврат:
  список значений в стандартном формате.
*/
function formatValueList(
  valueTypeCode varchar2
  , listSeparator varchar2
  , valueList varchar2
  , valueListSeparator varchar2 := null
  , valueListItemFormat varchar2 := null
  , valueListDecimalChar varchar2 := null
  , encryptionFlag varchar2 := null
)
return varchar2
is

  -- Отформатированный список
  resultList opt_value.string_value%type;

  -- Индекс значения в списке ( начиная с 1)
  valueIndex pls_integer := 0;

  -- Позиция первого символа значения в строке
  beginPos pls_integer := 1;

  -- Позиция за последним символом значения в строке
  endPos pls_integer := 1;

  -- Длина строки
  len pls_integer;

begin
  resultList := null;
  len := coalesce( length( valueList), 0);
  while endPos <= len loop
    begin
      valueIndex := valueIndex + 1;
      endPos := instr(
        valueList
        , coalesce( valueListSeparator, ListSeparator_Default)
        , beginPos
      );
      if endPos = 0 then
        endPos := len + 1;
      end if;
      resultList :=
        resultList
        || case when valueIndex > 1 then listSeparator end
        || case when endPos > beginPos then
            formatValueString(
              valueTypeCode       => valueTypeCode
              , valueString       =>
                  substr( valueList, beginPos, endPos - beginPos)
              , sourceValueFormat => valueListItemFormat
              , sourceDecimalChar => valueListDecimalChar
              , encryptionFlag    => encryptionFlag
              , forbiddenChar     => listSeparator
            )
          end
      ;
      beginPos := endPos + 1;
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.errorStack(
            'Ошибка при обработке элемента списка ('
            || ' valueIndex=' || valueIndex
            || ').'
          )
        , true
      );
    end;
  end loop;
  logger.trace( 'formatValueList: "' || resultList || '"');
  return resultList;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при форматировании списка значений.'
      )
    , true
  );
end formatValueList;

/* iproc: getValueFromList
  Возвращает значение из списка.

  Параметры:
  dateValue                   - значения типа дата
                                ( возврат)
  numberValue                 - числовое значение
                                ( возврат)
  stringValue                 - строковое значение
                                ( возврат)
  valueTypeCode               - код типа значения параметра
  valueList                   - список значений
  listSeparator               - символ, используемый в качестве разделителя в
                                списке значений
  valueIndex                  - индекс значения в списке ( начиная с 1)
*/
procedure getValueFromList(
  dateValue out nocopy date
  , numberValue out nocopy number
  , stringValue out nocopy varchar2
  , valueTypeCode varchar2
  , valueList varchar2
  , listSeparator varchar2
  , valueIndex integer
)
is

  -- Позиция первого символа значения
  beginPos pls_integer;

  -- Позиция после последнего символа значения
  endPos pls_integer;



  /*
    Устанавливает значение из строки, выполняя приведение типа.
  */
  procedure setFromString(
    valueString varchar2
  )
  is
  begin
    case valueTypeCode
      when Date_ValueTypeCode then
        dateValue := to_date( valueString, DateValue_ListFormat);
      when Number_ValueTypeCode then
        numberValue := toNumber( valueString);
      when String_ValueTypeCode then
        stringValue := valueString;
    end case;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при получении значения из строки ('
          || ' valueString="' || valueString || '"'
          || ').'
        )
      , true
    );
  end setFromString;



-- getValueFromList
begin
  if valueIndex = 1 then
    beginPos := 1;
  elsif valueIndex > 1 then
    beginPos := instr( valueList, listSeparator, 1, valueIndex - 1);
    if beginPos > 0 then
      beginPos := beginPos + 1;
    end if;
  else
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Указан некорректный индекс значения.'
    );
  end if;
  if beginPos > 0 then
    endPos := instr( valueList, listSeparator, beginPos);
    if endPos = 0 then
      endPos := length( valueList) + 1;
    end if;
  end if;
  if endPos > beginPos then
    setFromString(
      substr( valueList, beginPos, endPos - beginPos)
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при получении значения из списка.'
      )
    , true
  );
end getValueFromList;

/* func: getValueCount
  Возвращает число заданных значений.

  Параметры:
  valueTypeCode               - код типа значения параметра
                                ( null если значение не задано)
  listSeparator               - символ, используемый в качестве разделителя в
                                списке значений ( null если список не
                                используется)
  stringValue                 - строковое значение или строка со списком
                                значений

  Возврат:
  0 если значение ( в т.ч. null) не задано, иначе положительное число заданных
  значений ( 1 если задано значение для параметра, не использующего список
  значений, либо число значений в списке значений параметра).
*/
function getValueCount(
  valueTypeCode varchar2
  , listSeparator varchar2
  , stringValue varchar2
)
return integer
is

  -- Число значений
  valueCount pls_integer := 0;

begin
  if valueTypeCode is not null then
    if listSeparator is null or stringValue is null then
      valueCount := 1;
    else
      valueCount :=
        length( stringValue)
        - coalesce( length( replace( stringValue, listSeparator, '')), 0)
        + 1
      ;
    end if;
  end if;
  return valueCount;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при определении числа заданных значений.'
      )
    , true
  );
end getValueCount;

/* proc: getValue
  Возвращает значение параметра.

  Параметры:
  rowData                     - данные значения ( возврат)
  optionId                    - Id параметра
  prodValueFlag               - флаг использования значения только в
                                промышленных ( либо тестовых) БД
                                ( 1 только в промышленных БД, 0 только в
                                тестовых БД, null без ограничений
                                ( по умолчанию))
  instanceName                - имя экземпляра БД, в которой может
                                использоваться значение
                                ( null без ограничений ( по умолчанию))
  usedOperatorId              - Id оператора, для которого может
                                использоваться значение
                                ( null без ограничений ( по умолчанию))
  usedValueFlag               - флаг возврата используемого в текущей БД
                                значения
                                ( 1 да, 0 нет ( по умолчанию))
  valueTypeCode               - код типа значения параметра
                                ( выбрасывать исключение если отличается от
                                  указанного, по умолчанию не проверяется)
  valueListFlag               - флаг задания для параметра списка значений
                                ( 1 да, 0 нет)
                                ( выбрасывать исключение если отличается от
                                  указанного, по умолчанию не проверяется)
  valueIndex                  - индекс значения в списке значений
                                ( начиная с 1, 1 можно также указывать при
                                получении значения параметра, не использующего
                                список значений, по умолчанию null)
  decryptValueFlag            - флаг возврата расшифрованного значения в
                                случае, если оно хранится в зашифрованном виде
                                ( 1 да ( по умолчанию), 0 нет)
  raiseNotFoundFlag           - выбрасывать ли исключение в случае отсутствия
                                значения ( 1 да ( по умолчанию), 0 нет)

  Замечания:
  - в случае, если тип или флаг использования списка для значения отличается
    от тех же данных для параметра, то значение игнорируется;
  - в случае, если используемое значение ( при usedValueFlag = 1) не найдено и
    указано raiseNotFoundFlag равное 0, то в записи rowData поля
    prod_value_flag и instance_name заполняются значениями, соответствующими
    текущей БД, в остальных полях возвращается null;
  - в случае, если значение настроечного параметра не задано ( в т.ч. в
    случае, если индекс значения в valueIndex превышает число значений в
    списке либо больше 1 если список не используется) и значение параметра
    функции raiseNotFoundFlag равно 0, возвращается null;
  - в случае, если используется список значений и указан valueIndex, из поля
    string_value удаляется список значений и значение с указанным индексом
    сохраняется в одно из полей date_value, number_value или string_value
    согласно типу значения;
*/
procedure getValue(
  rowData out nocopy opt_value%rowtype
  , optionId integer
  , prodValueFlag integer := null
  , instanceName varchar2 := null
  , usedOperatorId integer := null
  , usedValueFlag integer := null
  , valueTypeCode varchar2 := null
  , valueListFlag integer := null
  , valueIndex integer := null
  , decryptValueFlag integer := null
  , raiseNotFoundFlag integer := null
)
is



  /*
    Получает данные используемого значения.
  */
  procedure getUsedValue
  is

    -- Параметры текущей БД
    usedProdValueFlag opt_value.prod_value_flag%type
      := pkg_Common.isProduction()
    ;

    usedInstanceName opt_value.instance_name%type
      := upper( pkg_Common.getInstanceName())
    ;

  begin
    if prodValueFlag is not null or instanceName is not null then
      raise_application_error(
        pkg_Error.IllegalArgument
        , 'При получении используемого значения ограничения по типу БД'
          || ' и имени экземпляра игнорируются.'
      );
    end if;
    select
      a.*
    into rowData
    from
      (
      select
        vl.*
      from
        opt_option_new opn
        left outer join opt_value vl
          on vl.option_id = opn.option_id
            and vl.deleted = 0
            and vl.value_type_code = opn.value_type_code
            and case when vl.list_separator is not null then 1 else 0 end
              = opn.value_list_flag
            and nullif( vl.prod_value_flag, usedProdValueFlag) is null
            and nullif( vl.instance_name, usedInstanceName) is null
            and nullif( vl.used_operator_id, usedOperatorId) is null
      where
        opn.option_id = optionId
        and opn.deleted = 0
        -- обеспечиваем ошибку в случае, если значение должно быть найдено
        and ( raiseNotFoundFlag = 0 or vl.value_id is not null)
      order by
        vl.used_operator_id nulls last
        , vl.instance_name nulls last
        , vl.prod_value_flag nulls last
      ) a
    where
      rownum <= 1
    ;

    if rowData.value_id is null then

      -- Возвращаем параметры текущей БД, которые могут пригодиться в случае
      -- установки значения
      select
        case when opn.test_prod_sensitive_flag = 1 then
            usedProdValueFlag
          end
          as prod_value_flag
      into rowData.prod_value_flag
      from
        opt_option_new opn
      where
        opn.option_id = optionId
        and opn.deleted = 0
      ;
      rowData.instance_name := usedInstanceName;
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при получении текущего значения.'
        )
      , true
    );
  end getUsedValue;



  /*
    Получает данные указанного значения.
  */
  procedure getThisValue
  is
  begin
    select
      vl.*
    into rowData
    from
      opt_option_new opn
      left outer join opt_value vl
        on vl.option_id = opn.option_id
          and vl.deleted = 0
          and vl.value_type_code = opn.value_type_code
          and case when vl.list_separator is not null then 1 else 0 end
            = opn.value_list_flag
          and (
            vl.prod_value_flag = prodValueFlag
            or prodValueFlag is null
              and vl.prod_value_flag is null
          )
          and (
            vl.instance_name = upper( instanceName)
            or instanceName is null
              and vl.instance_name is null
          )
          and (
            vl.used_operator_id = usedOperatorId
            or usedOperatorId is null
              and vl.used_operator_id is null
          )
    where
      opn.option_id = optionId
      and opn.deleted = 0
      -- обеспечиваем ошибку в случае, если значение должно быть найдено
      and ( raiseNotFoundFlag = 0 or vl.value_id is not null)
    ;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при получении указанного значения.'
        )
      , true
    );
  end getThisValue;



  /*
    Устанавливает данные значения с указанным индексом.
  */
  procedure setValueByIndex
  is

    -- Число заданных значений
    valueCount integer;

    -- Строка со списком значений
    valueList opt_value.string_value%type;

  begin
    if valueIndex < 1 then
      raise_application_error(
        pkg_Error.IllegalArgument
        , 'Указан некорректный индекс значения.'
      );
    end if;
    valueCount := getValueCount(
      valueTypeCode   => rowData.value_type_code
      , listSeparator => rowData.list_separator
      , stringValue   => rowData.string_value
    );
    if coalesce( raiseNotFoundFlag, 1) != 0 and valueIndex > valueCount then
      raise_application_error(
        pkg_Error.IllegalArgument
        , case when rowData.list_separator is null then
            'Указан недопустимый индекс значения'
            || ' ( параметр не использует список значений).'
          else
            'Указан индекс значения, превышающий число значений в списке.'
          end
      );
    end if;
    if valueIndex > valueCount then
      rowData.date_value := null;
      rowData.number_value := null;
      rowData.string_value := null;
    elsif rowData.list_separator is not null
        and rowData.string_value is not null
        then
      valueList := rowData.string_value;
      getValueFromList(
        dateValue       => rowData.date_value
        , numberValue   => rowData.number_value
        , stringValue   => rowData.string_value
        , valueTypeCode => rowData.value_type_code
        , valueList     => valueList
        , listSeparator => rowData.list_separator
        , valueIndex    => valueIndex
      );
    end if;
  end setValueByIndex;



-- getValue
begin
  if usedValueFlag = 1 then
    getUsedValue();
  else
    getThisValue();
  end if;
  if rowData.value_id is not null then
    if rowData.value_type_code != valueTypeCode then
      raise_application_error(
        pkg_Error.ProcessError
        , 'Тип значения отличается от ожидаемого ('
          || ' value_id=' || rowData.value_id
          || ', value_type_code="' || rowData.value_type_code || '"'
          || ').'
      );
    end if;
    if valueListFlag = 1 and rowData.list_separator is null
        or valueListFlag = 0 and rowData.list_separator is not null
        then
      raise_application_error(
        pkg_Error.ProcessError
        , 'Использование списка значений отличается от ожидаемого ('
          || ' value_id=' || rowData.value_id
          || ', list_separator="' || rowData.list_separator || '"'
          || ').'
      );
    end if;
    if valueIndex is not null then
      setValueByIndex();
    end if;
    if rowData.encryption_flag = 1 and coalesce( decryptValueFlag, 1) != 0 then
      rowData.string_value := getDecryptValue(
        stringValue     => rowData.string_value
        , listSeparator => rowData.list_separator
      );
      rowData.encryption_flag := 0;
    end if;
  end if;
  logger.trace(
    'getValue:'
    || ' optionId=' || optionId
    || ': value_id=' || rowData.value_id
    || ' ( prodValueFlag=' || prodValueFlag
    || ', instanceName="' || instanceName || '"'
    || ', usedOperatorId=' || usedOperatorId
    || ', usedValueFlag=' || usedValueFlag
    || ', valueIndex=' || valueIndex
    || ')'
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при получении значения параметра ('
        || ' optionId=' || optionId
        || ', prodValueFlag=' || prodValueFlag
        || ', instanceName="' || instanceName || '"'
        || ', usedOperatorId=' || usedOperatorId
        || ', usedValueFlag=' || usedValueFlag
        || ', valueTypeCode="' || valueTypeCode || '"'
        || ', valueListFlag=' || valueListFlag
        || ', valueIndex=' || valueIndex
        || ', raiseNotFoundFlag=' || raiseNotFoundFlag
        || ').'
      )
    , true
  );
end getValue;

/* proc: lockValue
  Блокирует и возвращает данные значения параметра.

  Параметры:
  rowData                     - данные записи ( возврат)
  valueId                     - Id значения параметра

  Замечания:
  - в случае, если запись была логически удалена, выбрасывается исключение;
*/
procedure lockValue(
  rowData out nocopy opt_value%rowtype
  , valueId integer
)
is
begin
  select
    t.*
  into rowData
  from
    opt_value t
  where
    t.value_id = valueId
  for update nowait;

  if rowData.deleted = 1 then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Запись не найдена ( была логически удалена).'
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при блокировке значения параметра ('
        || ' valueId=' || valueId
        || ').'
      )
    , true
  );
end lockValue;

/* iproc: fillValueData
  Заполняет поля с данными значения и выполняет проверку корректности.

  Параметры:
  valueId                     - Id значения
  valueTypeCode               - код типа значения параметра
  dateValue                   - значение типа дата
                                ( по умолчанию отсутствует)
  numberValue                 - числовое значение
                                ( по умолчанию отсутствует)
  stringValue                 - строковое значение или строка со списком
                                значений
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
  setValueListFlag            - установить значение согласно строке со списком
                                значений, переданной в параметре stringValue
                                ( 1 да, 0 нет ( по умолчанию))
  valueListSeparator          - символ, используемый в качестве разделителя
                                в строке со списком значений
                                ( по умолчанию используется ";")
  valueListItemFormat         - формат элементов в строке со списком значений
                                типа дата ( по умолчанию используется
                                "yyyy-mm-dd hh24:mi:ss" с опциональным
                                указанием времени)
  valueListDecimalChar        - десятичный разделитель для строки со списком
                                числовых значений
                                ( по умолчанию используется точка)
  ignoreTestProdSensitiveFlag - при создании значения не проверять его
                                соответствие текущему значению флага
                                test_prod_sensitive_flag параметра
                                ( 1 да, 0 нет ( выбрасывать исключение при
                                  расхождении))
                                ( по умолчанию 0)
*/
procedure fillValueData(
  vlr in out nocopy opt_value%rowtype
  , opt opt_option_new%rowtype
  , valueTypeCode varchar2
  , dateValue date := null
  , numberValue number := null
  , stringValue varchar2 := null
  , valueIndex integer := null
  , setValueListFlag integer := null
  , valueListSeparator varchar2 := null
  , valueListItemFormat varchar2 := null
  , valueListDecimalChar varchar2 := null
  , ignoreTestProdSensitiveFlag integer := null
)
is



  /*
    Проверяет корректность и совместимость аргументов.
  */
  procedure checkArgs
  is
  begin
    if dateValue is not null
        and (
          valueTypeCode != Date_ValueTypeCode
          or setValueListFlag = 1
        )
        then
      raise_application_error(
        pkg_Error.IllegalArgument
        , 'Указано неиспользуемое значение параметра dateValue ('
          || ' dateValue=' || to_char( dateValue, 'dd.mm.yyyy hh24:mi:ss')
          || ').'
      );
    end if;
    if numberValue is not null
        and (
          valueTypeCode != Number_ValueTypeCode
          or setValueListFlag = 1
        )
        then
      raise_application_error(
        pkg_Error.IllegalArgument
        , 'Указано неиспользуемое значение параметра numberValue ('
          || ' numberValue=' || numberValue
          || ').'
      );
    end if;
    if stringValue is not null
        and (
          valueTypeCode != String_ValueTypeCode
          and coalesce( setValueListFlag, 0) != 1
        )
        then
      raise_application_error(
        pkg_Error.IllegalArgument
        , 'Указано неиспользуемое значение параметра stringValue ('
          || ' stringValue="' || stringValue || '"'
          || ').'
      );
    end if;
    if opt.value_list_flag = 0
        and (
          nullif( valueIndex, 1) is not null
          or setValueListFlag = 1
          or valueListSeparator is not null
          or valueListItemFormat is not null
          or valueListDecimalChar is not null
        )
        then
      raise_application_error(
        pkg_Error.IllegalArgument
        , 'Некорректный аргумент, т.к. параметр не использует список значений ('
          || ' valueIndex=' || valueIndex
          || ', setValueListFlag=' || setValueListFlag
          || ', valueListSeparator="' || valueListSeparator || '"'
          || ', valueListItemFormat="' || valueListItemFormat || '"'
          || ', valueListDecimalChar="' || valueListDecimalChar || '"'
          || ').'
      );
    end if;
    if valueIndex < -1 then
      raise_application_error(
        pkg_Error.IllegalArgument
        , 'Указан некорректный индекс значения ('
          || ' valueIndex=' || valueIndex
          || ').'
      );
    end if;
    if setValueListFlag = 1 and valueIndex is not null then
      raise_application_error(
        pkg_Error.IllegalArgument
        , 'Список значений может быть использован только для установки'
          || ' всего значения ('
          || ' valueIndex=' || valueIndex
          || ').'
      );
    end if;
    if valueListItemFormat is not null
        and valueTypeCode != Date_ValueTypeCode
        then
      raise_application_error(
        pkg_Error.IllegalArgument
        , 'Указано неиспользуемое значение параметра valueListItemFormat ('
          || ' valueListItemFormat="' || valueListItemFormat || '"'
          || ').'
      );
    end if;
    if valueListDecimalChar is not null
        and valueTypeCode != Number_ValueTypeCode
        then
      raise_application_error(
        pkg_Error.IllegalArgument
        , 'Указано неиспользуемое значение параметра valueListDecimalChar ('
          || ' valueListDecimalChar="' || valueListDecimalChar || '"'
          || ').'
      );
    end if;
  end checkArgs;



  /*
    Возвращает значение элемента в виде строки.
  */
  function getValueString
  return varchar2
  is
  begin
    case opt.value_type_code
      when Date_ValueTypeCode then
        return
          to_char( dateValue, DateValue_ListFormat)
        ;
      when Number_ValueTypeCode then
        return
          to_char(
            numberValue
            , NumberValue_ListFormat
            , 'NLS_NUMERIC_CHARACTERS = ''' || Number_ListDecimalChar || ' '''
          )
        ;
      when String_ValueTypeCode then
        if instr( stringValue, vlr.list_separator) > 0 then
          raise_application_error(
            pkg_Error.IllegalArgument
            , 'Строка со значением элемента списка содержит'
              || ' символ-разделитель ('
              || ' list_separator="' || vlr.list_separator || '"'
              || ').'
          );
        end if;
        return
          case when opt.encryption_flag = 1 then
            pkg_OptionCrypto.encrypt(
              stringValue
              , forbiddenChar => vlr.list_separator
            )
          else
            stringValue
          end
        ;
    end case;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при возврате значения элемента в виде строки.'
        )
      , true
    );
  end getValueString;



  /*
    Изменяет элемент списка значений.
  */
  procedure setValueListItem
  is

    -- Значение элемента в виде строки
    valueString opt_value.string_value%type;

    -- Позиция первого символа значения
    beginPos pls_integer;

    -- Позиция после последнего символа значения
    endPos pls_integer;

  -- setValueListItem
  begin
    valueString := getValueString();
    if valueIndex = 0 then
      vlr.string_value := valueString || vlr.list_separator || vlr.string_value;
    elsif valueIndex = -1 then
      vlr.string_value := vlr.string_value || vlr.list_separator || valueString;
    else
      if valueIndex = 1 then
        beginPos := 1;
      elsif valueIndex > 1 then
        beginPos :=
          instr( vlr.string_value, vlr.list_separator, 1, valueIndex - 1)
        ;
        if beginPos > 0 then
          beginPos := beginPos + 1;
        else
          vlr.string_value :=
            vlr.string_value
            || rpad(
                vlr.list_separator
                , valueIndex
                  - getValueCount(
                      valueTypeCode   => vlr.value_type_code
                      , listSeparator => vlr.list_separator
                      , stringValue   => vlr.string_value
                    )
                , vlr.list_separator
              )
          ;
          beginPos := length( vlr.string_value) + 1;
        end if;
      else
        raise_application_error(
          pkg_Error.IllegalArgument
          , 'Указан некорректный индекс значения.'
        );
      end if;
      endPos := instr( vlr.string_value, vlr.list_separator, beginPos);
      if endPos = 0 then
        endPos := length( vlr.string_value) + 1;
      end if;
      vlr.string_value :=
        substr( vlr.string_value, 1, beginPos - 1)
        || valueString
        || substr( vlr.string_value, endPos)
      ;
    end if;
    logger.trace(
      'setValueListItem:'
      || ' valueIndex=' || valueIndex
      || ', valueString="' || valueString || '"'
      || ', string_value="' || vlr.string_value || '"'
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при изменении элемента списка значений ('
          || ' valueString="' || valueString || '"'
          || ').'
        )
      , true
    );
  end setValueListItem;



  /*
    Заполняет поля записи.
  */
  procedure fillData
  is
  begin
    vlr.value_type_code           := valueTypeCode;
    vlr.list_separator            :=
      case
        when opt.value_list_flag = 1 then
          coalesce(
            case when
                    opt.value_type_code = String_ValueTypeCode
                    and (
                      valueIndex is null
                      or vlr.list_separator is null
                      or vlr.string_value is null
                    )
                  then
                coalesce( valueListSeparator, ListSeparator_Default)
              end
            , vlr.list_separator
            , ListSeparator_Default
          )
      end
    ;
    vlr.encryption_flag           := opt.encryption_flag;
    vlr.storage_value_type_code   :=
      case when opt.value_list_flag = 1 then
        String_ValueTypeCode
      else
        valueTypeCode
      end
    ;
    if opt.value_list_flag = 0 then
      vlr.date_value   := dateValue;
      vlr.number_value := numberValue;
      vlr.string_value :=
        case when opt.encryption_flag = 1 then
          pkg_OptionCrypto.encrypt( stringValue)
        else
          stringValue
        end
      ;
      logger.trace(
        'set single value:'
        || ' date_value=' || to_char( vlr.date_value, 'dd.mm.yyyy hh24:mi:ss')
        || ', number_value=' || vlr.number_value
        || ', string_value="' || vlr.string_value || '"'
      );
    else
      vlr.date_value   := null;
      vlr.number_value := null;
      if valueIndex is null then
        if setValueListFlag = 1 then
          if opt.value_type_code != String_ValueTypeCode
                or vlr.encryption_flag = 1
              then
            vlr.string_value := formatValueList(
              valueTypeCode           => opt.value_type_code
              , listSeparator         => vlr.list_separator
              , valueList             => stringValue
              , valueListSeparator    => valueListSeparator
              , valueListItemFormat   => valueListItemFormat
              , valueListDecimalChar  => valueListDecimalChar
              , encryptionFlag        => opt.encryption_flag
            );
          else
            vlr.string_value := stringValue;
            logger.trace( 'set string list: "' || vlr.string_value || '"');
          end if;
        else
          vlr.string_value := getValueString();
          logger.trace( 'set string list(1): "' || vlr.string_value || '"');
        end if;
      else
        setValueListItem();
      end if;
    end if;
  end fillData;



  /*
    Проверяет заполнение полей значения.
  */
  procedure checkData
  is
  begin
    if coalesce(
          vlr.value_type_code != opt.value_type_code
          , true
        )
        then
      raise_application_error(
        pkg_Error.IllegalArgument
        , 'Тип значения отличается от указанного для параметра ('
          || ' value_type_code="' || opt.value_type_code || '"'
          || ').'
      );
    elsif coalesce( ignoreTestProdSensitiveFlag, 0) != 1
        and (
          opt.test_prod_sensitive_flag = 0 and vlr.prod_value_flag is not null
          or opt.test_prod_sensitive_flag = 1 and vlr.prod_value_flag is null
        )
        then
      raise_application_error(
        pkg_Error.IllegalArgument
        , 'Значение параметра должно быть задано'
          || case when opt.test_prod_sensitive_flag = 0 then
              ' без указания'
            else
              ' с указанием'
            end
          || ' типа БД ( тестовая или промышленная).'
      );
    elsif vlr.list_separator is not null and opt.value_list_flag = 0 then
      raise_application_error(
        pkg_Error.IllegalArgument
        , 'Указан символ-разделитель списка для параметра, не использующего'
          || ' список значений.'
      );
    elsif vlr.list_separator is null and opt.value_list_flag = 1 then
      raise_application_error(
        pkg_Error.IllegalArgument
        , 'Не указан символ-разделитель списка для параметра, использующего'
          || ' список значений.'
      );
    elsif vlr.list_separator != ListSeparator_Default
          and opt.value_type_code != String_ValueTypeCode
        then
      raise_application_error(
        pkg_Error.IllegalArgument
        , 'Специальный символ-разделитель может быть задан только для списка'
          || ' строковых значений.'
      );
    end if;
  end checkData;



-- fillValueData
begin
  checkArgs();
  fillData();
  checkData();
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при заполнении полей с данными значения ('
        || ' valueTypeCode="' || valueTypeCode || '"'
        || ', valueIndex=' || valueIndex
        || ', setValueListFlag=' || setValueListFlag
        || ').'
      )
    , true
  );
end fillValueData;

/* func: createValue
  Создает значение параметра.

  Параметры:
  optionId                    - Id параметра
  valueTypeCode               - код типа значения параметра
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
  stringValue                 - строковое значение или строка со списком
                                значений
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
  setValueListFlag            - установить значение согласно строке со списком
                                значений, переданной в параметре stringValue
                                ( 1 да, 0 нет ( по умолчанию))
  valueListSeparator          - символ, используемый в качестве разделителя
                                в строке со списком значений
                                ( по умолчанию используется ";")
  valueListItemFormat         - формат элементов в строке со списком значений
                                типа дата ( по умолчанию используется
                                "yyyy-mm-dd hh24:mi:ss" с опциональным
                                указанием времени)
  valueListDecimalChar        - десятичный разделитель для строки со списком
                                числовых значений
                                ( по умолчанию используется точка)
  oldOptionValueId            - Id значения в таблице opt_option_value
                                ( по умолчанию формируется автоматически)
  oldOptionId                 - Id параметра в таблице opt_option
                                ( по умолчанию формируется автоматически)
  oldOptionValueDelDate       - дата удаления значения из таблицы
                                opt_option_value
                                ( по умолчанию отсутствует)
  oldOptionDelDate            - дата удаления значения из таблицы
                                opt_option
                                ( по умолчанию отсутствует)
  ignoreTestProdSensitiveFlag - при создании значения не проверять его
                                соответствие текущему значению флага
                                test_prod_sensitive_flag параметра
                                ( 1 да, 0 нет ( выбрасывать исключение при
                                  расхождении))
                                ( по умолчанию 0)
  fillIdFromOldFlag           - использовать в качестве Id создаваемой записи
                                ( value_id) значение oldOptionValueId если
                                оно задано
                                ( 1 да ( по умолчанию), 0 нет)
  operatorId                  - Id оператора ( по умолчанию текущий)

  Возврат:
  Id значения параметра.

  Замечания:
  - если в пакете установлен признак <body::isCopyNew2OldChange>, то также
    добавляется запись в устаревшую таблицу opt_option_value;
*/
function createValue(
  optionId integer
  , valueTypeCode varchar2
  , prodValueFlag integer := null
  , instanceName varchar2 := null
  , usedOperatorId integer := null
  , dateValue date := null
  , numberValue number := null
  , stringValue varchar2 := null
  , valueIndex integer := null
  , setValueListFlag integer := null
  , valueListSeparator varchar2 := null
  , valueListItemFormat varchar2 := null
  , valueListDecimalChar varchar2 := null
  , oldOptionValueId integer := null
  , oldOptionId integer := null
  , oldOptionValueDelDate date := null
  , oldOptionDelDate date := null
  , ignoreTestProdSensitiveFlag integer := null
  , fillIdFromOldFlag integer := null
  , operatorId integer := null
)
return integer
is

  -- Данные в виде записи
  rec opt_value%rowtype;

  -- Данные параметра
  opt opt_option_new%rowtype;



  /*
    Заполняет поля записи.
  */
  procedure fillData
  is
  begin
    rec.option_id                 := optionId;
    rec.prod_value_flag           := prodValueFlag;
    rec.instance_name             := upper( instanceName);
    rec.used_operator_id          := usedOperatorId;
    rec.old_option_value_id       := oldOptionValueId;
    rec.old_option_id             := oldOptionId;
    rec.old_option_value_del_date := oldOptionValueDelDate;
    rec.old_option_del_date       := oldOptionDelDate;
    rec.operator_id               := operatorId;

    -- Id совпадают, т.к. используется одна последовательность
    if coalesce( fillIdFromOldFlag, 1) = 1 then
      rec.value_id := rec.old_option_value_id;
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при заполнении полей записи.'
        )
      , true
    );
  end fillData;



  /*
    Добавляет запись в устаревшую таблицу.
  */
  procedure insertOld
  is

    -- Данные тестового параметра
    testOptOldRec opt_option%rowtype;

  begin
    if rec.old_option_id is null then
      if rec.prod_value_flag = 0 then
        insertOptionOld(
          rowData                 => testOptOldRec
          , moduleId              => opt.module_id
          , objectShortName       => opt.object_short_name
          , objectTypeId          => opt.object_type_id
          , optionShortName       => opt.option_short_name
          , storageValueTypeCode  => rec.storage_value_type_code
          , optionName            => opt.option_name
          , testOptionFlag        => 1
          , operatorId            => rec.operator_id
          , prodOldOptionShortName => opt.old_option_short_name
        );
        rec.old_option_id := testOptOldRec.option_id;
      else
        rec.old_option_id := rec.option_id;
      end if;
    end if;
    if rec.old_option_value_id is null then
      rec.old_option_value_id := insertOptionValueOld(
        oldOptionId             => rec.old_option_id
        , dateValue             => rec.date_value
        , numberValue           => rec.number_value
        , stringValue           => rec.string_value
        , operatorId            => rec.operator_id
      );
      rec.value_id := rec.old_option_value_id;
    end if;
  end insertOld;



  /*
    Вставляет запись в таблицу opt_value и возвращает результат ( true в
    случае успеха, false в случае ошибки из-за нарушения уникальности).
  */
  function insertRecord
  return boolean
  is
  begin
    insert into
      opt_value
    values
      rec
    returning
      value_id
    into
      rec.value_id
    ;
    logger.trace(
      'createValue: opt_value inserted:'
      || ' value_id=' || rec.value_id
      || ', option_id=' || rec.option_id
      || ', prod_value_flag=' || rec.prod_value_flag
      || ', instance_name="' || rec.instance_name || '"'
      || ', used_operator_id=' || rec.used_operator_id
      || ', value_type_code="' || rec.value_type_code || '"'
      || ', list_separator="' || rec.list_separator || '"'
      || ', old_option_value_id=' || rec.old_option_value_id
      || ', old_option_id=' || rec.old_option_id
    );
    return true;
  exception
    when DUP_VAL_ON_INDEX then
      logger.trace(
        'createValue: insertRecord: DUP_VAL_ON_INDEX error: ' || SQLERRM
      );
      logger.clearErrorStack();
      return false;
    when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.errorStack(
            'Ошибка при вставке записи в таблицу opt_value.'
          )
        , true
      );
  end insertRecord;



  /*
    Восстанавливаем ранее удаленную запись.
  */
  procedure restoreDeleted
  is
  begin
    select
      d.value_id
      , d.deleted
    into rec.value_id, rec.deleted
    from
      opt_value d
    where
      d.option_id = rec.option_id
      and (
        rec.prod_value_flag is null
          and d.prod_value_flag is null
        or d.prod_value_flag = rec.prod_value_flag
      )
      and (
        rec.instance_name is null
          and d.instance_name is null
        or d.instance_name = rec.instance_name
      )
      and (
        rec.used_operator_id is null
          and d.used_operator_id is null
        or d.used_operator_id = rec.used_operator_id
      )
    for update nowait;

    if rec.deleted = 0 then
      raise_application_error(
        pkg_Error.IllegalArgument
        , 'Значение было создано ранее ('
          || ' value_id=' || rec.value_id
          || ').'
      );
    end if;

    update
      opt_value d
    set
      d.value_type_code             = rec.value_type_code
      , d.list_separator            = rec.list_separator
      , d.encryption_flag           = rec.encryption_flag
      , d.storage_value_type_code   = rec.storage_value_type_code
      , d.date_value                = rec.date_value
      , d.number_value              = rec.number_value
      , d.string_value              = rec.string_value
      , d.old_option_value_id       = rec.old_option_value_id
      , d.old_option_id             = rec.old_option_id
      , d.old_option_value_del_date = rec.old_option_value_del_date
      , d.old_option_del_date       = rec.old_option_del_date
      , d.deleted                   = 0
      , d.change_operator_id        = rec.operator_id
    where
      d.value_id = rec.value_id
    ;
    logger.trace(
      'createValue: restore deleted: opt_value updated:'
      || ' value_id=' || rec.value_id
      || ', option_id=' || rec.option_id
      || ', prod_value_flag=' || rec.prod_value_flag
      || ', instance_name="' || rec.instance_name || '"'
      || ', used_operator_id=' || rec.used_operator_id
      || ', value_type_code="' || rec.value_type_code || '"'
      || ', list_separator="' || rec.list_separator || '"'
      || ', old_option_value_id=' || rec.old_option_value_id
      || ', old_option_id=' || rec.old_option_id
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при восстановлении ранее удаленной записи.'
        )
      , true
    );
  end restoreDeleted;



-- createValue
begin
  lockOption( opt, optionId => optionId);
  fillData();
  fillValueData(
    vlr                           => rec
    , opt                         => opt
    , valueTypeCode               => valueTypeCode
    , dateValue                   => dateValue
    , numberValue                 => numberValue
    , stringValue                 => stringValue
    , valueIndex                  => valueIndex
    , setValueListFlag            => setValueListFlag
    , valueListSeparator          => valueListSeparator
    , valueListItemFormat         => valueListItemFormat
    , valueListDecimalChar        => valueListDecimalChar
    , ignoreTestProdSensitiveFlag => ignoreTestProdSensitiveFlag
  );
  if isCopyNew2OldChange
        and rec.instance_name is null
        and rec.used_operator_id is null
      then
    insertOld();
  end if;
  if not insertRecord() then
    restoreDeleted();
  end if;
  if isCopyNew2OldChange then
    checkNew2OldSync();
  end if;
  return rec.value_id;
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
  valueTypeCode               - код типа значения параметра
  dateValue                   - значение типа дата
                                ( по умолчанию отсутствует)
  numberValue                 - числовое значение
                                ( по умолчанию отсутствует)
  stringValue                 - строковое значение или строка со списком
                                значений
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
  setValueListFlag            - установить значение согласно строке со списком
                                значений, переданной в параметре stringValue
                                ( 1 да, 0 нет ( по умолчанию))
  valueListSeparator          - символ, используемый в качестве разделителя
                                в строке со списком значений
                                ( по умолчанию используется ";")
  valueListItemFormat         - формат элементов в строке со списком значений
                                типа дата ( по умолчанию используется
                                "yyyy-mm-dd hh24:mi:ss" с опциональным
                                указанием времени)
  valueListDecimalChar        - десятичный разделитель для строки со списком
                                числовых значений
                                ( по умолчанию используется точка)
  oldOptionValueId            - Id значения в таблице opt_option_value
                                ( по умолчанию формируется автоматически)
  oldOptionId                 - Id параметра в таблице opt_option
                                ( по умолчанию формируется автоматически)
  operatorId                  - Id оператора ( по умолчанию текущий)

  Замечания:
  - если в пакете установлен признак <body::isCopyNew2OldChange>, то также
    добавляется запись в устаревшую таблицу opt_option_value;
*/
procedure updateValue(
  valueId integer
  , valueTypeCode varchar2
  , dateValue date := null
  , numberValue number := null
  , stringValue varchar2 := null
  , valueIndex integer := null
  , setValueListFlag integer := null
  , valueListSeparator varchar2 := null
  , valueListItemFormat varchar2 := null
  , valueListDecimalChar varchar2 := null
  , oldOptionValueId integer := null
  , oldOptionId integer := null
  , operatorId integer := null
)
is

  -- Данные в виде записи
  rec opt_value%rowtype;

  -- Данные параметра
  opt opt_option_new%rowtype;



  /*
    Заполняет поля записи.
  */
  procedure fillData
  is
  begin
    rec.old_option_value_id       :=
      coalesce( oldOptionValueId, rec.old_option_value_id)
    ;
    rec.old_option_id             :=
      coalesce( oldOptionId, rec.old_option_id)
    ;
    rec.change_operator_id        := operatorId;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при заполнении полей записи.'
        )
      , true
    );
  end fillData;



  /*
    Добавляет запись в устаревшую таблицу.
  */
  procedure insertOld
  is
  begin
    rec.old_option_value_id := insertOptionValueOld(
      oldOptionId             => rec.old_option_id
      , dateValue             => rec.date_value
      , numberValue           => rec.number_value
      , stringValue           => rec.string_value
      , operatorId            => rec.change_operator_id
    );
  end insertOld;



  /*
    Изменяет запись в таблице opt_value.
  */
  procedure updateRecord
  is
  begin
    update
      opt_value d
    set
      d.value_type_code           = rec.value_type_code
      , d.list_separator          = rec.list_separator
      , d.encryption_flag         = rec.encryption_flag
      , d.storage_value_type_code = rec.storage_value_type_code
      , d.date_value              = rec.date_value
      , d.number_value            = rec.number_value
      , d.string_value            = rec.string_value
      , d.old_option_value_id     = rec.old_option_value_id
      , d.old_option_id           = rec.old_option_id
      , d.change_operator_id      = rec.change_operator_id
    where
      d.value_id = rec.value_id
    ;
    logger.trace(
      'updateValue: opt_value updated:'
      || ' value_id=' || rec.value_id
      || ', option_id=' || rec.option_id
      || ', valueTypeCode="' || rec.value_type_code || '"'
      || ', list_separator="' || rec.list_separator || '"'
      || ', old_option_value_id=' || rec.old_option_value_id
      || ', old_option_id=' || rec.old_option_id
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при изменении записи в таблице opt_value.'
        )
      , true
    );
  end updateRecord;



-- updateValue
begin
  lockValue( rec, valueId => valueId);
  lockOption( opt, optionId => rec.option_id);
  fillData();
  fillValueData(
    vlr                           => rec
    , opt                         => opt
    , valueTypeCode               => valueTypeCode
    , dateValue                   => dateValue
    , numberValue                 => numberValue
    , stringValue                 => stringValue
    , valueIndex                  => valueIndex
    , setValueListFlag            => setValueListFlag
    , valueListSeparator          => valueListSeparator
    , valueListItemFormat         => valueListItemFormat
    , valueListDecimalChar        => valueListDecimalChar
    , ignoreTestProdSensitiveFlag => 0
  );
  if isCopyNew2OldChange
        and rec.instance_name is null
        and rec.used_operator_id is null
      then
    insertOld();
  end if;
  updateRecord();
  if isCopyNew2OldChange then
    checkNew2OldSync();
  end if;
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

/* proc: setValue
  Устанавливает значение параметра.

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
  valueTypeCode               - код типа значения параметра
                                ( по умолчанию определяется по данным параметра)
  dateValue                   - значение типа дата
                                ( по умолчанию отсутствует)
  numberValue                 - числовое значение
                                ( по умолчанию отсутствует)
  stringValue                 - строковое значение или строка со списком
                                значений
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
  setValueListFlag            - установить значение согласно строке со списком
                                значений, переданной в параметре stringValue
                                ( 1 да, 0 нет ( по умолчанию))
  valueListSeparator          - символ, используемый в качестве разделителя
                                элементов в строке со списком значений
                                ( по умолчанию используется ";")
  valueListItemFormat         - формат элементов в строке со списком значений
                                типа дата ( по умолчанию используется
                                "yyyy-mm-dd hh24:mi:ss" с опциональным
                                указанием времени)
  valueListDecimalChar        - десятичный разделитель для строки со списком
                                числовых значений
                                ( по умолчанию используется точка)
  oldOptionValueId            - Id значения в таблице opt_option_value
                                ( по умолчанию формируется автоматически)
  oldOptionId                 - Id параметра в таблице opt_option
                                ( по умолчанию формируется автоматически)
  operatorId                  - Id оператора ( по умолчанию текущий)

  Замечания:
  - если в пакете установлен признак <body::isCopyNew2OldChange>, то также
    добавляется запись в устаревшую таблицу opt_option_value;
  - для установки значения в зависимости от его наличия используется либо
    функция <createValue> либо процедура <updateValue>;
*/
procedure setValue(
  optionId integer
  , prodValueFlag integer
  , instanceName varchar2 := null
  , usedOperatorId integer := null
  , valueTypeCode varchar2 := null
  , dateValue date := null
  , numberValue number := null
  , stringValue varchar2 := null
  , valueIndex integer := null
  , setValueListFlag integer := null
  , valueListSeparator varchar2 := null
  , valueListItemFormat varchar2 := null
  , valueListDecimalChar varchar2 := null
  , oldOptionValueId integer := null
  , oldOptionId integer := null
  , operatorId integer := null
)
is

  -- Данные параметра
  opt opt_option_new%rowtype;

  -- Id значения параметра
  valueId integer;

-- setValue
begin
  lockOption( opt, optionId => optionId);
  select
    min( d.value_id)
  into valueId
  from
    opt_value d
  where
    d.option_id = optionId
    and (
      prodValueFlag is null
        and d.prod_value_flag is null
      or d.prod_value_flag = prodValueFlag
    )
    and (
      instanceName is null
        and d.instance_name is null
      or d.instance_name = instanceName
    )
    and (
      usedOperatorId is null
        and d.used_operator_id is null
      or d.used_operator_id = usedOperatorId
    )
    -- восстановление значения делается в createValue
    and d.deleted = 0
  ;
  if valueId is null then
    valueId := createValue(
      optionId                => optionId
      , prodValueFlag         => prodValueFlag
      , instanceName          => instanceName
      , usedOperatorId        => usedOperatorId
      , valueTypeCode         => coalesce( valueTypeCode, opt.value_type_code)
      , dateValue             => dateValue
      , numberValue           => numberValue
      , stringValue           => stringValue
      , valueIndex            => valueIndex
      , setValueListFlag      => setValueListFlag
      , valueListSeparator    => valueListSeparator
      , valueListItemFormat   => valueListItemFormat
      , valueListDecimalChar  => valueListDecimalChar
      , oldOptionValueId      => oldOptionValueId
      , oldOptionId           => oldOptionId
      , operatorId            => operatorId
    );
  else
    updateValue(
      valueId                 => valueId
      , valueTypeCode         => coalesce( valueTypeCode, opt.value_type_code)
      , dateValue             => dateValue
      , numberValue           => numberValue
      , stringValue           => stringValue
      , valueIndex            => valueIndex
      , setValueListFlag      => setValueListFlag
      , valueListSeparator    => valueListSeparator
      , valueListItemFormat   => valueListItemFormat
      , valueListDecimalChar  => valueListDecimalChar
      , oldOptionValueId      => oldOptionValueId
      , oldOptionId           => oldOptionId
      , operatorId            => operatorId
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при установке значения параметра ('
        || ' optionId=' || optionId
        || ', prodValueFlag=' || prodValueFlag
        || ', instanceName="' || instanceName || '"'
        || ', usedOperatorId=' || usedOperatorId
        || ', valueTypeCode="' || valueTypeCode || '"'
        || ').'
      )
    , true
  );
end setValue;

/* proc: deleteValue
  Удаляет значение параметра.

  Параметры:
  valueId                     - Id значения параметра
  operatorId                  - Id оператора ( по умолчанию текущий)

  Замечания:
  - если в пакете установлен признак <body::isCopyNew2OldChange>, то также
    удаляются записи из устаревших таблиц opt_option_value и opt_option;
*/
procedure deleteValue(
  valueId integer
  , operatorId integer := null
)
is

  -- Данные в виде записи
  vlr opt_value%rowtype;

  -- Данные параметра
  opt opt_option_new%rowtype;

  -- Дата внесения изменений
  changeDate date := sysdate;



  /*
    Удаляет записи из устаревшей таблицы opt_option_value.
  */
  procedure deleteOptionValueOld
  is

    cursor dataCur is
      select
        a.*
      from
        (
        select
          t.value_id
          , t.old_option_value_id
          , max( t.value_history_id)
            keep ( dense_rank last order by t.change_number)
            as value_history_id
          , max( t.old_option_value_del_date)
            keep ( dense_rank last order by t.change_number)
            as old_option_value_del_date
        from
          v_opt_value_history t
        where
          t.deleted = 0
          and t.old_option_value_id is not null
          and (
            t.value_id = vlr.value_id
            -- значение, удаленное в результате изменения параметра с указанием
            -- moveProdSensitiveValueFlag = 1
            or t.value_id =
              (
              select distinct
                vl.value_id
              from
                opt_value vl
                inner join opt_value_history vh
                  on vh.value_id = vl.value_id
                    and vh.deleted = 0
                    and vh.old_option_value_id is not null
              where
                vl.option_id = vlr.option_id
                and vl.deleted = 1
                and (
                  vlr.prod_value_flag = 1
                    and vl.prod_value_flag is null
                  or vlr.prod_value_flag is null
                    and vl.prod_value_flag = 1
                )
                and exists
                  (
                  select
                    null
                  from
                    v_opt_value_history vh0
                  where
                    vh0.value_id = vlr.value_id
                    and vh0.old_option_value_id = vh.old_option_value_id
                  )
              )
          )
        group by
          t.value_id
          , t.old_option_value_id
        ) a
      where
        a.old_option_value_del_date is null
      order by
        nullif( a.value_id, vlr.value_id) nulls first
        , a.old_option_value_id
    ;

    -- Старое значение признака копирования в новые таблицы
    isCopyOld2NewChangeOld boolean := isCopyOld2NewChange;

  -- deleteOptionValueOld
  begin

    -- Исключаем обратное копирование изменений триггерами
    isCopyOld2NewChange := false;

    for rec in dataCur loop
      delete
        opt_option_value d
      where
        d.option_value_id = rec.old_option_value_id
      ;
      if sql%rowcount = 0 then
        if rec.value_id = vlr.value_id then
          raise_application_error(
            pkg_Error.ProcessError
            , 'Не удалось удалить запись в opt_option_value'
              || ' из-за ее отсутствия ('
              || ' option_value_id=' || rec.old_option_value_id
              || ', value_history_id=' || rec.value_history_id
              || ', value_id=' || rec.value_id
              || ').'
          );
        else
          logger.trace(
            'deleteValue: Не удалось удалить запись в opt_option_value'
            || ' из-за ее отсутствия ('
            || ' option_value_id=' || rec.old_option_value_id
            || ', value_history_id=' || rec.value_history_id
            || ', value_id=' || rec.value_id
            || ').'
          );
        end if;
      else
        logger.trace(
          'deleteValue: opt_option_value deleted: option_value_id='
          || rec.old_option_value_id
        );
      end if;
      setOldDelDate(
        valueId                 => rec.value_id
        , valueHistoryId        => rec.value_history_id
        , oldOptionValueDelDate => changeDate
      );
    end loop;

    isCopyOld2NewChange := isCopyOld2NewChangeOld;
  exception when others then
    isCopyOld2NewChange := isCopyOld2NewChangeOld;
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при удалении записей из устаревшей таблицы opt_option_value.'
        )
      , true
    );
  end deleteOptionValueOld;



-- deleteValue
begin
  lockValue( vlr, valueId => valueId);
  lockOption( opt, optionId => vlr.option_id);
  if isCopyNew2OldChange
        and vlr.instance_name is null
        and vlr.used_operator_id is null
      then
    deleteOptionValueOld();
    deleteOptionOld(
      valueId             => vlr.value_id
      , oldOptionDelDate  => changeDate
    );
  end if;
  update
    opt_value d
  set
    d.deleted = 1
    , d.old_option_value_id = null
    , d.old_option_id = null
    , d.old_option_value_del_date = null
    , d.old_option_del_date = null
    , d.change_operator_id = operatorId
  where
    d.value_id = vlr.value_id
  ;
  logger.trace(
    'deleteValue: set deleted: opt_value updated:'
    || ' value_id=' || vlr.value_id
    || ', option_id=' || vlr.option_id
  );
  if isCopyNew2OldChange then
    checkNew2OldSync();
  end if;
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



/* group: Дополнительные функции */

/* proc: addOptionWithValueOld
  Добавляет настроечный параметр со значением в устаревшие таблицы, если он не
  был создан ранее.

  Параметры:
  moduleName                  - имя модуля
  moduleOptionName            - имя опции уникальное в пределах модуля
  valueTypeCode               - код типа значения параметра
  optionName                  - название параметра
  dateValue                   - значение типа дата
                                ( по умолчанию отсутствует)
  numberValue                 - числовое значение
                                ( по умолчанию отсутствует)
  stringValue                 - строковое значение
                                ( по умолчанию отсутствует)
  operatorId                  - Id оператора ( по умолчанию текущий)
*/
procedure addOptionWithValueOld(
  moduleName varchar2
  , moduleOptionName varchar2
  , valueTypeCode varchar2
  , optionName varchar2
  , dateValue date := null
  , numberValue number := null
  , stringValue varchar2 := null
  , operatorId integer := null
)
is

  -- Id параметра
  optionId integer;

  -- Флаг использования значения только в промышленных ( либо тестовых) БД
  prodValueFlag integer;

  -- Данные добавленной в opt_option записи
  opt opt_option%rowtype;

  -- Id добавленной в opt_option_value записи
  optionValueId integer;

begin
  getOptionInfoOld(
    optionId            => optionId
    , prodValueFlag     => prodValueFlag
    , moduleName        => moduleName
    , moduleOptionName  => moduleOptionName
    , raiseNotFoundFlag => 0
  );
  if optionId is null then
    insertOptionOld(
      rowData                 => opt
      , oldOptionShortName    => moduleName || '.' || moduleOptionName
      , storageValueTypeCode  => valueTypeCode
      , oldOptionName         => optionName
      , operatorId            => operatorId
    );
    optionValueId := insertOptionValueOld(
      oldOptionId             => opt.option_id
      , dateValue             => dateValue
      , numberValue           => numberValue
      , stringValue           => stringValue
      , operatorId            => operatorId
      , copyOld2NewChange     => true
    );
    logger.trace(
      'addOptionWithValueOld: created: "' || opt.option_short_name || '"'
      || ' ( old option_id=' || opt.option_id
      || ', option_value_id=' || optionValueId
      || ')'
    );
  else
    logger.trace(
      'addOptionWithValueOld: exists: "' || opt.option_short_name || '"'
      || ' ( old option_id=' || optionId
      || ')'
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при добавлении параметра со значением устаревшими функциями ('
        || ' moduleName="' || moduleName || '"'
        || ', moduleOptionName="' || moduleOptionName || '"'
        || ', valueTypeCode="' || valueTypeCode || '"'
        || ').'
      )
    , true
  );
end addOptionWithValueOld;

/* proc: addOptionWithValue
  Добавляет настроечный параметр со значением, если он не был создан ранее.

  Параметры:
  moduleId                    - Id модуля, к которому относится параметр
  optionShortName             - короткое название параметра
  valueTypeCode               - код типа значения параметра
  optionName                  - название параметра
  objectShortName             - короткое название объекта модуля
                                ( по умолчанию отсутствует)
  objectTypeId                - Id типа объекта
                                ( по умолчанию отсутствует)
  valueListFlag               - флаг задания для параметра списка значений
                                указанного типа ( 1 да, 0 нет ( по умолчанию))
  encryptionFlag              - флаг хранения значений параметра в
                                зашифрованном виде
                                ( 1 да, 0 нет ( по умолчанию))
  testProdSensitiveFlag       - флаг указания для значения параметра типа базы
                                данных ( тестовая или промышленная), для
                                которого оно предназначено
                                ( 1 да, 0 нет ( по умолчанию))
  accessLevelCode             - код уровня доступа к параметру через
                                пользовательский интерфейс
                                ( по умолчанию только изменение значения в
                                  случае хранения значений в зашифрованном
                                  виде, иначе полный доступ)
  optionDescription           - описание параметра
                                ( по умолчанию отсутствует)
  instanceName                - имя экземпляра БД, в которой может
                                использоваться значение
                                ( null без ограничений ( по умолчанию))
  usedOperatorId              - Id оператора, для которого может
                                использоваться значение
                                ( null без ограничений ( по умолчанию))
  dateValue                   - значение типа дата для всех либо для
                                промышленных БД
                                ( по умолчанию отсутствует)
  testDateValue               - значение типа дата для тестовых БД
                                ( по умолчанию отсутствует)
  numberValue                 - числовое значение для всех либо для
                                промышленных БД
                                ( по умолчанию отсутствует)
  testNumberValue             - числовое значение для тестовых БД
                                ( по умолчанию отсутствует)
  stringValue                 - строковое значение или строка со списком
                                значений для всех либо для промышленных БД
                                ( по умолчанию отсутствует)
  testStringValue             - строковое значение или строка со списком
                                значений для тестовых БД
                                ( по умолчанию отсутствует)
  setValueListFlag            - установить значение согласно строке со списком
                                значений, переданной в параметре stringValue
                                ( 1 да, 0 нет ( по умолчанию))
  valueListSeparator          - символ, используемый в качестве разделителя
                                элементов списков значений, указанных в
                                параметрах stringValue и testStringValue
                                ( по умолчанию используется ";")
  valueListItemFormat         - формат элементов в строке со списком значений
                                типа дата ( по умолчанию используется
                                "yyyy-mm-dd hh24:mi:ss" с опциональным
                                указанием времени)
  valueListDecimalChar        - десятичный разделитель для списков числовых
                                значений, указанных в параметрах stringValue и
                                testStringValue
                                ( по умолчанию используется точка)
  changeValueFlag             - установить значение параметра, если он был
                                создан ранее
                                ( 1 да, 0 нет ( по умолчанию))
  operatorId                  - Id оператора ( по умолчанию текущий)
*/
procedure addOptionWithValue(
  moduleId integer
  , optionShortName varchar2
  , valueTypeCode varchar2
  , optionName varchar2
  , objectShortName varchar2 := null
  , objectTypeId integer := null
  , valueListFlag integer := null
  , encryptionFlag integer := null
  , testProdSensitiveFlag integer := null
  , accessLevelCode varchar2 := null
  , optionDescription varchar2 := null
  , instanceName varchar2 := null
  , usedOperatorId integer := null
  , dateValue date := null
  , testDateValue date := null
  , numberValue number := null
  , testNumberValue number := null
  , stringValue varchar2 := null
  , testStringValue varchar2 := null
  , setValueListFlag integer := null
  , valueListSeparator varchar2 := null
  , valueListItemFormat varchar2 := null
  , valueListDecimalChar varchar2 := null
  , changeValueFlag integer := null
  , operatorId integer := null
)
is

  -- Id параметра
  optionId integer;

  -- Признак создания параметра
  isCreateOption boolean;

begin
  optionId := getOptionId(
    moduleId              => moduleId
    , objectShortName     => objectShortName
    , objectTypeId        => objectTypeId
    , optionShortName     => optionShortName
    , raiseNotFoundFlag   => 0
  );
  isCreateOption := optionId is null;
  if isCreateOption then
    optionId := createOption(
      moduleId                => moduleId
      , optionShortName       => optionShortName
      , valueTypeCode         => valueTypeCode
      , optionName            => optionName
      , objectShortName       => objectShortName
      , objectTypeId          => objectTypeId
      , valueListFlag         => valueListFlag
      , encryptionFlag        => encryptionFlag
      , testProdSensitiveFlag => testProdSensitiveFlag
      , accessLevelCode       => accessLevelCode
      , optionDescription     => optionDescription
      , operatorId            => operatorId
    );
  end if;
  if isCreateOption or changeValueFlag = 1 then
    setValue(
      optionId                => optionId
      , prodValueFlag         => case when testProdSensitiveFlag = 1 then 1 end
      , instanceName          => instanceName
      , usedOperatorId        => usedOperatorId
      , dateValue             => dateValue
      , numberValue           => numberValue
      , stringValue           => stringValue
      , setValueListFlag      => setValueListFlag
      , valueListSeparator    => valueListSeparator
      , valueListItemFormat   => valueListItemFormat
      , valueListDecimalChar  => valueListDecimalChar
      , operatorId            => operatorId
    );
    if testProdSensitiveFlag = 1 then
      setValue(
        optionId                => optionId
        , prodValueFlag         => 0
        , instanceName          => instanceName
        , usedOperatorId        => usedOperatorId
        , dateValue             => testDateValue
        , numberValue           => testNumberValue
        , stringValue           => testStringValue
        , setValueListFlag      => setValueListFlag
        , valueListSeparator    => valueListSeparator
        , valueListItemFormat   => valueListItemFormat
        , valueListDecimalChar  => valueListDecimalChar
        , operatorId            => operatorId
      );
    end if;
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при добавлении параметра со значением ('
        || ' moduleId=' || moduleId
        || ', objectShortName="' || objectShortName || '"'
        || ', objectTypeId=' || objectTypeId
        || ', optionShortName="' || optionShortName || '"'
        || ', testProdSensitiveFlag=' || testProdSensitiveFlag
        || ', changeValueFlag=' || changeValueFlag
        || ').'
      )
    , true
  );
end addOptionWithValue;

/* proc: getOptionValue
  Возвращает таблицу параметров с текущими используемыми значениями.

  Параметры:
  rowTable                    - таблица с данными
                                ( тип <opt_option_value_table_t>)
                                ( возврат)
  moduleId                    - Id модуля, к которому относятся параметры
  objectShortName             - короткое название объекта модуля, к которому
                                относятся параметры ( по умолчанию относящиеся
                                ко всему модулю)
  objectTypeId                - Id типа объекта
                                ( null при отсутствии объекта ( по умолчанию))
  usedOperatorId              - Id оператора, для которого может
                                использоваться значение
                                ( null без ограничений ( по умолчанию))

  Замечания:
  - процедура позволяет получить данные из представления <v_opt_option_value>
    в контексте указанного usedOperatorId;
*/
procedure getOptionValue(
  rowTable out nocopy opt_option_value_table_t
  , moduleId integer
  , objectShortName varchar2 := null
  , objectTypeId integer := null
  , usedOperatorId integer := null
)
is

  cursor dataCur is
    select
      t.*
    from
      v_opt_option_value t
    where
      t.module_id = moduleId
      and (
        objectShortName is null
          and t.object_short_name is null
        or t.object_short_name = objectShortName
          and t.object_type_id = objectTypeId
      )
    order by
      t.option_short_name
  ;

-- getOptionValue
begin
  rowTable := opt_option_value_table_t();
  currentUsedOperatorId := usedOperatorId;
  for rec in dataCur loop
    begin
      rowTable.extend(1);
      rowTable( rowTable.last()) :=
        opt_option_value_t(
          option_id                         => rec.option_id
          , value_id                        => rec.value_id
          , module_name                     => rec.module_name
          , object_short_name               => rec.object_short_name
          , object_type_short_name          => rec.object_type_short_name
          , option_short_name               => rec.option_short_name
          , value_type_code                 => rec.value_type_code
          , date_value                      => rec.date_value
          , number_value                    => rec.number_value
          , string_value                    =>
              case when
                rec.encryption_flag = 1 and rec.string_value is not null
              then
                getDecryptValue(
                  stringValue     => rec.string_value
                  , listSeparator => rec.list_separator
                )
              else
                rec.string_value
              end
          , encrypted_string_value          =>
              case when rec.encryption_flag = 1 then
                rec.string_value
              end
          , list_separator                  => rec.list_separator
          , value_list_flag                 => rec.value_list_flag
          , encryption_flag                 => rec.encryption_flag
          , test_prod_sensitive_flag        => rec.test_prod_sensitive_flag
          , access_level_code               => rec.access_level_code
          , option_name                     => rec.option_name
          , option_description              => rec.option_description
          , prod_value_flag                 => rec.prod_value_flag
          , instance_name                   => rec.instance_name
          , used_operator_id                => rec.used_operator_id
          , module_id                       => rec.module_id
          , module_svn_root                 => rec.module_svn_root
          , object_type_id                  => rec.object_type_id
          , object_type_name                => rec.object_type_name
          , object_type_module_id           => rec.object_type_module_id
          , object_type_module_name         => rec.object_type_module_name
          , object_type_module_svn_root     => rec.object_type_module_svn_root
          , option_change_number            => rec.option_change_number
          , option_change_date              => rec.option_change_date
          , option_change_operator_id       => rec.option_change_operator_id
          , option_date_ins                 => rec.option_date_ins
          , option_operator_id              => rec.option_operator_id
          , value_change_number             => rec.value_change_number
          , value_change_date               => rec.value_change_date
          , value_change_operator_id        => rec.value_change_operator_id
          , value_date_ins                  => rec.value_date_ins
          , value_operator_id               => rec.value_operator_id
        )
      ;
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.errorStack(
            'Ошибка при обработке записи ('
            || ' option_id=' || rec.option_id
            || ', value_id=' || rec.value_id
            || ').'
          )
        , true
      );
    end;
  end loop;

  currentUsedOperatorId := null;
exception when others then
  currentUsedOperatorId := null;
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при получении таблицы параметров с текущими значениями ('
        || ' moduleId=' || moduleId
        || ', objectShortName="' || objectShortName || '"'
        || ', objectTypeId=' || objectTypeId
        || ', usedOperatorId=' || usedOperatorId
        || ').'
      )
    , true
  );
end getOptionValue;



/* group: Поддержка устаревших объектов */

/* func: getSaveValueHistoryFlag
  Возвращает текущее значение флага сохранения истории при изменении
  записей в <opt_value>.
*/
function getSaveValueHistoryFlag
return integer
is
begin
  return coalesce( saveValueHistoryFlag, 1);
end getSaveValueHistoryFlag;

/* func: getCopyOld2NewChangeFlag
  Возвращает текущее значение флага копирования изменений, вносимых в
  устаревшие таблицы, в новые таблицы.
*/
function getCopyOld2NewChangeFlag
return integer
is
begin
  return
    case when isCopyOld2NewChange then 1 else 0 end
  ;
end getCopyOld2NewChangeFlag;

/* iproc: checkNew2OldSync
  Проверяет отсутствие расхождений между значениями параметров в новых и
  устаревших таблицах.
*/
procedure checkNew2OldSync
is

  cursor diffCur is
    select
      count( distinct d.option_id) as option_id_cnt
      , count( distinct d.option_value_id) as option_value_id_cnt
      , min( d.option_id) as min_option_id
      , min( d.option_value_id) as min_option_value_id
    from
      v_opt_option_new2old_diff d
  ;

begin
  if not coalesce( isSkipCheckNew2OldSync, false) then
    for rec in diffCur loop
      if rec.option_id_cnt > 0 then
        raise_application_error(
          pkg_Error.ProcessError
          , 'Найдены расхождения ('
            || ' option_id_cnt=' || rec.option_id_cnt
            || ', option_value_id_cnt=' || rec.option_value_id_cnt
            || ', min_option_id=' || rec.min_option_id
            || ', min_option_value_id=' || rec.min_option_value_id
            || ').'
        );
      end if;
    end loop;
    logger.trace( 'checkNew2OldSync: OK');
  else
    logger.trace( 'checkNew2OldSync: skipped');
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при проверке отсутствия расхождений между данными в новых'
        || ' и устаревших таблицах.'
      )
    , true
  );
end checkNew2OldSync;

/* proc: onOldBeforeStatement
  Вызывается из триггеров на таблицах <opt_option> и <opt_option_value> перед
  выполнением DML.

  Параметры:
  tableName                   - имя таблицы ( в верхнем регистре)
  statementType               - тип DML ( INSERT / UPDATE / DELETE)
*/
procedure onOldBeforeStatement(
  tableName varchar2
  , statementType varchar2
)
is
begin
  logger.trace(
    'onOldBeforeStatement: ' || tableName || ': ' || statementType
    || case when not isCopyOld2NewChange then ' - skipped' end
  );
  if coalesce( isCopyOld2NewChange, true) then
    if coalesce( tableName, '-') not in ( 'OPT_OPTION', 'OPT_OPTION_VALUE') then
      raise_application_error(
        pkg_Error.IllegalArgument
        , 'Указано некорректное имя таблицы.'
      );
    elsif coalesce( statementType, '-') not in ( 'INSERT', 'UPDATE', 'DELETE')
        then
      raise_application_error(
        pkg_Error.IllegalArgument
        , 'Указан некорректный тип DML.'
      );
    elsif tableName = 'OPT_OPTION_VALUE' and statementType = 'UPDATE' then
      raise_application_error(
        pkg_Error.ProcessError
        , 'Изменение ( update) записей в таблице opt_option_value запрещено.'
      );
    end if;
    onChangeTableName := tableName;
    onChangeStatementType := statementType;
    onChangeIdList := IdListT();
    onDeleteOptionSNameList := OptionSNameListT();
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка в процедуре, вызываемой перед выполнением DML ('
        || ' tableName="' || tableName || '"'
        || ', statementType="' || statementType || '"'
        || ').'
      )
    , true
  );
end onOldBeforeStatement;

/* proc: onOldAfterRow
  Вызывается из триггеров на таблицах <opt_option> и <opt_option_value> при
  выполнении DML после изменения каждой записи.

  Параметры:
  tableName                   - имя таблицы ( в верхнем регистре)
  statementType               - тип DML ( INSERT / UPDATE / DELETE)
  newRowId                    - Id изменяемой записи ( новое значение)
  oldRowId                    - Id изменяемой записи ( старое значение)
  oldOptionShortName          - короткое название опции ( передается
                                только в случае удаления из opt_option)

  Замечания:
  - в качестве значения параметров newRowId и oldRowId для таблицы opt_option
    указывается option_id, для таблицы opt_option_value указывается
    option_value_id;
*/
procedure onOldAfterRow(
  tableName varchar2
  , statementType varchar2
  , newRowId integer
  , oldRowId integer
  , oldOptionShortName varchar2 := null
)
is
begin
  logger.trace(
    'onOldAfterRow: ' || tableName || ': ' || statementType
    || ': ' || newRowId || ' ( ' || oldRowId
    || case when oldOptionShortName is not null then
        ', "' || oldOptionShortName || '"'
      end
    || ')'
    || case when not isCopyOld2NewChange then ' - skipped' end
  );
  if coalesce( isCopyOld2NewChange, true) then
    if tableName = onChangeTableName and statementType = onChangeStatementType
        then
      if newRowId != oldRowId then
        raise_application_error(
          pkg_Error.ProcessError
          , 'Изменение значения первичного ключа записи запрещено.'
        );
      end if;
      onChangeIdList.extend(1);
      onChangeIdList( onChangeIdList.last) := coalesce( newRowId, oldRowId);
      if tableName = 'OPT_OPTION' and  statementType = 'DELETE' then
        onDeleteOptionSNameList.extend(1);
        onDeleteOptionSNameList( onDeleteOptionSNameList.last)
          := oldOptionShortName
        ;
      end if;
    else
      raise_application_error(
        pkg_Error.IllegalArgument
        , 'Неожиданное имя таблицы или тип DML ( ожидалось'
          || ' "' || onChangeTableName || '"'
          || ' и "' || onChangeStatementType || '"'
          || ').'
          || ' Выполнение сложных DML ( например, merge) не поддерживается.'
      );
    end if;
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка в процедуре, вызываемой после изменения каждой записи в DML ('
        || ' tableName="' || tableName || '"'
        || ', statementType="' || statementType || '"'
        || ', newRowId=' || newRowId
        || ', oldRowId=' || oldRowId
        || ').'
      )
    , true
  );
end onOldAfterRow;

/* proc: onOldAfterStatement
  Вызывается из триггеров на таблицах <opt_option> и <opt_option_value> после
  выполнения DML.

  Параметры:
  tableName                   - имя таблицы ( в верхнем регистре)
  statementType               - тип DML ( INSERT / UPDATE / DELETE)
*/
procedure onOldAfterStatement(
  tableName varchar2
  , statementType varchar2
)
is



  /*
    Обработка вставки в opt_option.
  */
  procedure processOptionInsert(
    optionId integer
  )
  is

    cursor oldOptionCur is
      select
        b.*
        , opn.option_id as new_option_id
        , cast( null as varchar2(100)) as batch_short_name
        , cast( null as integer) as module_id
      from
        (
        select
          a.*
          , case when
                a.option_short_name != a.prod_option_short_name
              then 1 else 0
            end
            as is_test_option
        from
          (
          select
            opt.*
            , case when
                opt.option_short_name like '%_'
                || OldTestOption_Suffix
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
          ) a
        ) b
        left outer join opt_option_new opn
          on opn.old_option_short_name = b.prod_option_short_name
            and opn.deleted = 0
    ;

    oldRec oldOptionCur%rowtype;

    rec opt_option_new%rowtype;



    /*
      Возвращает короткое имя батча и Id модуля, к которому относится
      параметр, либо null, если он не связан с батчем.
      Выборка вынесена из основного запроса в функцию и сделана динамической,
      чтобы избежать ошибки при отсутствии модуля Scheduler ( т.к. зависимости
      от него быть не должно).
    */
    procedure getBatchShortName(
      batchShortName out varchar2
      , moduleId out integer
      , optionId integer
    )
    is
    begin
      if schedulerExistsInfo is null then
        select
          coalesce(
            max( case when t.column_name = 'MODULE_ID' then 2 else 1 end)
            , 0
          )
          as scheduler_exists_flag
        into schedulerExistsInfo
        from
          user_tab_columns t
        where
          t.table_name = 'SCH_BATCH'
        ;
      end if;
      if schedulerExistsInfo > 0 then
        execute immediate '
          select
            max( opb.batch_short_name)
            , max( opb.module_id)
          from
            (
            select
              op.option_id
              , max( b.batch_short_name) as batch_short_name
              , to_number( substr(
                  max( rpad( b.batch_short_name, 50) || to_char( b.module_id))
                  , 51
                ))
                as module_id
            from
              opt_option op
              , (
                select
                  b.batch_short_name
                  , ' || case when schedulerExistsInfo = 2 then
                      'b.module_id'
                    else
                      'cast( null as integer) as module_id'
                    end
                  || '
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
          where
            opb.option_id = :optionId
        '
        into
          batchShortName
          , moduleId
        using
          optionId
        ;
      end if;
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.errorStack(
            'Ошибка при определении имени батча, к которому относится'
            || ' параметр ('
            || ' optionId=' || optionId
            || ').'
          )
        , true
      );
    end getBatchShortName;



    /*
      Возвращает тип значения параметра, соответствующий указанному значению
      маски.
    */
    function getValueTypeFromMask(
      maskId integer
    )
    return varchar2
    is
    begin
      return
        case oldRec.mask_id
          when 1 then Number_ValueTypeCode
          when 2 then Number_ValueTypeCode
          when 3 then String_ValueTypeCode
          when 4 then Date_ValueTypeCode
        end
      ;
    end getValueTypeFromMask;



    /*
      Заполнение полей для нового параметра.
    */
    procedure fillRec
    is
    begin
      rec.option_id                 := oldRec.option_id;
      rec.module_id                 :=
        case when oldRec.module_id is not null then
          oldRec.module_id
        else
          pkg_ModuleInfo.getModuleId(
            moduleName =>
              case
                when oldRec.batch_short_name is not null then
                  BatchLoader_ModuleName
                when oldRec.prod_option_short_name like '_%._%' then
                  substr(
                    oldRec.prod_option_short_name
                    , 1
                    , instr( oldRec.prod_option_short_name, '.') - 1
                  )
                when oldRec.prod_option_short_name like '_%:_%' then
                  substr(
                    oldRec.prod_option_short_name
                    , 1
                    , instr( oldRec.prod_option_short_name, ':') - 1
                  )
              end
            , raiseExceptionFlag => 0
          )
        end
      ;
      if rec.module_id is null then
        raise_application_error(
          pkg_Error.IllegalArgument
          , 'Не удалось определить имя модуля для параметра ('
            || ' option_short_name="' || oldRec.option_short_name || '"'
            || ', is_test_option=' || oldRec.is_test_option
            || ').'
        );
      end if;
      rec.object_short_name         := oldRec.batch_short_name;
      rec.object_type_id            :=
        case when oldRec.batch_short_name is not null then
          getObjectTypeId(
            moduleId              =>
                pkg_ModuleInfo.getModuleId(
                  svnRoot => Scheduler_SvnRoot
                )
            , objectTypeShortName => Batch_ObjectTypeShortName
          )
        end
      ;
      rec.option_short_name         :=
        case
          when oldRec.batch_short_name is not null then
            substr(
              oldRec.prod_option_short_name
              , length( oldRec.batch_short_name) + 1
            )
          when oldRec.prod_option_short_name like '_%._%' then
            substr(
              oldRec.prod_option_short_name
              , instr( oldRec.prod_option_short_name, '.') + 1
            )
          when oldRec.prod_option_short_name like '_%:_%' then
            substr(
              oldRec.prod_option_short_name
              , instr( oldRec.prod_option_short_name, ':') + 1
            )
          else
            oldRec.prod_option_short_name
        end
      ;
      rec.value_type_code           := getValueTypeFromMask( oldRec.mask_id);
      rec.value_list_flag           := 0;
      rec.encryption_flag           := 0;
      rec.test_prod_sensitive_flag  :=
        case when
            oldRec.is_test_option = 1
            or oldRec.batch_short_name is not null
          then 1
          else 0
        end
      ;
      rec.access_level_code         := null;
      rec.option_name               :=
        case
          when oldRec.is_test_option = 1
                and oldRec.option_name like '% (тест)'
              then
            substr( oldRec.option_name, 1, length( oldRec.option_name) - 7)
          when oldRec.is_test_option = 1
                and oldRec.option_name like '% ( тест)'
              then
            substr( oldRec.option_name, 1, length( oldRec.option_name) - 8)
          else
            oldRec.option_name
        end
      ;
      rec.option_description        := null;
      rec.old_option_short_name     := oldRec.prod_option_short_name;
      rec.old_mask_id               := oldRec.mask_id;
      rec.old_option_name_test      :=
        case when oldRec.is_test_option = 1 then
          oldRec.option_name
        end
      ;
      rec.operator_id               := oldRec.operator_id;
    end fillRec;



  -- processOptionInsert
  begin
    open oldOptionCur;
    fetch oldOptionCur into oldRec;
    close oldOptionCur;

    if oldRec.new_option_id is null then
      getBatchShortName(
        batchShortName  => oldRec.batch_short_name
        , moduleId      => oldRec.module_id
        , optionId      => oldRec.option_id
      );
      fillRec();
      rec.option_id := createOption(
        moduleId                => rec.module_id
        , optionShortName       => rec.option_short_name
        , valueTypeCode         => rec.value_type_code
        , optionName            => rec.option_name
        , objectShortName       => rec.object_short_name
        , objectTypeId          => rec.object_type_id
        , valueListFlag         => rec.value_list_flag
        , encryptionFlag        => rec.encryption_flag
        , testProdSensitiveFlag => rec.test_prod_sensitive_flag
        , accessLevelCode       => rec.access_level_code
        , optionDescription     => rec.option_description
        , optionId              => rec.option_id
        , oldOptionShortName    => rec.old_option_short_name
        , oldMaskId             => rec.old_mask_id
        , oldOptionNameTest     => rec.old_option_name_test
        , operatorId            => rec.operator_id
      );
    else
      lockOption(
        rowData     => rec
        , optionId  => oldRec.new_option_id
      );
      if rec.value_type_code != getValueTypeFromMask( oldRec.mask_id)
          or rec.value_list_flag = 1
          then
        raise_application_error(
          pkg_Error.ProcessError
          , 'Тип ранее созданного параметра отличается от типа добавляемого'
            || ' параметра ('
            || ' option_id=' || rec.option_id
            || ', value_type_code="' || rec.value_type_code || '"'
            || ', value_list_flag=' || rec.value_list_flag
            || ').'
        );
      elsif
          oldRec.is_test_option = 0
            and rec.option_name != oldRec.option_name
          or oldRec.is_test_option = 1
            and (
              rec.test_prod_sensitive_flag != 1
              or nullif( oldRec.option_name, rec.old_option_name_test)
                  is not null
            )
          then
        updateOption(
          optionId                      => rec.option_id
          , valueTypeCode               => rec.value_type_code
          , valueListFlag               => rec.value_list_flag
          , encryptionFlag              => rec.encryption_flag
          , testProdSensitiveFlag       =>
              case when oldRec.is_test_option = 1 then
                1
              else
                rec.test_prod_sensitive_flag
              end
          , accessLevelCode             => rec.access_level_code
          , optionName                  =>
              case when oldRec.is_test_option = 0 then
                oldRec.option_name
              else
                rec.option_name
              end
          , optionDescription           => rec.option_description
          , moveProdSensitiveValueFlag  => 1
          , deleteBadValueFlag          => 0
          , oldOptionNameTest           =>
              case when oldRec.is_test_option = 1 then
                oldRec.option_name
              else
                rec.old_option_name_test
              end
          , operatorId                  => oldRec.operator_id
        );
      end if;
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при обработке вставки в opt_option ('
          || ' optionId=' || optionId
          || ').'
        )
      , true
    );
  end processOptionInsert;



  /*
    Обработка изменения в opt_option ( разрешено только изменение поля
    option_name).
  */
  procedure processOptionUpdate(
    oldOptionId integer
  )
  is

    cursor oldOptionCur is
      select
        b.*
        , opn.option_id as new_option_id
      from
        (
        select
          a.*
          , case when
                a.option_short_name != a.prod_option_short_name
              then 1 else 0
            end
            as is_test_option
        from
          (
          select
            opt.*
            , case when
                opt.option_short_name like '%_'
                || OldTestOption_Suffix
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
            opt.option_id = oldOptionId
          ) a
        ) b
        left outer join opt_option_new opn
          on opn.old_option_short_name = b.prod_option_short_name
            and opn.deleted = 0
    ;

    oldRec oldOptionCur%rowtype;

    rec opt_option_new%rowtype;

  -- processOptionUpdate
  begin
    open oldOptionCur;
    fetch oldOptionCur into oldRec;
    close oldOptionCur;
    lockOption(
      rowData     => rec
      , optionId  => oldRec.new_option_id
    );
    updateOption(
      optionId                      => rec.option_id
      , valueTypeCode               => rec.value_type_code
      , valueListFlag               => rec.value_list_flag
      , encryptionFlag              => rec.encryption_flag
      , testProdSensitiveFlag       => rec.test_prod_sensitive_flag
      , accessLevelCode             => rec.access_level_code
      , optionName                  =>
          case when oldRec.is_test_option = 1 then
            rec.option_name
          else
            oldRec.option_name
          end
      , optionDescription           => rec.option_description
      , oldOptionNameTest           =>
          case
            when oldRec.is_test_option = 1 then
              oldRec.option_name
            else
              coalesce(
                rec.old_option_name_test
                -- исключаем появление различия из-за неявного изменения
                -- тестового названия опции ( которое формируется на базе
                -- option_name)
                , case when rec.test_prod_sensitive_flag = 1 then
                    rec.option_name || OldTestOptionName_Suffix
                  end
              )
          end
      , operatorId                  => null
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при обработке изменения в opt_option ('
          || ' oldOptionId=' || oldOptionId
          || ').'
        )
      , true
    );
  end processOptionUpdate;



  /*
    Обработка удаления из opt_option.
  */
  procedure processOptionDelete(
    oldOptionId integer
    , oldOptionShortName varchar2
  )
  is

    -- Последняя запись, относящаяся к удаленной из opt_option записи
    vhr v_opt_value_history%rowtype;



    /*
      Определяет последнюю запись из v_opt_value_history, относящуюся к
      удаленной записи и сохраняет ее в переменной vhr.
    */
    procedure getValue
    is

      cursor valueCur is
        select
          a.*
        into vhr
        from
          (
          select
            vlh.*
          from
            v_opt_value_history vlh
          where
            vlh.old_option_id = oldOptionId
          order by
            vlh.value_history_id desc nulls first
            , vlh.change_date desc
            , vlh.value_id desc
          ) a
        where
          rownum <= 1
      ;

    begin
      open valueCur;
      fetch valueCur into vhr;
      close valueCur;

      -- Данных может не быть, если для параметра не задавалось значение
      if vhr.value_id is not null then
        if vhr.deleted = 1 then
          raise_application_error(
            pkg_Error.ProcessError
            , 'Запись была удалена ('
              || ' value_id=' || vhr.value_id
              || ', change_number=' || vhr.change_number
              || ').'
          );
        elsif vhr.old_option_del_date is not null then
          raise_application_error(
            pkg_Error.ProcessError
            , 'Запись в opt_option_value уже была удалена ('
              || ' value_id=' || vhr.value_id
              || ', change_number=' || vhr.change_number
              || ', old_option_del_date='
                || to_char( vhr.old_option_del_date, 'dd.mm.yyyy hh24:mi:ss')
              || ').'
          );
        end if;
      end if;
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.errorStack(
            'Ошибка при определении записи из v_opt_value_history ('
            || ' oldOptionId=' || oldOptionId
            || ').'
          )
        , true
      );
    end getValue;



    /*
      Возвращает Id параметра по устаревшему короткому имени
      ( возвращает null, если параметр был удален).
      Если указан checkOptionId, то может быть возвращено только указанное
      значение.
    */
    function getOptionId(
      checkOptionId integer
    )
    return integer
    is

      -- Id параметра
      optionId integer;

    begin
      select
        case when opn.deleted = 0 then
          opn.option_id
        end
        as option_id
      into optionId
      from
        opt_option_new opn
      where
        opn.old_option_short_name =
          case when
            oldOptionShortName like '%_' || OldTestOption_Suffix
          then
            substr(
              oldOptionShortName, 1, length( oldOptionShortName) - 4
            )
          else
            oldOptionShortName
          end
        and nullif( checkOptionId, opn.option_id) is null
      ;
      return optionId;
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.errorStack(
            'Ошибка при определении Id параметра ('
            || ' oldOptionShortName="' || oldOptionShortName || '"'
            || ', checkOptionId=' || checkOptionId
            || ').'
          )
        , true
      );
    end getOptionId;



    /*
      Удаляет параметр, если относящихся к нему записей нет в opt_option.
    */
    procedure deleteNotUsedOption
    is

      -- Id параметра
      optionId integer;

      -- Id записи в opt_option, относящейся к параметру
      minOldOptionId integer;

    begin
      select
        min( opt.option_id)
      into minOldOptionId
      from
        opt_option opt
      where
        opt.option_short_name in (
          -- в принципе запись с oldOptionShortName может быть, т.к. в
          -- opt_option нет уникальности по этому полю
          oldOptionShortName
          , case when
              oldOptionShortName like '%_' || OldTestOption_Suffix
            then
              substr(
                oldOptionShortName, 1, length( oldOptionShortName) - 4
              )
            else
              oldOptionShortName || OldTestOption_Suffix
            end
        )
        -- кроме игнорируемых временных данных
        and opt.option_id >= 0
      ;
      if minOldOptionId is null then
        optionId := getOptionId(
          checkOptionId => vhr.option_id
        );

        -- Параметр может быть уже удален в случае удаления 2-х записей
        -- из opt_option ( по тестовому и промышленному значению)
        -- одной командой delete
        if optionId is not null then
          deleteOption(
            optionId        => optionId
            , operatorId    => null
          );
        end if;
      end if;
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.errorStack(
            'Ошибка проверке параметра на необходимость удаления ('
            || ' option_id=' || vhr.option_id
            || ').'
          )
        , true
      );
    end deleteNotUsedOption;



  -- processOptionDelete
  begin
    getValue();
    if vhr.value_id is not null then
      vhr.old_option_del_date := sysdate;
      setOldDelDate(
        valueId               => vhr.value_id
        , valueHistoryId      => vhr.value_history_id
        , oldOptionDelDate    => vhr.old_option_del_date
      );
    end if;
    deleteNotUsedOption();
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при обработке удаления из opt_option ('
          || ' oldOptionId=' || oldOptionId
          || ', oldOptionShortName="' || oldOptionShortName || '"'
          || ').'
        )
      , true
    );
  end processOptionDelete;



  /*
    Обработка вставки в opt_option_value.
  */
  procedure processValueInsert(
    optionValueId integer
  )
  is

    cursor oldValueCur is
      select
        b.*
        , opn.option_id as new_option_id
        , case when opn.value_list_flag = 1 then
            String_ValueTypeCode
          else
            opn.value_type_code
          end
          as storage_value_type_code
        , opn.test_prod_sensitive_flag
        , opn.encryption_flag
      from
        (
        select
          a.*
          , case when
                a.option_short_name != a.prod_option_short_name
              then 1 else 0
            end
            as is_test_option
        from
          (
          select
            ov.*
            , opt.option_short_name
            , case when
                opt.option_short_name like '%_'
                || OldTestOption_Suffix
              then
                substr(
                  opt.option_short_name, 1, length( opt.option_short_name) - 4
                )
              else
                opt.option_short_name
              end
              as prod_option_short_name
          from
            opt_option_value ov
            inner join opt_option opt
              on opt.option_id = ov.option_id
          where
            ov.option_value_id = optionValueId
          ) a
        ) b
        left outer join opt_option_new opn
          on opn.old_option_short_name = b.prod_option_short_name
            and opn.deleted = 0
    ;

    oldRec oldValueCur%rowtype;

  -- processValueInsert
  begin
    open oldValueCur;
    fetch oldValueCur into oldRec;
    close oldValueCur;
    if oldRec.encryption_flag = 1 then
      raise_application_error(
        pkg_Error.ProcessError
        , 'Для параметра с шифрованием значений установка значения возможна'
          || ' только через API ('
          || ' new_option_id=' || oldRec.new_option_id
          || ').'
      );
    end if;
    setValue(
      optionId                => oldRec.new_option_id
      , prodValueFlag         =>
          case when oldRec.test_prod_sensitive_flag = 1 then
            1 - oldRec.is_test_option
          end
      , instanceName          => null
      , usedOperatorId        => null
      , dateValue             => oldRec.datetime_value
      , numberValue           => oldRec.integer_value
      , stringValue           => oldRec.string_value
      , oldOptionValueId      => oldRec.option_value_id
      , oldOptionId           => oldRec.option_id
      , operatorId            => oldRec.operator_id
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при обработке вставки в opt_option_value ('
          || ' optionValueId=' || optionValueId
          || ').'
        )
      , true
    );
  end processValueInsert;



  /*
    Обработка удаления из opt_option_value.
  */
  procedure processValueDelete(
    optionValueId integer
  )
  is

    -- Последняя запись, относящаяся к удаленной из opt_option_value записи
    vhr v_opt_value_history%rowtype;

    -- Текущее значение
    cv opt_value%rowtype;

    -- Текущее значение согласно opt_option_value
    cov opt_option_value%rowtype;



    /*
      Определяет последнюю запись из v_opt_value_history, относящуюся к
      удаленной записи и сохраняет ее в переменной vhr.
    */
    procedure getValue
    is
    begin
      select
        a.*
      into vhr
      from
        (
        select
          vlh.*
        from
          v_opt_value_history vlh
        where
          vlh.old_option_value_id = optionValueId
        order by
          vlh.value_history_id desc nulls first
        ) a
      where
        rownum <= 1
      ;
      if vhr.deleted = 1 then
        raise_application_error(
          pkg_Error.ProcessError
          , 'Запись была удалена ('
            || ' value_id=' || vhr.value_id
            || ', change_number=' || vhr.change_number
            || ').'
        );
      elsif vhr.old_option_value_del_date is not null then
        raise_application_error(
          pkg_Error.ProcessError
          , 'Запись в opt_option_value уже была удалена ('
            || ' value_id=' || vhr.value_id
            || ', change_number=' || vhr.change_number
            || ', old_option_value_del_date='
              || to_char(
                  vhr.old_option_value_del_date, 'dd.mm.yyyy hh24:mi:ss'
                )
            || ').'
        );
      end if;
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.errorStack(
            'Ошибка при определении записи из v_opt_value_history ('
            || ' optionValueId=' || optionValueId
            || ').'
          )
        , true
      );
    end getValue;



    /*
      Определяет текущее значение согласно таблице opt_value и
      сохраняет его в переменной cv.
    */
    procedure getCurrentValue(
      valueId integer
    )
    is
    begin
      select
        vl.*
      into cv
      from
        opt_value vl
      where
        vl.value_id = valueId
      ;
      if cv.deleted = 1 then
        cv := null;
      end if;
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.errorStack(
            'Ошибка при определении текущего значения по opt_value ('
            || ' valueId=' || valueId
            || ').'
          )
        , true
      );
    end getCurrentValue;



    /*
      Определяет текущее значение согласно таблице opt_option_value и
      сохраняет его в переменной cov.
    */
    procedure getCurrentOldValue(
      valueId integer
      , storageValueTypeCode varchar2
    )
    is

      cursor dataCur is
        select
          a.*
        from
          (
          select
            ov.*
          from
            opt_option_value ov
            inner join opt_option opt
              on opt.option_id = ov.option_id
          where
            ov.option_value_id in
              (
              select
                vlh.old_option_value_id
              from
                v_opt_value_history vlh
              where
                vlh.value_id = valueId
                and vlh.old_option_value_id is not null
                and vlh.old_option_value_del_date is null
              )
            and case opt.mask_id
                when 1 then Number_ValueTypeCode
                when 2 then Number_ValueTypeCode
                when 3 then String_ValueTypeCode
                when 4 then Date_ValueTypeCode
              end
              = storageValueTypeCode
          order by
            ov.date_ins desc
          ) a
        where
          rownum <= 1
      ;

    begin
      open dataCur;
      fetch dataCur into cov;
      close dataCur;
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.errorStack(
            'Ошибка при определении текущего значения по opt_option_value ('
            || ' valueId=' || valueId
            || ').'
          )
        , true
      );
    end getCurrentOldValue;



  -- processValueDelete
  begin
    getValue();
    getCurrentValue( valueId => vhr.value_id);
    getCurrentOldValue(
      valueId                 => vhr.value_id
      , storageValueTypeCode  => vhr.storage_value_type_code
    );

    vhr.old_option_value_del_date := sysdate;
    setOldDelDate(
      valueId                 => vhr.value_id
      , valueHistoryId        => vhr.value_history_id
      , oldOptionValueDelDate => vhr.old_option_value_del_date
    );
    if nullif( cov.option_value_id, cv.old_option_value_id) is not null then
      updateValue(
        valueId                 => cv.value_id
        , valueTypeCode         => cv.value_type_code
        , dateValue             =>
            case when
              cv.storage_value_type_code = Date_ValueTypeCode
            then
              cov.datetime_value
            end
        , numberValue           =>
            case when
              cv.storage_value_type_code = Number_ValueTypeCode
            then
              cov.integer_value
            end
        , stringValue           =>
            case when
              cv.storage_value_type_code = String_ValueTypeCode
            then
              cov.string_value
            end
        , valueListSeparator    => cv.list_separator
        , oldOptionValueId      => cov.option_value_id
        , oldOptionId           => cov.option_id
        , operatorId            => null
      );
    elsif cov.option_value_id is null
          and cv.old_option_value_id is not null
        then
      deleteValue(
        valueId   => cv.value_id
      );
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при обработке удаления из opt_option_value ('
          || ' optionValueId=' || optionValueId
          || ').'
        )
      , true
    );
  end processValueDelete;



  /*
    Обработка изменений, внесенных в устаревшие таблицы.
  */
  procedure processChange
  is

    -- Индекс текущего элемента коллекции
    i pls_integer;

  begin
    i := onChangeIdList.first();
    while i is not null loop
      if onChangeIdList( i) < 0 then
        logger.trace(
          'processChange: ignore temporary changes: id=' || onChangeIdList( i)
        );
      else
        case
          when tableName = 'OPT_OPTION' and statementType = 'INSERT' then
            processOptionInsert( optionId => onChangeIdList( i));
          when tableName = 'OPT_OPTION' and statementType = 'UPDATE' then
            processOptionUpdate( oldOptionId => onChangeIdList( i));
          when tableName = 'OPT_OPTION' and statementType = 'DELETE' then
            processOptionDelete(
              oldOptionId           => onChangeIdList( i)
              , oldOptionShortName  => onDeleteOptionSNameList( i)
            );
          when tableName = 'OPT_OPTION_VALUE' and statementType = 'INSERT' then
            processValueInsert( optionValueId => onChangeIdList( i));
          when tableName = 'OPT_OPTION_VALUE' and statementType = 'DELETE' then
            processValueDelete( optionValueId => onChangeIdList( i));
          else
            raise_application_error(
              pkg_Error.ProcessError
              , 'Обработка изменения не поддерживается.'
            );
        end case;
      end if;
      i := onChangeIdList.next( i);
    end loop;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при обработке изменения.'
        )
      , true
    );
  end processChange;



-- onOldAfterStatement
begin
  logger.trace(
    'onOldAfterStatement: ' || tableName || ': ' || statementType
    || case when not isCopyOld2NewChange then ' - skipped' end
  );
  if coalesce( isCopyOld2NewChange, true) then
    isCopyOld2NewChange := true;
    if tableName = onChangeTableName and statementType = onChangeStatementType
        then

      -- отключаем, а затем включаем копирование изменений из новых таблиц
      -- в устаревшие
      begin
        isCopyNew2OldChange := false;
        processChange();
        isCopyNew2OldChange := true;
      exception when others then
        isCopyNew2OldChange := true;
        raise;
      end;

      checkNew2OldSync();
      onChangeTableName := null;
      onChangeStatementType := null;
      onChangeIdList := null;
    else
      raise_application_error(
        pkg_Error.IllegalArgument
        , 'Неожиданное имя таблицы или тип DML ( ожидалось'
          || ' "' || onChangeTableName || '"'
          || ' и "' || onChangeStatementType || '"'
          || ').'
          || ' Выполнение сложных DML ( например, merge) не поддерживается.'
      );
    end if;
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка в процедуре, вызываемой после выполнения DML ('
        || ' tableName="' || tableName || '"'
        || ', statementType="' || statementType || '"'
        || ').'
      )
    , true
  );
end onOldAfterStatement;

end pkg_OptionMain;
/
