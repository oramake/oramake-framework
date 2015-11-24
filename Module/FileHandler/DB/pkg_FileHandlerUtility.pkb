create or replace package body pkg_FileHandlerUtility is
/* package body: pkg_FileHandlerUtility::body */

/* ivar: logger
  Интерфейсный объект к модулю Logging
*/
  logger lg_logger_t := lg_logger_t.GetLogger(
    moduleName => pkg_FileHandlerBase.Module_Name
    , objectName => 'pkg_FileHandlerUtility'
  );

/* ivar: lastCommandCheck
  Время последней проверки команд
*/
  lastCommandCheck number := null;

/* ivar: lastRequestCheck
  Время последней проверки запроса
*/
  lastRequestCheck number := null;

/* ivar: batchInited
  Установлена ли переменная <batchShortName>
*/
  batchInited boolean not null:= false;

/* ivar: batchShortName
  Наименование текущего выполняемого в данном сеансе батча
*/
  batchShortName sch_batch.batch_short_name%type
    := null;

/* ivar: сreateCacheTextMask
  Маска для автоматического создания
  кэшированной директории. При установке
  <batchShortName> устанавливается с помощью
  <GetTextMaskByBatch>
*/
  сreateCacheTextMask flh_cached_file_mask.file_mask%type
     := null;

/* proc: SetCreateCacheTextMask
  Устаналивает значение маски текстовых файлов
  для автоматического кэширования директории

  Параметры:
    newValue - новое значение маски
*/
procedure SetCreateCacheTextMask(
  newValue varchar2
)
is
begin
  сreateCacheTextMask := newValue;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( 'Ошибка установки сreateCacheTextMask' )
    , true
  );
end SetCreateCacheTextMask;

/* func: GetCreateCacheTextMask
  Возвращет значение маски текстовых файлов
  для автоматического кэширования директории

  Возврат:
    - значение <сreateCacheTextMask>
*/
function GetCreateCacheTextMask
return varchar2
is
begin
  return
    сreateCacheTextMask;
end GetCreateCacheTextMask;

/* func: GetTextMaskByBatch
  Получает <сreateCacheTextMask> по <batchShortName>
  переменной и настроек в <flh_batch_config>
*/
procedure GetTextMaskByBatch
is
                                       -- Курсор для получения
                                       -- настроенной маски
  cursor curBatchConfig is
    select
      c.auto_cache_text_mask
    from
      flh_batch_config c
    where
      c.batch_short_name = batchShortName;
begin
  open curBatchConfig;
  fetch
    curBatchConfig
  into
    сreateCacheTextMask;
  close curBatchConfig;
exception when others then
  if curBatchConfig%ISOPEN then
    close curBatchConfig;
  end if;
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack(
        'Ошибка определения сreateCacheTextMask по batchShortName'
      )
    , true
  );
end GetTextMaskByBatch;

/* func: GetBatchShortName
  Возвращает наименование батча сеанса

  Параметры:
   forcedBatchShortName      - переопределение наименования
                               батча

  Возврат:
    - имя выполняемого батча
*/
function GetBatchShortName(
  forcedBatchShortName varchar2 := null
)
return varchar2
is
begin
  if forcedBatchShortName is not null then
    batchShortName := forcedBatchShortName;
    GetTextMaskByBatch;
  elsif not batchInited then
    select
      (
      select
        batch_short_name
      from
        v_sch_batch v
      where
        sid = pkg_Common.GetSessionSid
        and v.serial# = pkg_Common.GetSessionSerial
      )
    into
      batchShortName
    from
      dual;
    GetTextMaskByBatch;
  end if;
  batchInited := true;
  return batchShortName;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( 'Ошибка инициализации batchShortName' )
    , true
  );
end GetBatchShortName;

/* proc: InitCheckTime
  Инициализация проверки поступления запросов и команд
*/
procedure InitCheckTime
is
begin
  lastRequestCheck := null;
  lastCommandCheck := null;
end InitCheckTime;

/* proc: InitRequestCheckTime
  Инициализация проверки поступления команд и запросов
*/
procedure InitRequestCheckTime
is
begin
  lastRequestCheck := null;
end InitRequestCheckTime;


/* proc: InitHandler
  Инициализация обработчика

  Параметры:
    processName              - имя процесса
*/
procedure InitHandler(
  processName varchar2
)
is
begin
  pkg_TaskHandler.InitHandler(
    moduleName => pkg_FileHandlerBase.Module_Name
    , processName => processName
  );
  lastRequestCheck := null;
  lastCommandCheck := null;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( 'Ошибка инициализации обработчика' )
    , true
  );
end InitHandler;


/* func: WaitForCommand
  Ожидает команду, получаемую через pipe
  в случае если наступило время проверять команду
  с учётом <lastCommandCheck>.

  Параметры:
    command                  - команда для ожидания
    checkRequestTimeOut      - интервал для проверки ожидания запроса
                               Если задан интервал ожидания команды
                               вычисляется на основе переменной
                               (<lastRequestCheck>).
  Возврат:
    - получена ли команда
*/
function WaitForCommand(
  command varchar2
  , checkRequestTimeOut integer := null
)
return boolean
is
                                       -- Полученная команду
  recievedCommand varchar2( 50 );
                                       -- Возвращаемое значение
                                       -- функции
  isFinish boolean;
                                       -- Интервал для ожидания команды
                                       -- ( в секундах )
  waitTimeout number;
begin
  logger.Trace( 'WaitForStopCommand: start');
  pkg_TaskHandler.SetAction( 'wait' );
  logger.Trace( 'WaitForStopCommand: checkRequestTimeOut='
    || to_char( checkRequestTimeOut)
  );
                                       -- Наступило время проверять команду
                                       -- либо передан параметр интервала
                                       -- проверки запросов
  if checkRequestTimeOut is not null
    or pkg_TaskHandler.NextTime(
      checkTime => lastCommandCheck
      , timeout => pkg_FileHandlerBase.CheckCommand_Timeout
    )
  then
    waitTimeout :=
       checkRequestTimeout
       - pkg_TaskHandler.TimeDiff( pkg_TaskHandler.GetTime, lastRequestCheck);
    logger.Trace( 'WaitForStopCommand: waitTimeout='
      || to_char( waitTimeout)
    );
                                       -- Проверяем поступление команды
    if pkg_TaskHandler.GetCommand(
      command => recievedCommand
      , timeout => waitTimeout
    )
    then
      case recievedCommand
        when command then
          isFinish := true;
        else
          raise_application_error(
            pkg_Error.IllegalArgument
            , 'Получена неизвестная управляющая команда "' || command || '".'
          );
      end case;
      logger.Info('Получена команда "' || recievedCommand || '"');
    else
      isFinish := false;
    end if;
    lastCommandCheck := null;
  end if;
  pkg_TaskHandler.SetAction( '' );
  logger.Trace( 'WaitForStopCommand: end');
  return isFinish;
exception when others then
  pkg_TaskHandler.SetAction( '' );
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( 'Ошибка обработки команды' )
    , true
  );
end WaitForCommand;

/* func: NextRequestTime
  Определяет истечение таймаута для проверки
  наличия запросов.
  Учитывается переменная <lastRequestCheck>.

  Параметр:
  checkRequestTimeOut                  - таймаут ожидания
                                         запроса( в секундах)
  Возврат:
    - наступило ли время проверять запрос
*/
function NextRequestTime(
  checkRequestTimeOut number
)
return boolean
is
  isOk boolean;
begin
  logger.Trace( 'NextRequestTime: lastRequestCheck='
    || to_char( lastRequestCheck)
  );
  isOk :=
    pkg_TaskHandler.NextTime(
      checkTime => lastRequestCheck
      , timeout => checkRequestTimeOut
    );
  logger.Trace( 'NextRequestTime: isOk='
    || case when isOk then 'true' else 'false' end
  );
  return isOk;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( 'Ошибка проверки истечения таймаута' )
    , true
  );
end NextRequestTime;

/* proc: ClearOldRequest
 Очистка данных обработанных запросов
 
 Параметры:
   toDate - дата, до которой очищать данные
*/
procedure ClearOldRequest(
  toDate date
)
is
                                       -- Данные запросов
  type tabInteger is table of integer;
  colRequestId tabInteger := tabInteger();
  colFileDataId tabInteger := tabInteger();
                                       -- Курсор для выборки запросов  
  cursor curClearRequest is
    select
      request_id
      , file_data_id
    from
      flh_request
    where
      date_ins < toDate
      and request_state_code <> pkg_FileHandlerBase.Wait_RequestStateCode
      ;
      
  procedure ClearFileList
  is
  -- Очистка данных по спискам файлов
  begin
    logger.Info('Очистка данных по спискам файлов');
    forall i in colRequestId.first..colRequestId.last 
      delete from 
        flh_request_file_list l
      where
        l.request_id = colRequestId(i);
    logger.Info('Удалено записей: '
      || to_char( SQL%ROWCOUNT )
    );  
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack( 'Ошибка удаления данных по спискам файлов' )
      , true
    );
  end ClearFileList;

  procedure ClearTextData
  is
  -- Очистка текстовых данных
  begin
    logger.Info('Очистка текстовых данных');
    forall i in colFileDataId.first..colFileDataId.last 
      delete from 
        flh_text_data f
      where 
        file_data_id = colFileDataId(i);
    logger.Info('Удалено записей: '
      || to_char( SQL%ROWCOUNT )
    );  
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack( 'Ошибка очистки текстовых данных' )
      , true
    );
  end ClearTextData;
  
  procedure ClearFileData
  is
  -- Очистка заголовков данных файлов
  begin
    logger.Info('Очистка заголовков данных файлов' );
    forall i in colFileDataId.first..colFileDataId.last 
      delete from 
        flh_file_data f
      where 
        file_data_id = colFileDataId(i);
    logger.Info('Удалено записей: '
      || to_char( SQL%ROWCOUNT )
    );  
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack( 'Ошибка очистки заголовков данных файлов' )
      , true
    );
  end ClearFileData;  
  
  procedure ClearRequest
  is
  -- Очистка запросов
  begin
    logger.Info('Очистка запросов' );
    forall i in colRequestId.first..colRequestId.last 
      delete from 
        flh_request r
      where 
        request_id = colRequestId(i);
    logger.Info('Удалено записей: '
      || to_char( SQL%ROWCOUNT )
    );  
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack( 'Ошибка очистки запросов данных файлов' )
      , true
    );
  end ClearRequest;    

begin
  logger.Info('Дата для очистки: ' || 
    '{' || to_char( toDate, 'dd.mm.yyyy hh24:mi:ss' ) || '}'
  );
                                       -- Цикл по блокам
                                       -- запросов
  loop
    open 
      curClearRequest;
    fetch 
      curClearRequest
    bulk collect into
      colRequestId
      , colFileDataId
    limit
      10000;
    close 
      curClearRequest;
    exit when colRequestId.count = 0; 
    ClearFileList;
    ClearRequest;
    ClearTextData;
    ClearFileData;
  end loop;  
exception when others then
  if curClearRequest%isopen then
    close 
      curClearRequest;
  end if;
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( 'Ошибка очистки данных запросов' )
    , true
  );
end ClearOldRequest; 

end pkg_FileHandlerUtility;
/