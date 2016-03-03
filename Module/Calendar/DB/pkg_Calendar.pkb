create or replace package body pkg_Calendar is
/* package body: pkg_Calendar::body */

/*
  proc: AddSqlCondition
  Добавляет условие с параметром в строку SQL-условий.
  В случае, если фактическое значение параметра не null ( isNullValue false),
  условие добавляется в виде бинарной операции сравнения над полем и параметром,
  в противном случае добавляется тождественно истинное условие с параметром.

  Указанная схема обеспечивает постоянное число и порядок параметров при
  выполнении динамического SQL при том, что фактически часть параметров
  может быть не задана ( имеет значение null). Также обеспечивается разный
  текст запроса в зависимости от наличия фактических значений параметров,
  что позволяет использовать разные планы выполнения запроса.

  Параметры:
  searchCondition             - текст с SQL-условиями поиска, в который
                                добавляется условие ( подставляется затем в SQL
                                после "where")
  fieldExpr                   - выражение над полем таблицы ( указывается в
                                левой части операции сравнения)
  operation                   - операция сравнения ( "=", ">=" и т.д.)
  isNullValue                 - признак передачи null в качесте значения
                                параметра
  parameterExpr               - выражение над параметром ( указывается в правой
                                части операции сравнения, в случае отсутствия
                                ":" оно добавляется в начало строки, по
                                умолчанию берется из fieldExpr с удалением
                                алиаса и добавлением ":")

  Замечания:
  - в случае нетривиального значения в fieldExpr ( не просто
    "[<alias>.]<fieldName>"), значение parameterExpr должно быть явно задано;
*/
procedure AddSqlCondition(
  searchCondition in out nocopy varchar2
  , fieldExpr varchar2
  , operation varchar2
  , isNullValue boolean
  , parameterExpr varchar2 := null
)
is

                                        --Признак добавления бинарной операции
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
                                      --По умолчанию имя поля ( без алиаса)
          ':' || substr( fieldExpr, instr( fieldExpr, '.') + 1)
        else
                                      --Добавляем ":", если его нет
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
  Проверяет, является ли указанный день праздником или выходным.

  Параметры:
    day       - дата, которую нужно проверить

  Возвращаемые значения:
    1         - день является выходным или праздником
    0         - день является рабочим
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
    -- определяем порядковый день недели
    dayOfWeek := to_char (day, 'D');
    if (dayOfWeek = 6 or dayOfWeek = 7) then return 1;
    else return 0;
    end if;
end IsHoliday;

/*
  func: IsWorkingDay
  Проверяет, является ли указанный день рабочим.

  Параметры:
    day       - дата, которую нужно проверить

  Возвращаемые значения:
    1         - день является выходным или праздником
    0         - день является рабочим
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
  Возвращает предыдущий рабочий день, начиная с заданной даты.

  Параметры:
    day       - дата, начиная с которой нужно искать предыдущий рабочий день

  Возвращаемые значения:
    дата предыдущего рабочего дня
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
  Возвращает следующий рабочий день, начиная с заданной даты.

  Параметры:
    day       - дата, начиная с которой нужно искать следующий рабочий день

  Возвращаемые значения:
    дата следующего рабочего дня
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
  Функция возвращает типы дней календаря.

  Параметры:
    operatorId                 - идентификатор оператора, выполняющего загрузку

  Возврат (курсор):
    day_type_id                - идентификатор типа дня
    day_type_name              - наименование типа дня
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
    raise_application_error (pkg_Error.ErrorStackInfo, 'Нет прав доступа', true);
  end if;

  return resultSet;

end GetDayType;

/*
  func: FindDay
  Функция поиска дней календаря.

  Параметры:
    day                   - день календаря
    dayTypeId             - тип дня
    dateBegin             - начальная дата поиска
    dateEnd               - конечная дата поиска
    maxRowCount           - максимальное количество записей
    operatorId            - идентификатор текущего пользователя

  Возврат (курсор):
    day                   - день календаря
    day_type_name         - типа дня
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
  --Возвращаемый курсор
  resultSet sys_refcursor;
  -- строка с запросом
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
  -- проверка прав оператора
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
      , 'При поиске дней календаря возникла ошибка.'
      , true
    );
end FindDay;

/*
  func: CreateDay
  Функция добавления дней календаря.

  Параметры:
    day                   - день календаря
    dayTypeId             - тип дня
    operatorId            - идентификатор текущего пользователя

  Возврат:
    day                   - день календаря
*/
function CreateDay
(
    day         date
  , dayTypeId   integer
  , operatorId  integer
) return date
is
begin
  -- проверка прав оператора
  if pkg_Operator.IsRole (operatorId, CalendarAdministrator_RoleName) != 1
  then
    raise_application_error
    (
      pkg_Error.ErrorStackInfo
      , 'Не достаточно прав для выполнения данной операции.'
      , true
    );
  end if;

  if day is null
    then raise_application_error (pkg_Error.ErrorStackInfo, 'Не задан обязательный параметр day', true);
  end if;
  if dayTypeId is null
    then raise_application_error (pkg_Error.ErrorStackInfo, 'Не задан обязательный параметр dayTypeId', true);
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
      , 'Ошибка добавления дней календаря.'
      , true
    );
end CreateDay;

/*
  proc: DeleteDay
  Процедура удаления дней календаря.

  Параметры:
    day             - день календаря
    operatorId      - идентификатор текущего пользователя
*/
procedure DeleteDay
(
    day         date
  , operatorId  integer
)
is
begin
  -- проверка прав оператора
  if pkg_Operator.IsRole (operatorId, CalendarAdministrator_RoleName) != 1
  then
    raise_application_error
    (
      pkg_Error.ErrorStackInfo
      , 'Не достаточно прав для выполнения данной операции.'
      , true
    );
  end if;

  if day is null
    then raise_application_error (pkg_Error.ErrorStackInfo, 'Не задан обязательный параметр day', true);
  end if;

  delete from cdr_day
  where day = DeleteDay.day;

exception
  when others
    then raise_application_error
    (
      pkg_Error.ErrorStackInfo
      , 'Ошибка удаления дней календаря.'
      , true
    );
end DeleteDay;

/*
  func: GetWeekWorkingDayAmount
  Функция возвращает кол-во рабочих дней в неделе.

  Параметры:
    beginDay              - первый день недели

  Возврат:
    кол-во рабочих дней в неделе, начиная с указанной даты
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
  Функция возвращает кол-во рабочих дней в указанном периоде.

  Параметры:
    beginDate                   - дата начала периода
    endDdate                    - дата конца периода
                                 
  Возврат:
    кол-во рабочих дней периоде
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