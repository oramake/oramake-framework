create or replace package pkg_Scheduler is
/* package: pkg_Scheduler
  Интерфейсный пакет модуля Scheduler.
*/



/* group: Константы */

/* const: Module_Name
  Название модуля, к которому относится пакет.
*/
Module_Name constant varchar2(30) := 'Scheduler';



/* group: Результаты выполнения */

/* const: True_ResultId
  Id результата выполнения "Положительный результат".
*/
True_ResultId constant integer := 1;

/* const: False_ResultId
  Id результата выполнения "Отрицательный результат".
*/
False_ResultId constant integer := 2;

/* const: Error_ResultId
  Id результата выполнения "Ошибка".
*/
Error_ResultId constant integer := 3;

/* const: RunError_ResultId
  Id результата выполнения "Ошибка при запуске".
*/
RunError_ResultId constant integer := 4;

/* const: Skip_ResultId
  Id результата выполнения "Пропущен по условию".
*/
Skip_ResultId constant integer := 5;

/* const: Retryattempt_ResultId
  Id результата выполнения "Повторить попытку".
*/
RetryAttempt_ResultId constant integer := 6;



/* group: Привилегии на пакетное задание */

/* const: Admin_PrivilegeCode
  Код привилегии "Настройка прав ролей".
*/
Admin_PrivilegeCode constant varchar2(10) := 'ADMIN';

/* const: Exec_PrivilegeCode
  Код привилегии "Выполнение ( активация, деактивация, запуск, прерывание)".
*/
Exec_PrivilegeCode constant varchar2(10) := 'EXEC';

/* const: Read_PrivilegeCode
  Код привилегии "Просмотр данных".
*/
Read_PrivilegeCode constant varchar2(10) := 'READ';

/* const: Write_PrivilegeCode
  Код привилегии "Изменение пакетного задания ( кроме изменения параметров)".
*/
Write_PrivilegeCode constant varchar2(10) := 'WRITE';

/* const: WriteOption_PrivilegeCode
  Код привилегии "Изменение параметров пакетного задания".
*/
WriteOption_PrivilegeCode constant varchar2(10) := 'WRITE_OPT';



/* group: Типы сообщений */

/* const: Bmanage_MessageTypeCode
  Код типа сообщения "Управление пакетом".
*/
Bmanage_MessageTypeCode constant varchar2(10) := 'BMANAGE';

/* const: Bstart_MessageTypeCode
  Код типа сообщений "Старт пакета".
*/
Bstart_MessageTypeCode constant varchar2(10) := 'BSTART';

/* const: Bfinish_MessageTypeCode
  Код типа сообщений "Завершение пакета".
*/
Bfinish_MessageTypeCode constant varchar2(10) := 'BFINISH';

/* const: Jstart_MessageTypeCode
  Код типа сообщений "Старт задания".
*/
Jstart_MessageTypeCode constant varchar2(10) := 'JSTART';

/* const: Jfinish_MessageTypeCode
  Код типа сообщения "Завершение задания".
*/
Jfinish_MessageTypeCode constant varchar2(10) := 'JFINISH';

/* const: Error_MessageTypeCode
  Код типа сообщений "Ошибка".
*/
Error_MessageTypeCode constant varchar2(10) := 'ERROR';

/* const: Warning_MessageTypeCode
  Код типа сообщений "Предупреждение".
*/
Warning_MessageTypeCode constant varchar2(10) := 'WARNING';

/* const: Info_MessageTypeCode
  Код типа сообщений "Информация".
*/
Info_MessageTypeCode constant varchar2(10) := 'INFO';

/* const: Debug_MessageTypeCode
  Код типа сообщений "Отладка".
*/
Debug_MessageTypeCode constant varchar2(10) := 'DEBUG';



/* group: Типы интервалов */

/* const: Minute_IntervalTypeCode
  Код типа интервала "Минуты".
*/
Minute_IntervalTypeCode constant varchar2(10) := 'MI';

/* const: Hour_IntervalTypeCode
  Код типа интервала "Часы".
*/
Hour_IntervalTypeCode constant varchar2(10) := 'HH';

/* const: Dayofmonth_IntervalTypeCode
  Код типа интервала "Дни месяца".
*/
Dayofmonth_IntervalTypeCode constant varchar2(10) := 'DD';

/* const: Month_IntervalTypeCode
  Код типа интервала "Месяцы".
*/
Month_IntervalTypeCode constant varchar2(10) := 'MM';

/* const: Dayofweek_IntervalTypeCode
  Код типа интервала "Дни недели".
*/
Dayofweek_IntervalTypeCode constant varchar2(10) := 'DW';



/* group: Функции */



/* group: Пакетные задания */

/* pproc: updateBatch
  Изменяет пакет.

  Параметры:
  batchId                     - Id пакета
  batchName                   - название пакета
  retrialCount                - число перезапусков
  retrialTimeout              - интервал между перезапусками
  operatorId                  - Id оператора

  ( <body::updateBatch>)
*/
procedure updateBatch(
  batchId integer
  , batchName varchar2
  , retrialCount integer
  , retrialTimeout interval day to second
  , operatorId integer
);

/* pproc: activateBatch
  Ставит пакет заданий на выполнение в соответствии с расписанием (либо
  пересчитывает дату запуска и пытается восстановить работоспособность уже
  установленного на выполнение пакета).  Очищает номер повторной попытки (если
  он был установлен).

  Параметры:
  batchId                     - Id задания
  operatorId                  - Id оператора

  ( <body::activateBatch>)
*/
procedure activateBatch(
  batchId integer
  , operatorId integer
);

/* pproc: deactivateBatch
  Прекращает периодическое выполнение пакета заданий

  Параметры:
  batchId                     - Id задания
  operatorId                  - Id оператора

  ( <body::deactivateBatch>)
*/
procedure deactivateBatch(
  batchId integer
  , operatorId integer
);

/* pproc: setNextDate
  Устанавливает дату следующего запуска активированного пакета.

  batchId                     - Id пакета
  operatorId                  - Id оператора
  nextDate                    - дата следующего запуска
                                ( по умолчанию немедленно)

  ( <body::setNextDate>)
*/
procedure setNextDate(
  batchId integer
  , operatorId integer
  , nextDate date := sysdate
);

/* pproc: abortBatch
  Прерывает выполнение пакета заданий.

  Параметры:
  batchId                     - Id задания
  operatorId                  - Id оператора

  Замечание:
  - в случае успешного выполнения внутри процедуры выполняется commit.

  ( <body::abortBatch>)
*/
procedure abortBatch(
  batchId integer
  , operatorId integer
);

/* pfunc: findBatch
  Поиск пакетного задания.

  Параметры:
  batchId                     - Id пакетного задания
  batchShortName              - короткое название
  batchName                   - название
  moduleId                    - Id модуля, к которому относится пакетно задание
  retrialCount                - число повторов
  lastDateFrom                - дата последнего запуска с
  lastDateTo                  - дата последнего запуска до
  rowCount                    - максимальное число возвращаемых записей
  operatorId                  - Id оператора, выполняющего операцию ( по
                                умолчанию текущий)

  Возврат ( курсор):
  batch_id                    - Id пакетного задания
  batch_short_name            - короткое название
  batch_name                  - название
  module_id                   - Id модуля
  module_name                 - название модуля
  retrial_count               - число повторов
  retrial_timeout             - интервал между повторами
  oracle_job_id               - Id назначенного задания для dbms_job
  retrial_number              - номер повторного выполнения
  date_ins                    - дата добавления пакетного задания
  operator_id                 - Id оператора, добавившего пакетное задание
  operator_name               - имя оператора, добавившего пакетное задание
                                ( анг.)
  job                         - Id реально существующего задания для dbms_job
  last_date                   - дата последнего запуска
  this_date                   - дата текущего запуска
  next_date                   - дата следующего запуска
  total_time                  - суммарное время выполнения
  failures                    - число последних последовательных ошибок при
                                запуске через dbms_job
  is_job_broken               - признак отключенного задания в dbms_job
  root_log_id                 - Id корневого лога последнего выполнения
  last_start_date             - дата последнего запуска из лога
  last_log_date               - дата последней записи в логе
  batch_result_id             - Id результата выполнения пакетного задания
  result_name                 - название результата
  error_job_count             - число подзадач, завершившихся ошибкой при
                                последнем выполении
  error_count                 - число ошибок при последнем выполении
  warning_count               - число предупреждений при последнем выполении
  duration_second             - длительность последнего выполнения ( в секундах)
  sid                         - sid сессии, в которой выполняется пакетное
                                задание
  serial                      - serial# сессии, в которой выполняется пакетное
                                задание

  Замечания:
  - показываются только пакетные задания, доступные указанному оператору по
    чтению;
  - значение параметров batchShortName, batchName используется для поиска по
    шаблону ( like) без учета регистра по соответствующим полям;
  - если критериям поиска удовлетворяет больше записей, чем указанное
    максимальное число возвращаемых записей, то записи для возврата отбираются
    случайным образом ( без определенного порядка);
  - поисковые параметры со значением null не влияют на результат поиска;

  ( <body::findBatch>)
*/
function findBatch(
  batchId integer := null
  , batchShortName varchar2 := null
  , batchName varchar2 := null
  , moduleId integer := null
  , retrialCount integer := null
  , lastDateFrom date := null
  , lastDateTo date := null
  , rowCount integer := null
  , operatorId integer := null
)
return sys_refcursor;



/* group: Расписание запуска */

/* pfunc: createSchedule
  Создает расписание.

  Параметры:
  batchId                     - Id пакета
  scheduleName                - название расписания
  operatorId                  - Id оператора

  ( <body::createSchedule>)
*/
function createSchedule(
  batchId integer
  , scheduleName varchar2
  , operatorId integer
)
return integer;

/* pproc: updateSchedule
  Изменяет расписание.

  Параметры:
  scheduleId                  - Id расписания
  scheduleName                - название расписания
  operatorId                  - Id оператора

  ( <body::updateSchedule>)
*/
procedure updateSchedule(
  scheduleId integer
  , scheduleName varchar2
  , operatorId integer
);

/* pproc: deleteSchedule
  Удаляет расписание.

  Параметры:
  scheduleId                  - Id расписания
  operatorId                  - Id оператора

  ( <body::deleteSchedule>)
*/
procedure deleteSchedule(
  scheduleId integer
  , operatorId integer
);

/* pfunc: findSchedule

  Параметры:
    scheduleId                - Уникальный идентификатор
    batchId                    - Идентификатор батча
    maxRowCount                - Количество записей
    operatorId                - Идентификатор текущего пользователя

  Возврат (курсор):
    schedule_id                - Уникальный идентификатор
    batch_id                  - Идентификатор батча
    schedule_name              - Наименование
    date_ins                  - Дата создания
    operator_id                - Идентификатор оператора
    operator_name              - Оператор

  ( <body::findSchedule>)
*/
function findSchedule
(
    scheduleId  integer := null
  , batchId     integer := null
  , maxRowCount integer := null
  , operatorId  integer := null
) return sys_refcursor;



/* group: Интервалы расписания запуска */

/* pfunc: createInterval
  Создает интервал.

  Параметры:
  scheduleId                  - Id расписания
  intervalTypeCode            - код типа интервала
  minValue                    - минимальное значение
  maxValue                    - максимальное значение
  step                        - шаг ( по умолчанию 1)
  operatorId                  - Id оператора ( по умолчанию текущий)

  ( <body::createInterval>)
*/
function createInterval(
  scheduleId integer
  , intervalTypeCode varchar2
  , minValue integer
  , maxValue integer
  , step integer := null
  , operatorId integer := null
)
return integer;

/* pproc: updateInterval
  Изменяет интервал.

  Параметры:
  intervalId                  - Id интервала
  intervalTypeCode            - код типа интервала
  minValue                    - минимальное значение
  maxValue                    - максимальное значение
  step                        - шаг
  operatorId                  - Id оператора

  ( <body::updateInterval>)
*/
procedure updateInterval(
  intervalId integer
  , intervalTypeCode varchar2
  , minValue integer
  , maxValue integer
  , step integer
  , operatorId integer
);

/* pproc: deleteInterval
  Удаляет интервал.

  Параметры:
  intervalId                  - Id интервала
  operatorId                  - Id оператора

  ( <body::deleteInterval>)
*/
procedure deleteInterval(
  intervalId integer
  , operatorId integer
);

/* pfunc: findInterval

  Параметры:
    scheduleId                - Уникальный идентификатор
    batchId                    - Идентификатор батча
    maxRowCount                - Количество записей
    operatorId                - Идентификатор текущего пользователя

  Возврат (курсор):
    interval_id               - Уникальный идентификатор
    schedule_id               - Идентификатор расписания
    interval_type_code        - Код типа интервала
    interval_type_name        - Наименование типа интервала
    min_value                 - Нижняя граница
    max_value                 - Верхняя граница
    step                      - Шаг интервала
    date_ins                  - Дата создания
    operator_id               - Идентификатор оператора
    operator_name             - Оператор

  ( <body::findInterval>)
*/
function findInterval
(
    intervalId  integer := null
  , scheduleId  integer := null
  , maxRowCount integer := null
  , operatorId  integer := null
) return sys_refcursor;



/* group: Логи */

/* pfunc: findRootLog

  Параметры:
    logId                  - Уникальный идентификатор
    batchId                - Идентификатор батча
    maxRowCount            - Количество записей
    operatorId             - Идентификатор текущего пользователя

  Возврат (курсор):
    log_id                  - Уникальный идентификатор
    batch_id                - Идентификатор батча
    message_type_code       - Код типа сообщения
    message_type_name       - Наименование типа сообщения
    message_text            - Текст сообщения
    date_ins                - Дата создания
    operator_id             - Идентификатор оператора
    operator_name           - Оператор

  ( <body::findRootLog>)
*/
function findRootLog
(
    logId        integer := null
  , batchId      integer := null
  , maxRowCount  integer := null
  , operatorId  integer := null
) return sys_refcursor;

/* pfunc: getDetailedLog

  Параметры:
    parentLogId            - Идентификатор родительского лога
    operatorId             - Идентификатор текущего пользователя

  Возврат (курсор):
    log_id                  - Уникальный идентификатор
    parent_log_id           - Идентификатор родительского лога
    message_type_code       - Код типа сообщения
    message_type_name       - Наименование типа сообщения
    message_text            - Текст сообщения
    message_value           - Значение сообщения
    log_level               - Уровень иерархии
    date_ins                - Дата создания
    operator_id             - Идентификатор оператора
    operator_name           - Оператор

  ( <body::getDetailedLog>)
*/
function getDetailedLog
(
    parentLogId integer
  , operatorId  integer
) return sys_refcursor;



/* group: Параметры пакетных заданий */

/* pfunc: createOption
  Создает параметр пакетного задания и задает для него используемое в текущей
  БД значение.

  Параметры:
  batchId                     - Id пакетного задания
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
                                ( 1 да ( по умолчанию), 0 нет)
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
  operatorId                  - Id оператора ( по умолчанию текущий)

  Возврат:
  Id параметра.

  Замечания:
  - в случае, если используется список значений, указанное в параметрах
    функции значение сохраняется как первое значение списка;

  ( <body::createOption>)
*/
function createOption(
  batchId integer
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
  , operatorId integer := null
)
return integer;

/* pproc: updateOption
  Изменяет параметр пакетного задания.

  Параметры:
  batchId                     - Id пакетного задания
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
  operatorId                  - Id оператора ( по умолчанию текущий)

  Замечания:
  - значения, которые не соответствуют новым данным настроечного параметра,
    удаляются;
  - в промышленных БД при изменении знечения testProdSensitiveFlag текущее
    значение параметра сохраняется ( при этом вместо общего значения создается
    значение для промышленной БД или наоборот);

  ( <body::updateOption>)
*/
procedure updateOption(
  batchId integer
  , optionId integer
  , valueTypeCode varchar2
  , valueListFlag integer
  , encryptionFlag integer
  , testProdSensitiveFlag integer
  , optionName varchar2
  , optionDescription varchar2
  , operatorId integer := null
);

/* pproc: setOptionValue
  Задает используемое в текущей БД значение параметра пакетного задания.

  Параметры:
  batchId                     - Id пакетного задания
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
  operatorId                  - Id оператора ( по умолчанию текущий)

  ( <body::setOptionValue>)
*/
procedure setOptionValue(
  batchId integer
  , optionId integer
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
  batchId                     - Id пакетного задания
  optionId                    - Id параметра
  operatorId                  - Id оператора ( по умолчанию текущий)

  ( <body::deleteOption>)
*/
procedure deleteOption(
  batchId integer
  , optionId integer
  , operatorId integer := null
);

/* pfunc: findOption
  Поиск настроечных параметров пакетного задания.

  Параметры:
  batchId                     - Id пакетного задания
  optionId                    - Id параметра
                                ( по умолчанию без ограничений)
  maxRowCount                 - максимальное число возвращаемых поиском записей
                                ( по умолчанию без ограничений)
  operatorId                  - Id оператора, выполняющего операцию
                                ( по умолчанию текущий)

  Возврат ( курсор):
  option_id                   - Id параметра
  value_id                    - Id используемого значения
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
  - в возвращаемом курсоре также присутствуют другие недокументированные выше
    поля, которые не должны использоваться в интерфейсе;

  ( <body::findOption>)
*/
function findOption(
  batchId integer
  , optionId integer := null
  , maxRowCount integer := null
  , operatorId integer := null
)
return sys_refcursor;



/* group: Значения параметра пакетного задания */

/* pfunc: createValue
  Создает значение параметра.

  Параметры:
  batchId                     - Id пакетного задания
  optionId                    - Id параметра
  prodValueFlag               - флаг использования значения только в
                                промышленных ( либо тестовых) БД
                                ( 1 только в промышленных БД, 0 только в
                                  тестовых БД, null без ограничений)
  instanceName                - имя экземпляра БД, в которой может
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
  operatorId                  - Id оператора ( по умолчанию текущий)

  Возврат:
  Id значения параметра.

  Замечания:
  - в случае, если используется список значений, указанное в параметрах
    функции значение сохраняется как первое значение списка;

  ( <body::createValue>)
*/
function createValue(
  batchId integer
  , optionId integer
  , prodValueFlag integer
  , instanceName varchar2 := null
  , dateValue date := null
  , numberValue number := null
  , stringValue varchar2 := null
  , stringListSeparator varchar2 := null
  , operatorId integer := null
)
return integer;

/* pproc: updateValue
  Изменяет значение параметра пакетного задания.

  Параметры:
  batchId                     - Id пакетного задания
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
  operatorId                  - Id оператора ( по умолчанию текущий)

  ( <body::updateValue>)
*/
procedure updateValue(
  batchId integer
  , valueId integer
  , dateValue date := null
  , numberValue number := null
  , stringValue varchar2 := null
  , valueIndex integer := null
  , checkRoleFlag integer := null
  , operatorId integer := null
);

/* pproc: deleteValue
  Удаляет значение параметра пакетного задания.

  Параметры:
  batchId                     - Id пакетного задания
  valueId                     - Id значения параметра
  operatorId                  - Id оператора ( по умолчанию текущий)

  ( <body::deleteValue>)
*/
procedure deleteValue(
  batchId integer
  , valueId integer
  , operatorId integer := null
);

/* pfunc: findValue
  Поиск значений параметра пакетного задания.

  Параметры:
  batchId                     - Id пакетного задания
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

  ( <body::findValue>)
*/
function findValue(
  batchId integer
  , valueId integer := null
  , optionId integer := null
  , maxRowCount integer := null
  , operatorId integer := null
)
return sys_refcursor;



/* group: Права ролей на пакетные задания */

/* pfunc: createBatchRole
  Выдает роли привилегию на пакет.

  Параметры:
  batchId                     - Id пакета
  privilegeCode               - код привилегии
  roleId                      - Id роли
  operatorId                  - Id оператора

  ( <body::createBatchRole>)
*/
function createBatchRole(
  batchId integer
  , privilegeCode varchar2
  , roleId integer
  , operatorId integer
)
return integer;

/* pproc: deleteBatchRole
  Отбирает у роли привилегию на пакет.

  Параметры:
  batchRoleId                 - Id удаляемой записи
  operatorId                  - Id оператора

  ( <body::deleteBatchRole>)
*/
procedure deleteBatchRole(
  batchRoleId integer
  , operatorId integer
);

/* pfunc: findBatchRole

  Параметры:
    batchRoleId                 - Уникальный идентификатор
    batchId                     - Идентификатор батча
    maxRowCount                 - Количество записей
    operatorId                  - Идентификатор текущего пользователя

  Возврат (курсор):
    batch_role_id               - Уникальный идентификатор
    batch_id                    - Идентификатор батча
    privilege_code              - Код привилегии
    role_id                     - Идентификатор роли
    role_short_name             - Краткое наименование роли
    privilege_name              - Наименование привилегии
    role_name                   - Наименование роли
    date_ins                    - Дата создания
    operator_id                 - Идентификатор оператора
    operator_name               - Оператор

  ( <body::findBatchRole>)
*/
function findBatchRole
(
    batchRoleId integer := null
  , batchId     integer := null
  , maxRowCount  integer := null
  , operatorId  integer := null
) return sys_refcursor;



/* group: Права ролей на пакетные задания модулей */

/* pfunc: createModuleRolePrivilege
  Выдает роли привилегию на любые пакетные задания модуля.

  Параметры:
  moduleId                    - Id модуля
  roleId                      - Id роли
  privilegeCode               - код привилегии
  operatorId                  - Id оператора

  Возврат:
  Id созданной записи.

  ( <body::createModuleRolePrivilege>)
*/
function createModuleRolePrivilege(
  moduleId integer
  , roleId integer
  , privilegeCode varchar2
  , operatorId integer
)
return integer;

/* pproc: deleteModuleRolePrivilege
  Отбирает у роли привилегию на тип пакетов.

  Параметры:
  moduleRolePrivilegeId       - Id записи c выдачей привилегии
  operatorId                  - Id оператора

  ( <body::deleteModuleRolePrivilege>)
*/
procedure deleteModuleRolePrivilege(
  moduleRolePrivilegeId integer
  , operatorId integer
);

/* pfunc: findModuleRolePrivilege
  Поиск выданных ролям привилегий на любые пакетные задания модуля.

  Параметры:
  moduleRolePrivilegeId       - Id записи c выдачей привилегии
                                ( по умолчанию без ограничений)
  moduleId                    - Id модуля
                                ( по умолчанию без ограничений)
  roleId                      - Id роли
                                ( по умолчанию без ограничений)
  privilegeCode               - код привилегии
                                ( по умолчанию без ограничений)
  maxRowCount                 - максимальное число возвращаемых записей
                                ( по умолчанию без ограничений)
  operatorId                  - Id оператора, выполняющего операцию
                                ( по умолчанию текущий)

  Возврат (курсор):
  module_role_privilege_id    - Id записи c выдачей привилегии
  module_id                   - Id модуля
  module_name                 - название модуля
  role_id                     - Id роли
  role_short_name             - краткое название роли
  role_name                   - название роли
  privilege_code              - код привилегии
  privilege_name              - название привилегии
  date_ins                    - дата добавления записи
  operator_id                 - Id оператора, добавившего запись
  operator_name               - оператор, добавивший запись

  Замечания:
  - возвращаемые записи отсортированы по module_name, role_short_name,
    privilege_code;

  ( <body::findModuleRolePrivilege>)
*/
function findModuleRolePrivilege(
  moduleRolePrivilegeId integer := null
  , moduleId integer := null
  , privilegeCode varchar2 := null
  , roleId integer := null
  , maxRowCount  integer := null
  , operatorId integer := null
)
return sys_refcursor;



/* group: Справочники */

/* pfunc: findModule
  Возвращает программные модули, у которых есть пакетные задания.

  Возврат ( курсор):
  module_id                   - Id модуля
  module_name                 - Название модуля
  ( сортировка по module_name, module_id)

  ( <body::findModule>)
*/
function findModule
return sys_refcursor;

/* pfunc: getIntervalType
  Функция выбирает все данные из таблицы sch_interval_type без дополнительных условий.

  Возврат (курсор):
    interval_type_code          -  Уникальный идентификатор
    interval_type_name          -  Наименование

  ( <body::getIntervalType>)
*/
function getIntervalType
return sys_refcursor;

/* pfunc: getPrivilege
  Возвращает привилегии на работу с пакетными заданиями.

  Возврат ( курсор):
  privilege_code              - код типа привилегии
  privilege_name              - название типа привилегии

  ( сортировка по privilege_name)

  ( <body::getPrivilege>)
*/
function getPrivilege
return sys_refcursor;

/* pfunc: getRole
  Возвращает список ролей.

  Параметры:
  searchStr                   - строка-образец для поиска ( шаблон для поиска
                                по короткому названию, названию или описанию
                                роли без учета регистра)

  Возврат ( курсор):
  role_id                     - Id роли
  role_name                   - название роли

  Замечания:
  - возвращаемые записи отсортированы по role_name;

  ( <body::getRole>)
*/
function getRole(
  searchStr varchar2 := null
)
return sys_refcursor;

/* pfunc: getValueType
  Возвращает типы значений параметров пакетных заданий.

  Возврат ( курсор):
  value_type_code             - код типа значения параметра
  value_type_name             - название типа значения параметра

  ( <body::getValueType>)
*/
function getValueType
return sys_refcursor;



/* group: Выполнение батчей */

/* pfunc: calcNextDate
  Вычисляет дату следующего запуска пакета заданий.

  Параметры:
  batchId              - Id пакета
  startDate            - начальная дата (начиная с которой выполняется расчет)

  ( <body::calcNextDate>)
*/
function calcNextDate(
  batchId integer
  , startDate date := sysdate
)
return date;

/* pproc: stopHandler
  Останавливает сессию обработчика с помощью отправки команды остановки.

  Параметры:
  batchId                     - Id пакета
  sid                         - sid сессии
  serial#                     - serial# сессии
  operatorId                  - Id оператора

  ( <body::stopHandler>)
*/
procedure stopHandler(
  batchId integer
  , sid number
  , serial# number
  , operatorId integer
);

/* pproc: execBatch( BATCH_ID)
  Выполняет указанный пакет заданий

  Параметры:
  batchId              - Id задания

  ( <body::execBatch( BATCH_ID)>)
*/
function execBatch(
  batchId integer
)
return integer;

/* pproc: execBatch( BATCH_SHORT_NAME)
  Выполняет указанный пакет заданий

  Параметры:
  batchShortName       - Имя (batch_short_name) исполняемого задания

  ( <body::execBatch( BATCH_SHORT_NAME)>)
*/
function execBatch(
  batchShortName varchar2
)
return integer;



/* group: Другие функции */

/* pproc: clearLog
  Удаляет старые логи и возвращает число удаленных записей.

  Параметры:
  toDate                      - дата, до которой надо удалить логи ( не включая)

  ( <body::clearLog>)
*/
function clearLog(
  toDate date
)
return integer;

/* pfunc: getLog
  Возвращает ветку из лога ( таблицы sch_log).

  Параметры:
  rootLogId                - Id корневой записи из sch_log

  Замечания:
  - функция предназначена для использования в SQL-запросах вида:
  select lg.* from record( pkg_Scheduler.getLog( :rootLogId)) lg

  ( <body::getLog>)
*/
function getLog(
  rootLogId integer
)
return
  sch_log_table_t
pipelined parallel_enable;



/* group: Установка флагов выполнения заданий */

/* pfunc: getDebugFlag
  Возвращает значение флага отладки.

  ( <body::getDebugFlag>)
*/
function getDebugFlag
return integer;

/* pproc: setDebugFlag
  Устанавливает флаг отладки в указанное значение.

  ( <body::setDebugFlag>)
*/
procedure setDebugFlag(
  flagValue integer := 1
);

/* pfunc: getSendNotifyFlag
  Возвращает значение флага автоматической рассылки нотификации.

  ( <body::getSendNotifyFlag>)
*/
function getSendNotifyFlag
return integer;

/* pproc: setSendNotifyFlag
  Устанавливает флаг рассылки нотификации в указанное значение.

  ( <body::setSendNotifyFlag>)
*/
procedure setSendNotifyFlag(
  flagValue integer := 1
);



/* group: Переменные пакетного задания */

/* pproc: setContext( ANYDATA)
  Устанавливает значение переменной пакетного задания произвольного типа.

  Параметры:
  varName                     - имя переменной ( без учета регистра)
  varValue                    - значение переменной
  isConstant                  - переменная является константой
                                ( 1 да, 0 нет ( по умолчанию))
  valueIndex                  - индекс значения в списке значений
                                ( начиная с 1, по умолчанию 1)

  ( <body::setContext( ANYDATA)>)
*/
procedure setContext(
  varName varchar2
  , varValue anydata
  , isConstant integer := null
  , valueIndex pls_integer := null
);

/* pproc: setContext( DATE)
  Устанавливает значение переменной пакетного задания типа дата.
  заданий.

  Параметры:
  varName                     - имя переменной ( без учета регистра)
  varValue                    - значение переменной
  isConstant                  - переменная является константой
                                ( 1 да, 0 нет ( по умолчанию))
  valueIndex                  - индекс значения в списке значений
                                ( начиная с 1, по умолчанию 1)

  ( <body::setContext( DATE)>)
*/
procedure setContext(
  varName varchar2
  , varValue date
  , isConstant integer := null
  , valueIndex pls_integer := null
);

/* pproc: setContext( NUMBER)
  Устанавливает числовое значение переменной пакетного задания.

  Параметры:
  varName                     - имя переменной ( без учета регистра)
  varValue                    - значение переменной
  isConstant                  - переменная является константой
                                ( 1 да, 0 нет ( по умолчанию))
  valueIndex                  - индекс значения в списке значений
                                ( начиная с 1, по умолчанию 1)

  ( <body::setContext( NUMBER)>)
*/
procedure setContext(
  varName varchar2
  , varValue number
  , isConstant integer := null
  , valueIndex pls_integer := null
);

/* pproc: setContext( STRING)
  Устанавливает строковое значение переменной пакетного задания.

  Параметры:
  varName                     - имя переменной ( без учета регистра)
  varValue                    - значение переменной
  isConstant                  - переменная является константой
                                ( 1 да, 0 нет ( по умолчанию))
  valueIndex                  - индекс значения в списке значений
                                ( начиная с 1, по умолчанию 1)
  encryptedValue              - зашифрованное значение переменной
                                ( если указано, то используется для логирования
                                  вместо значения переменной)

  ( <body::setContext( STRING)>)
*/
procedure setContext(
  varName varchar2
  , varValue varchar2
  , isConstant integer := null
  , valueIndex pls_integer := null
  , encryptedValue varchar2 := null
);

/* pfunc: getContextAnydata
  Возвращает значение переменной пакетного задания произвольного типа.

  Параметры:
  varName                     - имя переменной ( без учета регистра)
  riseException               - флаг генерации исключения при отсутствии
                                переменной
                                ( 1 да, 0 нет ( по умолчанию))
  valueIndex                  - индекс значения в списке значений
                                ( начиная с 1, по умолчанию 1)

  Возврат:
  значение переменной.

  ( <body::getContextAnydata>)
*/
function getContextAnydata(
  varName in varchar2
  , riseException integer := null
  , valueIndex integer := null
)
return anydata;

/* pfunc: getContextDate
  Возвращает значение переменной пакетного задания типа дата.

  Параметры:
  varName                     - имя переменной ( без учета регистра)
  riseException               - флаг генерации исключения при отсутствии
                                переменной
                                ( 1 да, 0 нет ( по умолчанию))
  valueIndex                  - индекс значения в списке значений
                                ( начиная с 1, по умолчанию 1)

  Возврат:
  значение переменной.

  ( <body::getContextDate>)
*/
function getContextDate(
  varName in varchar2
  , riseException integer := null
  , valueIndex integer := null
)
return date;

/* pfunc: getContextNumber
  Возвращает значение переменной пакетного задания числового типа.

  Параметры:
  varName                     - имя переменной ( без учета регистра)
  riseException               - флаг генерации исключения при отсутствии
                                переменной
                                ( 1 да, 0 нет ( по умолчанию))
  valueIndex                  - индекс значения в списке значений
                                ( начиная с 1, по умолчанию 1)

  Возврат:
  значение переменной.

  ( <body::getContextNumber>)
*/
function getContextNumber(
  varName in varchar2
  , riseException integer := null
  , valueIndex integer := null
)
return number;

/* pfunc: getContextString
  Возвращает значение переменной пакетного задания строкового типа.

  Параметры:
  varName                     - имя переменной ( без учета регистра)
  riseException               - флаг генерации исключения при отсутствии
                                переменной
                                ( 1 да, 0 нет ( по умолчанию))
  valueIndex                  - индекс значения в списке значений
                                ( начиная с 1, по умолчанию 1)

  Возврат:
  значение переменной.

  ( <body::getContextString>)
*/
function getContextString(
  varName in varchar2
  , riseException integer := null
  , valueIndex integer := null
)
return varchar2;

/* pfunc: getContextValueCount
  Возвращает число значений для переменной пакетного задания.

  Параметры:
  varName                     - имя переменной ( без учета регистра)
  riseException               - флаг генерации исключения при отсутствии
                                переменной
                                ( 1 да, 0 нет ( по умолчанию))

  Возврат:
  число значений или 0 при отсутствии переменной.

  ( <body::getContextValueCount>)
*/
function getContextValueCount(
  varName in varchar2
  , riseException integer := null
)
return integer;

/* pproc: deleteContext
  Удаляет переменную пакетного задания.

  Параметры:
  varName                     - имя переменной ( без учета регистра)
  riseException               - флаг генерации исключения при отсутствии
                                переменной
                                ( 1 да, 0 нет ( по умолчанию))

  ( <body::deleteContext>)
*/
procedure deleteContext(
  varName in varchar2
  , riseException integer := null
);



/* group: Логирование */

/* pproc: writeLog
  Записывает сообщение в лог (таблицу sch_log).

  Параметры:
  MessageTypeCode           - код типа сообщения
  MessageText               - текст сообщения
  MessageValue              - целое значение, связанное с сообщением
  operatorId                - Id оператора

  ( <body::writeLog>)
*/
procedure writeLog(
  messageTypeCode varchar2
  , messageText varchar2
  , messageValue number := null
  , operatorId integer := null
);



/* group: Выполнение пакетного задания */

/* pproc: execBatch( ORACLE_JOB)
  Выполняет указанный пакет заданий

  Параметры:
  oracleJobId          - Id задания Oracle (для определения batch_id)
  nextDate             - Дата следующего запуска (для dbms_job)

  ( <body::execBatch( ORACLE_JOB)>)
*/
procedure execBatch(
  oracleJobId number
  , nextDate in out date
);



/* group: Устаревшие функции */

/* pfunc: getContextInteger
  Устаревшая функция, следует использовать <getContextNumber>.

  ( <body::getContextInteger>)
*/
function getContextInteger(
  varName in varchar2
  , riseException integer := 0
)
return number;

end pkg_Scheduler;
/
