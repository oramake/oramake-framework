--script: Do/activate-all.sql
--���������� ������ ��� ������, ������������� deactivate-all.sql
--usedDayCount                - ������ ������, ������� ��������������� deactivate-all.sql
--					  � ��������� usedDayCount ����
--                              ( 0 ������� ����, �� ��������� null ( ���
--                              ����������� ) )


declare

  Message varchar2( 100 ) := '��������� ���� ������';

  cursor curBatch is
    select
      b.batch_id
      , b.batch_short_name
    from
      sch_batch b
    where
      (
           case when &usedDayCount is not null then
            (
            select
              max( brl.date_ins)
            from
              v_sch_batch_root_log brl
            where
              brl.batch_id = b.batch_id
              and brl.message_type_code in (
                  pkg_Scheduler.BManage_MessageTypeCode
                )
		  and brl.message_text = message
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
  if nDone = 0 then
    raise_application_error( 
      pkg_Error.IllegalArgument
      , '�� ������� ������ ��� ���������.'
    );
  end if;
  commit;
end;
/

