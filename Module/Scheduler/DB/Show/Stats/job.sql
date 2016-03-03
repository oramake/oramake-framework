--script: Show/Stats/job.sql
--Показывает статистику по выполнению задания.
--
--Параметры:
--jobId                       - Id задания
--batchPattern                - маска для имени пакетов ( batch_short_name),
--                              по умолчанию без ограничений
--lastDayCount                - число дней ( не включая текущий), за которые
--                              показывается статистика, по умолчанию 10
--timeGroup                   - код группировки данных ( hh24 почасовая, dd 
--                              по дням), по умолчанию по дням
--                                      

define jobId = "&1"
define batchPattern = "&2"
define lastDayCount = "&3"
define timeGroup = "&4"

column tm format a30

select
  a.*
from
  (
  select
    b.tm
    , count(*) as start_count
    , round( avg( b.exec_second), 0) as avg_exec_second
    , min( b.exec_second) as min_exec_second
    , max( b.exec_second) as max_exec_second
    , min( b.batch_short_name) as min_batch_short_name
    , max( b.batch_short_name) as max_batch_short_name
    , min( b.root_log_id) as min_root_log_id
    , min( b.log_id) as min_log_id
    , max( b.log_id) as max_log_id
  from
    (
    select
      d.*
      , (
        select
          b.batch_short_name
        from
          document.sch_log lg
          inner join document.sch_batch b
            on b.batch_id = lg.message_value
        where
          lg.log_id = d.root_log_id
          and lg.message_type_code = 'BSTART'
        )
        as batch_short_name
    from
      (
      select
        lg.log_id
        , trunc( lg.date_ins, coalesce( nullif( '&timeGroup', 'null'), 'dd'))
          as tm
        , ( lg2.date_ins - lg.date_ins) * 86400
          as exec_second
        , (
          select
            t.log_id as root_log_id
          from
            document.sch_log t
          where
            t.parent_log_id is null
          start with
            t.log_id = lg.log_id
          connect by
            t.log_id = prior t.parent_log_id
          )
          as root_log_id
      from
        document.sch_log lg
        inner join document.sch_log lg2
          on lg2.parent_log_id = lg.log_id
            and lg2.message_type_code = 'JFINISH'
      where
        lg.date_ins >= trunc( sysdate)
          - coalesce( nullif( '&lastDayCount', 'null'), '10')
        and lg.message_type_code = 'JSTART'
        and lg.message_value = &jobId
      ) d
    ) b
  where
    b.batch_short_name like coalesce( '&batchPattern', '%')
  group by
    b.tm
  ) a
order by
  1
/



undefine jobId
undefine batchPattern
undefine lastDayCount
undefine timeGroup
