create or replace package body pkg_Calendar is
/* package body: pkg_Calendar(UserDb)::body */



/* group: Переменные */

/* ivar: logger
  Логер пакета.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => pkg_Calendar.Module_Name
  , objectName  => 'pkg_Calendar'
);


/* ivar: sourceDbLink
  DB-линк к источнику.
*/
sourceDbLink varchar2(100) := null;



/* group: Функции */

/* iproc: getSourceDbLink
  Получение значения опции sourceDbLink, если оно не задано.
*/
procedure getSourceDbLink
is
-- getSourceDbLink
begin
  if sourceDbLink is null then
    sourceDbLink :=
      opt_option_list_t(
        moduleName => Module_Name
      ).getOptionString( SourceDbLink_OptionName)
    ;
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка получения значения DB-линка к источнику'
      )
    , true
  );
end getSourceDbLink;

/* func: isWorkingDay
  Определяет, является ли указанный день рабочим.

  Параметры:
  forDate                     - исходная дата
*/
function isWorkingDay(
  forDate date
)
return integer
is

                                        --Признак рабочего дня
  isWorking integer;

  --FillMessageBase
begin
  getSourceDbLink();
  execute immediate '
begin
  :isWorking := pkg_Calendar.isWorkingDay@'
    || sourceDbLink
    || '(
      :forDate
  );
end;
'
  using
    out isWorking
    , in forDate
  ;
  return isWorking;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , 'Ошибка при определении рабочего дня ('
      || ' forDate={' || to_char( forDate, 'dd.mm.yyyy hh24:mi:ss')
      || ').'
    , true
  );
end isWorkingDay;

/* func: getLastWorkingDay
  Возвращает последний рабочий день для указанной даты.

   Параметры:
   forDate                    - граничная дата ( включительно)
*/
function getLastWorkingDay(
  forDate date
)
return date
is

                                        --Последний рабочий день
  lastWorkingDay date;

  --FillMessageBase
begin
  getSourceDbLink();
  execute immediate '
begin
  :lastWorkingDay := pkg_Calendar.getLastWorkingDay@'
    || sourceDbLink

    || '(
      :forDate
  );
end;
'
  using
    out lastWorkingDay
    , in forDate
  ;
  return lastWorkingDay;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , 'Ошибка при определении последнего рабочего дня ('
      || ' forDate={' || to_char( forDate, 'dd.mm.yyyy hh24:mi:ss') || '}'
      || ').'
    , true
  );
end getLastWorkingDay;

/* func: getNextWorkingDay
   Возвращает следующий рабочий день для указанной даты.

   Параметры:
     forDate                   - граничная дата ( включительно)
*/
function getNextWorkingDay (
  forDate in date
  )
return date
is
  -- следующий рабочий день
  nextWorkingDay date;

-- getNextWorkingDay
begin
  getSourceDbLink();
  execute immediate '
    begin
      :nextWorkingDay := pkg_Calendar.getNextWorkingDay@'
        || sourceDbLink
        || '( :forDate );
    end;'
    using out nextWorkingDay
        , in forDate
  ;
  return nextWorkingDay;

exception
  when others then
    raise_application_error(
        pkg_Error.ErrorStackInfo
      , 'Ошибка при определении следующего рабочего дня ('
          || ' forDate="' || to_char( forDate, 'dd.mm.yyyy' ) || '"'
          || ').'
      , true
      );

end getNextWorkingDay;

/* func: getPeriodWorkingDayAmount
  Функция возвращает кол-во рабочих дней в указанном периоде.

  Параметры:
  beginDate                   - дата начала периода
  endDdate                    - дата конца периода

  Возврат:
   - кол-во рабочих дней периоде;
*/
function getPeriodWorkingDayAmount
(
    beginDate date
  , endDate   date
)
return integer
is
  -- Количество рабочих дней периоде
  periodWorkDayAmount integer;
begin
  getSourceDbLink();
  execute immediate '
    begin
      :periodWorkDayAmount := pkg_Calendar.getPeriodWorkingDayAmount@'
        || sourceDbLink
        || '( :beginDate, :endDate );
    end;'
  using
    out periodWorkDayAmount
    , in beginDate
    , in endDate
  ;
  return
    periodWorkDayAmount
  ;
end getPeriodWorkingDayAmount;

end pkg_Calendar;
/
