create or replace package body pkg_SchedulerMain is
/* package body: pkg_SchedulerMain::body */



/* group: ���������� */

/* ivar: logger
  ����� ������.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => Module_Name
  , objectName  => 'pkg_SchedulerMain'
);

/* ivar: schedulerModuleId
  Id ������ ��� ������ Scheduler � ������� mod_module ������ ModuleInfo
  ( ������������ ��������).
*/
schedulerModuleId integer;



/* group: ������� */

/* func: getModuleId
  ���������� Id ������ Scheduler � ������� �� ( � ������������ �����
  ������������� ��������).

  �������:
  Id ������ ��� ������ Scheduler � ������� mod_module ������ ModuleInfo.
*/
function getModuleId
return integer
is
begin
  if schedulerModuleId is null then
    schedulerModuleId := pkg_ModuleInfo.getModuleId(
      svnRoot               => Module_SvnRoot
      , raiseExceptionFlag  => 1
    );
  end if;
  return schedulerModuleId;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ����������� Id ������ Scheduler � ������� ��.'
      )
    , true
  );
end getModuleId;

/* proc: getBatch( batchId)
  ���������� ������ ��������� �������.

  ���������:
  dataRec                     - ������ ��������� �������
                                ( �������)
  batchId                     - Id ��������� �������
*/
procedure getBatch(
  dataRec out nocopy sch_batch%rowtype
  , batchId integer
)
is
begin
  select
    t.*
  into dataRec
  from
    sch_batch t
  where
    t.batch_id = batchId
  ;
exception
  when no_data_found then
    raise_application_error(
      pkg_Error.BatchNotFound
      , '�������� ������� �� ������� ('
        || ' batchId=' || batchId
        || ').'
    );
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ��������� ������ ��������� ������� ('
          || ' batchId=' || batchId
          || ').'
        )
      , true
    );
end getBatch;

/* proc: getBatch( batchShortName)
  ���������� ������ ��������� �������.

  ���������:
  dataRec                     - ������ ��������� �������
                                ( �������)
  batchShortName              - �������� �������� ��������� �������
*/
procedure getBatch(
  dataRec out nocopy sch_batch%rowtype
  , batchShortName varchar2
)
is
begin
  select
    t.*
  into dataRec
  from
    sch_batch t
  where
    t.batch_short_name = batchShortName
  ;
exception
  when no_data_found then
    raise_application_error(
      pkg_Error.BatchNotFound
      , '�������� ������� �� ������� ('
        || ' batchShortName="' || batchShortName || '"'
        || ').'
    );
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ��������� ������ ��������� ������� ('
          || ' batchShortName="' || batchShortName || '"'
          || ').'
        )
      , true
    );
end getBatch;

/* func: getLastRootLogId
  ���������� Id ��������� ���� ���������� ������� ��������� �������.

  ���������:
  batchId                     - Id ��������� �������

  �������:
  Id ������ ��� null, ���� ��� �����������.
*/
function getLastRootLogId(
  batchId integer
)
return integer
is

  -- Id �������� ������ ����
  rootLogId integer;

begin
  select
    max( a.root_log_id)
  into rootLogId
  from
    (
    select
      t.log_id as root_log_id
    from
      v_sch_batch_root_log t
    where
      t.message_type_code = 'BSTART'
      and t.batch_id = batchId
    order by
      -- ������������� ������� ���������� � �������
      -- sch_log_ix_root_batch_date_log
      t.date_ins desc
      , t.log_id desc
    ) a
  where
    rownum <= 1
  ;
  return rootLogId;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� �������� Id ��������� ���� ������� ��������� ������� ('
        || ' batchId=' || batchId
        || ').'
      )
    , true
  );
end getLastRootLogId;

/* func: getBatchLogInfo
  ���������� ���������� �� ���� ���������� ��������� �������.

  ���������:
  batchId                     - Id ��������� �������
                                ( �� ������������, ���� ������ rootLogId)
  rootLogId                   - Id �������� ������ ����
                                ( �� ��������� ��� ���������� �������
                                  ���������� ��������� �������)

  ���������:
  - ������ ���� ����� �������� batchId ��� rootLogId, ����� �������������
    ����������;
*/
function getBatchLogInfo(
  batchId integer := null
  , rootLogId integer := null
)
return sch_batch_log_info_t
is

  -- ���������� �� ����
  lgi sch_batch_log_info_t;

  -- ���� ���� � �������������� ��������� ������ Logging
  isContextLog integer;

begin
  if batchId is null and rootLogId is null then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '������ ���� ������ Id ��������� ������� ���� Id ��������� ����.'
    );
  end if;

  lgi := sch_batch_log_info_t();
  lgi.root_log_id := rootLogId;
  if lgi.root_log_id is null then
    lgi.root_log_id := getLastRootLogId( batchId => batchId);
  end if;

  if lgi.root_log_id is not null then
    select
      count(*)
    into isContextLog
    from
      lg_log lg
    where
      lg.log_id = lgi.root_log_id
      and lg.context_type_id is not null
    ;
    if isContextLog = 1 then
      select
        min( lg.date_ins) as min_log_date
        , max( lg.date_ins) as max_log_date
        , max(
            case when
              ct.context_type_short_name = Batch_CtxTpSName
              -- ��������� ����� �������� ������
              and lg.log_id = ccl.close_log_id
            then
              lg.message_value
            end
          )
          as batch_result_id
        , sum(
            case when
                ct.context_type_short_name = Job_CtxTpSName
                and lg.open_context_flag = 0
                and lg.message_value in ( 3, 4)
              then 1
              else 0
            end
          )
          as error_job_count
        , sum(
            case when
                lg.level_code in (
                  pkg_Logging.Fatal_LevelCode
                  , pkg_Logging.Error_LevelCode
                )
              then 1
              else 0
            end
          )
          as error_count
        , sum(
            case when
                lg.level_code = pkg_Logging.Warn_LevelCode
              then 1
              else 0
            end
          )
          as warning_count
      into
        lgi.min_log_date
        , lgi.max_log_date
        , lgi.batch_result_id
        , lgi.error_job_count
        , lgi.error_count
        , lgi.warning_count
      from
        v_lg_context_change_log ccl
        inner join lg_log lg
          on lg.sessionid = ccl.sessionid
            and lg.log_id >= ccl.open_log_id
            and lg.log_id <= coalesce( ccl.close_log_id, lg.log_id)
        left join lg_context_type ct
          on ct.context_type_id = lg.context_type_id
      where
        ccl.log_id = lgi.root_log_id
      ;
    else
      select
        min( lg.date_ins) as min_log_date
        , max( lg.date_ins) as max_log_date
        , max(
            case when lg.message_type_code = 'BFINISH' and level = 2 then
              lg.message_value
            end
          )
          as batch_result_id
        , sum(
            case when lg.message_type_code = 'JFINISH'
                and lg.message_value in ( 3, 4)
                then 1 else 0
            end
          )
          as error_job_count
        , sum(
            case when lg.message_type_code = 'ERROR'
              then 1 else 0
            end
          )
          as error_count
        , sum(
            case when lg.message_type_code = 'WARNING'
              then 1 else 0
            end
          )
          as warning_count
      into
        lgi.min_log_date
        , lgi.max_log_date
        , lgi.batch_result_id
        , lgi.error_job_count
        , lgi.error_count
        , lgi.warning_count
      from
        sch_log lg
      start with
        lg.log_id = lgi.root_log_id
      connect by
        prior lg.log_id = lg.parent_log_id
      ;
    end if;
  end if;

  return lgi;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� �������� ���������� �� ���� ���������� ��������� ������� ('
        || ' batchId=' || batchId
        || ', rootLogId=' || rootLogId
        || ').'
      )
    , true
  );
end getBatchLogInfo;

end pkg_SchedulerMain;
/
