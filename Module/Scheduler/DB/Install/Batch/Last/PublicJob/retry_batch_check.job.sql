-- ��������� ������� ���������� ���������� ������ ( � ��������� ������)
declare

  leastNumber integer;

begin
  select
    max( b.retrial_count - b.retrial_number)
  into leastNumber
  from
    v_sch_batch b
  where
    b.sid = pkg_Common.GetSessionSid
    and b.serial# = pkg_Common.GetSessionSerial
  ;
  if leastNumber = 0 then
    lg_logger_t.getLogger(
        moduleName    => pkg_Scheduler.Module_Name
        , objectName  => 'PublicJob/retry_batch_check.job.sql'
      )
      .warn( '��������� ����� ������������ ��� ���������� ����������.')
    ;
  end if;
  retryBatchFlag := 1;
  jobResultMessage := '���������� ���� ���������� ���������� ������.';
end;
