-- �������� ����������� ���������� ���������� ������
declare
  
  leastNumber integer;
  
begin
  select
    max( b.retrial_count - coalesce( b.retrial_number, 0))
  into leastNumber
  from
    v_sch_batch b
  where
    b.sid = pkg_Common.GetSessionSid
    and b.serial# = pkg_Common.GetSessionSerial
  ;
  if leastNumber > 0 then
    jobResultMessage :=
      '��������� ��������� ������ �������� ('
      || ' �������� �������: ' || to_char( leastNumber)
      || ').'
    ;
  else
    jobResultId := pkg_Scheduler.False_ResultId;
    jobResultMessage :=
      case when leastNumber is null then
        '��� ������� ��� ���������� ���������� ������.'
      else
        '��������� ����� ������� ���������� ���������� ������.'
      end
    ;
  end if;
end;
