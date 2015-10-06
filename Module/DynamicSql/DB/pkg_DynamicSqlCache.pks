create or replace package pkg_DynamicSqlCache
authid current_user
is
/* package: pkg_DynamicSqlCache
  ���������� ����������� �� ����������� �������� ������ dbms_sql.

  � ����� � ��������� ����������� ������� ����������� ������ SQL, ����������
  ������������ � ������� ����������� ( authid current_user).

  SVN root: Oracle/Module/DynamicSql
*/



/* group: ��������� */

/* const: Module_Name
  ��� ������, � �������� ��������� �����.
*/
Module_Name constant varchar2(20) := 'DynamicSql';



/* group: ������� */



/* group: ���������� ���������� <dyn_cursor_cache_t> */

/* pfunc: getNextCacheId
  ���������� Id ��� ������ ������� ���� ( ���������� � ������ ������).

  ( <body::getNextCacheId>)
*/
function getNextCacheId
return integer;

/* pproc: closeCursor
  ��������� ������.

  ���������:
  cursorId                    - Id �������
                                ( �������� ��������������� � null)
  cacheId                     - Id ������� ���� ��������
                                ( ���� �������, �� ����������� ��������
                                �������������� ������� ���������� ���� � ������
                                ������� ������� � ����)

  ( <body::closeCursor>)
*/
procedure closeCursor(
  cursorId in out integer
  , cacheId integer := null
);

/* pfunc: getCursor
  ���������� ������ ��� ���������� ���������� ������������� SQL.

  ���������:
  cacheId                     - Id ������� ���� ��������
  sqlText                     - ����� SQL ��� ���������� � �������
  isSave                      - ������������ ���������� ������� � ����
                                � ������ �������� ������ �������
                                ( 1 �� ( �� ���������), 0 ���)

  �������:
  Id ��������� ������� �� ������ dbms_sql, � ������� ��� �������� ������
  ��������� ������ SQL ( null ���� � sqlText ������� null)

  ( <body::getCursor>)
*/
function getCursor(
  cacheId integer
  , sqlText varchar2
  , isSave integer := null
)
return integer;

/* pproc: freeCursor
  ����������� ������ ����� ���������� ���������� � ��� SQL.

  ���������:
  cacheId                     - Id ������� ���� ��������
  cursorId                    - Id �������
                                ( �������� ��������������� � null)

  ���������:
  - ���� ������ �� ��� �������� � ���� �������� <getCursor>, �� ��
    ����������� ����� ������ ����������� ��� ���������� �������������;

  ( <body::freeCursor>)
*/
procedure freeCursor(
  cacheId integer
  , cursorId in out integer
);

/* pproc: clear
  ������� ��������� ��� ��������, �������� ��� ����������� � ���� �������.

  ���������:
  cacheId                     - Id ������� ���� ��������

  ( <body::clear>)
*/
procedure clear(
  cacheId integer
);

/* pfunc: getCursorUsedCount
  ���������� ����� ������������� �������.

  ���������:
  cacheId                     - Id ������� ���� ��������
  cursorId                    - Id �������

  �������:
  ����� ������������� ������� ( ����� ������� ������� <getCursor>, � ����������
  ������� ��� ��������� ������), 0 � ������ ���������� ������� � ��������� Id
  � ����.

  ( <body::getCursorUsedCount>)
*/
function getCursorUsedCount(
  cacheId integer
  , cursorId integer
)
return integer;



/* group: ���������� ������� */

/* pproc: setMaxCachedCursor
  ������������� ������������ ����� ���������� �������� ( �������� �� ����
  �������� ����).


  ���������:
  cursorCount                 - ����� ��������

  ( <body::setMaxCachedCursor>)
*/
procedure setMaxCachedCursor(
  cursorCount pls_integer
);

/* pfunc: getCachedCursorCount
  ���������� ����� ������������ �������� ( �������� �� ���� �������� ����).

  �������:
  ����� ��������.

  ( <body::getCachedCursorCount>)
*/
function getCachedCursorCount
return integer;

end pkg_DynamicSqlCache;
/
