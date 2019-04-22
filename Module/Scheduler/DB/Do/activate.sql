--script: Do/activate.sql
--���������� ������.
--
--���������:
--batchPattern                - ����� ��� ����� ������� ( batch_short_name),
--                              �� ��������� ����� ( "%")
--batchTypePattern            - ����� ��� ���� ������� ( batch_type_name),
--                              �� ��������� ����� ( "%")
--usedDayCount                - ������ ������, ������� ����������� ���
--                              ����������� � ��������� usedDayCount ����
--                              ( 0 ������� ����, �� ��������� null ( ���
--                              �����������))
--
--���������:
--  - � ������ ������ commit �� ����������� � �� ���� ����� �� ������������;
--  - � ������, ���� ����� ��� �����������, ����� ���������� ������� �����
--    ������������� �� ���������� � ������� ����� ������� ( ���� ����) �����
--    �������;
--

define batchPattern     = "&1"
define batchTypePattern = "&2"
define usedDayCount     = "&3"




declare

  batchPattern varchar2(255) := coalesce( '&batchPattern', '%');
  batchTypePattern varchar2(255) := coalesce( '&batchTypePattern', '%');
  usedDayCount number := to_number( '&usedDayCount');

  cursor curBatch is
    select
      b.batch_id
      , b.batch_name_rus
      , b.batch_short_name
      , b.oracle_job_id
      , b.next_date
    from
      v_sch_batch b
    where
      b.batch_type_id in
        (
        select
          bt.batch_type_id
        from
          sch_batch_type bt
        where
          bt.batch_type_name_rus like batchTypePattern
        )
      and b.batch_short_name like batchPattern
      and (
        usedDayCount is null
        or exists
          (
          select
            null
          from
            v_sch_batch_operation bo
          where
            bo.batch_id = b.batch_id
            and bo.start_time_utc >=
              sys_extract_utc(
                to_timestamp_tz(
                  to_char( systimestamp, 'dd.mm.yyyy tzh:tzm')
                  , 'dd.mm.yyyy tzh:tzm'
                )
                - numtodsinterval( usedDayCount, 'DAY')
              )
          )
        )
    order by
      b.batch_short_name
  ;

  -- ����� �������
  logger lg_logger_t := lg_logger_t.getLogger(
    moduleName    => pkg_Scheduler.Module_Name
    , objectName  => 'Do/activate.sql'
  );

  -- Id ���������, �� ����� �������� ����������� ��������
  operatorId integer := pkg_Operator.getCurrentUserId();


  nChecked integer := 0;

  nDone integer := 0;

begin
  for rec in curBatch loop
    nChecked := nChecked + 1;
    if rec.oracle_job_id is null then
      pkg_Scheduler.activateBatch(
        batchId       => rec.batch_id
        , operatorId  => operatorId
      );
      nDone := nDone + 1;
    else
      logger.info(
        '����� ��� ��� �����������: "'
        || rec.batch_name_rus || '" [' || rec.batch_short_name ||  ']'
        || ' ( batch_id=' || rec.batch_id
        || ', ���� ������� '
          || to_char( rec.next_date, 'dd.mm.yyyy hh24:mi:ss')
        || ').'
      );
    end if;
  end loop;
  if nChecked = 0 then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '�� ������� ������ ��� ���������.'
    );
  end if;
  commit;
end;
/



undefine batchPattern
undefine batchTypePattern
undefine usedDayCount
