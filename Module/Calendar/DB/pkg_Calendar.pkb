create or replace package body pkg_Calendar is
/* package body: pkg_Calendar::body */

/*
  proc: AddSqlCondition
  ��������� ������� � ���������� � ������ SQL-�������.
  � ������, ���� ����������� �������� ��������� �� null ( isNullValue false),
  ������� ����������� � ���� �������� �������� ��������� ��� ����� � ����������,
  � ��������� ������ ����������� ������������ �������� ������� � ����������.

  ��������� ����� ������������ ���������� ����� � ������� ���������� ���
  ���������� ������������� SQL ��� ���, ��� ���������� ����� ����������
  ����� ���� �� ������ ( ����� �������� null). ����� �������������� ������
  ����� ������� � ����������� �� ������� ����������� �������� ����������,
  ��� ��������� ������������ ������ ����� ���������� �������.

  ���������:
  searchCondition             - ����� � SQL-��������� ������, � �������
                                ����������� ������� ( ������������� ����� � SQL
                                ����� "where")
  fieldExpr                   - ��������� ��� ����� ������� ( ����������� �
                                ����� ����� �������� ���������)
  operation                   - �������� ��������� ( "=", ">=" � �.�.)
  isNullValue                 - ������� �������� null � ������� ��������
                                ���������
  parameterExpr               - ��������� ��� ���������� ( ����������� � ������
                                ����� �������� ���������, � ������ ����������
                                ":" ��� ����������� � ������ ������, ��
                                ��������� ������� �� fieldExpr � ���������
                                ������ � ����������� ":")

  ���������:
  - � ������ �������������� �������� � fieldExpr ( �� ������
    "[<alias>.]<fieldName>"), �������� parameterExpr ������ ���� ���� ������;
*/
procedure AddSqlCondition(
  searchCondition in out nocopy varchar2
  , fieldExpr varchar2
  , operation varchar2
  , isNullValue boolean
  , parameterExpr varchar2 := null
)
is

                                        --������� ���������� �������� ��������
  isBinaryOp boolean := coalesce( not isNullValue, false);

--AddSqlCondition
begin
  searchCondition := searchCondition
    || case when searchCondition is not null then ' and' end
    || case when isBinaryOp then
        ' ' || fieldExpr || ' ' || operation
      end
    || ' '
    || case when parameterExpr is null then
                                      --�� ��������� ��� ���� ( ��� ������)
          ':' || substr( fieldExpr, instr( fieldExpr, '.') + 1)
        else
                                      --��������� ":", ���� ��� ���
          case when instr( parameterExpr, ':') = 0 then
            ':'
          end
          || parameterExpr
        end
      || case when not isBinaryOp then
          ' is null'
        end
  ;
end AddSqlCondition;

/*
  func: IsHoliday
  ���������, �������� �� ��������� ���� ���������� ��� ��������.

  ���������:
    day       - ����, ������� ����� ���������

  ������������ ��������:
    1         - ���� �������� �������� ��� ����������
    0         - ���� �������� �������
*/
function IsHoliday (day in date) return integer
is
  dayTypeId integer;
  dayOfWeek integer;
begin
  select day_type_id
  into dayTypeId
  from cdr_day d
  where d.day = trunc (IsHoliday.day);

  if dayTypeId != WorkingDay then return 1;
  else return 0;
  end if;
exception
  when NO_DATA_FOUND then
    -- ���������� ���������� ���� ������
    dayOfWeek := to_char (day, 'D');
    if (dayOfWeek = 6 or dayOfWeek = 7) then return 1;
    else return 0;
    end if;
end IsHoliday;

/*
  func: IsWorkingDay
  ���������, �������� �� ��������� ���� �������.

  ���������:
    day       - ����, ������� ����� ���������

  ������������ ��������:
    1         - ���� �������� �������� ��� ����������
    0         - ���� �������� �������
*/
function IsWorkingDay (day date) return integer
is
  result integer;
begin
  if IsHoliday (day) = 1 then return 0;
  else return 1;
  end if;
end IsWorkingDay;

/*
  func: GetLastWorkingDay
  ���������� ���������� ������� ����, ������� � �������� ����.

  ���������:
    day       - ����, ������� � ������� ����� ������ ���������� ������� ����

  ������������ ��������:
    ���� ����������� �������� ���
*/
function GetLastWorkingDay (day date) return date
is
  result date;
begin
  result := trunc (day);

  while IsHoliday (result) = 1
  loop
    result := result - 1;
  end loop;

  return result;
end GetLastWorkingDay;

/*
  func: GetNextWorkingDay
  ���������� ��������� ������� ����, ������� � �������� ����.

  ���������:
    day       - ����, ������� � ������� ����� ������ ��������� ������� ����

  ������������ ��������:
    ���� ���������� �������� ���
*/
function GetNextWorkingDay (day date) return date
is
  result date;
begin
  result := trunc (day);

  while IsHoliday (result) = 1
  loop
    result := result + 1;
  end loop;

  return result;
end GetNextWorkingDay;

/*
  func: GetDayType
  ������� ���������� ���� ���� ���������.

  ���������:
    operatorId                 - ������������� ���������, ������������ ��������

  ������� (������):
    day_type_id                - ������������� ���� ���
    day_type_name              - ������������ ���� ���
*/
function GetDayType (operatorId integer) return sys_refcursor
is
  resultSet sys_refcursor;
begin
  if pkg_Operator.IsRole (operatorId, CalendarAdministrator_RoleName) = 1
  or pkg_Operator.IsRole (operatorId, CalendarUser_RoleName) = 1
  then
    open resultSet for '
    select
        day_type_id
      , day_type_name
    from cdr_day_type
    order by day_type_id
    ';
  else
    raise_application_error (pkg_Error.ErrorStackInfo, '��� ���� �������', true);
  end if;

  return resultSet;

end GetDayType;

/*
  func: FindDay
  ������� ������ ���� ���������.

  ���������:
    day                   - ���� ���������
    dayTypeId             - ��� ���
    dateBegin             - ��������� ���� ������
    dateEnd               - �������� ���� ������
    maxRowCount           - ������������ ���������� �������
    operatorId            - ������������� �������� ������������

  ������� (������):
    day                   - ���� ���������
    day_type_name         - ���� ���
*/
function FindDay
(
    day         date    := null
  , dayTypeId   integer := null
  , dateBegin   date    := null
  , dateEnd     date    := null
  , maxRowCount integer := null
  , operatorId  integer := null
) return sys_refcursor
is
  --������������ ������
  resultSet sys_refcursor;
  -- ������ � ��������
  sqlStr varchar2(1000):= '
  select
    day
    , day_type_name
  from cdr_day
  inner join cdr_day_type using (day_type_id)
    where $(condition)
  order by day
  ';

  searchCondition varchar2(500);
begin
  -- �������� ���� ���������
  if pkg_Operator.IsRole (operatorId, CalendarAdministrator_RoleName) = 1
  or pkg_Operator.IsRole (operatorId, CalendarUser_RoleName) = 1
  then
    searchCondition := '1=1';
  else
    searchCondition := '1=0';
  end if;

  AddSqlCondition (searchCondition, 'day', '=', day is null);
  AddSqlCondition (searchCondition, 'day_type_id', '=', dayTypeId is null);
  AddSqlCondition (searchCondition, 'day', '>=', dateBegin is null);
  AddSqlCondition (searchCondition, 'day', '<=', dateEnd is null);
  AddSqlCondition (searchCondition, 'rownum', '<=', maxRowCount is null, 'maxRowCount');

  open resultSet for replace (sqlStr, '$(condition)', searchCondition)
  using
      day
    , dayTypeId
    , dateBegin
    , dateEnd
    , maxRowCount;

  return resultSet;

exception
  when others then
    raise_application_error
    (
        pkg_Error.ErrorStackInfo
      , '��� ������ ���� ��������� �������� ������.'
      , true
    );
end FindDay;

/*
  func: CreateDay
  ������� ���������� ���� ���������.

  ���������:
    day                   - ���� ���������
    dayTypeId             - ��� ���
    operatorId            - ������������� �������� ������������

  �������:
    day                   - ���� ���������
*/
function CreateDay
(
    day         date
  , dayTypeId   integer
  , operatorId  integer
) return date
is
begin
  -- �������� ���� ���������
  if pkg_Operator.IsRole (operatorId, CalendarAdministrator_RoleName) != 1
  then
    raise_application_error
    (
      pkg_Error.ErrorStackInfo
      , '�� ���������� ���� ��� ���������� ������ ��������.'
      , true
    );
  end if;

  if day is null
    then raise_application_error (pkg_Error.ErrorStackInfo, '�� ����� ������������ �������� day', true);
  end if;
  if dayTypeId is null
    then raise_application_error (pkg_Error.ErrorStackInfo, '�� ����� ������������ �������� dayTypeId', true);
  end if;

  insert into cdr_day
  (
      day
    , day_type_id
    , operator_id
  )
  values
  (
      CreateDay.day
    , dayTypeId
    , operatorId
  );

  return day;

exception
  when others
    then raise_application_error
    (
      pkg_Error.ErrorStackInfo
      , '������ ���������� ���� ���������.'
      , true
    );
end CreateDay;

/*
  proc: DeleteDay
  ��������� �������� ���� ���������.

  ���������:
    day             - ���� ���������
    operatorId      - ������������� �������� ������������
*/
procedure DeleteDay
(
    day         date
  , operatorId  integer
)
is
begin
  -- �������� ���� ���������
  if pkg_Operator.IsRole (operatorId, CalendarAdministrator_RoleName) != 1
  then
    raise_application_error
    (
      pkg_Error.ErrorStackInfo
      , '�� ���������� ���� ��� ���������� ������ ��������.'
      , true
    );
  end if;

  if day is null
    then raise_application_error (pkg_Error.ErrorStackInfo, '�� ����� ������������ �������� day', true);
  end if;

  delete from cdr_day
  where day = DeleteDay.day;

exception
  when others
    then raise_application_error
    (
      pkg_Error.ErrorStackInfo
      , '������ �������� ���� ���������.'
      , true
    );
end DeleteDay;

/*
  func: GetWeekWorkingDayAmount
  ������� ���������� ���-�� ������� ���� � ������.

  ���������:
    beginDay              - ������ ���� ������

  �������:
    ���-�� ������� ���� � ������, ������� � ��������� ����
*/

function GetWeekWorkingDayAmount (beginDay date) return integer
is
  weekWorkDayAmount integer := 0;
begin

  for i in 0..6
  loop
    if isHoliday (beginDay+i) != 1 then
      weekWorkDayAmount := weekWorkDayAmount + 1;
    end if;
  end loop;

  return weekWorkDayAmount;

end GetWeekWorkingDayAmount;

/*
  func: GetPeriodWorkingDayAmount
  ������� ���������� ���-�� ������� ���� � ��������� �������.

  ���������:
    beginDate                   - ���� ������ �������
    endDdate                    - ���� ����� �������
                                 
  �������:
    ���-�� ������� ���� �������
*/
function GetPeriodWorkingDayAmount 
(
    beginDate date
  , endDate   date
) return integer
is
  periodWorkDayAmount integer := 0;
begin

  for i in 0..endDate-beginDate
  loop
    if isHoliday (beginDate+i) != 1 then
      periodWorkDayAmount := periodWorkDayAmount + 1;
    end if;
  end loop;

  return periodWorkDayAmount;

end GetPeriodWorkingDayAmount;

end pkg_Calendar;
/