-- script: oms-check-lock.sql
-- Проверяет наличие блокировок на указанные объекты и в случае их наличия
-- выбрасывает исключение.
--
-- Параметры:
-- objectList                 - список имен проверяемых объектов ( через пробел)
--                              с добавлением стандартных расширений,
--                              указывающих тип объекта ( %.pks %.pkb %.prc
--                              %.snp %.tab %typ %tyb %.vw) либо без расширения
--                              ( проверка без учета типа)
--
-- Замечания:
--  - скрипт используется внутри OMS;
--  - для выполнения проверки используются представления dba_ddl_locks,
--    dba_jobs_running и v$session, при отсутствии доступа к которым проверка
--    не производится ( выводится предупреждение);
--  - при проверке учитываются только блокировки, принадлежащие пользователю,
--    соответствующему текущей схеме;
--  - для проверки блокировок, принадлежащих другому пользователю, нужно
--    перед вызовом скрипта установить текущую схему с помощью команды
--    "alter session set current_schema=<anotherUserName>";
--

define objectList = "&1"

-- Sessions blocking objects
var rc refcursor

declare

  objectList constant varchar2(4000) := '&objectList';

  emptyRefCursor sys_refcursor;

  sqlText constant varchar2(4000) := '
select
  d.sid
  , d.serial#
  , d.logon_time
  $(getBatchShortNameText)
  , d.oracle_job_id
  , d.lock_object_name
  , d.lock_count
from
  (
  select
    ss.sid
    , ss.serial#
    , ss.logon_time
    , a.*
    , (
      select
        jr.job
      from
        dba_jobs_running jr
      where
        jr.sid = ss.sid
      ) as oracle_job_id
  from
    (
    select
      b.session_id
      , min( b.name) keep(
          dense_rank first
          order by
            b.priority_order
            , b.name
        )
        as lock_object_name
      , count(*) as lock_count
    from
      (
      select
        lc.*
        , case lc.type
            when ''Body'' then 99
            when ''Table/Procedure/Type'' then 1
            when ''Trigger'' then 2
            else 10
          end
          as priority_order
        , case lc.type
            when ''Body'' then ''.pkb''
            when ''Table/Procedure/Type'' then ''.tab''
            when ''Trigger'' then ''.trg''
          end
          as file_extension
        , upper(
            replace( replace( replace( replace( replace( replace(
              '' '' || :objectList || '' ''
              , ''.pks '' , ''.tab '')
              , ''.prc '' , ''.tab '')
              , ''.snp '' , ''.tab '')
              , ''.typ '' , ''.tab '')
              , ''.tyb '' , ''.pkb '')
              , ''.vw '' , ''.tab '')
          )
          as check_object_list
      from
        dba_ddl_locks lc
      where
        lc.owner = sys_context( ''USERENV'', ''CURRENT_SCHEMA'')
      ) b
    where
      -- object of this type
      instr(
          b.check_object_list
          , upper( '' '' || b.name || b.file_extension || '' '')
        ) > 0
      -- object name without type
      or instr(
          b.check_object_list
          , upper( '' '' || b.name || '' '')
        ) > 0
    group by
      b.session_id
    ) a
    inner join v$session ss
      on ss.sid = a.session_id
  where
    ss.status <> ''INACTIVE''
    and ss.sid <> sys_context( ''USERENV'',''SID'')
  ) d
order by
  d.logon_time
  , d.sid
  , d.serial#
'
  ;

getBatchShortNameText varchar2( 1000) :='
  , (
    select
      bt.batch_short_name
    from
      $(schSchema).sch_batch bt
    where
      bt.oracle_job_id = d.oracle_job_id
    )
    as batch_short_name
'
  ;

  schSchema varchar2( 100);

begin

  -- Get scheme of installation Scheduler module
  select
    max( tb.owner) as sch_schema
  into schSchema
  from
    all_tables tb
  where
    tb.table_name = 'SCH_BATCH'
  ;

  open :rc for
    replace( sqlText, '$(getBatchShortNameText)'
      , case when schSchema is not null then
          replace( getBatchShortNameText, '$(schSchema)', schSchema)
        else
          '--'
        end
    )
  using
    objectList
  ;
exception when others then
  open :rc for select * from dual where null is not null;
  if SQLCODE = -942 then
    dbms_output.put_line(
      'Warning: Tables for check lock not accessable, check skipped.'
    );
  else
    raise;
  end if;
end;
/

-- Throw an exception if locks are found
define lockSessionSid = ""
column sid new_value lockSessionSid
print rc
column sid clear


declare
  lockSessionSid varchar2( 100) := trim( '&lockSessionSid');
begin
  if lockSessionSid is not null then
    raise_application_error(
      -20185
      , 'Found locks on installing objects.'
    );
  end if;
end;
/



undefine lockSessionSid
undefine objectList
