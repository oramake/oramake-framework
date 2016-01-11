begin
merge into
  tp_file_status d
using
  (
  select
    pkg_TaskProcessorBase.Loading_FileStatusCode as file_status_code
    , '�������� ������...' as file_status_name
  from dual
  union all select
    pkg_TaskProcessorBase.Loaded_FileStatusCode
    , '������ ��������� ( �� ����������)'
  from dual
  union all select
    pkg_TaskProcessorBase.Processing_FileStatusCode
    , '��������� ������...'
  from dual
  union all select
    pkg_TaskProcessorBase.Processed_FileStatusCode
    , '������ ����������'
  from dual
  minus
  select
    t.file_status_code
    , t.file_status_name
  from
    tp_file_status t
  ) s
on
  (
  d.file_status_code = s.file_status_code
  )
when not matched then insert
  (
  file_status_code
  , file_status_name
  )
values
  (
  s.file_status_code
  , s.file_status_name
  )
when matched then update set
  d.file_status_name            = s.file_status_name
;
  dbms_output.put_line( 'changed: ' || SQL%ROWCOUNT);
  commit;
end;
/
