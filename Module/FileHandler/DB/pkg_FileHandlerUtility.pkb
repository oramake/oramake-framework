create or replace package body pkg_FileHandlerUtility is
/* package body: pkg_FileHandlerUtility::body */

/* ivar: logger
  ������������ ������ � ������ Logging
*/
  logger lg_logger_t := lg_logger_t.GetLogger(
    moduleName => pkg_FileHandlerBase.Module_Name
    , objectName => 'pkg_FileHandlerUtility'
  );

/* ivar: lastCommandCheck
  ����� ��������� �������� ������
*/
  lastCommandCheck number := null;

/* ivar: lastRequestCheck
  ����� ��������� �������� �������
*/
  lastRequestCheck number := null;

/* ivar: batchInited
  ����������� �� ���������� <batchShortName>
*/
  batchInited boolean not null:= false;

/* ivar: batchShortName
  ������������ �������� ������������ � ������ ������ �����
*/
  batchShortName sch_batch.batch_short_name%type
    := null;

/* ivar: �reateCacheTextMask
  ����� ��� ��������������� ��������
  ������������ ����������. ��� ���������
  <batchShortName> ��������������� � �������
  <GetTextMaskByBatch>
*/
  �reateCacheTextMask flh_cached_file_mask.file_mask%type
     := null;

/* proc: SetCreateCacheTextMask
  ������������ �������� ����� ��������� ������
  ��� ��������������� ����������� ����������

  ���������:
    newValue - ����� �������� �����
*/
procedure SetCreateCacheTextMask(
  newValue varchar2
)
is
begin
  �reateCacheTextMask := newValue;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( '������ ��������� �reateCacheTextMask' )
    , true
  );
end SetCreateCacheTextMask;

/* func: GetCreateCacheTextMask
  ��������� �������� ����� ��������� ������
  ��� ��������������� ����������� ����������

  �������:
    - �������� <�reateCacheTextMask>
*/
function GetCreateCacheTextMask
return varchar2
is
begin
  return
    �reateCacheTextMask;
end GetCreateCacheTextMask;

/* func: GetTextMaskByBatch
  �������� <�reateCacheTextMask> �� <batchShortName>
  ���������� � �������� � <flh_batch_config>
*/
procedure GetTextMaskByBatch
is
                                       -- ������ ��� ���������
                                       -- ����������� �����
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
    �reateCacheTextMask;
  close curBatchConfig;
exception when others then
  if curBatchConfig%ISOPEN then
    close curBatchConfig;
  end if;
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack(
        '������ ����������� �reateCacheTextMask �� batchShortName'
      )
    , true
  );
end GetTextMaskByBatch;

/* func: GetBatchShortName
  ���������� ������������ ����� ������

  ���������:
   forcedBatchShortName      - ��������������� ������������
                               �����

  �������:
    - ��� ������������ �����
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
    , logger.ErrorStack( '������ ������������� batchShortName' )
    , true
  );
end GetBatchShortName;

/* proc: InitCheckTime
  ������������� �������� ����������� �������� � ������
*/
procedure InitCheckTime
is
begin
  lastRequestCheck := null;
  lastCommandCheck := null;
end InitCheckTime;

/* proc: InitRequestCheckTime
  ������������� �������� ����������� ������ � ��������
*/
procedure InitRequestCheckTime
is
begin
  lastRequestCheck := null;
end InitRequestCheckTime;


/* proc: InitHandler
  ������������� �����������

  ���������:
    processName              - ��� ��������
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
    , logger.ErrorStack( '������ ������������� �����������' )
    , true
  );
end InitHandler;


/* func: WaitForCommand
  ������� �������, ���������� ����� pipe
  � ������ ���� ��������� ����� ��������� �������
  � ������ <lastCommandCheck>.

  ���������:
    command                  - ������� ��� ��������
    checkRequestTimeOut      - �������� ��� �������� �������� �������
                               ���� ����� �������� �������� �������
                               ����������� �� ������ ����������
                               (<lastRequestCheck>).
  �������:
    - �������� �� �������
*/
function WaitForCommand(
  command varchar2
  , checkRequestTimeOut integer := null
)
return boolean
is
                                       -- ���������� �������
  recievedCommand varchar2( 50 );
                                       -- ������������ ��������
                                       -- �������
  isFinish boolean;
                                       -- �������� ��� �������� �������
                                       -- ( � �������� )
  waitTimeout number;
begin
  logger.Trace( 'WaitForStopCommand: start');
  pkg_TaskHandler.SetAction( 'wait' );
  logger.Trace( 'WaitForStopCommand: checkRequestTimeOut='
    || to_char( checkRequestTimeOut)
  );
                                       -- ��������� ����� ��������� �������
                                       -- ���� ������� �������� ���������
                                       -- �������� ��������
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
                                       -- ��������� ����������� �������
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
            , '�������� ����������� ����������� ������� "' || command || '".'
          );
      end case;
      logger.Info('�������� ������� "' || recievedCommand || '"');
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
    , logger.ErrorStack( '������ ��������� �������' )
    , true
  );
end WaitForCommand;

/* func: NextRequestTime
  ���������� ��������� �������� ��� ��������
  ������� ��������.
  ����������� ���������� <lastRequestCheck>.

  ��������:
  checkRequestTimeOut                  - ������� ��������
                                         �������( � ��������)
  �������:
    - ��������� �� ����� ��������� ������
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
    , logger.ErrorStack( '������ �������� ��������� ��������' )
    , true
  );
end NextRequestTime;

/* proc: ClearOldRequest
 ������� ������ ������������ ��������
 
 ���������:
   toDate - ����, �� ������� ������� ������
*/
procedure ClearOldRequest(
  toDate date
)
is
                                       -- ������ ��������
  type tabInteger is table of integer;
  colRequestId tabInteger := tabInteger();
  colFileDataId tabInteger := tabInteger();
                                       -- ������ ��� ������� ��������  
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
  -- ������� ������ �� ������� ������
  begin
    logger.Info('������� ������ �� ������� ������');
    forall i in colRequestId.first..colRequestId.last 
      delete from 
        flh_request_file_list l
      where
        l.request_id = colRequestId(i);
    logger.Info('������� �������: '
      || to_char( SQL%ROWCOUNT )
    );  
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack( '������ �������� ������ �� ������� ������' )
      , true
    );
  end ClearFileList;

  procedure ClearTextData
  is
  -- ������� ��������� ������
  begin
    logger.Info('������� ��������� ������');
    forall i in colFileDataId.first..colFileDataId.last 
      delete from 
        flh_text_data f
      where 
        file_data_id = colFileDataId(i);
    logger.Info('������� �������: '
      || to_char( SQL%ROWCOUNT )
    );  
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack( '������ ������� ��������� ������' )
      , true
    );
  end ClearTextData;
  
  procedure ClearFileData
  is
  -- ������� ���������� ������ ������
  begin
    logger.Info('������� ���������� ������ ������' );
    forall i in colFileDataId.first..colFileDataId.last 
      delete from 
        flh_file_data f
      where 
        file_data_id = colFileDataId(i);
    logger.Info('������� �������: '
      || to_char( SQL%ROWCOUNT )
    );  
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack( '������ ������� ���������� ������ ������' )
      , true
    );
  end ClearFileData;  
  
  procedure ClearRequest
  is
  -- ������� ��������
  begin
    logger.Info('������� ��������' );
    forall i in colRequestId.first..colRequestId.last 
      delete from 
        flh_request r
      where 
        request_id = colRequestId(i);
    logger.Info('������� �������: '
      || to_char( SQL%ROWCOUNT )
    );  
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack( '������ ������� �������� ������ ������' )
      , true
    );
  end ClearRequest;    

begin
  logger.Info('���� ��� �������: ' || 
    '{' || to_char( toDate, 'dd.mm.yyyy hh24:mi:ss' ) || '}'
  );
                                       -- ���� �� ������
                                       -- ��������
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
    , logger.ErrorStack( '������ ������� ������ ��������' )
    , true
  );
end ClearOldRequest; 

end pkg_FileHandlerUtility;
/