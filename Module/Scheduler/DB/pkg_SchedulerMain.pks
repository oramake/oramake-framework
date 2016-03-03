create or replace package pkg_SchedulerMain is
/* package: pkg_SchedulerMain
  Основной пакет модуля Scheduler.

  SVN root: Oracle/Module/Scheduler
*/



/* group: Константы */

/* const: Module_Name
  Название модуля, к которому относится пакет.
*/
Module_Name constant varchar2(30) := 'Scheduler';

/* const: Module_SvnRoot
  Путь к корневому каталогу модуля в Subversion.
*/
Module_SvnRoot constant varchar2(100) := 'Oracle/Module/Scheduler';

/* const: Batch_OptionObjTypeSName
  Короткое название типа объекта "Пакетное задание" в модуле Option ( поле
  object_type_short_name таблицы opt_object_type).
  Модуль Option используетя для хранения параметров пакетных заданий, при этом
  в качестве короткого имени объекта ( поле object_short_name представления
  v_opt_option_value) указывается короткое имя пакетного задания
  ( batch_short_name таблицы <sch_batch>).
*/
Batch_OptionObjTypeSName constant varchar2(50) := 'batch';



/* group: Настроечные параметры */

/* const: LocalRoleSuffix_OptionSName
  Короткое наименование опции
  "Суффикс для ролей, с помощью которых выдаются права на все пакетные задания,
  созданные в локально установленном модуле Scheduler".

  При проверке прав доступа учитываются
  роли:

  AdminAllBatch<LocalRoleSuffix>    - полные права
  ExecuteAllBatch<LocalRoleSuffix>  - выполнение пакетных заданий
  ShowAllBatch<LocalRoleSuffix>     - просмотр данных

  где <LocalRoleSuffix> это значение опции.

  Права даются на все пакетные задания, создаваемые в модуле Scheduler, в
  котором используется значение опции. При этом подразумевается, что в
  различных БД данная опция имеет различное значение, которое задается при
  установке модуля Scheduler.

  Пример:
  в БД DbNameP опция имеет значение "DbName", в результате права на
  все пакетные задания, созданные в БД DbNameP, можно выдать с помощью
  ролей "AdminAllBatchDbName", "ExecuteAllBatchDbName",
  "ShowAllBatchDbName".
*/
LocalRoleSuffix_OptionSName constant varchar2(50) := 'LocalRoleSuffix';



/* group: Функции */

/* pfunc: getModuleId
  Возвращает Id модуля Scheduler в текущей БД ( с кэшированием ранее
  определенного значения).

  Возврат:
  Id записи для модуля Scheduler в таблице mod_module модуля ModuleInfo.

  ( <body::getModuleId>)
*/
function getModuleId
return integer;

/* pproc: getBatch( batchId)
  Возвращает данные пакетного задания.

  Параметры:
  dataRec                     - данные пакетного задания
                                ( возврат)
  batchId                     - Id пакетного задания

  ( <body::getBatch( batchId)>)
*/
procedure getBatch(
  dataRec out nocopy sch_batch%rowtype
  , batchId integer
);

/* pproc: getBatch( batchShortName)
  Возвращает данные пакетного задания.

  Параметры:
  dataRec                     - данные пакетного задания
                                ( возврат)
  batchShortName              - короткое название пакетного задания

  ( <body::getBatch( batchShortName)>)
*/
procedure getBatch(
  dataRec out nocopy sch_batch%rowtype
  , batchShortName varchar2
);

/* pfunc: getLastRootLogId
  Возвращает Id корневого лога последнего запуска пакетного задания.

  Параметры:
  batchId                     - Id пакетного задания

  Возврат:
  Id записи или null, если лог отсутствует.

  ( <body::getLastRootLogId>)
*/
function getLastRootLogId(
  batchId integer
)
return integer;

/* pfunc: getBatchLogInfo
  Возвращает информацию из лога выполнения пакетного задания.

  Параметры:
  batchId                     - Id пакетного задания
                                ( не используется, если указан rootLogId)
  rootLogId                   - Id корневой записи лога
                                ( по умолчанию лог последнего запуска
                                  указанного пакетного задания)

  Замечания:
  - должен быть задан параметр batchId или rootLogId, иначе выбрасывается
    исключение;

  ( <body::getBatchLogInfo>)
*/
function getBatchLogInfo(
  batchId integer := null
  , rootLogId integer := null
)
return sch_batch_log_info_t;

end pkg_SchedulerMain;
/
