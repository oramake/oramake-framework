create or replace package body pkg_Calendar is
/* package body: pkg_Calendar(UserDb)::body */



/* group: ���������� */

/* ivar: logger
  ����� ������.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => pkg_Calendar.Module_Name
  , objectName  => 'pkg_Calendar'
);


/* ivar: sourceDbLink
  DB-���� � ���������.
*/
sourceDbLink varchar2(100) := null;



/* group: ������� */

/* iproc: getSourceDbLink
  ��������� �������� ����� sourceDbLink, ���� ��� �� ������.
*/
procedure getSourceDbLink
is
-- getSourceDbLink
begin
  if sourceDbLink is null then
    sourceDbLink :=
      opt_option_list_t(
        moduleName => Module_Name
      ).getOptionString( SourceDbLink_OptionName)
    ;
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��������� �������� DB-����� � ���������'
      )
    , true
  );
end getSourceDbLink;

/* func: isWorkingDay
  ����������, �������� �� ��������� ���� �������.

  ���������:
  forDate                     - �������� ����
*/
function isWorkingDay(
  forDate date
)
return integer
is

                                        --������� �������� ���
  isWorking integer;

  --FillMessageBase
begin
  getSourceDbLink();
  execute immediate '
begin
  :isWorking := pkg_Calendar.isWorkingDay@'
    || sourceDbLink
    || '(
      :forDate
  );
end;
'
  using
    out isWorking
    , in forDate
  ;
  return isWorking;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , '������ ��� ����������� �������� ��� ('
      || ' forDate={' || to_char( forDate, 'dd.mm.yyyy hh24:mi:ss')
      || ').'
    , true
  );
end isWorkingDay;

/* func: getLastWorkingDay
  ���������� ��������� ������� ���� ��� ��������� ����.

   ���������:
   forDate                    - ��������� ���� ( ������������)
*/
function getLastWorkingDay(
  forDate date
)
return date
is

                                        --��������� ������� ����
  lastWorkingDay date;

  --FillMessageBase
begin
  getSourceDbLink();
  execute immediate '
begin
  :lastWorkingDay := pkg_Calendar.getLastWorkingDay@'
    || sourceDbLink

    || '(
      :forDate
  );
end;
'
  using
    out lastWorkingDay
    , in forDate
  ;
  return lastWorkingDay;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , '������ ��� ����������� ���������� �������� ��� ('
      || ' forDate={' || to_char( forDate, 'dd.mm.yyyy hh24:mi:ss') || '}'
      || ').'
    , true
  );
end getLastWorkingDay;

/* func: getNextWorkingDay
   ���������� ��������� ������� ���� ��� ��������� ����.

   ���������:
     forDate                   - ��������� ���� ( ������������)
*/
function getNextWorkingDay (
  forDate in date
  )
return date
is
  -- ��������� ������� ����
  nextWorkingDay date;

-- getNextWorkingDay
begin
  getSourceDbLink();
  execute immediate '
    begin
      :nextWorkingDay := pkg_Calendar.getNextWorkingDay@'
        || sourceDbLink
        || '( :forDate );
    end;'
    using out nextWorkingDay
        , in forDate
  ;
  return nextWorkingDay;

exception
  when others then
    raise_application_error(
        pkg_Error.ErrorStackInfo
      , '������ ��� ����������� ���������� �������� ��� ('
          || ' forDate="' || to_char( forDate, 'dd.mm.yyyy' ) || '"'
          || ').'
      , true
      );

end getNextWorkingDay;

/* func: getPeriodWorkingDayAmount
  ������� ���������� ���-�� ������� ���� � ��������� �������.

  ���������:
  beginDate                   - ���� ������ �������
  endDdate                    - ���� ����� �������

  �������:
   - ���-�� ������� ���� �������;
*/
function getPeriodWorkingDayAmount
(
    beginDate date
  , endDate   date
)
return integer
is
  -- ���������� ������� ���� �������
  periodWorkDayAmount integer;
begin
  getSourceDbLink();
  execute immediate '
    begin
      :periodWorkDayAmount := pkg_Calendar.getPeriodWorkingDayAmount@'
        || sourceDbLink
        || '( :beginDate, :endDate );
    end;'
  using
    out periodWorkDayAmount
    , in beginDate
    , in endDate
  ;
  return
    periodWorkDayAmount
  ;
end getPeriodWorkingDayAmount;

end pkg_Calendar;
/
