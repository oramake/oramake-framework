-- Тест генерации исторической структуры
--
-- Макропеременные:
-- outputPath                        - путь для выгрузки
--


begin
  if '&outputPath' is null then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Please, define outputPath!'
    );
  end if;
end;
/

prompt * outputPath=&outputPath

begin
  execute immediate 'drop table t';
exception when others then
  pkg_Common.outputMessage( '* ok: ' || sqlerrm);
end;
/



@oms-set-indexTablespace.sql

create table t(
  action_job_id                   integer                             not null
  , action_code                   varchar2(5)                         not null
  , criteria_code                 varchar2(10)                        not null
  , is_cross_send                 number(1,0)                         not null
  , recommended_count_from        integer
  , recommended_count_to          integer
  , recommended_count_divisor     integer
  , max_client_count              integer
  , job_end_date                  date                                not null
  , is_sms_notification           integer
  , partner_id                    integer
  , project_name                  varchar2(50)
  , deleted                       number(1)           default 0       not null
  , change_number                 integer             default 1       not null
  , change_date                   date                default sysdate not null
  , change_operator_id            integer                             not null
  , date_ins                      date                default sysdate not null
  , operator_id                   integer                             not null
  , constraint t_pk primary key
    ( action_job_id)
    using index tablespace &indexTablespace
  , constraint g_ck_is_sms_not check
    ( is_sms_notification in ( 0, 1))
  , constraint g_ck_action_code check
    ( length( action_code) = 5)
  , constraint g_ck_deleted check
    ( deleted in ( 0, 1))
  , constraint g_ck_change_num check
    ( change_number >= 1)
  , constraint g_ck_is_cross_send check
    ( is_cross_send in ( 0, 1))
)
/

declare
  outPath varchar2(1000) := '&outputPath';
  tableName varchar2(30) := 't';
  moduleName varchar2(30) := 'ScriptUtility';
  tableComment varchar2(30) := 'Тестовая таблица';
  svnRoot varchar2(30) := 'Oracle/Module/ScriptUtility';
begin
  pkg_ScriptUtility.GenerateHistoryStructure(
    tableName => tableName
    , outputFilePath => outPath
    , moduleName => moduleName
    , tableComment => tableComment
    , svnRoot => svnRoot
  );
end;
/

drop table t
/

prompt * please, check the scripts in "&outputPath"


