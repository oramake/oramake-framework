-- script: Install/Schema/add-install-job.sql
-- ��������� ������� Oracle ��� ����������� ���������� ���������� �����
-- ���������.
--
-- ���������:
-- jobShortName               - ���������� �������� ��� �������
-- runTimeoutMinute           - ����� �������� � ������� �� �������� �������
--                              ����� �������� ������� ( �� ��������� 15)
-- jobText                    - ���������� PL/SQL ���� � ����� �������
--
-- ���������:
--   - � ������ ��������� ���������� PL/SQL ����� � ������� ����������� commit,
--     ��� ������ ����������� rollback � ������������� ���������� ( �������
--     ����� ������������ �� ����������� ����� ����������� � Oracle);
--   - � ������ ������� ���������������� �������, ����� ������� �� �����������
--     � �������������� ����� � ���� ������� ������������� �������;
--   - �������� jobText ����� ���������� � ������� bind-����������, ��������
--     ��� ������� �������� ���� "' || :bindVar || '";
--   - � ����������� PL/SQL ����� �������� ���������� job ( Id ������� ��
--     user_jobs) � next_date ( ���� ���������� �������, �� ��������� ��
--     ���������, ����� ���� �����������), ��������������� dbms_job;
--


define jobShortName = "&1"
define runTimeoutMinute = "&2"
define jobText = "&3"



declare

  jobShortName varchar2(200) := '&jobShortName';

  startDate date :=
    sysdate
    + coalesce(
        to_number( nullif( '&runTimeoutMinute', 'null'))
        , 15
      )
      / 24 / 60
  ;

  jobPrefix varchar2(200) :=
    '-- JobName: Oracle/Module/Logging: Install: ' || jobShortName || chr(10)
  ;

  fullJobText varchar2(32767) :=
jobPrefix ||
'begin
' || '&jobText' || '
  commit;
end;'
  ;

  jobNumber integer;
  jobCount integer;

begin
  select
    max( jb.job)
    , count(*)
  into jobNumber, jobCount
  from
    user_jobs jb
  where
    jb.what like jobPrefix || '%'
  ;
  if jobCount > 1 then
    raise_application_error(
      pkg_Error.ProcessError
      , 'Several existing jobs were found by name ('
        || ' jobShortName="' || jobShortName || '"'
        || ', jobCount: ' || to_char( jobCount)
        || ').'
    );
  end if;
  dbms_output.put(
    jobShortName || ':'
  );
  if jobNumber is null then
    dbms_job.submit(
      job           => jobNumber
      , what        => fullJobText
      , next_date   => startDate
    );
    dbms_output.put_line(
      ' add job: ' || jobNumber
      || ' ( next_date: '
        || to_char( startDate, 'dd.mm.yyyy hh24:mi:ss') || ')'
    );
  else
    dbms_job.change(
      job           => jobNumber
      , what        => fullJobText
      , next_date   => startDate
      , interval    => null
    );
    dbms_output.put_line(
      ' change exist job: ' || jobNumber
      || ' ( next_date: '
        || to_char( startDate, 'dd.mm.yyyy hh24:mi:ss') || ')'
    );
  end if;
  commit;
end;
/



undefine jobShortName
undefine runTimeoutMinute
undefine jobText
