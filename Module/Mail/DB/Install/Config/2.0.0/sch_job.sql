-- ����� ���� � Scheduler 4.3.4.x: � ��������� pkg_SchedulerLoad.loadJob
-- �� ����������� �������� public_flag � ������ ( ��������, ���� �����������
-- ������� ���� � ������ �� ������ ���������� �����)
--

update
  sch_job jb
set
  jb.batch_short_name = null
  , jb.public_flag = 1
where
  jb.public_flag = 0
  and jb.module_id =
    (
    select
      md.module_id
    from
      v_mod_module md
    where
      md.module_name = 'Mail'
    )
  and jb.job_short_name in (
    'fetch_mail_handler'
    , 'send_mail_handler'
  )
  and jb.batch_short_name in (
    'FetchMailHandler'
    , 'SendMailHandler'
  )
/

commit
/
