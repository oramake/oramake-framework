create or replace package body pkg_Calendar
as
/* package body: pkg_Calendar::body */



/* group: ѕеременные */

/* ivar: logger
   Ћогер пакета.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName  => Module_Name
  , objectName => 'pkg_Calendar'
);



/* group: ‘ункции */

/* func: isHoliday
  ѕровер€ет, €вл€етс€ ли указанный день праздником или выходным.

  ѕараметры:
    day                     - дата, которую нужно проверить

  ¬озврат:
    1                       - день €вл€етс€ выходным или праздником
    0                       - день €вл€етс€ рабочим
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
    -- определ€ем пор€дковый день недели
    dayOfWeek := to_char( day, 'D' );
    if (dayOfWeek = 6 or dayOfWeek = 7) then
      return 1;
    else
      return 0;
    end if;

end isHoliday;

/* func: isWorkingDay
  ѕровер€ет, €вл€етс€ ли указанный день рабочим.

  ѕараметры:
    day                     - дата, которую нужно проверить

  ¬озврат:
    1                       - день €вл€етс€ выходным или праздником
    0                       - день €вл€етс€ рабочим
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
  ¬озвращает предыдущий рабочий день, начина€ с заданной даты.

  ѕараметры:
    day                     - дата, начина€ с которой нужно искать предыдущий рабочий день

  ¬озврат:
    - дата предыдущего рабочего дн€
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
  ¬озвращает следующий рабочий день, начина€ с заданной даты.

  ѕараметры:
    day                     - дата, начина€ с которой нужно искать следующий рабочий день

  ¬озврат:
    - дата следующего рабочего дн€
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
  ¬озвращает кол-во рабочих дней в неделе.

  ѕараметры:
    beginDay                - первый день недели

  ¬озврат:
    - кол-во рабочих дней в неделе, начина€ с указанной даты
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
  ¬озвращает кол-во рабочих дней в указанном периоде.

  ѕараметры:
    beginDate               - дата начала периода
    endDdate                - дата конца периода

  ¬озврат:
    - кол-во рабочих дней периоде
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
