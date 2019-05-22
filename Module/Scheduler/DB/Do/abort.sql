--script: Do/abort.sql
--��������� ���������� ������ � ������������� ���� ���������� ������� ��������
--���������� ( �� �������� �������).
--
--���������:
--batchPattern                - ����� ��� ����� ������� ( batch_short_name)
--
--���������:
-- - ��� ���������� ������� ������ ����������� commit;

define batchPattern = "&1"



declare

  cursor curBatch is
    select
      b.batch_id
      , b.batch_short_name
    from
      v_sch_batch b
    where
      b.activated_flag = 1
      and b.sid is not null
      and b.batch_short_name like '&batchPattern'
    order by
      b.batch_short_name
  ;

  nDone integer := 0;

begin
  for rec in curBatch loop
    pkg_Scheduler.AbortBatch(
      batchID => rec.batch_id
      , operatorID => pkg_Operator.GetCurrentUserID()
    );
    dbms_output.put_line(
      rpad( rec.batch_short_name, 30)
      || ' ( batch_id =' || lpad( rec.batch_id, 3)
      || ')   - aborted'
    );
    nDone := nDone + 1;
  end loop;
  if nDone = 0 then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '������ �� �������.'
    );
  end if;
end;
/



undefine batchPattern
