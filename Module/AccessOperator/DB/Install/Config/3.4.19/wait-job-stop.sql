prompt * Waiting job stop...

timing start

declare
                                        --������������ ����� �������� � ��������
  maxWaitSecond constant integer := 10;
                                        --����� ���������� ��������
  limitDate date := sysdate + maxWaitSecond / 86400;
                                        --����� job-��
  jr integer;

begin
  loop
    select
      count(*)
    into 
      jr
    from
      dba_jobs_running ss
    ;
    exit when jr = 0 or sysdate >= limitDate;
    dbms_lock.sleep( 1);
  end loop;
end;
/

timing stop