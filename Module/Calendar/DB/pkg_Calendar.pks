create or replace package pkg_Calendar is
/* package: pkg_Calendar
  ������������ ����� ������ Calendar.

  SVN root: Oracle/Module/Calendar
*/

/* group: ��������� */

/* const: Module_Name
  �������� ������, � �������� ��������� �����.
*/
Module_Name constant varchar2(30) := 'Calendar';

/* ������� ���� */
WorkingDay constant integer := 2;

/* group: ���� */

/* const: CalendarUser_RoleName
  ������������ ������ Calendar
*/
CalendarUser_RoleName constant varchar2(30) := 'CdrUser';

/* const: CalendarAdministrator_RoleName
  ������������� ������ Calendar
*/
CalendarAdministrator_RoleName constant varchar2(30) := 'CdrAdministrator';

/* group: ������� */

/*
  func: IsHoliday
  ���������, �������� �� ��������� ���� ���������� ��� ��������.
  (<body::IsHoliday>).
*/
function IsHoliday (day date) return integer;

/*
  func: IsWorkingDay
  ���������, �������� �� ��������� ���� �������.
  (<body::IsWorkingDay>).
*/
function IsWorkingDay (day date) return integer;

/*
  func: GetLastWorkingDay
  ���������� ���������� ������� ����, ������� � �������� ����.
  (<body::GetLastWorkingDay>).
*/
function GetLastWorkingDay (day date) return date;

/*
  func: GetNextWorkingDay
  ���������� ��������� ������� ����, ������� � �������� ����.
  (<body::GetNextWorkingDay>).
*/
function GetNextWorkingDay (day date) return date;

/*
  func: GetDayType
  ������� ���������� ���� ���� ���������.
  (<body::GetDayType>).
*/
function GetDayType (operatorId integer) return sys_refcursor;

/*
  func: FindDay
  ������� ������ ���� ���������.
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
  ������� ���������� ���� ���������.
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
  ��������� �������� ���� ���������.
  (<body::DeleteDay>).
*/
procedure DeleteDay
(
    day         date
  , operatorId  integer
);

/*
  func: GetWeekWorkingDayAmount
  ������� ���������� ���-�� ������� ���� � ������.
  (<body::GetWeekWorkingDayAmount>).
*/
function GetWeekWorkingDayAmount (beginDay date) return integer;

/*
  func: GetPeriodWorkingDayAmount
  ������� ���������� ���-�� ������� ���� � ��������� �������.
  (<body::GetWeekWorkingDayAmount>).
*/
function GetPeriodWorkingDayAmount 
(
    beginDate date
  , endDate   date
) return integer;

end pkg_Calendar;
/