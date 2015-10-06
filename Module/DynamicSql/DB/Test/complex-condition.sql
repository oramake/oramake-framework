-- script: Test/complex-condition.sql
-- Скрипт, использующий сложные условия для динамического sql.
-- ( рекомендуется выполнять в SQL*Plus)
var rc refcursor

declare

/* find
  Находит объекты с именами вида <Префикс>_<...>.

  Параметры:
  prefix                      - префикс объекта
  objectName                  - имя объекта
  objectCountMin              - минимальное количество объектов с данным
                                префиксом
  objectCountMin              - максимальное количество объектов с данным
                                префиксом
  prefixCount                 - максимальное количество записей по каждому
                                префиксу
  rowCount                    - максимальное количество записей

  Примечание:
  - при значении null, соответствующие параметры не учитываются;
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

  -- Возвращаемый курсор
  rc sys_refcursor;

  -- Динамически формируемый текст запроса
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

  -- Условия на объект
  dsql.addCondition(
    'lower( t.object_name) like lower( :objectName) escape ''\'''
    , objectName is null
  );
  dsql.addCondition(
    'lower( t.object_type) like lower( :objectType) escape ''\'''
    , objectType is null
  );
  dsql.useCondition( 'objectCondition');

  -- Условие на префикс
  dsql.addCondition(
    'lower( prefix) like lower( :prefix) escape ''\'''
    , prefix is null
  );
  dsql.useCondition( 'prefixCondition');

  -- Прочие условия для самого внешнего запроса
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

  -- Вывод текста запроса для отладки
  pkg_Common.OutputMessage( dsql.getSqlText);

  -- Выполняем запрос
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

  -- Получаем не более 100 записей объектов, для которых количество объектов с
  -- тем же префиксом от 50, причём выводить не более 5 на каждый
  -- префикс.
  :rc := find(
    objectCountMin => 10
    , prefixRowCount => 5
    , rowCount => 100
  );
end;
/

print rc
