-- script: Test/complex-condition.sql
-- ������, ������������ ������� ������� ��� ������������� sql.
-- ( ������������� ��������� � SQL*Plus)
var rc refcursor

declare

/* find
  ������� ������� � ������� ���� <�������>_<...>.

  ���������:
  prefix                      - ������� �������
  objectName                  - ��� �������
  objectCountMin              - ����������� ���������� �������� � ������
                                ���������
  objectCountMin              - ������������ ���������� �������� � ������
                                ���������
  prefixCount                 - ������������ ���������� ������� �� �������
                                ��������
  rowCount                    - ������������ ���������� �������

  ����������:
  - ��� �������� null, ��������������� ��������� �� �����������;
*/
function find(
  prefix varchar2 := null
  , objectName varchar2 := null
  , objectType varchar2 := null
  , objectCountMin integer := null
  , objectCountMax integer := null
  , prefixRowCount integer := null
  , rowCount integer := null
)
return sys_refcursor
is

  -- ������������ ������
  rc sys_refcursor;

  -- ����������� ����������� ����� �������
  dsql dyn_dynamic_sql_t := dyn_dynamic_sql_t( '
select
  prefix
  , object_name
  , object_type
  , prefix_row_number
  , prefix_object_count
from
  (
  select
    t.*
    , count(1) over( partition by
        prefix
      ) as prefix_object_count
    , row_number() over( partition by
        prefix
      order by rownum
      ) as prefix_row_number
  from
    (
    select
      t.*
      , substr( object_name, 1, delimiter_pos - 1) as prefix
    from
      (
      select
        t.*
        , instr( object_name, ''_'') as delimiter_pos
      from
        user_objects t
      where
        $(objectCondition)
      ) t
    where
      delimiter_pos > 0
    ) t
  where
    $(prefixCondition)
  )
'
  );

begin

  -- ������� �� ������
  dsql.addCondition(
    'lower( t.object_name) like lower( :objectName) escape ''\'''
    , objectName is null
  );
  dsql.addCondition(
    'lower( t.object_type) like lower( :objectType) escape ''\'''
    , objectType is null
  );
  dsql.useCondition( 'objectCondition');

  -- ������� �� �������
  dsql.addCondition(
    'lower( prefix) like lower( :prefix) escape ''\'''
    , prefix is null
  );
  dsql.useCondition( 'prefixCondition');

  -- ������ ������� ��� ������ �������� �������
  dsql.addCondition(
    'prefix_object_count >=', objectCountMin is null, 'objectCountMin'
  );
  dsql.addCondition(
    'prefix_object_count <=', objectCountMax is null, 'objectCountMax'
  );
  dsql.addCondition(
    'prefix_row_number <=', prefixRowCount is null, 'prefixRowCount'
  );
  dsql.addCondition(
    'rownum <=', rowCount is null, 'rowCount'
  );

  -- ����� ������ ������� ��� �������
  pkg_Common.OutputMessage( dsql.getSqlText);

  -- ��������� ������
  open rc for
    dsql.getSqlText()
  using
    objectName
    , objectType
    , prefix
    , objectCountMin
    , objectCountMax
    , prefixRowCount
    , rowCount
  ;
  return rc;
end find;

begin

  -- �������� �� ����� 100 ������� ��������, ��� ������� ���������� �������� �
  -- ��� �� ��������� �� 50, ������ �������� �� ����� 5 �� ������
  -- �������.
  :rc := find(
    objectCountMin => 10
    , prefixRowCount => 5
    , rowCount => 100
  );
end;
/

print rc
