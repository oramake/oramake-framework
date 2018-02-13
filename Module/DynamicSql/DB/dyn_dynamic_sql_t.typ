create or replace type dyn_dynamic_sql_t force
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
mSqlText                    varchar2(32767),

/* ivar: mConditionText
  Текст условий запроса.
*/
mConditionText              varchar2(32767),

/* ivar: groupText
  Conditions in a group
*/
groupText                   varchar2(32767),

/* ivar: groupOpened
  Indicate if conditions group opened
*/
groupOpened                 number(1),

/* ivar: mParameterCount
  Число параметров запроса.
*/
mParameterCount             integer,


/* group: Открытые объявления */


/* pfunc: dyn_dynamic_sql_t
  Создает объект
  (<body::dyn_dynamic_sql_t>).
*/
constructor function dyn_dynamic_sql_t(
  sqlText                   in varchar2
)
return self as result,

/* pproc: openGroup
  Open group of conditions
  (<body::openGroup>)
*/
member procedure openGroup,

/* pproc: closeGroup
  Close group of conditions
  
  Params:
  
  logicalOperator           - logical operator ('and' by default)
  
  (<body::closeGroup>)
*/
member procedure closeGroup(
  logicalOperator           in varchar2 := null
),

/* pproc: addCondition
  Добавляет условие в запрос
  (<body::addCondition>).
*/
member procedure addCondition(
  conditionText             in varchar2
, isNullValue               in boolean
, parameterName             in varchar2 := null
, logicalOperator           in varchar2 := null
),

/* pproc: addCondition
  Add new filter condition

  Params:
  
  conditionText             - free text filter condition
  logicalOperator           - logical operator ('and' by default)
  
  (<body::addCondition>)
*/
member procedure addCondition(
  conditionText             in varchar2
, logicalOperator           in varchar2 := null
),

/* pfunc: useCondition
  Заменяет макропеременную $(macroName) в тексте запроса на выражение с
  параметрами
  (<body::useCondition>).
*/
member procedure useCondition(
  macroName                 in varchar2
),

/* pfunc: getSqlText
  Возвращает текст SQL-запроса
  (<body::getSqlText>).
*/
member function getSqlText
return varchar2

)
/
