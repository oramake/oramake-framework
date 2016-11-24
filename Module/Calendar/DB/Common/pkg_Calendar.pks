create or replace package pkg_Calendar
as
/* package: pkg_Calendar
  �������� ����� ������ Calendar, ��������������� �� ��� ��.

  SVN root: Oracle/Module/Calendar
*/



/* group: ��������� */

/* const: Module_Name
  �������� ������, � �������� ��������� �����.
*/
Module_Name constant varchar2(30) := 'Calendar';



/* group: ���� ���� ��������� */

/* const: PublicHoliday_DayTypeId
  Id ���� ��� "��������������� ��������"
*/
PublicHoliday_DayTypeId constant integer := 1;

/* const: WorkingDay_DayTypeId
  Id ���� ��� "������� ����"
*/
WorkingDay_DayTypeId constant integer := 2;

/* const: DayOff_DayTypeId
  Id ���� ��� "�������� ����"
*/
DayOff_DayTypeId constant integer := 3;



/* group: ������� */

/* pfunc: isHoliday
  ���������, �������� �� ��������� ���� ���������� ��� ��������.

  ���������:
    day                     - ����, ������� ����� ���������

  �������:
    1                       - ���� �������� �������� ��� ����������
    0                       - ���� �������� �������

  ( <body::isHoliday>)
*/
function isHoliday (
  day                       in date
)
return integer;

/* pfunc: isWorkingDay
  ���������, �������� �� ��������� ���� �������.

  ���������:
    day                     - ����, ������� ����� ���������

  �������:
    1                       - ���� �������� �������� ��� ����������
    0                       - ���� �������� �������

  ( <body::isWorkingDay>)
*/
function isWorkingDay (
  day                       in date
)
return integer;

/* pfunc: getLastWorkingDay
  ���������� ���������� ������� ����, ������� � �������� ����.

  ���������:
    day                     - ����, ������� � ������� ����� ������ ���������� ������� ����

  �������:
    - ���� ����������� �������� ���

  ( <body::getLastWorkingDay>)
*/
function getLastWorkingDay (
  day                       in date
)
return date;

/* pfunc: getNextWorkingDay
  ���������� ��������� ������� ����, ������� � �������� ����.

  ���������:
    day                     - ����, ������� � ������� ����� ������ ��������� ������� ����

  �������:
    - ���� ���������� �������� ���

  ( <body::getNextWorkingDay>)
*/
function getNextWorkingDay (
  day                       in date
)
return date;

/* pfunc: getWeekWorkingDayAmount
  ���������� ���-�� ������� ���� � ������.

  ���������:
    beginDay                - ������ ���� ������

  �������:
    - ���-�� ������� ���� � ������, ������� � ��������� ����

  ( <body::getWeekWorkingDayAmount>)
*/
function getWeekWorkingDayAmount (
  beginDay                  in date
)
return integer;

/* pfunc: getPeriodWorkingDayAmount
  ���������� ���-�� ������� ���� � ��������� �������.

  ���������:
    beginDate               - ���� ������ �������
    endDdate                - ���� ����� �������

  �������:
    - ���-�� ������� ���� �������

  ( <body::getPeriodWorkingDayAmount>)
*/
function getPeriodWorkingDayAmount (
  beginDate                 in date
, endDate                   in date
)
return integer;

end pkg_Calendar;
/
