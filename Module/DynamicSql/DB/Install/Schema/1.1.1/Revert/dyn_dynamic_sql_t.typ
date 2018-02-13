@oms-drop-type.sql dyn_dynamic_sql_t

create or replace type dyn_dynamic_sql_t
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
  mSqlText varchar2(32767)

/* ivar: mConditionText
  ����� ������� �������.
*/
, mConditionText varchar2(32767)

/* ivar: mParameterCount
  ����� ���������� �������.
*/
, mParameterCount integer



/* group: �������� ���������� */

/* pfunc: dyn_dynamic_sql_t
  ������� ������
  ( <body::dyn_dynamic_sql_t>).
*/
, constructor function dyn_dynamic_sql_t(
    sqlText varchar2
  )
  return self as result

/* pproc: addCondition
  ��������� ������� � ������
  ( <body::addCondition>).
*/
, member procedure addCondition(
    conditionText varchar2
    , isNullValue boolean
    , parameterName varchar2 := null
  )

/* func: useCondition
  �������� ��������������� $(macroName) � ������ ������� �� ��������� �
  �����������
  ( <body::useCondition>).
*/
, member procedure useCondition(
    macroName varchar2
  )

/* pfunc: getSqlText
  ���������� ����� SQL-�������
  ( <body::getSqlText>).
*/
, member function getSqlText
  return varchar2

)
/
