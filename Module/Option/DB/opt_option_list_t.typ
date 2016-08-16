-- Для Oracle 11.2 и выше для пересоздания типа используется опция "force"
-- в create type, для более ранних версий используется "drop type force"
set define on

@oms-default forceOption "' || case when to_number( '&_O_RELEASE') >= 1102000000 then 'force' else '--' end || '"

@oms-default dropTypeScript "' || case when '&forceOption' = '--' then './oms-drop-type.sql' else '' end || '"

@oms-run "&dropTypeScript" opt_option_list_t

create or replace type
  opt_option_list_t
&forceOption
as object
(
/* db object type: opt_option_list_t
  Набор настроечных параметров ( интерфейс для прикладных модулей).

  SVN root: Oracle/Module/Option
*/



/* group: Закрытые объявления */

/* ivar: moduleId
  Id модуля, к которому относятся параметры.
*/
moduleId integer,

/* ivar: objectShortName
  Краткое наименование объекта модуля, к которому относятся параметры
  ( null если параметры относятся ко всему модулю).
*/
objectShortName varchar2(100),

/* ivar: objectTypeId
  Id типа объекта ( null при отсутствии объекта).
*/
objectTypeId integer,

/* ivar: usedOperatorId
  Id оператора, для которого может использоваться значение ( null без
  ограничений).
*/
usedOperatorId integer,



/* group: Защищенные объявления */

/* ivar: logger
  Логер объекта
*/
logger lg_logger_t,



/* group: Функции */



/* group: Защищенные объявления */

/* pproc: initialize
  Инициализирует экземпляр объекта.

  Параметры:
  moduleId                    - Id модуля, к которому относятся параметры
  objectShortName             - краткое наименование объекта модуля, к которому
                                относятся параметры ( по умолчанию относящиеся
                                ко всему модулю)
  objectTypeShortName         - краткое наименование типа объекта
                                ( нужно указывать если указан objectShortName,
                                  по умолчанию отсутствует)
  objectTypeModuleId          - Id модуля, к которому относится тип объекта
                                ( по умолчанию к тому же модулю, что и
                                  параметры)
  usedOperatorId              - Id оператора, для которого может
                                использоваться значение
                                ( null без ограничений ( по умолчанию))

  ( <body::initialize>)
*/
member procedure initialize(
  moduleId integer
  , objectShortName varchar2 := null
  , objectTypeShortName varchar2 := null
  , objectTypeModuleId integer := null
  , usedOperatorId integer := null
),



/* group: Уровни доступа через интерфейс */

/* pfunc: getFullAccessLevelCode
  Возвращает код уровня доступа "Полный доступ".

  ( <body::getFullAccessLevelCode>)
*/
static function getFullAccessLevelCode
return varchar2,

/* pfunc: getReadAccessLevelCode
  Возвращает код уровня доступа "Только для чтения".

  ( <body::getReadAccessLevelCode>)
*/
static function getReadAccessLevelCode
return varchar2,

/* pfunc: getValueAccessLevelCode
  Возвращает код уровня доступа "Изменение значения".

  ( <body::getValueAccessLevelCode>)
*/
static function getValueAccessLevelCode
return varchar2,



/* group: Типы значений параметров */

/* pfunc: getDateValueTypeCode
  Возвращает код типа значения "Дата ( со временем)".

  ( <body::getDateValueTypeCode>)
*/
static function getDateValueTypeCode
return varchar2,

/* pfunc: getNumberValueTypeCode
  Возвращает код типа значения "Число".

  ( <body::getNumberValueTypeCode>)
*/
static function getNumberValueTypeCode
return varchar2,

/* pfunc: getStringValueTypeCode
  Возвращает код типа значения "Строка".

  ( <body::getStringValueTypeCode>)
*/
static function getStringValueTypeCode
return varchar2,



/* group: Типы объектов */

/* pfunc: getPlsqlObjectTypeSName
  Возвращает краткое наименование типа объекта "PL/SQL объект".

  ( <body::getPlsqlObjectTypeSName>)
*/
static function getPlsqlObjectTypeSName
return varchar2,



/* group: Изменение значения параметра */

/* pproc: updateDateValue
  Изменяет значение настроечного параметра типа дата.

  Параметры:
  valueId                     - Id значения
  dateValue                   - значение параметра типа дата
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
  operatorId                  - Id оператора ( по умолчанию текущий)

  ( <body::updateDateValue>)
*/
static procedure updateDateValue(
  valueId integer
  , dateValue date
  , valueIndex integer := null
  , operatorId integer := null
),

/* pproc: updateNumberValue
  Изменяет числовое значение настроечного параметра.

  Параметры:
  valueId                     - Id значения
  numberValue                 - числовое значение параметра
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
  operatorId                  - Id оператора ( по умолчанию текущий)

  ( <body::updateNumberValue>)
*/
static procedure updateNumberValue(
  valueId integer
  , numberValue number
  , valueIndex integer := null
  , operatorId integer := null
),

/* pproc: updateStringValue
  Изменяет строковое значение настроечного параметра.

  Параметры:
  valueId                     - Id значения
  stringValue                 - строковое значение параметра
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
  operatorId                  - Id оператора ( по умолчанию текущий)

  ( <body::updateStringValue>)
*/
static procedure updateStringValue(
  valueId integer
  , stringValue varchar2
  , valueIndex integer := null
  , operatorId integer := null
),



/* group: Удаление значения по value_id */

/* pproc: deleteValue( VALUE_ID)
  Удаляет значение настроечного параметра.

  Параметры:
  valueId                     - Id значения
  operatorId                  - Id оператора ( по умолчанию текущий)

  ( <body::deleteValue( VALUE_ID)>)
*/
static procedure deleteValue(
  valueId integer
  , operatorId integer := null
),



/* group: Конструкторы */

/* pfunc: opt_option_list_t
  Создает набор настроечных параметров и устанавливает его свойства.

  Параметры:
  findModuleString            - строка для поиска модуля (
                                может совпадать с одним из трех атрибутов
                                модуля: названием, путем к корневому каталогу,
                                первоначальным путем к корневому каталогу в
                                Subversion)
  objectShortName             - краткое наименование объекта модуля, к которому
                                относятся параметры ( по умолчанию относящиеся
                                ко всему модулю)
  objectTypeShortName         - краткое наименование типа объекта
                                ( нужно указывать если указан objectShortName,
                                  по умолчанию отсутствует)
  objectTypeFindModuleString  - строка для поиска модуля типа объекта
                                ( аналогично findModuleString, по умолчанию
                                  отсутствует)
  usedOperatorId              - Id оператора, для которого может
                                использоваться значение
                                ( null без ограничений ( по умолчанию))
  moduleName                  - наименование модуля ( например "ModuleInfo")
  moduleSvnRoot               - путь к корневому каталогу модуля в Subversion
                                ( начиная с имени репозитария, например
                                "Oracle/Module/ModuleInfo")
  objectTypeModuleName        - наименование модуля типа объекта
                                ( аналогично moduleName, по умолчанию
                                  отсутствует)
  objectTypeModuleSvnRoot     - путь к корневому каталогу модуля типа объекта
                                в Subversion ( аналогично moduleSvnRoot, по
                                умолчанию отсутствует)

  Замечания:
  - для определения модуля должен быть задан один из параметров
    findModuleString, moduleName, moduleSvnRoot и модуль по нему
    должен определяться однозначно, иначе будет выброшено исключение
    ( то же самое касается параметров определения модуля типа объекта);
  - если не заданы параметры для определения модуля типа объекта, то считается,
    что тип объекта относится к тому же модулю, что и параметры;

  ( <body::opt_option_list_t>)
*/
constructor function opt_option_list_t(
  findModuleString varchar2 := null
  , objectShortName varchar2 := null
  , objectTypeShortName varchar2 := null
  , objectTypeFindModuleString varchar2 := null
  , usedOperatorId integer := null
  , moduleName varchar2 := null
  , moduleSvnRoot varchar2 := null
  , objectTypeModuleName varchar2 := null
  , objectTypeModuleSvnRoot varchar2 := null
)
return self as result,

/* pfunc: opt_option_list_t( moduleId)
  Создает набор настроечных параметров и устанавливает его свойства.

  Параметры:
  moduleId                    - Id модуля, к которому относятся параметры
  objectShortName             - краткое наименование объекта модуля, к которому
                                относятся параметры ( по умолчанию относящиеся
                                ко всему модулю)
  objectTypeShortName         - краткое наименование типа объекта
                                ( нужно указывать если указан objectShortName,
                                  по умолчанию отсутствует)
  objectTypeModuleId          - Id модуля, к которому относится тип объекта
                                ( по умолчанию к тому же модулю, что и
                                  параметры)
  usedOperatorId              - Id оператора, для которого может
                                использоваться значение
                                ( null без ограничений ( по умолчанию))

  ( <body::opt_option_list_t( moduleId)>)
*/
constructor function opt_option_list_t(
  moduleId integer
  , objectShortName varchar2 := null
  , objectTypeShortName varchar2 := null
  , objectTypeModuleId integer := null
  , usedOperatorId integer := null
)
return self as result,



/* group: Вспомогательные функции */

/* pfunc: existsOption
  Проверяет наличие настроечного параметра.

  Параметры:
  optionShortName             - краткое наименование параметра

  Возврат:
  1 в случае наличия параметра, иначе 0.

  ( <body::existsOption>)
*/
member function existsOption(
  optionShortName varchar2
)
return integer,

/* pfunc: getModuleId
  Возвращает Id модуля, к которому относятся параметры.

  Возврат:
  Id модуля ( из таблицы mod_module модуля ModuleInfo).

  ( <body::getModuleId>)
*/
member function getModuleId
return integer,

/* pfunc: getObjectShortName
  Возвращает краткое наименование объекта модуля, к которому относятся параметры.

  Возврат:
  краткое наименование объекта ( null если параметры относятся ко всему модулю).

  ( <body::getObjectShortName>)
*/
member function getObjectShortName
return varchar2,

/* pfunc: getObjectTypeId
  Возвращает Id типа объекта, к которому относятся параметры.

  Возврат:
  Id типа объекта ( null при отсутствии объекта).

  ( <body::getObjectTypeId>)
*/
member function getObjectTypeId
return integer,

/* pfunc: getObjectTypeId( objectTypeShortName)
  Возвращает Id типа объекта.

  Параметры:
  objectTypeShortName         - краткое наименование типа объекта
  raiseNotFoundFlag           - выбрасывать ли исключение в случае отсутствия
                                типа объекта ( 1 да, 0 нет ( по умолчанию))

  Возврат:
  Id типа объекта.

  Замечания:
  - считается, что тип объекта относится к модулю, для которого был создан
    текущий экземпляр объекта opt_option_list_t;

  ( <body::getObjectTypeId( objectTypeShortName)>)
*/
member function getObjectTypeId(
  objectTypeShortName varchar2
  , raiseNotFoundFlag integer := null
)
return integer,

/* pfunc: getOptionId
  Возвращает Id настроечного параметра.

  Параметры:
  optionShortName             - краткое наименование параметра
  raiseNotFoundFlag           - выбрасывать ли исключение в случае отсутствия
                                параметра ( 1 да ( по умолчанию), 0 нет)

  Возврат:
  Id параметра либо null, если параметр не
  найден и значение raiseNotFoundFlag равно 0.

  ( <body::getOptionId>)
*/
member function getOptionId(
  optionShortName varchar2
  , raiseNotFoundFlag integer := null
)
return integer,

/* pfunc: getUsedOperatorId
  Id оператора, для которого может использоваться значение.

  Возврат:
  Id оператора ( null без ограничений).

  ( <body::getUsedOperatorId>)
*/
member function getUsedOperatorId
return integer,

/* pfunc: getValueId
  Возвращает Id указанного значения ( списка значений) настроечного параметра.

  Параметры:
  optionShortName             - краткое наименование параметра
  prodValueFlag               - флаг использования значения только в
                                промышленных ( либо тестовых) БД
                                ( 1 только в промышленных БД, 0 только в
                                тестовых БД, null без ограничений)
  instanceName                - имя экземпляра БД, в которой может
                                использоваться значение
                                ( null без ограничений ( по умолчанию))
  raiseNotFoundFlag           - выбрасывать ли исключение в случае отсутствия
                                параметра ( 1 да ( по умолчанию), 0 нет)

  Возврат:
  Id значения ( из таблицы <opt_value>) либо null, если указанное значение
  не задано.

  ( <body::getValueId>)
*/
member function getValueId(
  optionShortName varchar2
  , prodValueFlag integer
  , instanceName varchar2 := null
  , raiseNotFoundFlag integer := null
)
return integer,

/* pfunc: getValueId( USED)
  Возвращает Id используемого в текущей БД значения ( списка значений)
  настроечного параметра.

  Параметры:
  optionShortName             - краткое наименование параметра
  raiseNotFoundFlag           - выбрасывать ли исключение в случае отсутствия
                                параметра ( 1 да ( по умолчанию), 0 нет)

  Возврат:
  Id значения ( из таблицы <opt_value>) либо null, если подходящего для
  использования значения параметра не задано.

  ( <body::getValueId( USED)>)
*/
member function getValueId(
  optionShortName varchar2
  , raiseNotFoundFlag integer := null
)
return integer,

/* pfunc: getValueCount
  Возвращает число указанных значений настроечного параметра.

  Параметры:
  optionShortName             - краткое наименование параметра
  prodValueFlag               - флаг использования значения только в
                                промышленных ( либо тестовых) БД
                                ( 1 только в промышленных БД, 0 только в
                                тестовых БД, null без ограничений)
  instanceName                - имя экземпляра БД, в которой может
                                использоваться значение
                                ( null без ограничений ( по умолчанию))
  raiseNotFoundFlag           - выбрасывать ли исключение в случае отсутствия
                                параметра ( 1 да ( по умолчанию), 0 нет)

  Возврат:
  0 если значение ( в т.ч. null) не задано, иначе положительное число заданных
  значений ( 1 если задано значение для параметра, не использующего список
  значений, либо число значений в списке значений параметра).

  ( <body::getValueCount>)
*/
member function getValueCount(
  optionShortName varchar2
  , prodValueFlag integer
  , instanceName varchar2 := null
  , raiseNotFoundFlag integer := null
)
return integer,

/* pfunc: getValueCount( USED)
  Возвращает число используемых в текущей БД значений настроечного параметра.

  Параметры:
  optionShortName             - краткое наименование параметра
  raiseNotFoundFlag           - выбрасывать ли исключение в случае отсутствия
                                параметра ( 1 да ( по умолчанию), 0 нет)

  Возврат:
  0 если значение ( в т.ч. null) не задано, иначе положительное число заданных
  значений ( 1 если задано значение для параметра, не использующего список
  значений, либо число значений в списке значений параметра).

  ( <body::getValueCount( USED)>)
*/
member function getValueCount(
  optionShortName varchar2
  , raiseNotFoundFlag integer := null
)
return integer,

/* pfunc: getValueListSeparator
  Возвращает символ, используемый в качестве разделителя в указанном списке
  значений настроечного параметра.

  Параметры:
  optionShortName             - краткое наименование параметра
  prodValueFlag               - флаг использования значения только в
                                промышленных ( либо тестовых) БД
                                ( 1 только в промышленных БД, 0 только в
                                тестовых БД, null без ограничений)
  instanceName                - имя экземпляра БД, в которой может
                                использоваться значение
                                ( null без ограничений ( по умолчанию))
  raiseNotFoundFlag           - выбрасывать ли исключение в случае отсутствия
                                параметра ( 1 да ( по умолчанию), 0 нет)

  Возврат:
  символ, используемый в качестве разделителя в списке значений, либо null,
  если для параметра не используется список значений или значение не задано.

  ( <body::getValueListSeparator>)
*/
member function getValueListSeparator(
  optionShortName varchar2
  , prodValueFlag integer
  , instanceName varchar2 := null
  , raiseNotFoundFlag integer := null
)
return varchar2,

/* pfunc: getValueListSeparator( USED)
  Возвращает символ, используемый в качестве разделителя в используемом в
  текущей БД списке значений настроечного параметра.

  Параметры:
  optionShortName             - краткое наименование параметра
  raiseNotFoundFlag           - выбрасывать ли исключение в случае отсутствия
                                параметра ( 1 да ( по умолчанию), 0 нет)

  Возврат:
  символ, используемый в качестве разделителя в списке значений, либо null,
  если для параметра не используется список значений или значение не задано.

  ( <body::getValueListSeparator( USED)>)
*/
member function getValueListSeparator(
  optionShortName varchar2
  , raiseNotFoundFlag integer := null
)
return varchar2,



/* group: Добавление параметра */

/* pproc: addDate
  Добавляет настроечный параметр со значением типа дата, если он не был создан
  ранее.

  Параметры:
  optionShortName             - краткое наименование параметра
  optionName                  - наименование параметра
  accessLevelCode             - код уровня доступа к параметру через
                                пользовательский интерфейс
                                ( по умолчанию полный доступ)
  optionDescription           - описание параметра
                                ( по умолчанию отсутствует)
  instanceName                - имя экземпляра БД, в которой может
                                использоваться значение
                                ( null без ограничений ( по умолчанию))
  dateValue                   - значение параметра типа дата
                                ( по умолчанию null)
  changeValueFlag             - установить значение параметра, если он был
                                создан ранее
                                ( 1 да, 0 нет ( по умолчанию))
  operatorId                  - Id оператора ( по умолчанию текущий)

  ( <body::addDate>)
*/
member procedure addDate(
  self in opt_option_list_t
  , optionShortName varchar2
  , optionName varchar2
  , accessLevelCode varchar2 := null
  , optionDescription varchar2 := null
  , instanceName varchar2 := null
  , dateValue date := null
  , changeValueFlag integer := null
  , operatorId integer := null
),

/* pproc: addDate( TEST_PROD)
  Добавляет настроечный параметр с промышленным и тестовым значениями типа
  дата если он не был создан ранее.

  Параметры:
  optionShortName             - краткое наименование параметра
  optionName                  - наименование параметра
  accessLevelCode             - код уровня доступа к параметру через
                                пользовательский интерфейс
                                ( по умолчанию полный доступ)
  optionDescription           - описание параметра
                                ( по умолчанию отсутствует)
  instanceName                - имя экземпляра БД, в которой может
                                использоваться значение
                                ( null без ограничений ( по умолчанию))
  prodDateValue               - значение параметра типа дата для промышленных
                                БД
  testDateValue               - значение параметра типа дата для тестовых БД
  changeValueFlag             - установить значение параметра, если он был
                                создан ранее
                                ( 1 да, 0 нет ( по умолчанию))
  operatorId                  - Id оператора ( по умолчанию текущий)

  ( <body::addDate( TEST_PROD)>)
*/
member procedure addDate(
  self in opt_option_list_t
  , optionShortName varchar2
  , optionName varchar2
  , accessLevelCode varchar2 := null
  , optionDescription varchar2 := null
  , instanceName varchar2 := null
  , prodDateValue date
  , testDateValue date
  , changeValueFlag integer := null
  , operatorId integer := null
),

/* pproc: addDateList
  Добавляет настроечный параметр со списком значений типа дата если он не был
  создан ранее.

  Параметры:
  optionShortName             - краткое наименование параметра
  optionName                  - наименование параметра
  accessLevelCode             - код уровня доступа к параметру через
                                пользовательский интерфейс
                                ( по умолчанию полный доступ)
  optionDescription           - описание параметра
                                ( по умолчанию отсутствует)
  instanceName                - имя экземпляра БД, в которой может
                                использоваться значение
                                ( null без ограничений ( по умолчанию))
  valueList                   - строка со списком значений параметра
                                ( по умолчанию null)
  listSeparator               - символ, используемый в качестве разделителя в
                                строке со списком значений
                                ( по умолчанию используется ";")
  valueFormat                 - формат элементов в строке со списком значений
                                ( по умолчанию используется
                                "yyyy-mm-dd hh24:mi:ss" с опциональным указанием
                                времени)
  changeValueFlag             - установить значение параметра, если он был
                                создан ранее
                                ( 1 да, 0 нет ( по умолчанию))
  operatorId                  - Id оператора ( по умолчанию текущий)

  Замечания:
  - пустая строка в качестве списка значений рассматривается как список из
    одного значения null;

  ( <body::addDateList>)
*/
member procedure addDateList(
  self in opt_option_list_t
  , optionShortName varchar2
  , optionName varchar2
  , accessLevelCode varchar2 := null
  , optionDescription varchar2 := null
  , instanceName varchar2 := null
  , valueList varchar2 := null
  , listSeparator varchar2 := null
  , valueFormat varchar2 := null
  , changeValueFlag integer := null
  , operatorId integer := null
),

/* pproc: addDateList( TEST_PROD)
  Добавляет настроечный параметр с промышленным и тестовым списками значений
  типа дата если он не был создан ранее.

  Параметры:
  optionShortName             - краткое наименование параметра
  optionName                  - наименование параметра
  accessLevelCode             - код уровня доступа к параметру через
                                пользовательский интерфейс
                                ( по умолчанию полный доступ)
  optionDescription           - описание параметра
                                ( по умолчанию отсутствует)
  instanceName                - имя экземпляра БД, в которой может
                                использоваться значение
                                ( null без ограничений ( по умолчанию))
  prodValueList               - строка со списком значений параметра для
                                промышленных БД
  testValueList               - строка со списком значений параметра для
                                тестовых БД
  listSeparator               - символ, используемый в качестве разделителя в
                                строке со списком значений
                                ( по умолчанию используется ";")
  valueFormat                 - формат элементов в строке со списком значений
                                ( по умолчанию используется
                                "yyyy-mm-dd hh24:mi:ss" с опциональным указанием
                                времени)
  changeValueFlag             - установить значение параметра, если он был
                                создан ранее
                                ( 1 да, 0 нет ( по умолчанию))
  operatorId                  - Id оператора ( по умолчанию текущий)

  Замечания:
  - пустая строка в качестве списка значений рассматривается как список из
    одного значения null;

  ( <body::addDateList( TEST_PROD)>)
*/
member procedure addDateList(
  self in opt_option_list_t
  , optionShortName varchar2
  , optionName varchar2
  , accessLevelCode varchar2 := null
  , optionDescription varchar2 := null
  , instanceName varchar2 := null
  , prodValueList varchar2
  , testValueList varchar2
  , listSeparator varchar2 := null
  , valueFormat varchar2 := null
  , changeValueFlag integer := null
  , operatorId integer := null
),

/* pproc: addNumber
  Добавляет настроечный параметр с числовым значением, если он не был создан
  ранее.

  Параметры:
  optionShortName             - краткое наименование параметра
  optionName                  - наименование параметра
  accessLevelCode             - код уровня доступа к параметру через
                                пользовательский интерфейс
                                ( по умолчанию полный доступ)
  optionDescription           - описание параметра
                                ( по умолчанию отсутствует)
  instanceName                - имя экземпляра БД, в которой может
                                использоваться значение
                                ( null без ограничений ( по умолчанию))
  numberValue                 - числовое значение параметра
                                ( по умолчанию null)
  changeValueFlag             - установить значение параметра, если он был
                                создан ранее
                                ( 1 да, 0 нет ( по умолчанию))
  operatorId                  - Id оператора ( по умолчанию текущий)

  ( <body::addNumber>)
*/
member procedure addNumber(
  self in opt_option_list_t
  , optionShortName varchar2
  , optionName varchar2
  , accessLevelCode varchar2 := null
  , optionDescription varchar2 := null
  , instanceName varchar2 := null
  , numberValue number := null
  , changeValueFlag integer := null
  , operatorId integer := null
),

/* pproc: addNumber( TEST_PROD)
  Добавляет настроечный параметр с промышленным и тестовым числовыми значениями
  если он не был создан ранее.

  Параметры:
  optionShortName             - краткое наименование параметра
  optionName                  - наименование параметра
  accessLevelCode             - код уровня доступа к параметру через
                                пользовательский интерфейс
                                ( по умолчанию полный доступ)
  optionDescription           - описание параметра
                                ( по умолчанию отсутствует)
  instanceName                - имя экземпляра БД, в которой может
                                использоваться значение
                                ( null без ограничений ( по умолчанию))
  prodNumberValue             - числовое значение параметра для промышленных
                                БД
  testNumberValue             - числовое значение параметра для тестовых БД
  changeValueFlag             - установить значение параметра, если он был
                                создан ранее
                                ( 1 да, 0 нет ( по умолчанию))
  operatorId                  - Id оператора ( по умолчанию текущий)

  ( <body::addNumber( TEST_PROD)>)
*/
member procedure addNumber(
  self in opt_option_list_t
  , optionShortName varchar2
  , optionName varchar2
  , accessLevelCode varchar2 := null
  , optionDescription varchar2 := null
  , instanceName varchar2 := null
  , prodNumberValue number
  , testNumberValue number
  , changeValueFlag integer := null
  , operatorId integer := null
),

/* pproc: addNumberList
  Добавляет настроечный параметр со списком числовых значений если он не был
  создан ранее.

  Параметры:
  optionShortName             - краткое наименование параметра
  optionName                  - наименование параметра
  accessLevelCode             - код уровня доступа к параметру через
                                пользовательский интерфейс
                                ( по умолчанию полный доступ)
  optionDescription           - описание параметра
                                ( по умолчанию отсутствует)
  instanceName                - имя экземпляра БД, в которой может
                                использоваться значение
                                ( null без ограничений ( по умолчанию))
  valueList                   - строка со списком значений параметра
                                ( по умолчанию null)
  listSeparator               - символ, используемый в качестве разделителя в
                                строке со списком значений
                                ( по умолчанию используется ";")
  decimalChar                 - десятичный разделитель для строки со списком
                                числовых значений
                                ( по умолчанию используется точка)
  changeValueFlag             - установить значение параметра, если он был
                                создан ранее
                                ( 1 да, 0 нет ( по умолчанию))
  operatorId                  - Id оператора ( по умолчанию текущий)

  Замечания:
  - пустая строка в качестве списка значений рассматривается как список из
    одного значения null;

  ( <body::addNumberList>)
*/
member procedure addNumberList(
  self in opt_option_list_t
  , optionShortName varchar2
  , optionName varchar2
  , accessLevelCode varchar2 := null
  , optionDescription varchar2 := null
  , instanceName varchar2 := null
  , valueList varchar2 := null
  , listSeparator varchar2 := null
  , decimalChar varchar2 := null
  , changeValueFlag integer := null
  , operatorId integer := null
),

/* pproc: addNumberList( TEST_PROD)
  Добавляет настроечный параметр с промышленным и тестовым списками числовых
  значений если он не был создан ранее.

  Параметры:
  optionShortName             - краткое наименование параметра
  optionName                  - наименование параметра
  accessLevelCode             - код уровня доступа к параметру через
                                пользовательский интерфейс
                                ( по умолчанию полный доступ)
  optionDescription           - описание параметра
                                ( по умолчанию отсутствует)
  instanceName                - имя экземпляра БД, в которой может
                                использоваться значение
                                ( null без ограничений ( по умолчанию))
  prodValueList               - строка со списком значений параметра для
                                промышленных БД
  testValueList               - строка со списком значений параметра для
                                тестовых БД
  listSeparator               - символ, используемый в качестве разделителя в
                                строке со списком значений
                                ( по умолчанию используется ";")
  decimalChar                 - десятичный разделитель для строки со списком
                                числовых значений
                                ( по умолчанию используется точка)
  changeValueFlag             - установить значение параметра, если он был
                                создан ранее
                                ( 1 да, 0 нет ( по умолчанию))
  operatorId                  - Id оператора ( по умолчанию текущий)

  Замечания:
  - пустая строка в качестве списка значений рассматривается как список из
    одного значения null;

  ( <body::addNumberList( TEST_PROD)>)
*/
member procedure addNumberList(
  self in opt_option_list_t
  , optionShortName varchar2
  , optionName varchar2
  , accessLevelCode varchar2 := null
  , optionDescription varchar2 := null
  , instanceName varchar2 := null
  , prodValueList varchar2
  , testValueList varchar2
  , listSeparator varchar2 := null
  , decimalChar varchar2 := null
  , changeValueFlag integer := null
  , operatorId integer := null
),

/* pproc: addString
  Добавляет настроечный параметр со строковым значением, если он не был создан
  ранее.

  Параметры:
  optionShortName             - краткое наименование параметра
  optionName                  - наименование параметра
  encryptionFlag              - флаг хранения значений параметра в
                                зашифрованном виде
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
  stringValue                 - строковое значение параметра
                                ( по умолчанию null)
  changeValueFlag             - установить значение параметра, если он был
                                создан ранее
                                ( 1 да, 0 нет ( по умолчанию))
  operatorId                  - Id оператора ( по умолчанию текущий)

  ( <body::addString>)
*/
member procedure addString(
  self in opt_option_list_t
  , optionShortName varchar2
  , optionName varchar2
  , encryptionFlag integer := null
  , accessLevelCode varchar2 := null
  , optionDescription varchar2 := null
  , instanceName varchar2 := null
  , stringValue varchar2 := null
  , changeValueFlag integer := null
  , operatorId integer := null
),

/* pproc: addString( TEST_PROD)
  Добавляет настроечный параметр с промышленным и тестовым строковыми значениями
  если он не был создан ранее.

  Параметры:
  optionShortName             - краткое наименование параметра
  optionName                  - наименование параметра
  encryptionFlag              - флаг хранения значений параметра в
                                зашифрованном виде
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
  prodStringValue             - строковое значение параметра для промышленных
                                БД
  testStringValue             - строковое значение параметра для тестовых БД
  changeValueFlag             - установить значение параметра, если он был
                                создан ранее
                                ( 1 да, 0 нет ( по умолчанию))
  operatorId                  - Id оператора ( по умолчанию текущий)

  ( <body::addString( TEST_PROD)>)
*/
member procedure addString(
  self in opt_option_list_t
  , optionShortName varchar2
  , optionName varchar2
  , encryptionFlag integer := null
  , accessLevelCode varchar2 := null
  , optionDescription varchar2 := null
  , instanceName varchar2 := null
  , prodStringValue varchar2
  , testStringValue varchar2
  , changeValueFlag integer := null
  , operatorId integer := null
),

/* pproc: addStringList
  Добавляет настроечный параметр со списком строковых значений если он не был
  создан ранее.

  Параметры:
  optionShortName             - краткое наименование параметра
  optionName                  - наименование параметра
  encryptionFlag              - флаг хранения значений параметра в
                                зашифрованном виде
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
  valueList                   - строка со списком значений параметра
                                ( по умолчанию null)
  listSeparator               - символ, используемый в качестве разделителя в
                                строке со списком значений
                                ( по умолчанию используется ";")
  changeValueFlag             - установить значение параметра, если он был
                                создан ранее
                                ( 1 да, 0 нет ( по умолчанию))
  operatorId                  - Id оператора ( по умолчанию текущий)

  Замечания:
  - пустая строка в качестве списка значений рассматривается как список из
    одного значения null;

  ( <body::addStringList>)
*/
member procedure addStringList(
  self in opt_option_list_t
  , optionShortName varchar2
  , optionName varchar2
  , encryptionFlag integer := null
  , accessLevelCode varchar2 := null
  , optionDescription varchar2 := null
  , instanceName varchar2 := null
  , valueList varchar2 := null
  , listSeparator varchar2 := null
  , changeValueFlag integer := null
  , operatorId integer := null
),

/* pproc: addStringList( TEST_PROD)
  Добавляет настроечный параметр с промышленным и тестовым списками строковых
  значений если он не был создан ранее.

  Параметры:
  optionShortName             - краткое наименование параметра
  optionName                  - наименование параметра
  encryptionFlag              - флаг хранения значений параметра в
                                зашифрованном виде
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
  prodValueList               - строка со списком значений параметра для
                                промышленных БД
  testValueList               - строка со списком значений параметра для
                                тестовых БД
  listSeparator               - символ, используемый в качестве разделителя в
                                строке со списком значений
                                ( по умолчанию используется ";")
  changeValueFlag             - установить значение параметра, если он был
                                создан ранее
                                ( 1 да, 0 нет ( по умолчанию))
  operatorId                  - Id оператора ( по умолчанию текущий)

  Замечания:
  - пустая строка в качестве списка значений рассматривается как список из
    одного значения null;

  ( <body::addStringList( TEST_PROD)>)
*/
member procedure addStringList(
  self in opt_option_list_t
  , optionShortName varchar2
  , optionName varchar2
  , encryptionFlag integer := null
  , accessLevelCode varchar2 := null
  , optionDescription varchar2 := null
  , instanceName varchar2 := null
  , prodValueList varchar2
  , testValueList varchar2
  , listSeparator varchar2 := null
  , changeValueFlag integer := null
  , operatorId integer := null
),



/* group: Получение значения параметра */

/* pfunc: getDate
  Возвращает указанное значение настроечного параметра типа дата.

  Параметры:
  optionShortName             - краткое наименование параметра
  prodValueFlag               - флаг использования значения только в
                                промышленных ( либо тестовых) БД
                                ( 1 только в промышленных БД, 0 только в
                                тестовых БД, null без ограничений)
  instanceName                - имя экземпляра БД, в которой может
                                использоваться значение
                                ( null без ограничений ( по умолчанию))
  valueIndex                  - индекс значения в списке значений
                                ( начиная с 1, 1 можно также указывать при
                                получении значения параметра, не использующего
                                список значений, по умолчанию 1)
  raiseNotFoundFlag           - выбрасывать ли исключение в случае отсутствия
                                параметра ( 1 да ( по умолчанию), 0 нет)

  Возврат:
  значение типа дата.

  Замечения:
  - в случае, если значение настроечного параметра не задано ( в т.ч. в
    случае, если индекс значения в valueIndex превышает число значений в
    списке либо больше 1 если список не используется) возвращается null;

  ( <body::getDate>)
*/
member function getDate(
  optionShortName varchar2
  , prodValueFlag integer
  , instanceName varchar2 := null
  , valueIndex integer := null
  , raiseNotFoundFlag integer := null
)
return date,

/* pfunc: getDate( USED)
  Возвращает используемое в текущей БД значение настроечного параметра типа
  дата.

  Параметры:
  optionShortName             - краткое наименование параметра
  valueIndex                  - индекс значения в списке значений
                                ( начиная с 1, 1 можно также указывать при
                                получении значения параметра, не использующего
                                список значений, по умолчанию 1)
  raiseNotFoundFlag           - выбрасывать ли исключение в случае отсутствия
                                параметра ( 1 да ( по умолчанию), 0 нет)

  Возврат:
  значение типа дата.

  Замечения:
  - в случае, если значение настроечного параметра не задано ( в т.ч. в
    случае, если индекс значения в valueIndex превышает число значений в
    списке либо больше 1 если список не используется) возвращается null;

  ( <body::getDate( USED)>)
*/
member function getDate(
  optionShortName varchar2
  , valueIndex integer := null
  , raiseNotFoundFlag integer := null
)
return date,

/* pfunc: getNumber
  Возвращает указанное числовое значение настроечного параметра.

  Параметры:
  optionShortName             - краткое наименование параметра
  prodValueFlag               - флаг использования значения только в
                                промышленных ( либо тестовых) БД
                                ( 1 только в промышленных БД, 0 только в
                                тестовых БД, null без ограничений)
  instanceName                - имя экземпляра БД, в которой может
                                использоваться значение
                                ( null без ограничений ( по умолчанию))
  valueIndex                  - индекс значения в списке значений
                                ( начиная с 1, 1 можно также указывать при
                                получении значения параметра, не использующего
                                список значений, по умолчанию 1)
  raiseNotFoundFlag           - выбрасывать ли исключение в случае отсутствия
                                параметра ( 1 да ( по умолчанию), 0 нет)

  Возврат:
  числовое значение.

  Замечения:
  - в случае, если значение настроечного параметра не задано ( в т.ч. в
    случае, если индекс значения в valueIndex превышает число значений в
    списке либо больше 1 если список не используется) возвращается null;

  ( <body::getNumber>)
*/
member function getNumber(
  optionShortName varchar2
  , prodValueFlag integer
  , instanceName varchar2 := null
  , valueIndex integer := null
  , raiseNotFoundFlag integer := null
)
return number,

/* pfunc: getNumber( USED)
  Возвращает используемое в текущей БД числовое значение настроечного параметра.

  Параметры:
  optionShortName             - краткое наименование параметра
  valueIndex                  - индекс значения в списке значений
                                ( начиная с 1, 1 можно также указывать при
                                получении значения параметра, не использующего
                                список значений, по умолчанию 1)
  raiseNotFoundFlag           - выбрасывать ли исключение в случае отсутствия
                                параметра ( 1 да ( по умолчанию), 0 нет)

  Возврат:
  числовое значение.

  Замечения:
  - в случае, если значение настроечного параметра не задано ( в т.ч. в
    случае, если индекс значения в valueIndex превышает число значений в
    списке либо больше 1 если список не используется) возвращается null;

  ( <body::getNumber( USED)>)
*/
member function getNumber(
  optionShortName varchar2
  , valueIndex integer := null
  , raiseNotFoundFlag integer := null
)
return number,

/* pfunc: getString
  Возвращает указанное строковое значение настроечного параметра.

  Параметры:
  optionShortName             - краткое наименование параметра
  prodValueFlag               - флаг использования значения только в
                                промышленных ( либо тестовых) БД
                                ( 1 только в промышленных БД, 0 только в
                                тестовых БД, null без ограничений)
  instanceName                - имя экземпляра БД, в которой может
                                использоваться значение
                                ( null без ограничений ( по умолчанию))
  valueIndex                  - индекс значения в списке значений
                                ( начиная с 1, 1 можно также указывать при
                                получении значения параметра, не использующего
                                список значений, по умолчанию 1)
  raiseNotFoundFlag           - выбрасывать ли исключение в случае отсутствия
                                параметра ( 1 да ( по умолчанию), 0 нет)

  Возврат:
  строковое значение.

  Замечения:
  - в случае, если значение настроечного параметра не задано ( в т.ч. в
    случае, если индекс значения в valueIndex превышает число значений в
    списке либо больше 1 если список не используется) возвращается null;

  ( <body::getString>)
*/
member function getString(
  optionShortName varchar2
  , prodValueFlag integer
  , instanceName varchar2 := null
  , valueIndex integer := null
  , raiseNotFoundFlag integer := null
)
return varchar2,

/* pfunc: getString( USED)
  Возвращает используемое в текущей БД строковое значение настроечного
  параметра.

  Параметры:
  optionShortName             - краткое наименование параметра
  valueIndex                  - индекс значения в списке значений
                                ( начиная с 1, 1 можно также указывать при
                                получении значения параметра, не использующего
                                список значений, по умолчанию 1)
  raiseNotFoundFlag           - выбрасывать ли исключение в случае отсутствия
                                параметра ( 1 да ( по умолчанию), 0 нет)

  Возврат:
  строковое значение.

  Замечения:
  - в случае, если значение настроечного параметра не задано ( в т.ч. в
    случае, если индекс значения в valueIndex превышает число значений в
    списке либо больше 1 если список не используется) возвращается null;

  ( <body::getString( USED)>)
*/
member function getString(
  optionShortName varchar2
  , valueIndex integer := null
  , raiseNotFoundFlag integer := null
)
return varchar2,

/* pfunc: getValueList
  Возвращает указанный список значений настроечного параметра.

  Параметры:
  optionShortName             - краткое наименование параметра
  prodValueFlag               - флаг использования значения только в
                                промышленных ( либо тестовых) БД
                                ( 1 только в промышленных БД, 0 только в
                                тестовых БД, null без ограничений)
  instanceName                - имя экземпляра БД, в которой может
                                использоваться значение
                                ( null без ограничений ( по умолчанию))
  raiseNotFoundFlag           - выбрасывать ли исключение в случае отсутствия
                                параметра ( 1 да ( по умолчанию), 0 нет)

  Возврат:
  строка со списком значений ( символ, используемый в качестве разделителя,
  возвращается функцией <getValueListSeparator>).

  Замечения:
  - в случае, если указанное значение настроечного параметра не задано,
    возвращается null;

  ( <body::getValueList>)
*/
member function getValueList(
  optionShortName varchar2
  , prodValueFlag integer
  , instanceName varchar2 := null
  , raiseNotFoundFlag integer := null
)
return varchar2,

/* pfunc: getValueList( USED)
  Возвращает используемый в текущей БД список значений настроечного параметра.

  Параметры:
  optionShortName             - краткое наименование параметра
  raiseNotFoundFlag           - выбрасывать ли исключение в случае отсутствия
                                параметра ( 1 да ( по умолчанию), 0 нет)

  Возврат:
  строка со списком значений ( символ, используемый в качестве разделителя,
  возвращается функцией <getValueListSeparator( USED)>).

  Замечения:
  - в случае, если указанное значение настроечного параметра не задано,
    возвращается null;

  ( <body::getValueList( USED)>)
*/
member function getValueList(
  optionShortName varchar2
  , raiseNotFoundFlag integer := null
)
return varchar2,



/* group: Установка значения параметра */

/* pproc: setDate
  Устанавливает указанное значение настроечного параметра типа дата.

  Параметры:
  optionShortName             - краткое наименование параметра
  prodValueFlag               - флаг использования значения только в
                                промышленных ( либо тестовых) БД
                                ( 1 только в промышленных БД, 0 только в
                                тестовых БД, null без ограничений)
  instanceName                - имя экземпляра БД, в которой может
                                использоваться значение
                                ( null без ограничений ( по умолчанию))
  dateValue                   - значение параметра типа дата
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
  operatorId                  - Id оператора ( по умолчанию текущий)

  ( <body::setDate>)
*/
member procedure setDate(
  self in opt_option_list_t
  , optionShortName varchar2
  , prodValueFlag integer
  , instanceName varchar2 := null
  , dateValue date
  , valueIndex integer := null
  , operatorId integer := null
),

/* pproc: setDate( TEST_PROD)
  Устанавливает промышленное и тестовое значение настроечного параметра типа
  дата.

  Параметры:
  optionShortName             - краткое наименование параметра
  prodDateValue               - значение параметра типа дата для промышленных
                                БД
  testDateValue               - значение параметра типа дата для тестовых БД
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
  instanceName                - имя экземпляра БД, в которой может
                                использоваться значение
                                ( null без ограничений ( по умолчанию))
  operatorId                  - Id оператора ( по умолчанию текущий)

  ( <body::setDate( TEST_PROD)>)
*/
member procedure setDate(
  self in opt_option_list_t
  , optionShortName varchar2
  , prodDateValue date
  , testDateValue date
  , valueIndex integer := null
  , instanceName varchar2 := null
  , operatorId integer := null
),

/* pproc: setDate( USED)
  Устанавливает используемое в текущей БД значение настроечного параметра типа
  дата.

  Параметры:
  optionShortName             - краткое наименование параметра
  dateValue                   - значение параметра типа дата
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
  createForInstanceFlag       - при отсутствии используемого значения задавать
                                его для использования только в текущем
                                экземпляре БД
                                ( 1 да, 0 нет ( по умолчанию))
  operatorId                  - Id оператора ( по умолчанию текущий)

  ( <body::setDate( USED)>)
*/
member procedure setDate(
  self in opt_option_list_t
  , optionShortName varchar2
  , dateValue date
  , valueIndex integer := null
  , createForInstanceFlag integer := null
  , operatorId integer := null
),

/* pproc: setNumber
  Устанавливает указанное числовое значение настроечного параметра.

  Параметры:
  optionShortName             - краткое наименование параметра
  prodValueFlag               - флаг использования значения только в
                                промышленных ( либо тестовых) БД
                                ( 1 только в промышленных БД, 0 только в
                                тестовых БД, null без ограничений)
  instanceName                - имя экземпляра БД, в которой может
                                использоваться значение
                                ( null без ограничений ( по умолчанию))
  numberValue                 - числовое значение параметра
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
  operatorId                  - Id оператора ( по умолчанию текущий)

  ( <body::setNumber>)
*/
member procedure setNumber(
  self in opt_option_list_t
  , optionShortName varchar2
  , prodValueFlag integer
  , instanceName varchar2 := null
  , numberValue number
  , valueIndex integer := null
  , operatorId integer := null
),

/* pproc: setNumber( TEST_PROD)
  Устанавливает промышленное и тестовое числовые значения настроечного
  параметра.

  Параметры:
  optionShortName             - краткое наименование параметра
  prodNumberValue             - числовое значение параметра для промышленных
                                БД
  testNumberValue             - числовое значение параметра для тестовых БД
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
  instanceName                - имя экземпляра БД, в которой может
                                использоваться значение
                                ( null без ограничений ( по умолчанию))
  operatorId                  - Id оператора ( по умолчанию текущий)

  ( <body::setNumber( TEST_PROD)>)
*/
member procedure setNumber(
  self in opt_option_list_t
  , optionShortName varchar2
  , prodNumberValue number
  , testNumberValue number
  , valueIndex integer := null
  , instanceName varchar2 := null
  , operatorId integer := null
),

/* pproc: setNumber( USED)
  Устанавливает используемое в текущей БД числовое значение настроечного
  параметра.

  Параметры:
  optionShortName             - краткое наименование параметра
  numberValue                 - числовое значение параметра
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
  createForInstanceFlag       - при отсутствии используемого значения задавать
                                его для использования только в текущем
                                экземпляре БД
                                ( 1 да, 0 нет ( по умолчанию))
  operatorId                  - Id оператора ( по умолчанию текущий)

  ( <body::setNumber( USED)>)
*/
member procedure setNumber(
  self in opt_option_list_t
  , optionShortName varchar2
  , numberValue number
  , valueIndex integer := null
  , createForInstanceFlag integer := null
  , operatorId integer := null
),

/* pproc: setString
  Устанавливает указанное строковое значение настроечного параметра.

  Параметры:
  optionShortName             - краткое наименование параметра
  prodValueFlag               - флаг использования значения только в
                                промышленных ( либо тестовых) БД
                                ( 1 только в промышленных БД, 0 только в
                                тестовых БД, null без ограничений)
  instanceName                - имя экземпляра БД, в которой может
                                использоваться значение
                                ( null без ограничений ( по умолчанию))
  stringValue                 - строковое значение параметра
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
  operatorId                  - Id оператора ( по умолчанию текущий)

  ( <body::setString>)
*/
member procedure setString(
  self in opt_option_list_t
  , optionShortName varchar2
  , prodValueFlag integer
  , instanceName varchar2 := null
  , stringValue varchar2
  , valueIndex integer := null
  , operatorId integer := null
),

/* pproc: setString( TEST_PROD)
  Устанавливает промышленное и тестовое строковые значения настроечного
  параметра.

  Параметры:
  optionShortName             - краткое наименование параметра
  prodStringValue             - строковое значение параметра для промышленных
                                БД
  testStringValue             - строковое значение параметра для тестовых БД
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
  instanceName                - имя экземпляра БД, в которой может
                                использоваться значение
                                ( null без ограничений ( по умолчанию))
  operatorId                  - Id оператора ( по умолчанию текущий)

  ( <body::setString( TEST_PROD)>)
*/
member procedure setString(
  self in opt_option_list_t
  , optionShortName varchar2
  , prodStringValue varchar2
  , testStringValue varchar2
  , valueIndex integer := null
  , instanceName varchar2 := null
  , operatorId integer := null
),

/* pproc: setString( USED)
  Устанавливает используемое в текущей БД строковое значение настроечного
  параметра.

  Параметры:
  optionShortName             - краткое наименование параметра
  stringValue                 - строковое значение параметра
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
  createForInstanceFlag       - при отсутствии используемого значения задавать
                                его для использования только в текущем
                                экземпляре БД
                                ( 1 да, 0 нет ( по умолчанию))
  operatorId                  - Id оператора ( по умолчанию текущий)

  ( <body::setString( USED)>)
*/
member procedure setString(
  self in opt_option_list_t
  , optionShortName varchar2
  , stringValue varchar2
  , valueIndex integer := null
  , createForInstanceFlag integer := null
  , operatorId integer := null
),

/* pproc: setValueList
  Устанавливает указанный список значений настроечного параметра.

  Параметры:
  optionShortName             - краткое наименование параметра
  prodValueFlag               - флаг использования значения только в
                                промышленных ( либо тестовых) БД
                                ( 1 только в промышленных БД, 0 только в
                                тестовых БД, null без ограничений)
  instanceName                - имя экземпляра БД, в которой может
                                использоваться значение
                                ( null без ограничений ( по умолчанию))
  valueList                   - строка со списком значений параметра
                                ( по умолчанию null)
  listSeparator               - символ, используемый в качестве разделителя в
                                строке со списком значений
                                ( по умолчанию используется ";")
  valueFormat                 - формат элементов в строке со списком значений
                                типа дата ( по умолчанию для дат используется
                                "yyyy-mm-dd hh24:mi:ss" с опциональным
                                указанием времени)
  decimalChar                 - десятичный разделитель для строки со списком
                                числовых значений
                                ( по умолчанию используется точка)
  operatorId                  - Id оператора ( по умолчанию текущий)

  Замечания:
  - пустая строка в качестве списка значений рассматривается как список из
    одного значения null;

  ( <body::setValueList>)
*/
member procedure setValueList(
  self in opt_option_list_t
  , optionShortName varchar2
  , prodValueFlag integer
  , instanceName varchar2 := null
  , valueList varchar2 := null
  , listSeparator varchar2 := null
  , valueFormat varchar2 := null
  , decimalChar varchar2 := null
  , operatorId integer := null
),

/* pproc: setValueList( TEST_PROD)
  Устанавливает промышленный и тестовый список значений настроечного параметра.

  Параметры:
  optionShortName             - краткое наименование параметра
  prodValueList               - строка со списком значений параметра для
                                промышленных БД
  testValueList               - строка со списком значений параметра для
                                тестовых БД
  instanceName                - имя экземпляра БД, в которой может
                                использоваться значение
                                ( null без ограничений ( по умолчанию))
  listSeparator               - символ, используемый в качестве разделителя в
                                строке со списком значений
                                ( по умолчанию используется ";")
  valueFormat                 - формат элементов в строке со списком значений
                                типа дата ( по умолчанию для дат используется
                                "yyyy-mm-dd hh24:mi:ss" с опциональным
                                указанием времени)
  decimalChar                 - десятичный разделитель для строки со списком
                                числовых значений
                                ( по умолчанию используется точка)
  operatorId                  - Id оператора ( по умолчанию текущий)

  Замечания:
  - пустая строка в качестве списка значений рассматривается как список из
    одного значения null;

  ( <body::setValueList( TEST_PROD)>)
*/
member procedure setValueList(
  self in opt_option_list_t
  , optionShortName varchar2
  , prodValueList varchar2
  , testValueList varchar2
  , instanceName varchar2 := null
  , listSeparator varchar2 := null
  , valueFormat varchar2 := null
  , decimalChar varchar2 := null
  , operatorId integer := null
),

/* pproc: setValueList( USED)
  Устанавливает используемый в текущей БД список значений настроечного
  параметра.

  Параметры:
  optionShortName             - краткое наименование параметра
  valueList                   - строка со списком значений параметра
                                ( по умолчанию null)
  listSeparator               - символ, используемый в качестве разделителя в
                                строке со списком значений
                                ( по умолчанию используется ";")
  valueFormat                 - формат элементов в строке со списком значений
                                типа дата ( по умолчанию для дат используется
                                "yyyy-mm-dd hh24:mi:ss" с опциональным
                                указанием времени)
  decimalChar                 - десятичный разделитель для строки со списком
                                числовых значений
                                ( по умолчанию используется точка)
  createForInstanceFlag       - при отсутствии используемого значения задавать
                                его для использования только в текущем
                                экземпляре БД
                                ( 1 да, 0 нет ( по умолчанию))
  operatorId                  - Id оператора ( по умолчанию текущий)

  Замечания:
  - пустая строка в качестве списка значений рассматривается как список из
    одного значения null;

  ( <body::setValueList( USED)>)
*/
member procedure setValueList(
  self in opt_option_list_t
  , optionShortName varchar2
  , valueList varchar2 := null
  , listSeparator varchar2 := null
  , valueFormat varchar2 := null
  , decimalChar varchar2 := null
  , createForInstanceFlag integer := null
  , operatorId integer := null
),



/* group: Дополнительные функции */

/* pproc: createOption
  Создает настроечный параметр без задания значений.

  Параметры:
  optionShortName             - краткое наименование параметра
  valueTypeCode               - код типа значения параметра
  optionName                  - наименование параметра
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
  operatorId                  - Id оператора ( по умолчанию текущий)

  ( <body::createOption>)
*/
member procedure createOption(
  self in opt_option_list_t
  , optionShortName varchar2
  , valueTypeCode varchar2
  , optionName varchar2
  , valueListFlag integer := null
  , encryptionFlag integer := null
  , testProdSensitiveFlag integer := null
  , accessLevelCode varchar2 := null
  , optionDescription varchar2 := null
  , operatorId integer := null
),

/* pproc: moveAll
  Переносит все настроечные параметры из текущего в указанный набор параметров,
  корректируя модуль, краткое наименование и тип объекта, к которому относятся
  параметры.

  Параметры:
  optionList                  - набор, в который переносятся параметры
  operatorId                  - Id оператора ( по умолчанию текущий)

  ( <body::moveAll>)
*/
member procedure moveAll(
  self in opt_option_list_t
  , optionList opt_option_list_t
  , operatorId integer := null
),

/* pproc: moveOption
  Переносит настроечный параметр из текущего в указанный набор параметров,
  корректируя модуль, краткое наименование и тип объекта, к которому относится
  параметр.

  Параметры:
  optionShortName             - краткое наименование параметра
  optionList                  - набор, в который переносится параметр
  operatorId                  - Id оператора ( по умолчанию текущий)

  ( <body::moveOption>)
*/
member procedure moveOption(
  self in opt_option_list_t
  , optionShortName varchar2
  , optionList opt_option_list_t
  , operatorId integer := null
),

/* pfunc: updateOption
  Изменяет настроечный параметр.

  Параметры:
  optionShortName             - краткое наименование параметра
  newOptionShortName          - новое краткое наименование параметра
                                ( null не изменять ( по умолчанию))
  valueTypeCode               - код типа значения параметра
                                ( null не изменять ( по умолчанию))
  valueListFlag               - флаг задания для параметра списка значений
                                указанного типа ( 1 да, 0 нет,
                                null не изменять ( по умолчанию))
  encryptionFlag              - флаг хранения значений параметра в
                                зашифрованном виде
                                ( 1 да, 0 нет, null не изменять ( по умолчанию))
  testProdSensitiveFlag       - флаг указания для значения параметра типа базы
                                данных ( тестовая или промышленная), для
                                которого оно предназначено
                                ( 1 да, 0 нет, null не изменять ( по умолчанию))
  accessLevelCode             - код уровня доступа к параметру через
                                пользовательский интерфейс
                                ( null не изменять)
                                ( по умолчанию только изменение значения в
                                  случае encryptionFlag = 1, полный доступ
                                  в случае encryptionFlag = 0, иначе не
                                  изменять)
  optionName                  - наименование параметра
                                ( null не изменять ( по умолчанию))
  optionDescription           - описание параметра
                                ( null не изменять ( по умолчанию))
  forceOptionDescriptionFlag  - обновить описание параметра согласно значению
                                optionDescription даже если оно null
                                ( 1 да, 0 нет ( по умолчанию))
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
  skipIfNoChangeFlag          - не выполнять изменение, если нет фактических
                                изменений в данных параметра
                                ( 1 да, 0 нет ( по умолчанию))
  operatorId                  - Id оператора ( по умолчанию текущий)

  Возврат:
  1 в случае изменения параметра, иначе 0.

  Замечания:
  - использование deleteBadValueFlag совместно с moveProdSensitiveValueFlag
    обеспечивает удаление тестовых значений в случае установки
    для параметра значения testProdSensitiveFlag равным в 0
    ( в противном случае при наличии тестовых значений было бы выброшено
      исключение);

  ( <body::updateOption>)
*/
member function updateOption(
  optionShortName varchar2
  , newOptionShortName varchar2 := null
  , valueTypeCode varchar2 := null
  , valueListFlag integer := null
  , encryptionFlag integer := null
  , testProdSensitiveFlag integer := null
  , accessLevelCode varchar2 := null
  , optionName varchar2 := null
  , optionDescription varchar2 := null
  , forceOptionDescriptionFlag integer := null
  , moveProdSensitiveValueFlag integer := null
  , deleteBadValueFlag integer := null
  , skipIfNoChangeFlag integer := null
  , operatorId integer := null
)
return integer,

/* pproc: updateOption( PROC)
  Изменяет настроечный параметр.
  Процедура идентична функции <updateOption> за исключением отсутствия
  возвращаемого значения.

  ( <body::updateOption( PROC)>)
*/
member procedure updateOption(
  self in opt_option_list_t
  , optionShortName varchar2
  , newOptionShortName varchar2 := null
  , valueTypeCode varchar2 := null
  , valueListFlag integer := null
  , encryptionFlag integer := null
  , testProdSensitiveFlag integer := null
  , accessLevelCode varchar2 := null
  , optionName varchar2 := null
  , optionDescription varchar2 := null
  , forceOptionDescriptionFlag integer := null
  , moveProdSensitiveValueFlag integer := null
  , deleteBadValueFlag integer := null
  , skipIfNoChangeFlag integer := null
  , operatorId integer := null
),

/* pfunc: setValue
  Устанавливает значение настроечного параметра.

  Параметры:
  optionShortName             - краткое наименование параметра
  prodValueFlag               - флаг использования значения только в
                                промышленных ( либо тестовых) БД
                                ( 1 только в промышленных БД, 0 только в
                                тестовых БД, null без ограничений)
  instanceName                - имя экземпляра БД, в которой может
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
  setValueListFlag            - установить значение согласно строке со списком
                                значений, переданной в параметре stringValue
                                ( 1 да, 0 нет ( по умолчанию))
  listSeparator               - символ, используемый в качестве разделителя в
                                строке со списком значений
                                ( по умолчанию используется ";")
  valueFormat                 - формат элементов в строке со списком значений
                                типа дата ( по умолчанию для дат используется
                                "yyyy-mm-dd hh24:mi:ss" с опциональным
                                указанием времени)
  decimalChar                 - десятичный разделитель для строки со списком
                                числовых значений
                                ( по умолчанию используется точка)
  skipIfNoChangeFlag          - не выполнять изменение, если нет фактических
                                изменений в данных значения
                                ( 1 да, 0 нет ( по умолчанию))
  operatorId                  - Id оператора ( по умолчанию текущий)

  Возврат:
  1 в случае изменения значения, иначе 0.

  ( <body::setValue>)
*/
member function setValue(
  optionShortName varchar2
  , prodValueFlag integer
  , instanceName varchar2 := null
  , valueTypeCode varchar2 := null
  , dateValue date := null
  , numberValue number := null
  , stringValue varchar2 := null
  , setValueListFlag integer := null
  , listSeparator varchar2 := null
  , valueFormat varchar2 := null
  , decimalChar varchar2 := null
  , skipIfNoChangeFlag integer := null
  , operatorId integer := null
)
return integer,

/* pproc: setValue( PROC)
  Устанавливает значение настроечного параметра.
  Процедура идентична функции <setValue> за исключением отсутствия
  возвращаемого значения.

  ( <body::setValue( PROC)>)
*/
member procedure setValue(
  self in opt_option_list_t
  , optionShortName varchar2
  , prodValueFlag integer
  , instanceName varchar2 := null
  , valueTypeCode varchar2 := null
  , dateValue date := null
  , numberValue number := null
  , stringValue varchar2 := null
  , setValueListFlag integer := null
  , listSeparator varchar2 := null
  , valueFormat varchar2 := null
  , decimalChar varchar2 := null
  , skipIfNoChangeFlag integer := null
  , operatorId integer := null
),

/* pproc: deleteAll
  Удаляет все настроечные параметры, относящиеся к набору параметров.

  Параметры:
  operatorId                  - Id оператора ( по умолчанию текущий)

  ( <body::deleteAll>)
*/
member procedure deleteAll(
  self in opt_option_list_t
  , operatorId integer := null
),

/* pproc: deleteOption
  Удаляет настроечный параметр.

  Параметры:
  optionShortName             - краткое наименование параметра
  operatorId                  - Id оператора ( по умолчанию текущий)

  Замечания:
  - при удалении параметра автоматически удаляются относящиеся к нему значения;

  ( <body::deleteOption>)
*/
member procedure deleteOption(
  self in opt_option_list_t
  , optionShortName varchar2
  , operatorId integer := null
),

/* pproc: deleteValue
  Удаляет указанное значение настроечного параметра.

  Параметры:
  optionShortName             - краткое наименование параметра
  prodValueFlag               - флаг использования значения только в
                                промышленных ( либо тестовых) БД
                                ( 1 только в промышленных БД, 0 только в
                                тестовых БД, null без ограничений)
  instanceName                - имя экземпляра БД, в которой может
                                использоваться значение
                                ( null без ограничений ( по умолчанию))
  operatorId                  - Id оператора ( по умолчанию текущий)

  ( <body::deleteValue>)
*/
member procedure deleteValue(
  self in opt_option_list_t
  , optionShortName varchar2
  , prodValueFlag integer
  , instanceName varchar2 := null
  , operatorId integer := null
),

/* pproc: deleteValue( USED)
  Удаляет используемое в текущей БД значение настроечного параметра.

  Параметры:
  optionShortName             - краткое наименование параметра
  operatorId                  - Id оператора ( по умолчанию текущий)

  ( <body::deleteValue( USED)>)
*/
member procedure deleteValue(
  self in opt_option_list_t
  , optionShortName varchar2
  , operatorId integer := null
),



/* group: Функции для использования в SQL */

/* pfunc: getOptionValue
  Возвращает таблицу параметров с текущими используемыми значениями.

  Возврат:
  таблица с набором полей, который отличается от полей представления
  <v_opt_option_value> добавлением поля encrypted_string_value ( при этом
  значение в поле string_value всегда указывается в незашифрованном виде)
  ( поля перечислены в типе <opt_option_value_t>).

  Пример использования:

(code)

SQL> select * from table( opt_option_list_t( 'Option').getOptionValue());

(end)

  ( выборка параметров модуля Option)

  ( <body::getOptionValue>)
*/
member function getOptionValue
return opt_option_value_table_t
pipelined,

/* pfunc: getValue
  Возвращает таблицу с заданными значениями параметра.

  Параметры:
  optionShortName             - краткое наименование параметра

  Возврат:
  таблица с набором полей, который отличается от полей представления
  <v_opt_value> добавлением поля encrypted_string_value ( при этом значение
  в поле string_value всегда указывается в незашифрованном виде) ( поля
  перечислены в типе <opt_value_t>).

  Пример использования:

(code)

SQL> select * from table( opt_option_list_t( 'Option').getValue('Test1'));

(end)

  ( выборка значений параметра Test1 модуля Option)

  ( <body::getValue>)
*/
member function getValue(
  optionShortName varchar2
)
return opt_value_table_t
pipelined,



/* group: Типы объектов */

/* pfunc: mergeObjectType
  Создает или обновляет тип объекта.

  Параметры:
  objectTypeShortName         - краткое наименование типа объекта
  objectTypeName              - наименование типа объекта
  operatorId                  - Id оператора ( по умолчанию текущий)

  Возврат:
  - флаг внесения изменений ( 0 нет изменений, 1 если изменения внесены)

  Замечания:
  - считается, что тип объекта относится к модулю, для которого был создан
    текущий экземпляр объекта opt_option_list_t;

  ( <body::mergeObjectType>)
*/
member function mergeObjectType(
  objectTypeShortName varchar2
  , objectTypeName varchar2
  , operatorId integer := null
)
return integer,

/* pproc: deleteObjectType
  Удаляет тип объекта.

  Параметры:
  objectTypeShortName         - краткое наименование типа объекта
  operatorId                  - Id оператора, выполняющего операцию ( по
                                умолчанию текущий)

  Замечания:
  - считается, что тип объекта относится к модулю, для которого был создан
    текущий экземпляр объекта opt_option_list_t;
  - в случае использования типа в актуальных данных выбрасывается исключение;
  - при отсутствии использования запись удаляется физически, иначе ставится
    флаг логического удаления;

  ( <body::deleteObjectType>)
*/
member procedure deleteObjectType(
  self in opt_option_list_t
  , objectTypeShortName varchar2
  , operatorId integer := null
)

)
not final
/
