--script: Do/activate.sql
--���������� �������� �������� ��������� ( ����������� ����� Scheduler).
--
--���������:
--batchPattern                - ����� ��� ����� ������� ( batch_short_name),
--                              �� ��������� ����� ( "%")
--usedDayCount                - ������ ������, ������� ����������� ���
--                              ����������� � ��������� usedDayCount ����
--                              ( �� ��������� ���� �� ������ batchPattern,
--                              �� 0 ( ������� ����), ����� null ( ���
--                              �����������))
--
--���������:
-- - � ������ ������ commit �� ����������� � �� ���� ����� �� ������������;

define batchPattern = "coalesce( '&1', '%')"
define usedDayCount = "nullif( coalesce( '&2', case when nullif( &batchPattern, '%') is null then '0' end), 'null')"

define batchTypeNameRus = "�������� ���������"



declare

  cursor curBatch is
    select
      b.batch_id
      , b.batch_short_name
    from
      sch_batch b
    where
      b.batch_type_id =
        (
        select
          bt.batch_type_id
        from
          sch_batch_type bt
        where
          bt.batch_type_name_rus = '&batchTypeNameRus'
        )
      and (
        b.oracle_job_id is null
        and b.batch_short_name like &batchPattern
        and case when &usedDayCount is not null then
            (
            select
              max( brl.date_ins)
            from
              v_sch_batch_root_log brl
            where
              brl.batch_id = b.batch_id
              and brl.message_type_code in (
                  pkg_Scheduler.BStart_MessageTypeCode
                  , pkg_Scheduler.BManage_MessageTypeCode
                )
            )
            + &usedDayCount
          else
            sysdate
          end
          >= trunc( sysdate)
      )
    order by
      b.batch_short_name
  ;  
  
  nDone integer := 0;

begin
  for rec in curBatch loop
    pkg_Scheduler.ActivateBatch( 
      batchID => rec.batch_id
      , operatorID => pkg_Operator.GetCurrentUserID()
    );
    dbms_output.put_line( 
      rpad( rec.batch_short_name, 30)
      || ' ( batch_id =' || lpad( rec.batch_id, 3)
      || ')   - activated');
    nDone := nDone + 1;
  end loop;
  dbms_output.put_line( '������������ �������: ' || to_char( nDone));
  commit;
end;
/



undefine batchTypeNameRus

undefine batchPattern
undefine usedDayCount
