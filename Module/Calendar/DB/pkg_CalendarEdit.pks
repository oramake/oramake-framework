create or replace package pkg_CalendarEdit is
/* package: pkg_CalendarEdit
  ������������ ������� ������ Calendar.

  SVN root: Oracle/Module/Calendar
*/




/* group: ��������� */



/* group: ���� */

/* const: Admin_RoleSName
  ������� ������������ ����, ������ ����� �� �������������� ������.
*/
Admin_RoleSName constant varchar2(50) := 'CdrAdministrator';

/* const: Show_RoleSName
  ������� ������������ ����, ������ ����� �� �������� ������
  ( ����������� � App-�����).
*/
Show_RoleSName constant varchar2(50) := 'CdrUser';



/* group: ������� */

/* pfunc: createDay
  ��������� ���� ���������.

  ���������:
  day                         - ���� ���������
  dayTypeId                   - Id ���� ���
  operatorId                  - Id ���������

  �������:
  ���� ���������.

  ( <body::createDay>)
*/
function createDay(
  day date
  , dayTypeId integer
  , operatorId integer
)
return date;

/* pproc: deleteDay
  ������� ���� ���������.

  ���������:
  day                         - ���� ���������
  operatorId                  - Id ���������

  ( <body::deleteDay>)
*/
procedure deleteDay(
  day date
  , operatorId integer
);

/* pfunc: findDay
  ����� ���� ���������.

  ���������:
  day                         - ���� ���������
  dayTypeId                   - Id ���� ���
  dateBegin                   - ��������� ���� ������
  dateEnd                     - �������� ���� ������
  maxRowCount                 - ������������ ����� ������������ ������� �������
  operatorId                  - Id ���������

  ������� ( ������):
  day                         - ���� ���������
  day_type_name               - ������������ ���� ���

  ( ���������� �� day)

  ( <body::findDay>)
*/
function findDay (
  day                       in date    := null
, dayTypeId                 in integer := null
, dateBegin                 in date    := null
, dateEnd                   in date    := null
, maxRowCount               in integer := null
, operatorId                in integer := null
)
return sys_refcursor;

/* pfunc: getDayType
  ���������� ���� ���� ���������.

  ���������:
  operatorId                  - Id ���������
                                ( �� ��������� �������)

  ������� (������):
  day_type_id                 - Id ���� ���
  day_type_name               - ������������ ���� ���

  ( ���������� �� day_type_id)

  ( <body::getDayType>)
*/
function getDayType(
  operatorId integer := null
)
return sys_refcursor;

end pkg_CalendarEdit;
/
