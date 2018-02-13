create or replace type dyn_dynamic_sql_t force
as object
(
/* db object type: dyn_dynamic_sql_t
  ��������� ����� ������������� SQL, ���������� �� �������� ����������.

  SVN root: Oracle/Module/DynamicSql

*/


/* group: �������� ���������� */


/* ivar: mSqlText
  ����� SQL-�������.
*/
mSqlText                    varchar2(32767),

/* ivar: mConditionText
  ����� ������� �������.
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
  ����� ���������� �������.
*/
mParameterCount             integer,


/* group: �������� ���������� */


/* pfunc: dyn_dynamic_sql_t
  ������� ������
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
  ��������� ������� � ������
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
  �������� ��������������� $(macroName) � ������ ������� �� ��������� �
  �����������
  (<body::useCondition>).
*/
member procedure useCondition(
  macroName                 in varchar2
),

/* pfunc: getSqlText
  ���������� ����� SQL-�������
  (<body::getSqlText>).
*/
member function getSqlText
return varchar2

)
/
