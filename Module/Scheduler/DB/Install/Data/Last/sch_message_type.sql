begin
merge into
  sch_message_type d
using
  (
  select
    pkg_Scheduler.BManage_MessageTypeCode as message_type_code
    , 'Управление пакетом' as message_type_name_rus
    , 'Manage batch' as message_type_name_eng
  from dual
  union all select
    pkg_Scheduler.BStart_MessageTypeCode
    , 'Старт пакета'
    , 'Start batch'
  from dual
  union all select
    pkg_Scheduler.BFinish_MessageTypeCode
    , 'Завершение пакета'
    , 'Finish'
  from dual
  union all select
    pkg_Scheduler.JStart_MessageTypeCode
    , 'Старт задания'
    , 'Start job'
  from dual
  union all select
    pkg_Scheduler.JFinish_MessageTypeCode
    , 'Завершение задания'
    , 'Finish'
  from dual
  -- записи с
  --  pkg_Scheduler.Error_MessageTypeCode
  --  pkg_Scheduler.Warning_MessageTypeCode
  --  pkg_Scheduler.Info_MessageTypeCode
  --  pkg_Scheduler.Debug_MessageTypeCode
  -- добавляются в модуле Logging
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
