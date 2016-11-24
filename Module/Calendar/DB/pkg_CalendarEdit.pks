create or replace package pkg_CalendarEdit is
/* package: pkg_CalendarEdit
  Интерфейсные функции модуля Calendar.

  SVN root: Oracle/Module/Calendar
*/



/* group: Функции */

/* pfunc: createDay
  Добавляет день календаря.

  Параметры:
  day                         - День календаря
  dayTypeId                   - Id типа дня
  operatorId                  - Id оператора

  Возврат:
  день календаря.

  ( <body::createDay>)
*/
function createDay(
  day date
  , dayTypeId integer
  , operatorId integer
)
return date;

/* pproc: deleteDay
  Удаляет день календаря.

  Параметры:
  day                         - День календаря
  operatorId                  - Id оператора

  ( <body::deleteDay>)
*/
procedure deleteDay(
  day date
  , operatorId integer
);

/* pfunc: findDay
  Поиск дней календаря.

  Параметры:
  day                         - День календаря
  dayTypeId                   - Id типа дня
  dateBegin                   - начальная дата поиска
  dateEnd                     - конечная дата поиска
  maxRowCount                 - максимальное число возвращаемых поиском записей
  operatorId                  - Id оператора

  Возврат ( курсор):
  day                         - День календаря
  day_type_name               - Наименование типа дня

  ( сортировка по day)

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
  Возвращает типы дней календаря.

  Возврат (курсор):
  day_type_id                 - Id типа дня
  day_type_name               - Наименование типа дня

  ( сортировка по day_type_id)

  ( <body::getDayType>)
*/
function getDayType
return sys_refcursor;

end pkg_CalendarEdit;
/
