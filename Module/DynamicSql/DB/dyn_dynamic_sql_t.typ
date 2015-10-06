@oms-drop-type.sql dyn_dynamic_sql_t

create or replace type dyn_dynamic_sql_t
as object
(
/* db object type: dyn_dynamic_sql_t
  Формирует текст динамического SQL, зависящего от значения параметров.

  SVN root: Oracle/Module/DynamicSql

*/



/* group: Закрытые объявления */

/* ivar: mSqlText
  Текст SQL-запроса.
*/
  mSqlText varchar2(32767)

/* ivar: mConditionText
  Текст условий запроса.
*/
, mConditionText varchar2(32767)

/* ivar: mParameterCount
  Число параметров запроса.
*/
, mParameterCount integer



/* group: Открытые объявления */

/* pfunc: dyn_dynamic_sql_t
  Создает объект
  ( <body::dyn_dynamic_sql_t>).
*/
, constructor function dyn_dynamic_sql_t(
    sqlText varchar2
  )
  return self as result

/* pproc: addCondition
  Добавляет условие в запрос
  ( <body::addCondition>).
*/
, member procedure addCondition(
    conditionText varchar2
    , isNullValue boolean
    , parameterName varchar2 := null
  )

/* func: useCondition
  Заменяет макропеременную $(macroName) в тексте запроса на выражение с
  параметрами
  ( <body::useCondition>).
*/
, member procedure useCondition(
    macroName varchar2
  )

/* pfunc: getSqlText
  Возвращает текст SQL-запроса
  ( <body::getSqlText>).
*/
, member function getSqlText
  return varchar2

)
/
