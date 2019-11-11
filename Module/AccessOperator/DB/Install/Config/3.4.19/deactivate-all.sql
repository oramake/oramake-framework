--script: deactivate-all.sql
--������������ ��� �������� ����� � ���������� ��������� �� ��������� � ���
--���������:
-- - � ������ ������ commit �� ����������� � �� ���� ����� �� ��������������;
-- - ��� ����������� ������������� ��������� ���������� ������� ���������;
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
  
  nDone integer := 0;
                                       
  Message varchar2( 100 ) := '��������� ���� ������';
  
begin
  for rec in curBatch loop
    pkg_Scheduler.DeactivateBatch( 
      batchID => rec.batch_id
      , operatorID => 1
    );
    dbms_output.put_line( 
      rpad( rec.batch_short_name, 30)
      || ' ( batch_id =' || lpad( rec.batch_id, 3)
      || ')   - deactivated');
    pkg_Scheduler.WriteLog(
      messageTypeCode => pkg_Scheduler.BMANAGE_MESSAGETYPECODE
      , messageText   => Message
      , messageValue  => rec.batch_ID
      , operatorID    => 1
    );
    nDone := nDone + 1;
  end loop;
  dbms_output.put_line( '�������������� �������: ' || to_char( nDone));
  commit;
  -- ���� 30 ���, ����� ������ ���� ������
  dbms_lock.sleep( 30);
exception when others then dbms_output.put_line(SQLERRM);  
end;
/
