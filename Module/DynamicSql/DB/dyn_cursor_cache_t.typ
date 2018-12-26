create or replace type dyn_cursor_cache_t
authid current_user
as object
(
/* db object type: dyn_cursor_cache_t
  ��� �������� ����������� �������� ������ dbms_sql.

  � ����� � ��������� ����������� ������� ����������� ������ SQL, ����������
  ������������ � ������� ����������� ( authid current_user).

  SVN root: Oracle/Module/DynamicSql
*/



/* group: �������� ���������� */



/* group: ���������� */

/* var: cacheId
  ���������� ������������� ����.
*/
cacheId integer,



/* group: �������� ���������� */



/* group: ������� */

/* pfunc: dyn_cursor_cache_t
  ������� ������.

  �������:
  - ��������� ������

  ( <body::dyn_cursor_cache_t>)
*/
constructor function dyn_cursor_cache_t
return self as result,

/* pfunc: getCursor
  ���������� ������ ��� ���������� ���������� ������������� SQL.

  ���������:
  sqlText                     - ����� SQL ��� ���������� � �������
  isSave                      - ������������ ���������� ������� � ����
                                ( 1 �� ( �� ���������), 0 ���)

  �������:
  Id ��������� ������� �� ������ dbms_sql, � ������� ��� �������� ������
  ��������� ������ SQL.

  ( <body::getCursor>)
*/
member function getCursor(
  sqlText clob
  , isSave integer := null
)
return integer,

/* pproc: freeCursor
  ����������� ������ ����� ���������� ���������� � ��� SQL.

  ���������:
  cursorId                    - Id �������
                                ( �������� ��������������� � null)

  ���������:
  - ���� ������ �� ��� �������� � ���� �������� <getCursor>, �� ��
    ����������� ����� ������ ����������� ��� ���������� �������������;

  ( <body::freeCursor>)
*/
member procedure freeCursor(
  self in dyn_cursor_cache_t
  , cursorId in out integer
),

/* pproc: closeCursor
  ��������� ������.

  ���������:
  cursorId                    - Id �������
                                ( �������� ��������������� � null)

  ( <body::closeCursor>)
*/
member procedure closeCursor(
  self in dyn_cursor_cache_t
  , cursorId in out integer
),

/* pproc: clear
  ������� ���, �������� ��� ����������� � ���� �������.

  ( <body::clear>)
*/
member procedure clear(
  self in dyn_cursor_cache_t
),

/* pfunc: getCursorUsedCount
  ���������� ����� ������������� �������.

  ���������:
  cursorId                    - Id �������

  �������:
  ����� ������������� ������� ( ����� ������� ������� <getCursor>, � ����������
  ������� ��� ��������� ������), 0 � ������ ���������� ������� � ��������� Id
  � ����.

  ( <body::getCursorUsedCount>)
*/
member function getCursorUsedCount(
  cursorId integer
)
return integer

)
/
