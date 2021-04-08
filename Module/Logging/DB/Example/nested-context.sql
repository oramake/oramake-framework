-- ������������� ���������� ��������� (������).

var testModuleName varchar2(100)

set feedback off



-- Create module for test...

declare
  testModuleId integer;
begin
  testModuleId := pkg_ModuleInfoTest.getTestModuleId(
    baseName => 'Module1'
  );
  select
    t.module_name
  into :testModuleName
  from
    v_mod_module t
  where
    t.module_id = testModuleId
  ;
  -- ���������, �.�. ���� ������ ��� ������, �� �� ����� ������� �
  -- ��� ����������� (����������� � ���������� ����������)
  commit;
end;
/



-- Create context type (lg_context_type) ...

var CalcStats_CtxTpSName varchar2(50)
var RequestId_CtxTpSName varchar2(50)

declare

  CalcStats_CtxTpSName constant varchar2(50) := 'calcStats';
  RequestId_CtxTpSName constant varchar2(50) := 'request_id';

  logger lg_logger_t := lg_logger_t.getLogger(
    moduleName    => :testModuleName
    , objectName  => 'Install/Data/Last/lg_context_type.sql'
  );

  nChanged integer := 0;

begin
  nChanged :=
    logger.mergeContextType(
        contextTypeShortName      => CalcStats_CtxTpSName
        , contextTypeName         => '������ ���������� �� ��������'
        , nestedFlag              => 1
        , contextTypeDescription  =>
'������ ���������� �� ��������. ��� �������� ��������� � message_value ����������� ����� ������� ������������ ��������'
      )
    + logger.mergeContextType(
        contextTypeShortName      => RequestId_CtxTpSName
        , contextTypeName         => '��������� �������'
        , nestedFlag              => 1
        , contextTypeDescription  =>
'��������� �������, � context_value_id ����������� Id ������� (�������� ���� request_id �� ������� tst_request)'
      )
  ;
  commit;

  :CalcStats_CtxTpSName := CalcStats_CtxTpSName;
  :RequestId_CtxTpSName := RequestId_CtxTpSName;
end;
/


-- ����� ������ � ������� ����
exec pkg_Logging.setDestination( pkg_Logging.Table_DestinationCode);


prompt
prompt Calculate statistics #1 ...
define isError = 0
define logLevel = ""

declare

  -- ������� ��������� ������ ��� ���������
  isError integer := '&isError';

  -- ����������� ���������� ������
  logLevel varchar2(100) := trim( '&logLevel');

  logger lg_logger_t := lg_logger_t.getLogger(
    moduleName    => :testModuleName
    , objectName  => 'Do/calc-stats.sql'
  );

  processedCount integer := 0;

  cursor requestCur is
    select
      t.column_value as request_id
    from
      table( pkg_Common.split('15,21,33,45,54')) t
  ;



  procedure processRequest(
    requestId integer
  )
  is
  begin
    logger.trace(
      '��������� �������: requestId='  || requestId
      , contextTypeShortName => :RequestId_CtxTpSName
      , contextValueId => requestId
      , openContextFlag => 1
    );

    -- ��������� �������...

    -- ��� ��������� ������ �� �������� ��������� ������
    if isError = 1 and requestId = 33 then
      raise_application_error(
        pkg_Error.ProcessError
        , '������������ ������'
      );
    end if;

    processedCount := processedCount + 1;

    logger.trace(
      '��������� ������� ���������'
      , contextTypeShortName => :RequestId_CtxTpSName
      , contextValueId => requestId
      , openContextFlag => 0
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ��������� ������� ('
            || 'requestId=' || requestId
            || ').'
          , closeContextTypeShortName => :RequestId_CtxTpSName
          , contextValueId            => requestId
            -- �������������� INFO, �.�. ������ ���� ������ ����� ������������
            -- ������� ����
          , levelCode                 => lg_logger_t.getInfoLevelCode()
        )
      , true
    );
  end processRequest;



-- main
begin
  logger.setLevel( logLevel);
  logger.info(
    '������ ���������� �� ��������'
    , contextTypeShortName => :CalcStats_CtxTpSName
    , openContextFlag => 1
  );
  for rec in requestCur loop
    processRequest( requestId => rec.request_id);
  end loop;
  logger.info(
    '������ ��������, ���������� ��������: ' || processedCount
    , contextTypeShortName => :CalcStats_CtxTpSName
    , openContextFlag => 0
    , messageValue => processedCount
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ������� (���������� ��������: ' || processedCount || ').'
				, logMessageFlag            => 1
        , closeContextTypeShortName => :CalcStats_CtxTpSName
        , messageValue              => processedCount
      )
    , true
  );
end;
/

prompt
prompt Calculate statistics #2 (with error) ...
define isError = 1

/

-- ��������������� ��������� ������ �� ���������
exec pkg_Logging.setDestination( null);


prompt Rows in v_lg_context_change:


select
  a.*
from
  (
  select
    cc.open_log_id
    , cc.close_log_id
    , cc.close_level_code
    , cc.close_message_value
  from
    lg_context_type ct
    inner join v_mod_module md
      on md.module_id = ct.module_id
    inner join v_lg_context_change cc
      on cc.context_type_id = ct.context_type_id
  where
    md.module_name = :testModuleName
    and ct.context_type_short_name = :CalcStats_CtxTpSName
  order by
    cc.open_log_id desc
  ) a
where
  rownum <= 2
order by
  open_log_id
/


prompt
prompt Rows in lg_log (last calculation):

column message_text format A60

select
  lg.log_id
  , lg.level_code
  , lg.message_text
  , lg.message_value
  , lg.context_level
  , lg.context_value_id
from
  v_lg_context_change_log ccl
  inner join lg_log lg
    on lg.sessionid = ccl.sessionid
      and lg.log_id >= ccl.open_log_id
      and lg.log_id <= coalesce( ccl.close_log_id, lg.log_id)
where
  ccl.log_id =
    (
    select
      max( cc.open_log_id)
    from
      lg_context_type ct
      inner join v_mod_module md
        on md.module_id = ct.module_id
      inner join v_lg_context_change cc
        on cc.context_type_id = ct.context_type_id
    where
      md.module_name = :testModuleName
      and ct.context_type_short_name = :CalcStats_CtxTpSName
    )
order by
  1
/

column message_text clear

set feedback on
