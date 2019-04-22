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

/* ivar: jobContextTypeId
  Id ���� ��������� ���������� ���� ��� �������
  ( ������������ ��������).
*/
jobContextTypeId integer;



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

/* func: getBatchLogInfo
  ���������� ���������� �� ���� ���������� ��������� �������, ������������
  �� <v_sch_batch>.

  ���������:
  batchId                     - Id ��������� �������
*/
function getBatchLogInfo(
  batchId integer
)
return sch_batch_log_info_t
is

  -- ���������� �� ����
  lgi sch_batch_log_info_t;

begin
  if batchId is null then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '������ ���� ������ Id ��������� �������.'
    );
  end if;

  if jobContextTypeId is null then
    -- max ��� ������������������ (������ ������ ����)
    select
      max( ct.context_type_id)
    into jobContextTypeId
    from
      v_mod_module md
      inner join lg_context_type ct
        on ct.module_id = md.module_id
    where
      md.svn_root = Module_SvnRoot
      and ct.context_type_short_name = Job_CtxTpSName
    ;
  end if;

  lgi := sch_batch_log_info_t();

  -- ������������ ������� ���� ���������� � �������������� ���������
  select
    max( a.start_log_id) as root_log_id
    , min( lg.date_ins) as min_log_date
    , max( lg.date_ins) as max_log_date
    , max( a.batch_result_id) as batch_result_id
    , sum(
        case when
            lg.context_type_id = jobContextTypeId
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
    lgi.root_log_id
    , lgi.min_log_date
    , lgi.max_log_date
    , lgi.batch_result_id
    , lgi.error_job_count
    , lgi.error_count
    , lgi.warning_count
  from
    (
    select
      max( bo.sessionid)
          keep( dense_rank last order by bo.start_time_utc, bo.start_log_id)
        as sessionid
      , max( bo.start_log_id)
          keep( dense_rank last order by bo.start_time_utc, bo.start_log_id)
        as start_log_id
      , max( bo.finish_log_id)
          keep( dense_rank last order by bo.start_time_utc, bo.start_log_id)
        as finish_log_id
      , max( bo.result_id)
          keep( dense_rank last order by bo.start_time_utc, bo.start_log_id)
        as batch_result_id
    from
      v_sch_batch_operation bo
    where
      bo.batch_id = batchId
      and bo.batch_operation_label = Exec_BatchMsgLabel
      and bo.execution_level = 1
    ) a
    inner join lg_log lg
      on lg.sessionid = a.sessionid
        and lg.log_id >= a.start_log_id
        and lg.log_id <= coalesce( a.finish_log_id, lg.log_id)
  ;
  return lgi;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� �������� ���������� �� ���� ���������� ��������� ������� ('
        || ' batchId=' || batchId
        || ').'
      )
    , true
  );
end getBatchLogInfo;

end pkg_SchedulerMain;
/
