create or replace package body pkg_CalendarEdit is
/* package body: pkg_CalendarEdit::body */



/* group: ���������� */

/* ivar: logger
   ����� ������.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName  => 'Calendar'
  , objectName => 'pkg_CalendarEdit'
);




/* group: ������� */

/* func: createDay
  ��������� ���� ���������.

  ���������:
  day                         - ���� ���������
  dayTypeId                   - Id ���� ���
  operatorId                  - Id ���������

  �������:
  ���� ���������.
*/
function createDay(
  day date
  , dayTypeId integer
  , operatorId integer
)
return date
is

  -- ���� ���������
  calendarDay cdr_day.day%type;

begin
  pkg_Operator.isRole( operatorId, Admin_RoleSName);
  insert into
    cdr_day
  (
    day
    , day_type_id
    , operator_id
  )
  values
  (
    createDay.day
    , dayTypeId
    , operatorId
  )
  returning
    day
  into
    calendarDay
  ;

  return calendarDay;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ���������� ��� ��������� ('
        || ' day=' || to_char( day, 'dd.mm.yyyy hh24:mi:ss')
        || ', dayTypeId=' || dayTypeId
        || ', operatorId=' || operatorId
        || ').'
      )
    , true
  );
end createDay;

/* proc: deleteDay
  ������� ���� ���������.

  ���������:
  day                         - ���� ���������
  operatorId                  - Id ���������
*/
procedure deleteDay(
  day date
  , operatorId integer
)
is
begin
  pkg_Operator.isRole( operatorId, Admin_RoleSName);
  delete from
    cdr_day t
  where
    t.day = deleteDay.day
  ;
  if sql%rowcount = 0 then
    raise_application_error(
      pkg_Error.ProcessError
      , '������ �� �������.'
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� �������� ��� ��������� ('
        || ' day=' || to_char( day, 'dd.mm.yyyy hh24:mi:ss')
        || ', operatorId=' || operatorId
        || ').'
      )
    , true
  );
end deleteDay;

/* func: findDay
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
*/
function findDay (
  day                       in date    := null
, dayTypeId                 in integer := null
, dateBegin                 in date    := null
, dateEnd                   in date    := null
, maxRowCount               in integer := null
, operatorId                in integer := null
)
return sys_refcursor
is
  sqlQuery dyn_dynamic_sql_t := dyn_dynamic_sql_t( '
    select
      d.day
    , dt.day_type_name
    from
      v_cdr_day d
    inner join
      v_cdr_day_type dt
    on
      dt.day_type_id = d.day_type_id
    where
      $(filterCondition)
    order by
      d.day'
  );

  rc sys_refcursor;

begin
  sqlQuery.addCondition( 'd.day =', day is null, 'day' );
  sqlQuery.addCondition( 'd.day_type_id =', dayTypeId is null, 'dayTypeId' );
  sqlQuery.addCondition( 'd.day >=', dateBegin is null, 'dateBegin' );
  sqlQuery.addCondition( 'd.day <=', dateEnd is null, 'dateEnd' );
  sqlQuery.addCondition( 'rownum <=', maxRowCount is null, 'maxRowCount' );
  sqlQuery.useCondition( 'filterCondition' );

  open rc for
    sqlQuery.getSqlText()
  using
    in day
  , in dayTypeId
  , in dateBegin
  , in dateEnd
  , in maxRowCount
  ;

  return rc;

exception
  when others then
    raise_application_error(
        pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ������ ���� ���������'
          )
      , true
      );

end findDay;

/* func: getDayType
  ���������� ���� ���� ���������.

  ���������:
  operatorId                  - Id ���������
                                ( �� ��������� �������)

  ������� (������):
  day_type_id                 - Id ���� ���
  day_type_name               - ������������ ���� ���

  ( ���������� �� day_type_id)
*/
function getDayType(
  operatorId integer := null
)
return sys_refcursor
is
  rc sys_refcursor;

begin
  open rc for
  select
    day_type_id
  , day_type_name
  from
    v_cdr_day_type
  order by
    day_type_id
  ;

  return rc;

end getDayType;

end pkg_CalendarEdit;
/
