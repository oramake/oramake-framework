-- script: Install/Schema/validate-constraint.sql
-- Выполняет валидацию невалидированных ограничений целостности на таблице.
-- Валидация выполняется асинхронно в создаваемых заданиях Oracle, выполняемых
-- через dbms_scheduler.
--
-- Параметры:
-- tableName                  - имя таблицы
-- runTimeoutMinute           - время ожидания в минутах от текущего времени
--                              перед запуском задания (по умолчанию 10)
-- skipConstraintList         - список ограничений, которые не нужно
--                              валидировать (через запятую, по умолчанию
--                              таких нет)
--
-- Замечания:
--  - в случае наличия соответствующего задания, новое задание не добавляется,
--    но корректируются дата запуска существующего задания;
--

define tableName = "&1"
define runTimeoutMinute = "&2"
define skipConstraintList = "&3"



declare

  moduleName varchar2(30) := 'Logging';

  tableName varchar2(30) := '&tableName';

  startDate timestamp with time zone :=
    systimestamp
    + numtodsinterval(
        coalesce( to_number( nullif( '&runTimeoutMinute', 'null')), 10)
        , 'MINUTE'
      )
  ;

  skipConstraintList varchar2(1000) := '&skipConstraintList';

  cursor curConstraint is
    select
      a.*
      , (
        select
          count(*)
        from
          user_scheduler_jobs jb
        where
          jb.job_name = a.job_name
        )
        as job_exists_flag
    from
      (
      select
        uc.table_name
        , uc.constraint_name
        , moduleName || ':install:validate constraint: ' || uc.constraint_name
          as job_name
      from
        user_constraints uc
      where
        uc.validated = 'NOT VALIDATED'
        and uc.table_name = upper( tableName)
        and (
          skipConstraintList is null
          or instr(
              ',' || upper( skipConstraintList) || ','
              , ',' || uc.constraint_name || ','
            ) = 0
        )
      ) a
    order by
      a.table_name
      , a.constraint_name
  ;

  jobSqlTemplate varchar2(4000) :=
'
declare
  logger lg_logger_t := lg_logger_t.getLogger(
    moduleName => ''$(moduleName)''
    , objectName => ''Install/Schema/validate-constraint.sql''
  );
begin
  logger.info(
    ''Start job for validate constraint: $(constraint_name)''
    , messageLabel => trim( both ''"'' from job_name)
  );
  execute immediate
    ''alter table $(table_name) enable validate constraint $(constraint_name)''
  ;
  logger.info(''Job finished'');
exception when others then
  logger.error( ''Job finished with error: '' || logger.getErrorStack());
  raise;
end;
'
;

begin
  for rec in curConstraint loop
    if rec.job_exists_flag = 0 then
      dbms_scheduler.create_job(
        job_name      => '"' || rec.job_name || '"'
        , job_type    => 'PLSQL_BLOCK'
        , job_action  =>
            replace( replace( replace(
              jobSqlTemplate
              , '$(moduleName)', moduleName)
              , '$(table_name)', rec.table_name)
              , '$(constraint_name)', rec.constraint_name)
        , enabled     => true
        , start_date  => startDate
        , comments    => moduleName
      );
      dbms_output.put_line(
        'add job: ' || rec.job_name
        || ' (start_date: '
          || to_char( startDate, 'dd.mm.yyyy hh24:mi:ss tzh:tzm') || ')'
      );
    else
      dbms_scheduler.disable( name => rec.job_name);
      dbms_scheduler.set_attribute(
        name => rec.job_name
        , attribute => 'START_DATE'
        , value => startDate
      );
      dbms_scheduler.enable(name => rec.job_name);
      dbms_output.put_line(
        'change job start date: ' || rec.job_name
        || ' (start_date: '
          || to_char( startDate, 'dd.mm.yyyy hh24:mi:ss tzh:tzm') || ')'
      );
    end if;
  end loop;
end;
/



undefine tableName
undefine runTimeoutMinute
undefine skipConstraintList
