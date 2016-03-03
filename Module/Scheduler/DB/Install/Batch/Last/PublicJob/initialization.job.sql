-- Инициализация
--
declare

  opt sch_batch_option_t;

  cursor optionCur is
    select
      t.*
    from
      table(
        -- явное приведение типа добавлено для совместимости с Oracle 10.2
        cast( opt.getOptionValue() as opt_option_value_table_t)
      ) t
    order by
      t.option_short_name
  ;

  -- Общее число определений
  nVar pls_integer := 0;

  -- Уровень логирования
  loggingLevelCode varchar2(10);
  sqlTraceLevel integer;
  spid varchar2(50);

begin
  opt := sch_batch_option_t( batchShortName);
  for rec in optionCur loop
    for i in 1 .. greatest( opt.getValueCount( rec.option_short_name), 1) loop
      case rec.value_type_code
        when opt_option_list_t.getDateValueTypeCode() then
          pkg_Scheduler.setContext(
            rec.option_short_name
            , opt.getDate( rec.option_short_name, valueIndex => i)
            , valueIndex => i
          );
        when opt_option_list_t.getNumberValueTypeCode() then
          pkg_Scheduler.setContext(
            rec.option_short_name
            , opt.getNumber( rec.option_short_name, valueIndex => i)
            , valueIndex => i
          );
          if rec.option_short_name = 'SqlTraceLevel' then
            sqlTraceLevel := rec.number_value;
          end if;
        when opt_option_list_t.getStringValueTypeCode() then
          pkg_Scheduler.setContext(
            rec.option_short_name
            , opt.getString( rec.option_short_name, valueIndex => i)
            , valueIndex => i
            , encryptedValue => rec.encrypted_string_value
          );
          if rec.option_short_name = 'LoggingLevelCode' then
            loggingLevelCode := rec.string_value;
          end if;
      end case;
    end loop;
    nVar := nVar + 1;
  end loop;
  if loggingLevelCode is not null then
    execute immediate
      'begin lg_logger_t.getRootLogger().setLevel( :levelCode); end;'
    using
      in loggingLevelCode
    ;
  end if;
  if sqlTraceLevel is not null then
    execute immediate
'alter session set events ''10046 trace name context forever, level '
|| sqlTraceLevel || ''''
    ;
    execute immediate '
select
  pr.spid
from
  v$session ss
  inner join v$process pr
    on pr.addr = ss.paddr
where
  ss.sid = :sid
'
    into spid
    using in pkg_Common.getSessionSid()
    ;
  end if;
  jobResultMessage :=
    'Загружены значения переменных ( ' || nVar || ' штук)'
    || '; сессия sid=' || pkg_Common.getSessionSid()
    || ', serial#=' || pkg_Common.getSessionSerial()
    || case when spid is not null then
        '; включена трассировка spid=' || spid
      end
  ;
end;
