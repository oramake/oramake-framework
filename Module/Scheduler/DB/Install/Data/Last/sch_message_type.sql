begin
merge into
  sch_message_type d
using
  (
  select
    pkg_Scheduler.BManage_MessageTypeCode as message_type_code
    , '���������� �������' as message_type_name_rus
    , 'Manage batch' as message_type_name_eng
  from dual
  union all select
    pkg_Scheduler.BStart_MessageTypeCode
    , '����� ������'
    , 'Start batch'
  from dual
  union all select
    pkg_Scheduler.BFinish_MessageTypeCode
    , '���������� ������'
    , 'Finish'
  from dual
  union all select
    pkg_Scheduler.JStart_MessageTypeCode
    , '����� �������'
    , 'Start job'
  from dual
  union all select
    pkg_Scheduler.JFinish_MessageTypeCode
    , '���������� �������'
    , 'Finish'
  from dual
  -- ������ �
  --  pkg_Scheduler.Error_MessageTypeCode
  --  pkg_Scheduler.Warning_MessageTypeCode
  --  pkg_Scheduler.Info_MessageTypeCode
  --  pkg_Scheduler.Debug_MessageTypeCode
  -- ����������� � ������ Logging
  ) s
on
  (
  d.message_type_code = s.message_type_code
  )
when not matched then insert
  (
  message_type_code
  , message_type_name_rus
  , message_type_name_eng
  )
values
  (
  s.message_type_code
  , s.message_type_name_rus
  , s.message_type_name_eng
  )
when matched then update set
  d.message_type_name_rus         = s.message_type_name_rus
  , d.message_type_name_eng       = s.message_type_name_eng
;
commit;
end;
/
