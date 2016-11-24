create or replace package body pkg_Calendar
as
/* package body: pkg_Calendar::body */



/* group: ���������� */

/* ivar: logger
   ����� ������.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName  => Module_Name
  , objectName => 'pkg_Calendar'
);



/* group: ������� */

/* func: isHoliday
  ���������, �������� �� ��������� ���� ���������� ��� ��������.

  ���������:
    day                     - ����, ������� ����� ���������

  �������:
    1                       - ���� �������� �������� ��� ����������
    0                       - ���� �������� �������
*/
function isHoliday (
  day                       in date
)
return integer
is
  dayTypeId                 integer;
  dayOfWeek                 integer;

begin
  select
    day_type_id
  into
    dayTypeId
  from
    v_cdr_day d
  where
    d.day = trunc( isHoliday.day );

  if dayTypeId != WorkingDay_DayTypeId then
    return 1;
  else
    return 0;
  end if;

exception
  when no_data_found then
    -- ���������� ���������� ���� ������
    dayOfWeek := to_char( day, 'D' );
    if (dayOfWeek = 6 or dayOfWeek = 7) then
      return 1;
    else
      return 0;
    end if;

end isHoliday;

/* func: isWorkingDay
  ���������, �������� �� ��������� ���� �������.

  ���������:
    day                     - ����, ������� ����� ���������

  �������:
    1                       - ���� �������� �������� ��� ����������
    0                       - ���� �������� �������
*/
function isWorkingDay (
  day                       in date
)
return integer
is
  result                    integer;

begin
  if isHoliday( day ) = 1 then
    return 0;
  else
    return 1;
  end if;

end isWorkingDay;

/* func: getLastWorkingDay
  ���������� ���������� ������� ����, ������� � �������� ����.

  ���������:
    day                     - ����, ������� � ������� ����� ������ ���������� ������� ����

  �������:
    - ���� ����������� �������� ���
*/
function getLastWorkingDay (
  day                       in date
)
return date
is
  result                    date;
begin
  result := trunc( day );

  while isHoliday( result ) = 1
  loop
    result := result - 1;
  end loop;

  return result;

end getLastWorkingDay;

/* func: getNextWorkingDay
  ���������� ��������� ������� ����, ������� � �������� ����.

  ���������:
    day                     - ����, ������� � ������� ����� ������ ��������� ������� ����

  �������:
    - ���� ���������� �������� ���
*/
function getNextWorkingDay (
  day                       in date
)
return date
is
  result                    date;

begin
  result := trunc( day );

  while isHoliday( result ) = 1
  loop
    result := result + 1;
  end loop;

  return result;

end getNextWorkingDay;

/* func: getWeekWorkingDayAmount
  ���������� ���-�� ������� ���� � ������.

  ���������:
    beginDay                - ������ ���� ������

  �������:
    - ���-�� ������� ���� � ������, ������� � ��������� ����
*/
function getWeekWorkingDayAmount (
  beginDay                  in date
)
return integer
is
  weekWorkDayAmount         integer := 0;

begin
  for i in 0..6
  loop
    if isHoliday( beginDay + i ) != 1 then
      weekWorkDayAmount := weekWorkDayAmount + 1;
    end if;
  end loop;

  return weekWorkDayAmount;

end getWeekWorkingDayAmount;

/* func: getPeriodWorkingDayAmount
  ���������� ���-�� ������� ���� � ��������� �������.

  ���������:
    beginDate               - ���� ������ �������
    endDdate                - ���� ����� �������

  �������:
    - ���-�� ������� ���� �������
*/
function getPeriodWorkingDayAmount (
  beginDate                 in date
, endDate                   in date
)
return integer
is
  periodWorkDayAmount       integer := 0;

begin

  for i in 0..endDate-beginDate
  loop
    if isHoliday( beginDate + i ) != 1 then
      periodWorkDayAmount := periodWorkDayAmount + 1;
    end if;
  end loop;

  return periodWorkDayAmount;

end getPeriodWorkingDayAmount;

end pkg_Calendar;
/
