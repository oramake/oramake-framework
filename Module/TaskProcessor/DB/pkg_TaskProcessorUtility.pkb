create or replace package body pkg_TaskProcessorUtility is
/* package body: pkg_TaskProcessorUtility::body */

/* group: ������� */

/* func: ClearOldTask
  ������� ������ ������� � �������� ������ ��������.
  ���� �������� �������������� ������� ������������ �� ���� task_keep_day
  ������� <tp_task_type>, ����� ���������� ������������� ��������� ��������
  ���� manage_date �� <tp_task>.

  �������:
  - ����� ��������� �������
*/
function ClearOldTask
return integer
is

  cursor curTaskType is
    select
      tt.task_type_id
      , tt.task_keep_day
    from
      tp_task_type tt
    where
      tt.task_keep_day is not null
    order by
      tt.task_type_id
  ;
                                        --����� ��������� �������
  nDeleted integer := 0;

--ClearOldTask
begin
  for rec in curTaskType loop
    delete from
      tp_task ts
    where
      ts.task_type_id = rec.task_type_id
      and ts.manage_date < trunc( sysdate) - rec.task_keep_day
      and ts.task_status_code = pkg_TaskProcessorBase.Idle_TaskStatusCode
      and greatest(
          coalesce( ts.start_date, DATE '0000-01-01')
          , coalesce( ts.finish_date, DATE '0000-01-01')
        ) < trunc( sysdate) - rec.task_keep_day
    ;
    nDeleted := nDeleted + SQL%ROWCOUNT;
  end loop;
  return nDeleted;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , '������ ��� �������� ������ �������.'
    , true
  );
end ClearOldTask;

end pkg_TaskProcessorUtility;
/
