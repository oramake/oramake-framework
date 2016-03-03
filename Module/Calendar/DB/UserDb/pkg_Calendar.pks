create or replace package pkg_Calendar is
/* package: pkg_Calendar(UserDb)
  Интерфейсный пакет модуля для пользовательских БД.

  SVN root: Oracle/Module/Calendar
*/

/* const: Module_Name
  Имя модуля.
*/
Module_Name constant varchar2(30) := 'Calendar';

/* const: SourceDbLink_OptionName
  Наименование опции "Линк к БД-источнику".
*/
SourceDbLink_OptionName constant varchar2(30) := 'SourceDbLink';



/* group: Функции */

/* pfunc: isWorkingDay
  Определяет, является ли указанный день рабочим.

  Параметры:
  forDate                     - исходная дата

  ( <body::isWorkingDay>)
*/
function isWorkingDay(
  forDate date
)
return integer;

/* pfunc: getLastWorkingDay
  Возвращает последний рабочий день для указанной даты.

   Параметры:
   forDate                    - граничная дата ( включительно)

  ( <body::getLastWorkingDay>)
*/
function getLastWorkingDay(
  forDate date
)
return date;

/* pfunc: getNextWorkingDay
   Возвращает следующий рабочий день для указанной даты.

   Параметры:
     forDate                   - граничная дата ( включительно)

  ( <body::getNextWorkingDay>)
*/
function getNextWorkingDay (
  forDate in date
  )
return date;

/* pfunc: getPeriodWorkingDayAmount
  Функция возвращает кол-во рабочих дней в указанном периоде.

  Параметры:
  beginDate                   - дата начала периода
  endDdate                    - дата конца периода

  Возврат:
   - кол-во рабочих дней периоде;

  ( <body::getPeriodWorkingDayAmount>)
*/
function getPeriodWorkingDayAmount
(
    beginDate date
  , endDate   date
)
return integer;

end pkg_Calendar;
/
