create or replace type dyn_cursor_cache_t
authid current_user
as object
(
/* db object type: dyn_cursor_cache_t
  Кэш открытых разобранных курсоров пакета dbms_sql.

  В связи с возможным выполнением разбора переданного текста SQL, выполнение
  производится с правами вызывающего ( authid current_user).

  SVN root: Oracle/Module/DynamicSql
*/



/* group: Закрытые объявления */



/* group: Переменные */

/* var: cacheId
  Уникальный идентификатор кэша.
*/
cacheId integer,



/* group: Открытые объявления */



/* group: Функции */

/* pfunc: dyn_cursor_cache_t
  Создает объект.

  Возврат:
  - созданный объект

  ( <body::dyn_cursor_cache_t>)
*/
constructor function dyn_cursor_cache_t
return self as result,

/* pfunc: getCursor
  Возвращает курсор для выполнения указанного динамического SQL.

  Параметры:
  sqlText                     - текст SQL для выполнения в курсоре
  isSave                      - допустимость сохранения курсора в кэше
                                ( 1 да ( по умолчанию), 0 нет)

  Возврат:
  Id открытого курсора из пакета dbms_sql, в котором был выполнен разбор
  указаного текста SQL.

  ( <body::getCursor>)
*/
member function getCursor(
  sqlText clob
  , isSave integer := null
)
return integer,

/* pproc: freeCursor
  Освобождает курсор после завершения выполнения в нем SQL.

  Параметры:
  cursorId                    - Id курсора
                                ( значение устанавливается в null)

  Замечания:
  - если курсор не был сохранен в кэше функцией <getCursor>, то он
    закрывается иначе курсор сохраняется для повторного использования;

  ( <body::freeCursor>)
*/
member procedure freeCursor(
  self in dyn_cursor_cache_t
  , cursorId in out integer
),

/* pproc: closeCursor
  Закрывает курсор.

  Параметры:
  cursorId                    - Id курсора
                                ( значение устанавливается в null)

  ( <body::closeCursor>)
*/
member procedure closeCursor(
  self in dyn_cursor_cache_t
  , cursorId in out integer
),

/* pproc: clear
  Очишает кэш, закрывая все относящиеся к нему курсоры.

  ( <body::clear>)
*/
member procedure clear(
  self in dyn_cursor_cache_t
),

/* pfunc: getCursorUsedCount
  Возвращает число использований курсора.

  Параметры:
  cursorId                    - Id курсора

  Возврат:
  число использований курсора ( число вызовов функции <getCursor>, в результате
  которых был возвращен курсор), 0 в случае отсутствия курсора с указанным Id
  в кэше.

  ( <body::getCursorUsedCount>)
*/
member function getCursorUsedCount(
  cursorId integer
)
return integer

)
/
