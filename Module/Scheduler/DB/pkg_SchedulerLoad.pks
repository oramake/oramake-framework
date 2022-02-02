create or replace package pkg_SchedulerLoad is
/* package: pkg_SchedulerLoad
  Пакет для загрузки данных пакетных заданий в БД.

  SVN root: Oracle/Module/Scheduler
*/



/* group: Функции */



/* group: Утилиты */

/* pfunc: getAttributeString
  Получение значения атрибута строки.

  Параметры:
  xml                       - данные xml
  xPath                     - путь XPath к тегу
  raiseExceptionFlag        - генерировать ли исключение, если тег не найден

  ( <body::getAttributeString>)
*/
function getAttributeString(
  xml xmltype
  , xPath varchar2
  , attributeName varchar2
  , raiseExceptionFlag boolean := null
)
return varchar2;

/* pfunc: getBatchTypeId
  Получение id типа батча.

  Параметры:
  moduleId                    - id модуля

  ( <body::getBatchTypeId>)
*/
function getBatchTypeId(
  moduleId integer
)
return integer;

/* pfunc: getXmlString
  Получение строки для выгрузки xml.

  Параметры:
  sourceString                - исходная строка

  ( <body::getXmlString>)
*/
function getXmlString(
  sourceString varchar2
)
return varchar2;

/* pproc: setLoggingLevel
  Устанавливает уровень логирования пакета ( <logger>).

  Параметры:
  levelCode               - уровень логирования

  ( <body::setLoggingLevel>)
*/
procedure setLoggingLevel(
  levelCode varchar2
);

/* pfunc: normalizeText
  Нормализует текст. Удаляет игнорируемые символы и "." в конце и в начале
  текста. Удаляет пробельные символы в конце строк. Преобразует Windows-концы
  строк в вид Unix.

  Параметры:
  sourceText                  - исходный текс

  Возврат:
  - преобразованный текст;

  ( <body::normalizeText>)
*/
function normalizeText(
  sourceText varchar2
)
return varchar2;



/* group: Загрузка данных в БД */

/* pproc: loadJob(moduleId)
  Загрузка задания (job) в БД.

  Параметры:
  moduleId                    - id модуля
  jobShortName                - короткое наименование задания
  jobName                     - наименование задания ( на русском)
  description                 - описания задания
  jobWhat                     - plsql-код задания
  publicFlag                  - флаг интерфейсного задания ( 1 - задание может
                                быть использовано в других модулях, 0 - задание
                                может быть использовано только в данном модуле,
                                по-умолчанию 0)
  batchShortName              - короткое наименование пакетного задания ( батча),
                                если задание может быть использовано только
                                в данном пакетном задании ( батче)
  skipCheckJob                - флаг пропуска проверки корректности
                                ( компиляции) PL/SQL-блоков заданий ( "1" не
                                проверять, по умолчанию проверять)

  ( <body::loadJob(moduleId)>)
*/
procedure loadJob(
  moduleId integer
  , jobShortName varchar2
  , jobName varchar2
  , description varchar2
  , jobWhat varchar2
  , publicFlag number := null
  , batchShortName varchar2 := null
  , skipCheckJob number := null
);

/* pproc: loadJob(jobName)
  Загрузка задания (job) в БД.

  Параметры:
  moduleName                  - название модуля ( например "ModuleInfo")
  moduleSvnRoot               - путь к корневому каталогу устанавливаемого
                                модуля в Subversion ( начиная с имени
                                репозитария, например
                                "Oracle/Module/ModuleInfo")
  moduleInitialSvnPath        - первоначальный путь к корневому каталогу
                                устанавливаемого модуля в Subversion ( начиная
                                с имени репозитария и влючая номер правки, в
                                которой он был создан, например
                                "Oracle/Module/ModuleInfo@711")
  jobShortName                - короткое наименование задания
  jobName                     - наименование задания ( на русском)
  jobWhat                     - PL/SQL-код задания
  publicFlag                  - флаг интерфейсного задания ( 1 - задание может
                                быть использовано в других модулях, 0 - задание
                                может быть использовано только в данном модуле,
                                по-умолчанию 0)
  batchShortName              - короткое наименование пакетного задания ( батча),
                                если задание может быть использовано только
                                в данном пакетном задании ( батче)
  skipCheckJob                - флаг пропуска проверки корректности
                                ( компиляции) PL/SQL-блоков заданий ( "1" не
                                проверять, по умолчанию проверять)

  Примечание:
  - должен быть задан хотя бы один из трёх параметров moduleName,
    moduleSvnRoot, moduleInitialSvnPath;

  ( <body::loadJob(jobName)>)
*/
procedure loadJob(
  moduleName varchar2 := null
  , moduleSvnRoot varchar2 := null
  , moduleInitialSvnPath varchar2 := null
  , jobShortName varchar2
  , jobName varchar2
  , jobWhat varchar2
  , description varchar2
  , publicFlag number := null
  , batchShortName varchar2 := null
  , skipCheckJob number := null
);

/* pproc: loadJob(fileText)
  Загрузка задания (job) в БД.

  Параметры:
  moduleName                  - название модуля ( например "ModuleInfo")
  moduleSvnRoot               - путь к корневому каталогу устанавливаемого
                                модуля в Subversion ( начиная с имени
                                репозитария, например
                                "Oracle/Module/ModuleInfo")
  moduleInitialSvnPath        - первоначальный путь к корневому каталогу
                                устанавливаемого модуля в Subversion ( начиная
                                с имени репозитария и влючая номер правки, в
                                которой он был создан, например
                                "Oracle/Module/ModuleInfo@711")
  jobShortName                - короткое наименование задания
  fileText                    - текст исходного файла для загрузки
  publicFlag                  - флаг интерфейсного задания ( 1 - задание может
                                быть использовано в других модулях, 0 - задание
                                может быть использовано только в данном модуле,
                                по-умолчанию 0)
  batchShortName              - короткое наименование пакетного задания ( батча),
                                если задание может быть использовано только
                                в данном пакетном задании ( батче)
  skipCheckJob                - флаг пропуска проверки корректности
                                ( компиляции) PL/SQL-блоков заданий ( "1" не
                                проверять, по умолчанию проверять)

  Примечание:
  - должен быть задан хотя бы один из трёх параметров moduleName,
    moduleSvnRoot, moduleInitialSvnPath;

  ( <body::loadJob(fileText)>)
*/
procedure loadJob(
  moduleName varchar2 := null
  , moduleSvnRoot varchar2 := null
  , moduleInitialSvnPath varchar2 := null
  , jobShortName varchar2
  , fileText clob
  , publicFlag number := null
  , batchShortName varchar2 := null
  , skipCheckJob number := null
);

/* pproc: loadBatchConfig(batchShortName)
  Загрузка настроек пакетного задания ( батчей) в БД из XML.

  Параметры:
  moduleId                    - id модуля
  batchConfigXml              - xml с данными настроек
  batchShortName              - короткое наименование батча
                                Если задано, то осуществляется проверка соответствия
                                с атрибутом short_name. Если не задан, то
                                выполняется попытка извлечь наименование батча из
                                атрибута short_name;
  batchNewFlag                - считается ли батч новым ( для определения
                                необходимости загрузки расписания)
  updateScheduleFlag          - обновлять ли расписание существующего батча
                                ( по-умолчанию загружается расписание только
                                  нового батча)
  skipLoadOption              - флаг исключения загрузки параметров пакетных
                                заданий ( "1" не загружать, по умолчанию
                                загружать параметры устнавливаемых пакетных
                                заданий)
  updateOptionValue           - обновлять ли значения существующих параметров

  ( <body::loadBatchConfig(batchShortName)>)
*/
procedure loadBatchConfig(
  moduleId integer
  , batchConfigXml xmltype
  , batchShortName varchar2
  , batchNewFlag number
  , updateScheduleFlag number
  , skipLoadOption number
  , updateOptionValue number
);

/* pproc: loadBatchConfig
  Загрузка настроек пакетных заданий ( батчей) в БД из XML.

  Параметры:
  moduleName                  - название модуля ( например "ModuleInfo")
  moduleSvnRoot               - путь к корневому каталогу устанавливаемого
                                модуля в Subversion ( начиная с имени
                                репозитария, например
                                "Oracle/Module/ModuleInfo")
  moduleInitialSvnPath        - первоначальный путь к корневому каталогу
                                устанавливаемого модуля в Subversion ( начиная
                                с имени репозитария и влючая номер правки, в
                                которой он был создан, например
                                "Oracle/Module/ModuleInfo@711")
  xmlText                     - текст xml с данными настроек
  updateScheduleFlag          - обновлять ли расписание существующего батча
                                ( по-умолчанию загружается расписание только
                                  нового батча)
  skipLoadOption              - флаг исключения загрузки параметров пакетных
                                заданий ( "1" не загружать, по умолчанию
                                загружать параметры устнавливаемых пакетных
                                заданий)
  updateOptionValue           - обновлять ли значения существующих параметров

  ( <body::loadBatchConfig>)
*/
procedure loadBatchConfig(
  moduleName varchar2 := null
  , moduleSvnRoot varchar2 := null
  , moduleInitialSvnPath varchar2 := null
  , xmlText clob
  , updateScheduleFlag number := null
  , skipLoadOption number := null
  , updateOptionValue number := null
);

/* pproc: loadBatch(moduleId)
  Загрузка пакетного задания ( батча) в БД из XML.

  Параметры:
  moduleId                    - id модуля
  batchShortName              - короткое наименование пакетного задания ( батча)
                                ( должно соответствовать данным XML)
  xmlText                     - спефикация пакетного задания в виде xml
  updateScheduleFlag          - обновлять ли расписание существующего батча
                                ( по-умолчанию загружается расписание только
                                  нового батча)
  skipLoadOption              - флаг исключения загрузки параметров пакетных
                                заданий ( "1" не загружать, по умолчанию
                                загружать параметры устанавливаемых пакетных
                                заданий)
  updateOptionValue           - обновлять ли значения существующих параметров

  ( <body::loadBatch(moduleId)>)
*/
procedure loadBatch(
  moduleId integer
  , batchShortName varchar2
  , xmlText clob
  , updateScheduleFlag number := null
  , skipLoadOption number := null
  , updateOptionValue number := null
);

/* pproc: loadBatch
  Загрузка пакетного задания ( батча) в БД из XML.

  Параметры:
  moduleName                  - название модуля ( например "ModuleInfo")
  moduleSvnRoot               - путь к корневому каталогу устанавливаемого
                                модуля в Subversion ( начиная с имени
                                репозитария, например
                                "Oracle/Module/ModuleInfo")
  moduleInitialSvnPath        - первоначальный путь к корневому каталогу
                                устанавливаемого модуля в Subversion ( начиная
                                с имени репозитария и влючая номер правки, в
                                которой он был создан, например
                                "Oracle/Module/ModuleInfo@711")
  batchShortName              - короткое наименование пакетного задания ( батча)
                                ( должно соответствовать данным XML)
  xmlText                     - спефикация пакетного задания в виде xml
  updateScheduleFlag          - обновлять ли расписание существующего батча
                                ( по-умолчанию загружается расписание только
                                  нового батча)
  skipLoadOption              - флаг исключения загрузки параметров пакетных
                                заданий ( "1" не загружать, по умолчанию
                                загружать параметры устанавливаемых пакетных
                                заданий)
  updateOptionValue           - обновлять ли значения существующих параметров

  ( <body::loadBatch>)
*/
procedure loadBatch(
  moduleName varchar2 := null
  , moduleSvnRoot varchar2 := null
  , moduleInitialSvnPath varchar2 := null
  , batchShortName varchar2
  , xmlText clob
  , updateScheduleFlag number := null
  , skipLoadOption number := null
  , updateOptionValue number := null
);

/* pproc: renameBatch( INTERNAL)
  Переименовывает пакетное задание.

  Параметры:
  batchRec                    - данные пакетного задания
  newBatchShortName           - новое короткое наименование пакетного задания

  ( <body::renameBatch( INTERNAL)>)
*/
procedure renameBatch(
  batchRec sch_batch%rowtype
  , newBatchShortName varchar2
);

/* pproc: renameBatch( batchId)
  Переименовывает пакетное задание.

  Параметры:
  batchId                     - Id пакетного задания
  newBatchShortName           - новое короткое наименование пакетного задания

  ( <body::renameBatch( batchId)>)
*/
procedure renameBatch(
  batchId integer
  , newBatchShortName varchar2
);

/* pproc: renameBatch
  Переименовывает пакетное задание.

  Параметры:
  batchShortName              - короткое наименование пакетного задания
  newBatchShortName           - новое короткое наименование пакетного задания

  ( <body::renameBatch>)
*/
procedure renameBatch(
  batchShortName varchar2
  , newBatchShortName varchar2
);

/* pproc: deleteBatch(batchId)
  Удаление батча.

  Параметры:
  batchId                     - id батча

  ( <body::deleteBatch(batchId)>)
*/
procedure deleteBatch(
  batchId integer
);

/* pproc: deleteBatch
  Удаление батча.

  Параметры:
  batchShortName              - короткое наименование батча
  activatedFlag               - флаг удаления активированных батчей
                                ( 1 - удалить активированный батч
                                  0 - удалять неактивированный батч)

  ( <body::deleteBatch>)
*/
procedure deleteBatch(
  batchShortName varchar2
  , activatedFlag number := 0
);

/* pproc deleteModuleBatch
  Удаление всех батчей, принадлежащих модулю
  Предназначен для удаления батчей, принадлежащих модулю при его деинсталляции
  
  Параметры:
  moduleName                  - наименование модуля
*/
procedure deleteModuleBatch(
  moduleName varchar2 
);



/* group: Выгрузка данных из БД */

/* pfunc: createBatchConfigXml
  Выгрузка настроек батча в XML.

  Параметры:
  batchShortName              - короткое наименование батча
  seperateFileFlag            - является ли создаваемый xml отдельным
                                ( вне batch.xml)
                                ( 1 да, 0 нет ( по умолчанию))

  ( <body::createBatchConfigXml>)
*/
function createBatchConfigXml(
  batchShortName varchar2
  , separateFileFlag integer := null
)
return clob;

/* pproc: unloadBatchConfigXml
  Выгрузка настроек батча в XML-файл.

  Параметры:
  batchShortName              - короткое наименование батча
  filePath                    - путь к файлу для выгрузи

  ( <body::unloadBatchConfigXml>)
*/
procedure unloadBatchConfigXml(
  batchShortName varchar2
  , filePath varchar2
);

/* pfunc: createBatchXml
  Выгрузка данных батча в XML.

  Параметры:
  batchShortName              - короткое наименование батча
  skipConfigFlag              - пропускать ли настройки батча
                                ( по-умолчанию выгружать)

  ( <body::createBatchXml>)
*/
function createBatchXml(
  batchShortName varchar2
  , skipConfigFlag number := null
)
return clob;

/* pproc: unloadBatchXml
  Выгрузка данных батча в XML-файл.

  Параметры:
  batchShortName              - короткое наименование батча
  filePath                    - путь к файлу для выгрузи
  skipConfigFlag              - пропускать ли настройки батча
                                ( по-умолчанию выгружать)

  ( <body::unloadBatchXml>)
*/
procedure unloadBatchXml(
  batchShortName varchar2
  , filePath varchar2
  , skipConfigFlag number := null
);

/* pfunc: createJobText
  Преобразование данных задания ( job) в текстовые данные.

  Параметры:
  jobId                       - id задания ( job)
  xmlText                     - получаемый текст xml

  ( <body::createJobText>)
*/
function createJobText(
  jobId integer
)
return clob;

/* pproc: unloadJob(filePath)
  Выгрузка данных задания ( job) в файл.

  Параметры:
  jobId                       - id задания ( job)
  filePath                    - путь к файлу для выгрузки

  ( <body::unloadJob(filePath)>)
*/
procedure unloadJob(
  jobId integer
  , filePath varchar2
);

/* pproc: unloadBatch
  Выгрузка данных батча.

  Параметры:
  batchShortNameList          - список коротких наименований батчей через ','
  batchParentPath             - корневая директория для батчей
  publicJobPath               - директория для публичных job-ов
                                в случае принадлежности модулю батча
  configPath                  - директория для выгрузки настроек батчей
                                По-умолчанию настройки выгружаются вместе с
                                данными батча.

  ( <body::unloadBatch>)
*/
procedure unloadBatch(
  batchShortNameList varchar2
  , batchParentPath varchar2
  , publicJobPath varchar2
  , configPath varchar2 := null
);

end pkg_SchedulerLoad;
/
