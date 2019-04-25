-- ������ ��� ������� �� �������������� ������ � Id ����.
create index
  lg_log_ix_sessionid_logid
on
  lg_log (
    sessionid
    , log_id
  )
tablespace &indexTablespace
/

-- ������ ��� ������� �� ������� �����������.
create index
  lg_log_ix_log_time
on
  lg_log (
    log_time
  )
tablespace &indexTablespace
/
