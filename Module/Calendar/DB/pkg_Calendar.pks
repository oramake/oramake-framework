create or replace package pkg_Calendar is
/* package: pkg_Calendar
  Интерфейсный пакет модуля Calendar.

  SVN root: Oracle/Module/Calendar
*/

/* group: Константы */

/* const: Module_Name
  Название модуля, к которому относится пакет.
*/
Module_Name constant varchar2(30) := 'Calendar';

/* Рабочий день */
WorkingDay constant integer := 2;

/* group: Роли */

/* const: CalendarUser_RoleName
  Пользователь модуля Calendar
*/
CalendarUser_RoleName constant varchar2(30) := 'CdrUser';

/* const: CalendarAdministrator_RoleName
  Администратор модуля Calendar
*/
CalendarAdministrator_RoleName constant varchar2(30) := 'CdrAdministrator';

/* group: Функции */

/*
  func: IsHoliday
  Проверяет, является ли указанный день праздником или выходным.
  (<body::IsHoliday>).
*/
function IsHoliday (day date) return integer;

/*
  func: IsWorkingDay
  Проверяет, является ли указанный день рабочим.
  (<body::IsWorkingDay>).
*/
function IsWorkingDay (day date) return integer;

/*
  func: GetLastWorkingDay
  Возвращает предыдущий рабочий день, начиная с заданной даты.
  (<body::GetLastWorkingDay>).
*/
function GetLastWorkingDay (day date) return date;

/*
  func: GetNextWorkingDay
  Возвращает следующий рабочий день, начиная с заданной даты.
  (<body::GetNextWorkingDay>).
*/
function GetNextWorkingDay (day date) return date;

/*
  func: GetDayType
  Функция возвращает типы дней календаря.
  (<body::GetDayType>).
*/
function GetDayType (operatorId integer) return sys_refcursor;

/*
  func: FindDay
  Функция поиска дней календаря.
  (<body::FindDay>).
*/
function FindDay
(
    day         date    := null
  , dayTypeId   integer := null
  , dateBegin   date    := null
  , dateEnd     date    := null
  , maxRowCount integer := null
  , operatorId  integer := null
) return sys_refcursor;

/*
  func: CreateDay
  Функция добавления дней календаря.
  (<body::CreateDay>).
*/
function CreateDay
(
    day         date
  , dayTypeId   integer
  , operatorId  integer
) return date;

/*
  proc: DeleteDay
  Процедура удаления дней календаря.
  (<body::DeleteDay>).
*/
procedure DeleteDay
(
    day         date
  , operatorId  integer
);

/*
  func: GetWeekWorkingDayAmount
  Функция возвращает кол-во рабочих дней в неделе.
  (<body::GetWeekWorkingDayAmount>).
*/
function GetWeekWorkingDayAmount (beginDay date) return integer;

/*
  func: GetPeriodWorkingDayAmount
  Функция возвращает кол-во рабочих дней в указанном периоде.
  (<body::GetWeekWorkingDayAmount>).
*/
function GetPeriodWorkingDayAmount 
(
    beginDate date
  , endDate   date
) return integer;

end pkg_Calendar;
/