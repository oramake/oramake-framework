create or replace package pkg_OptionMain is
/* package: pkg_OptionMain
  Основной пакет модуля Option.

  SVN root: Oracle/Module/Option
*/



/* group: Константы */

/* const: Module_Name
  Наименование модуля, к которому относится пакет.
*/
Module_Name constant varchar2(30) := 'Option';

/* const: Module_SvnRoot
  Путь к корневому каталогу модуля в Subversion.
*/
Module_SvnRoot constant varchar2(30) := 'Oracle/Module/Option';



/* group: Настроечные параметры */

/* const: LocalRoleSuffix_OptionSName
  Краткое наименование параметра
  "Суффикс для ролей, с помощью которых выдаются права на все параметры,
  созданные в локально установленном модуле Option".

  При проверке прав доступа учитываются
  роли:

  OptAdminAllOption<LocalRoleSuffix>    - полные права
  OptShowAllOption<LocalRoleSuffix>     - просмотр данных

  где <LocalRoleSuffix> это значение данного параметра.

  Права даются на все параметры, создаваемые в модуле Option, в котором задан
  данный параметр. При этом подразумевается, что для различных установок
  модуля параметр может иметь различное значение, которое задается при
  установке модуля Option.

  Пример:
  для установок в  БД ProdDb параметр имеет значение "Prod", в результате
  права на все параметры, созданные в БД ProdDb, можно выдать с помощью ролей
  "OptAdminAllOptionProd" и "OptShowAllOptionProd".

  Замечания:
  - настройки, определяющие БД, для которых создаются роли указаного вида,
    и используемые суффиксы ролей, задаются в скрипте
    <Install/Data/Last/Custom/set-optDbRoleSuffixList.sql>;
*/
LocalRoleSuffix_OptionSName constant varchar2(50) := 'LocalRoleSuffix';



/* group: Роли модуля AccessOperator */

/* const: Admin_RoleSName
  Краткое наименование роли
  "Администрирование всех параметров"
*/
Admin_RoleSName constant varchar2(50) := 'GlobalOptionAdmin';

/* const: Show_RoleSName
  Краткое наименование роли
  "Просмотр всех параметров"
*/
Show_RoleSName constant varchar2(50) := 'OptShowAllOption';



/* group: Уровни доступа через интерфейс */

/* const: Full_AccessLevelCode
  Код уровня доступа "Полный доступ".
*/
Full_AccessLevelCode constant varchar2(10) := 'FULL';

/* const: Read_AccessLevelCode
  Код уровня доступа "Только для чтения".
*/
Read_AccessLevelCode constant varchar2(10) := 'READ';

/* const: Value_AccessLevelCode
  Код уровня доступа "Изменение значения".
*/
Value_AccessLevelCode constant varchar2(10) := 'VALUE';



/* group: Типы значений параметров */

/* const: Date_ValueTypeCode
  Код типа значения "Дата ( со временем)".
*/
Date_ValueTypeCode constant varchar2(10) := 'DATE';

/* const: Number_ValueTypeCode
  Код типа значения "Число".
*/
Number_ValueTypeCode constant varchar2(10) := 'NUM';

/* const: String_ValueTypeCode
  Код типа значения "Строка".
*/
String_ValueTypeCode constant varchar2(10) := 'STR';



/* group: Типы объектов */

/* const: PlsqlObject_ObjTypeSName
  Краткое наименование типа объекта "PL/SQL объект".
*/
PlsqlObject_ObjTypeSName constant varchar2(50) := 'plsql_object';



/* group: Функции */

/* pfunc: getCurrentUsedOperatorId
  Возвращает текущий установленный Id оператора, для которого может
  использоваться значение, для использования в представлении
  <v_opt_option_value>.

  ( <body::getCurrentUsedOperatorId>)
*/
function getCurrentUsedOperatorId
return integer;



/* group: Типы объектов */

/* pfunc: getObjectTypeId
  Возвращает Id типа объекта.

  Параметры:
  moduleId                    - Id модуля, к которому относится тип объекта
  objectTypeShortName         - краткое наименование типа объекта
  raiseNotFoundFlag           - выбрасывать ли исключение в случае отсутствия
                                записи ( 1 да ( по умолчанию), 0 нет)

  Возврат:
  Id типа объекта ( из таблицы <opt_object_type>) либо null, если запись не
  найдена и значение raiseNotFoundFlag равно 0.

  ( <body::getObjectTypeId>)
*/
function getObjectTypeId(
  moduleId integer
  , objectTypeShortName varchar2
  , raiseNotFoundFlag integer := null
)
return integer;

/* pfunc: createObjectType
  Создает тип объекта.

  Параметры:
  moduleId                    - Id модуля, к которому относится тип объекта
  objectTypeShortName         - краткое наименование типа объекта
  objectTypeName              - наименование типа объекта
  operatorId                  - Id оператора ( по умолчанию текущий)

  Возврат:
  Id типа объекта.

  ( <body::createObjectType>)
*/
function createObjectType(
  moduleId integer
  , objectTypeShortName varchar2
  , objectTypeName varchar2
  , operatorId integer := null
)
return integer;

/* pfunc: mergeObjectType
  Создает или обновляет тип объекта.

  Параметры:
  moduleId                    - Id модуля, к которому относится тип объекта
  objectTypeShortName         - краткое наименование типа объекта
  objectTypeName              - наименование типа объекта
  operatorId                  - Id оператора ( по умолчанию текущий)

  Возврат:
  - флаг внесения изменений ( 0 нет изменений, 1 если изменения внесены)

  ( <body::mergeObjectType>)
*/
function mergeObjectType(
  moduleId integer
  , objectTypeShortName varchar2
  , objectTypeName varchar2
  , operatorId integer := null
)
return integer;

/* pproc: deleteObjectType
  Удаляет тип объекта.

  Параметры:
  moduleId                    - Id модуля, к которому относится тип объекта
  objectTypeShortName         - краткое наименование типа объекта
  operatorId                  - Id оператора, выполняющего операцию ( по
                                умолчанию текущий)

  Замечания:
  - в случае использования типа в актуальных данных выбрасывается исключение;
  - при отсутствии использования запись удаляется физически, иначе ставится
    флаг логического удаления;

  ( <body::deleteObjectType>)
*/
procedure deleteObjectType(
  moduleId integer
  , objectTypeShortName varchar2
  , operatorId integer := null
);



/* group: Настроечные параметры */

/* pfunc: getDecryptValue
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

  ( <body::getDecryptValue>)
*/
function getDecryptValue(
  stringValue varchar2
  , listSeparator varchar2
)
return varchar2;

/* pfunc: getOptionId
  Возвращает Id настроечного параметра.

  Параметры:
  moduleId                    - Id модуля, к которому относится параметр
  objectShortName             - краткое наименование объекта модуля
  objectTypeId                - Id типа объекта
  optionShortName             - краткое наименование параметра
  raiseNotFoundFlag           - выбрасывать ли исключение в случае отсутствия
                                параметра ( 1 да ( по умолчанию), 0 нет)

  Возврат:
  Id параметра либо null, если параметр не найден и значение raiseNotFoundFlag
  равно 0.

  ( <body::getOptionId>)
*/
function getOptionId(
  moduleId integer
  , objectShortName varchar2
  , objectTypeId integer
  , optionShortName varchar2
  , raiseNotFoundFlag integer := null
)
return integer;

/* pproc: lockOption
  Блокирует и возвращает данные параметра.

  Параметры:
  rowData                     - данные записи ( возврат)
  optionId                    - Id параметра

  Замечания:
  - в случае, если запись была логически удалена, выбрасывается исключение;

  ( <body::lockOption>)
*/
procedure lockOption(
  rowData out nocopy opt_option%rowtype
  , optionId integer
);

/* pfunc: createOption
  Создает настроечный параметр.

  Параметры:
  moduleId                    - Id модуля, к которому относится параметр
  optionShortName             - краткое наименование параметра
  valueTypeCode               - код типа значения параметра
  optionName                  - наименование параметра
  objectShortName             - краткое наименование объекта модуля
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
  operatorId                  - Id оператора ( по умолчанию текущий)

  Возврат:
  Id параметра.

  ( <body::createOption>)
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
  , operatorId integer := null
)
return integer;

/* pproc: updateOption
  Изменяет настроечный параметр.

  Параметры:
  optionId                    - Id параметра
  moduleId                    - Id модуля, к которому относится параметр
  objectShortName             - краткое наименование объекта модуля
  objectTypeId                - Id типа объекта
  optionShortName             - краткое наименование параметра
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
  optionName                  - наименование параметра
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
  operatorId                  - Id оператора ( по умолчанию текущий)

  Замечания:
  - использование deleteBadValueFlag совместно с moveProdSensitiveValueFlag
    обеспечивает удаление тестовых значений в случае установки
    для параметра значения testProdSensitiveFlag равным в 0
    ( в противном случае при наличии тестовых значений было бы выброшено
      исключение);

  ( <body::updateOption>)
*/
procedure updateOption(
  optionId integer
  , moduleId integer
  , objectShortName varchar2
  , objectTypeId integer
  , optionShortName varchar2
  , valueTypeCode varchar2
  , valueListFlag integer
  , encryptionFlag integer
  , testProdSensitiveFlag integer
  , accessLevelCode varchar2
  , optionName varchar2
  , optionDescription varchar2
  , moveProdSensitiveValueFlag integer := null
  , deleteBadValueFlag integer := null
  , operatorId integer := null
);

/* pproc: deleteOption
  Удаляет настроечный параметр.

  Параметры:
  optionId                    - Id параметра
  operatorId                  - Id оператора ( по умолчанию текущий)

  Замечания:
  - при удалении параметра автоматически удаляются относящиеся к нему значения;

  ( <body::deleteOption>)
*/
procedure deleteOption(
  optionId integer
  , operatorId integer := null
);



/* group: Значения параметров */

/* pfunc: formatValueList
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

  ( <body::formatValueList>)
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
return varchar2;

/* pfunc: getValueCount
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

  ( <body::getValueCount>)
*/
function getValueCount(
  valueTypeCode varchar2
  , listSeparator varchar2
  , stringValue varchar2
)
return integer;

/* pproc: getValue
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

  ( <body::getValue>)
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
);

/* pproc: lockValue
  Блокирует и возвращает данные значения параметра.

  Параметры:
  rowData                     - данные записи ( возврат)
  valueId                     - Id значения параметра

  Замечания:
  - в случае, если запись была логически удалена, выбрасывается исключение;

  ( <body::lockValue>)
*/
procedure lockValue(
  rowData out nocopy opt_value%rowtype
  , valueId integer
);

/* pfunc: createValue
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
  ignoreTestProdSensitiveFlag - при создании значения не проверять его
                                соответствие текущему значению флага
                                test_prod_sensitive_flag параметра
                                ( 1 да, 0 нет ( выбрасывать исключение при
                                  расхождении))
                                ( по умолчанию 0)
  operatorId                  - Id оператора ( по умолчанию текущий)

  Возврат:
  Id значения параметра.

  ( <body::createValue>)
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
  , ignoreTestProdSensitiveFlag integer := null
  , operatorId integer := null
)
return integer;

/* pproc: updateValue
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
  operatorId                  - Id оператора ( по умолчанию текущий)

  ( <body::updateValue>)
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
  , operatorId integer := null
);

/* pproc: setValue
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
  operatorId                  - Id оператора ( по умолчанию текущий)

  Замечания:
  - для установки значения в зависимости от его наличия используется либо
    функция <createValue> либо процедура <updateValue>;

  ( <body::setValue>)
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
  , operatorId integer := null
);

/* pproc: deleteValue
  Удаляет значение параметра.

  Параметры:
  valueId                     - Id значения параметра
  operatorId                  - Id оператора ( по умолчанию текущий)

  ( <body::deleteValue>)
*/
procedure deleteValue(
  valueId integer
  , operatorId integer := null
);



/* group: Дополнительные функции */

/* pproc: addOptionWithValue
  Добавляет настроечный параметр со значением, если он не был создан ранее.

  Параметры:
  moduleId                    - Id модуля, к которому относится параметр
  optionShortName             - краткое наименование параметра
  valueTypeCode               - код типа значения параметра
  optionName                  - наименование параметра
  objectShortName             - краткое наименование объекта модуля
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

  ( <body::addOptionWithValue>)
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
);

/* pproc: getOptionValue
  Возвращает таблицу параметров с текущими используемыми значениями.

  Параметры:
  rowTable                    - таблица с данными
                                ( тип <opt_option_value_table_t>)
                                ( возврат)
  moduleId                    - Id модуля, к которому относятся параметры
  objectShortName             - краткое наименование объекта модуля, к которому
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

  ( <body::getOptionValue>)
*/
procedure getOptionValue(
  rowTable out nocopy opt_option_value_table_t
  , moduleId integer
  , objectShortName varchar2 := null
  , objectTypeId integer := null
  , usedOperatorId integer := null
);

end pkg_OptionMain;
/
