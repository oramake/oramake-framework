create or replace package pkg_Calendar is
/* package: pkg_Calendar(UserDb)
  ������������ ����� ������ ��� ���������������� ��.

  SVN root: Oracle/Module/Calendar
*/

/* const: Module_Name
  ��� ������.
*/
Module_Name constant varchar2(30) := 'Calendar';

/* const: SourceDbLink_OptionName
  ������������ ����� "���� � ��-���������".
*/
SourceDbLink_OptionName constant varchar2(30) := 'SourceDbLink';



/* group: ������� */

/* pfunc: isWorkingDay
  ����������, �������� �� ��������� ���� �������.

  ���������:
  forDate                     - �������� ����

  ( <body::isWorkingDay>)
*/
function isWorkingDay(
  forDate date
)
return integer;

/* pfunc: getLastWorkingDay
  ���������� ��������� ������� ���� ��� ��������� ����.

   ���������:
   forDate                    - ��������� ���� ( ������������)

  ( <body::getLastWorkingDay>)
*/
function getLastWorkingDay(
  forDate date
)
return date;

/* pfunc: getNextWorkingDay
   ���������� ��������� ������� ���� ��� ��������� ����.

   ���������:
     forDate                   - ��������� ���� ( ������������)

  ( <body::getNextWorkingDay>)
*/
function getNextWorkingDay (
  forDate in date
  )
return date;

/* pfunc: getPeriodWorkingDayAmount
  ������� ���������� ���-�� ������� ���� � ��������� �������.

  ���������:
  beginDate                   - ���� ������ �������
  endDdate                    - ���� ����� �������

  �������:
   - ���-�� ������� ���� �������;

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
