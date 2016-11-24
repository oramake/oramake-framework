create or replace package pkg_Calendar
as
/* package: pkg_Calendar
  Основной пакет модуля Calendar, устанавливаемый во все БД.

  SVN root: Oracle/Module/Calendar
*/



/* group: Константы */

/* const: Module_Name
  Название модуля, к которому относится пакет.
*/
Module_Name constant varchar2(30) := 'Calendar';



/* group: Типы дней календаря */

/* const: PublicHoliday_DayTypeId
  Id типа дня "Государственный праздник"
*/
PublicHoliday_DayTypeId constant integer := 1;

/* const: WorkingDay_DayTypeId
  Id типа дня "Рабочий день"
*/
WorkingDay_DayTypeId constant integer := 2;

/* const: DayOff_DayTypeId
  Id типа дня "Выходной день"
*/
DayOff_DayTypeId constant integer := 3;



/* group: Функции */

/* pfunc: isHoliday
  Проверяет, является ли указанный день праздником или выходным.

  Параметры:
    day                     - дата, которую нужно проверить

  Возврат:
    1                       - день является выходным или праздником
    0                       - день является рабочим

  ( <body::isHoliday>)
*/
function isHoliday (
  day                       in date
)
return integer;

/* pfunc: isWorkingDay
  Проверяет, является ли указанный день рабочим.

  Параметры:
    day                     - дата, которую нужно проверить

  Возврат:
    1                       - день является выходным или праздником
    0                       - день является рабочим

  ( <body::isWorkingDay>)
*/
function isWorkingDay (
  day                       in date
)
return integer;

/* pfunc: getLastWorkingDay
  Возвращает предыдущий рабочий день, начиная с заданной даты.

  Параметры:
    day                     - дата, начиная с которой нужно искать предыдущий рабочий день

  Возврат:
    - дата предыдущего рабочего дня

  ( <body::getLastWorkingDay>)
*/
function getLastWorkingDay (
  day                       in date
)
return date;

/* pfunc: getNextWorkingDay
  Возвращает следующий рабочий день, начиная с заданной даты.

  Параметры:
    day                     - дата, начиная с которой нужно искать следующий рабочий день

  Возврат:
    - дата следующего рабочего дня

  ( <body::getNextWorkingDay>)
*/
function getNextWorkingDay (
  day                       in date
)
return date;

/* pfunc: getWeekWorkingDayAmount
  Возвращает кол-во рабочих дней в неделе.

  Параметры:
    beginDay                - первый день недели

  Возврат:
    - кол-во рабочих дней в неделе, начиная с указанной даты

  ( <body::getWeekWorkingDayAmount>)
*/
function getWeekWorkingDayAmount (
  beginDay                  in date
)
return integer;

/* pfunc: getPeriodWorkingDayAmount
  Возвращает кол-во рабочих дней в указанном периоде.

  Параметры:
    beginDate               - дата начала периода
    endDdate                - дата конца периода

  Возврат:
    - кол-во рабочих дней периоде

  ( <body::getPeriodWorkingDayAmount>)
*/
function getPeriodWorkingDayAmount (
  beginDate                 in date
, endDate                   in date
)
return integer;

end pkg_Calendar;
/
