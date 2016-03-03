-- script: Do/deactivate-all.sql
-- ������������ ��� �������� ����� � ���������� ��������� �� ��������� � ���.
--
-- ���������:
--  - � ������ ������ commit �� ����������� � �� ���� ����� �� ��������������;
--  - � ������ ������ ��� ��������� Id �������� ������������������� ���������
--    ����������� ����������� �� ����� ��������� � operator_id=1;
--

declare

  cursor curBatch is
    select
      b.batch_id
      , b.batch_short_name
    from
      sch_batch b
    where
      oracle_job_id is not null
    order by
      b.batch_short_name
  ;

  message varchar2( 100) := '��������� ���� ������';

  -- Id ���������, �� ����� �������� ����������� �����������
  operatorId integer;

  nDone integer := 0;

begin
  begin
    operatorId := pkg_Operator.getCurrentUserId();
  exception when others then
    operatorId := 1;
    dbms_output.put_line(
      'Use default operator_id: ' || operatorId
    );
  end;

  for rec in curBatch loop
    pkg_Scheduler.deactivateBatch(
      batchId       => rec.batch_id
      , operatorId  => operatorId
    );
    dbms_output.put_line(
      rpad( rec.batch_short_name, 30)
      || ' ( batch_id =' || lpad( rec.batch_id, 3)
      || ')   - deactivated'
    );
    pkg_Scheduler.writeLog(
      messageTypeCode => pkg_Scheduler.BManage_MessageTypeCode
      , messageText   => message
      , messageValue  => rec.batch_Id
      , operatorId    => operatorId
    );
    nDone := nDone + 1;
  end loop;
  dbms_output.put_line( 'Batches deactivated: ' || nDone);
  commit;
end;
/
