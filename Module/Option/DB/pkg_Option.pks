create or replace package pkg_Option is
/* package: pkg_Option
  Функции по работе с настроечными параметрами для использования из
  web-интерфейса.

  SVN root: Oracle/Module/Option
*/



/* group: Константы */

/* const: Module_Name
  Название модуля, к которому относится пакет.
*/
Module_Name constant varchar2(30) := pkg_OptionMain.Module_Name;



/* group: Устаревшие константы */

/* const: StorageRuleInteger
  Правило хранения числовых значений.
*/
StorageRuleInteger constant integer := 1;

/* const: StorageRuleString
  Правило хранения строковых значений.
*/
StorageRuleString constant integer := 2;

/* const: StorageRuleDate
  Правило хранения значений типа Дата.
*/
StorageRuleDate constant integer := 3;

/* const: Test_Option_Postfix
  Постфикс имени опции, содержащей значение для работы в тестовой БД.
*/
Test_Option_Postfix constant varchar2(30) := 'Test';

/* const: Role_Global_Option_Admin
  Id роли администратора глобальных параметров.
*/
Role_Global_Option_Admin constant integer := 2;



/* group: Функции */



/* group: Настроечные параметры */

/* pfunc: createOption
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

  ( <body::createOption>)
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
return integer;

/* pproc: updateOption
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

  ( <body::updateOption>)
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
);

/* pproc: setOptionValue
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

  ( <body::setOptionValue>)
*/
procedure setOptionValue(
  optionId integer
  , dateValue date := null
  , numberValue number := null
  , stringValue varchar2 := null
  , valueIndex integer := null
  , checkRoleFlag integer := null
  , operatorId integer := null
);

/* pproc: deleteOption
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

  ( <body::deleteOption>)
*/
procedure deleteOption(
  optionId integer
  , checkRoleFlag integer := null
  , operatorId integer := null
);

/* pfunc: findOption
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

  ( <body::findOption>)
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
return sys_refcursor;



/* group: Значения параметров */

/* pfunc: createValue
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

  ( <body::createValue>)
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
return integer;

/* pproc: updateValue
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

  ( <body::updateValue>)
*/
procedure updateValue(
  valueId integer
  , dateValue date := null
  , numberValue number := null
  , stringValue varchar2 := null
  , valueIndex integer := null
  , checkRoleFlag integer := null
  , operatorId integer := null
);

/* pproc: deleteValue
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

  ( <body::deleteValue>)
*/
procedure deleteValue(
  valueId integer
  , checkRoleFlag integer := null
  , operatorId integer := null
);

/* pfunc: findValue
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

  ( <body::findValue>)
*/
function findValue(
  valueId integer := null
  , optionId integer := null
  , maxRowCount integer := null
  , checkRoleFlag integer := null
  , operatorId integer := null
)
return sys_refcursor;



/* group: Справочники */

/* pfunc: getObjectType
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

  ( <body::getObjectType>)
*/
function getObjectType
return sys_refcursor;

/* pfunc: getValueType
  Возвращает типы значений параметров.

  Возврат ( курсор):
  value_type_code             - код типа значения параметра
  value_type_name             - название типа значения параметра

  ( сортировка по value_type_name)

  ( <body::getValueType>)
*/
function getValueType
return sys_refcursor;



/* group: Справочники других модулей */

/* pfunc: findModule
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

  ( <body::findModule>)
*/
function findModule(
  moduleId integer := null
  , moduleName varchar2 := null
  , maxRowCount integer := null
)
return sys_refcursor;

/* pfunc: getOperator
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

  ( <body::getOperator>)
*/
function getOperator(
  operatorName varchar2 := null
  , maxRowCount integer := null
)
return sys_refcursor;



/* group: Устаревшие функции */

/* pfunc: getOptionDate(optionShortName)
  Устаревшая функция, в других модулях следует использовать функции из типа
  <opt_option_list_t>.

  ( <body::getOptionDate(optionShortName)>)
*/
function getOptionDate(
  optionShortName varchar2
)
return date;

/* pfunc: getOptionString(optionShortName)
  Устаревшая функция, в других модулях следует использовать функции из типа
  <opt_option_list_t>.

  ( <body::getOptionString(optionShortName)>)
*/
function getOptionString(
  optionShortName varchar2
)
return varchar2;

/* pfunc: getOptionNumber(optionShortName)
  Устаревшая функция, в других модулях следует использовать функции из типа
  <opt_option_list_t>.

  ( <body::getOptionNumber(optionShortName)>)
*/
function getOptionNumber(
  optionShortName varchar2
)
return number;

/* pproc: addOptionDate(optionShortName)
  Устаревшая функция, в других модулях следует использовать функции из типа
  <opt_option_list_t>.

  ( <body::addOptionDate(optionShortName)>)
*/
procedure addOptionDate(
  optionShortName varchar2
  , optionName varchar2
  , defaultDateValue varchar2 := null
);

/* pproc: addOptionNumber(optionShortName)
  Устаревшая функция, в других модулях следует использовать функции из типа
  <opt_option_list_t>.

  ( <body::addOptionNumber(optionShortName)>)
*/
procedure addOptionNumber(
  optionShortName varchar2
  , optionName varchar2
  , defaultNumberValue varchar2 := null
);

/* pproc: addOptionString(optionShortName)
  Устаревшая функция, в других модулях следует использовать функции из типа
  <opt_option_list_t>.

  ( <body::addOptionString(optionShortName)>)
*/
procedure addOptionString(
  optionShortName varchar2
  , optionName varchar2
  , defaultStringValue varchar2 := null
);

/* pfunc: getOptionDate(optionId)
  Устаревшая функция, в других модулях следует использовать функции из типа
  <opt_option_list_t>.

  ( <body::getOptionDate(optionId)>)
*/
function getOptionDate(
  optionId in opt_option_value.option_id%type
)
return opt_option_value.datetime_value%type;

/* pfunc: getOptionInteger(optionId)
  Устаревшая функция, в других модулях следует использовать функции из типа
  <opt_option_list_t>.

  ( <body::getOptionInteger(optionId)>)
*/
function getOptionInteger(
  optionId in opt_option_value.option_id%type
)
return opt_option_value.integer_value%type;

/* pfunc: getOptionString(optionId)
  Устаревшая функция, в других модулях следует использовать функции из типа
  <opt_option_list_t>.

  ( <body::getOptionString(optionId)>)
*/
function getOptionString(
  optionId in opt_option_value.option_id%type
)
return opt_option_value.string_value%type;

/* pfunc: getOptionDate
  Устаревшая функция, в других модулях следует использовать функции из типа
  <opt_option_list_t>.

  ( <body::getOptionDate>)
*/
function getOptionDate(
  moduleName varchar2
  , moduleOptionName varchar2
)
return date;

/* pfunc: getOptionString
  Устаревшая функция, в других модулях следует использовать функции из типа
  <opt_option_list_t>.

  ( <body::getOptionString>)
*/
function getOptionString(
  moduleName varchar2
  , moduleOptionName varchar2
)
return varchar2;

/* pfunc: getOptionNumber
  Устаревшая функция, в других модулях следует использовать функции из типа
  <opt_option_list_t>.

  ( <body::getOptionNumber>)
*/
function getOptionNumber(
  moduleName varchar2
  , moduleOptionName varchar2
)
return number;

/* pproc: setDateTime(optionId)
  Устаревшая функция, в других модулях следует использовать функции из типа
  <opt_option_list_t>.

  ( <body::setDateTime(optionId)>)
*/
procedure setDateTime(
  optionid in opt_option_value.option_id%type
  , value in opt_option_value.datetime_value%type
);

/* pproc: setString(optionId)
  Устаревшая функция, в других модулях следует использовать функции из типа
  <opt_option_list_t>.

  ( <body::setString(optionId)>)
*/
procedure setString(
  optionid in opt_option_value.option_id%type
  , value in opt_option_value.string_value%type
);

/* pproc: setInteger(optionId)
  Устаревшая функция, в других модулях следует использовать функции из типа
  <opt_option_list_t>.

  ( <body::setInteger(optionId)>)
*/
procedure setInteger(
  optionId in opt_option_value.option_id%type
  , value in opt_option_value.integer_value%type
);

/* pproc: setDate
  Устаревшая функция, в других модулях следует использовать функции из типа
  <opt_option_list_t>.

  ( <body::setDate>)
*/
procedure setDate(
  moduleName varchar2
  , moduleOptionName varchar2
  , dateValue date
);

/* pproc: setString
  Устаревшая функция, в других модулях следует использовать функции из типа
  <opt_option_list_t>.

  ( <body::setString>)
*/
procedure setString(
  moduleName varchar2
  , moduleOptionName varchar2
  , stringValue varchar2
);

/* pproc: setNumber
  Устаревшая функция, в других модулях следует использовать функции из типа
  <opt_option_list_t>.

  ( <body::setNumber>)
*/
procedure setNumber(
  moduleName varchar2
  , moduleOptionName varchar2
  , numberValue number
);

/* pfunc: createOption
  Устаревшая функция, в других модулях следует использовать функции из типа
  <opt_option_list_t>.

  ( <body::createOption>)
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
return opt_option.option_id%type;

/* pfunc: createOption
  Устаревшая функция, в других модулях следует использовать функции из типа
  <opt_option_list_t>.

  ( <body::createOption>)
*/
function createOption(
  optionName opt_option.option_name%type
  , optionShortName opt_option.option_short_name%type
  , isGlobal opt_option.is_global%type
  , maskId opt_option.mask_id%type
  , stringValue varchar2
  , operatorId op_operator.operator_id%type
)
return integer;

/* pproc: updateOption
  Устаревшая функция, в других модулях следует использовать функции из типа
  <opt_option_list_t>.

  ( <body::updateOption>)
*/
procedure updateOption(
  optionId in opt_option.option_id%type
  , dateTimeValue in opt_option_value.datetime_value%type
  , integerValue in opt_option_value.integer_value%type
  , stringValue in opt_option_value.string_value%type
  , operatorId in op_operator.operator_id%type
);

/* pproc: updateOption
  Устаревшая функция, в других модулях следует использовать функции из типа
  <opt_option_list_t>.

  ( <body::updateOption>)
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
);

/* pproc: updateOption
  Устаревшая функция, в других модулях следует использовать функции из типа
  <opt_option_list_t>.

  ( <body::updateOption>)
*/
procedure updateOption(
  optionId in opt_option.option_id%type
  , maskId in opt_option.mask_id%type
  , stringValue in varchar2
  , operatorId in op_operator.operator_id%type
);

/* pproc: updateOption
  Устаревшая функция, в других модулях следует использовать функции из типа
  <opt_option_list_t>.

  ( <body::updateOption>)
*/
procedure updateOption(
  optionId opt_option.option_id%type
  , optionName opt_option.option_name%type
  , optionShortName opt_option.option_short_name%type
  , isGlobal opt_option.is_global%type
  , maskId opt_option.mask_id%type
  , stringValue varchar2
  , operatorId op_operator.operator_id%type
);

/* pproc: addOptionDate
  Устаревшая функция, в других модулях следует использовать функции из типа
  <opt_option_list_t>.

  ( <body::addOptionDate>)
*/
procedure addOptionDate(
  moduleName varchar2
  , moduleOptionName varchar2
  , optionName varchar2
  , defaultDateValue varchar2 := null
);

/* pproc: addOptionNumber
  Устаревшая функция, в других модулях следует использовать функции из типа
  <opt_option_list_t>.

  ( <body::addOptionNumber>)
*/
procedure addOptionNumber(
  moduleName varchar2
  , moduleOptionName varchar2
  , optionName varchar2
  , defaultNumberValue varchar2 := null
);

/* pproc: addOptionString
  Устаревшая функция, в других модулях следует использовать функции из типа
  <opt_option_list_t>.

  ( <body::addOptionString>)
*/
procedure addOptionString(
  moduleName varchar2
  , moduleOptionName varchar2
  , optionName varchar2
  , defaultStringValue varchar2 := null
);



/* group:	Устаревшие интерфейсные функции */

/* pfunc: getMask
  Устаревшая функция.

  ( <body::getMask>)
*/
function getMask return sys_refcursor;

/* pfunc: findOption( DEPRECATED)
  Устаревшая функция.

  ( <body::findOption( DEPRECATED)>)
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
) return sys_refcursor;

/* pfunc: getStorageRule
  Устаревшая функция.

  ( <body::getStorageRule>)
*/
function getStorageRule (maskId integer) return sys_refcursor;

end pkg_Option;
/
