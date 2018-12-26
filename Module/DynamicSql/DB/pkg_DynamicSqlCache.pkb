create or replace package body pkg_DynamicSqlCache is
/* package body: pkg_DynamicSqlCache::body */



/* group: ���� */

/* itype: IntegerStringT
  ��� ��� ���������� �������� ���� integer � ���� ������.
  ��-�� ����������� ����������� �� ���� ������������� �������� ������ ���
  ������������ ������ integer.
*/
subtype IntegerStringT is varchar2(38);

/* itype: CursorCacheKeyT
  ��� ����� ��� ���� �������� ��������.
  � �������� ����� ������������ Id ������� � ���� ������.
*/
subtype CursorCacheKeyT is IntegerStringT;

/* itype: CursorByLastUsedKeyT
  ��� ����� ��� ������ ������������ �������� �� ������ ���������� �������������.
  � �������� ����� ������������ ����� ���������� �������������, �����������
  ����� �������� ������ ( ��� ����������� ���������� � ������������ � ��������
  ���������).
*/
subtype CursorByLastUsedKeyT is IntegerStringT;

/* itype: CursorCacheItemT
  ��� �������� ��� ���� �������� ��������.
*/
type CursorCacheItemT is record
(

  -- Id ����, � �������� ��������� ������
  cacheId integer

  -- ����� SQL, ����������� � �������
  , sqlText clob

  -- Id �������
  , cursorId integer

  -- ������� �������� ������������� ������� ( ������ ��� ��������� ��������
  -- <getCursor> � ����� ����� �� ���� ������� ������� <freeCursor>)
  , isUsed boolean

  -- ����� ������������� �������
  , usedCount integer

  -- ���������� ����� ���������� ������������� ( � ���� ������)
  , lastUsedKey CursorByLastUsedKeyT
);

/* itype: CursorCacheT
  ��� ���� �������� ��������.
*/
type CursorCacheT is table of CursorCacheItemT index by CursorCacheKeyT;

/* itype: CursorByLastUsedT
  ��� ��� �������������� �� ������ ���������� ������������� ������ ��������
  ����. ������������ ����������� ����� ����� ������������ ��������.
*/
type CursorByLastUsedT is table of
  CursorCacheKeyT
index by
  CursorByLastUsedKeyT
;

/* itype: CursorCacheKeyColT
  ��� ��� ������ ������ ��������� � ���� �������.
*/
type CursorCacheKeyColT is table of
  CursorCacheKeyT
index by
  CursorCacheKeyT
;

/* itype: CursorBySqlLengthItemT
  ��� �������� ��� �������������� �������� ���� ��� ����� SQL.
  ������ ��������� �������� ����� SQL � ���� ������.
*/
type CursorBySqlLengthItemT is table of
  CursorCacheKeyColT
index by
  pls_integer
;

/* itype: CursorBySqlLengthT
  ��� ��� �������������� �������� ���� �� ����� ���������������� �� ������ SQL.
  ������������ ��� ������������ ������ �������� �� ������ SQL.
  ������ ��������� �������� Id ���� � ���� ������.
*/
type CursorBySqlLengthT is table of
  CursorBySqlLengthItemT
index by
  IntegerStringT
;



/* group: ��������� */

/* iconst: MaxCachedCursor_Default
  ������������ ����� ���������� �������� ( �������� �� ���������).
  ���� 0, �� ��� ������� ������� ����������� ����� ������.
*/
MaxCachedCursor_Default constant pls_integer := 80;



/* group: ���������� */

/* ivar: logger
  ����� ������.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => Module_Name
  , objectName  => 'pkg_DynamicSqlCache'
);

/* ivar: maxCachedCursor
  ������������ ����� ���������� ��������.
*/
maxCachedCursor pls_integer := MaxCachedCursor_Default;

/* ivar: lastCacheId
  Id ���������� ���������� � ������ ���� ��������.
*/
lastCacheId integer;

/* ivar: cursorCacheUsedNumber
  ���������� ����� ������������� ���� �������� � ������.
*/
cursorCacheUsedNumber integer;

/* ivar: cursorCache
  ��� �������� ��������.
*/
cursorCache CursorCacheT;

/* ivar: cursorByLastUsed
  ������������� �� ������ ���������� ������������� ������� �������� ����.
*/
cursorByLastUsed CursorByLastUsedT;

/* ivar: cursorBySqlLength
  ������ �������� �� ����� ���������������� �� ������ SQL.
*/
cursorBySqlLength CursorBySqlLengthT;



/* group: ������� */



/* group: ���������� ���������� <dyn_cursor_cache_t> */


/* func: getNextCacheId
  ���������� Id ��� ������ ������� ���� ( ���������� � ������ ������).
*/
function getNextCacheId
return integer
is
begin
  lastCacheId := coalesce( lastCacheId, 0) + 1;
  return lastCacheId;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� �������� Id ��� ������ ������� ���� ��������.'
      )
    , true
  );
end getNextCacheId;

/* proc: closeCursor
  ��������� ������.

  ���������:
  cursorId                    - Id �������
                                ( �������� ��������������� � null)
  cacheId                     - Id ������� ���� ��������
                                ( ���� �������, �� ����������� ��������
                                �������������� ������� ���������� ���� � ������
                                ������� ������� � ����)
*/
procedure closeCursor(
  cursorId in out integer
  , cacheId integer := null
)
is

  -- ���� ������� � ����
  cursorKey CursorCacheKeyT;

begin
  cursorKey := to_char( cursorId);
  if cursorCache.exists( cursorKey) then
    if nullif( cacheId, cursorCache( cursorKey).cacheId) is not null then
      raise_application_error(
        pkg_Error.IllegalArgument
        , '������ ��������� � ������� ���� ('
          || ' cacheId=' || cursorCache( cursorKey).cacheId
          || ').'
      );
    end if;
    cursorByLastUsed.delete( cursorCache( cursorKey).lastUsedKey);
    cursorBySqlLength
      ( to_char( cursorCache( cursorKey).cacheId))
      ( length( cursorCache( cursorKey).sqlText))
      .delete( cursorKey)
    ;
    cursorCache.delete( cursorKey);
  end if;
  dbms_sql.close_cursor( cursorId);
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� �������� ������� ('
        || ' cursorId=' || cursorId
        || ', cacheId=' || cacheId
        || ').'
      )
    , true
  );
end closeCursor;

/* ifunc: closeUnusedCursor
  �������� ������� ��������� ����� �������������� ��������.

  ���������:
  cursorCount                 - ����� �������� ��� ��������

  �������:
  ������ � ������ �������� ����������, ����� ����.
*/
function closeUnusedCursor(
  cursorCount pls_integer
)
return boolean
is

  -- ����� �������� ��������
  nClosed pls_integer := 0;

  -- ���� �������� �������� � ��������� �� ���������� �������������
  lastUsedKey CursorByLastUsedKeyT;

  -- ���� �������� �������
  cursorKey CursorCacheKeyT;

  -- Id ������� ��� ��������
  cursorId integer;

begin
  lastUsedKey := cursorByLastUsed.first();
  while lastUsedKey is not null and nClosed < cursorCount loop
    cursorKey := cursorByLastUsed( lastUsedKey);

    -- ��������� �� ���������� �������� ��������
    lastUsedKey := cursorByLastUsed.next( lastUsedKey);

    if not cursorCache( cursorKey).isUsed then
      cursorId := cursorCache( cursorKey).cursorId;
      closeCursor( cursorId);
      nClosed := nClosed + 1;
    end if;
  end loop;
  return nClosed = cursorCount;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ������� �������� �������������� �������� ('
        || ' cursorCount=' || cursorCount
        || ').'
      )
    , true
  );
end closeUnusedCursor;

/* func: getCursor
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
*/
function getCursor(
  cacheId integer
  , sqlText clob
  , isSave integer := null
)
return integer
is

  -- Id �������
  cursorId integer;

  -- Id ���� � ���� ������
  cacheIdString IntegerStringT;

  -- ����� ������ SQL
  sqlLength pls_integer;

  -- ����������� ���������� ������ ������� � ����
  isAllowSave boolean :=
    coalesce( isSave, 1) != 0
    and maxCachedCursor > 0
  ;



  /*
    ������������� ����� �������� ���������� ������������� �������.
  */
  procedure setLastUsed(
    lastUsedKey in out nocopy CursorByLastUsedKeyT
    , cursorKey CursorCacheKeyT
  )
  is
  begin
    if lastUsedKey is not null then
      cursorByLastUsed.delete( lastUsedKey);
    end if;
    cursorCacheUsedNumber := coalesce( cursorCacheUsedNumber, 0) + 1;
    lastUsedKey := to_char( cursorCacheUsedNumber);
    cursorByLastUsed( lastUsedKey) := cursorKey;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ���������� �������� ���������� ������������ �������.'
        )
      , true
    );
  end setLastUsed;



  /*
    ���� ���������� ������ � ����.
  */
  procedure findCursor
  is



    /*
      ���� ���������� ������ ����� ��������� � ���������.
    */
    procedure find(
      keyCol CursorCacheKeyColT
    )
    is

      -- ���� ������������ �������
      cursorKey CursorCacheKeyT := keyCol.first();

    -- find
    begin
      while cursorKey is not null loop
        if cursorCache( cursorKey).sqlText = sqlText then
          if cursorCache( cursorKey).isUsed then
            logger.debug(
              'Ignore already used cursor from cache'
              || ' ( cursorId=' || cursorCache( cursorKey).cursorId || ').'
            );

            -- ��������� ���������� ������ ������� � ����, �.�. ����� ������ ���
            -- ����
            isAllowSave := false;
          else
            cursorCache( cursorKey).isUsed := true;
            cursorCache( cursorKey).usedCount :=
              cursorCache( cursorKey).usedCount + 1
            ;
            setLastUsed(
              lastUsedKey => cursorCache( cursorKey).lastUsedKey
              , cursorKey => cursorKey
            );
            cursorId := cursorCache( cursorKey).cursorId;
          end if;

          -- ��������� �����, �.�. � ��� �� ����������� ������� � ����������
          -- SQL
          exit;
        end if;
        cursorKey := keyCol.next( cursorKey);
      end loop;
    end find;



  -- findCursor
  begin
    if cursorBySqlLength.exists( cacheIdString)
        and cursorBySqlLength( cacheIdString).exists( sqlLength)
        then
      find( cursorBySqlLength( cacheIdString)( sqlLength));
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ������ ������� � ����.'
        )
      , true
    );
  end findCursor;



  /*
    ������� ����� ������.
  */
  procedure createCursor
  is
  begin

    -- ��������� ������
    cursorId := dbms_sql.open_cursor();

    -- ������ ����� �������
    dbms_sql.parse( cursorId, sqlText, dbms_sql.native);

    logger.trace(
      'createCursor: cursorId=' || cursorId
      || ', sqlText=' || substr( sqlText, 1, 50) || '...'
    );
  exception when others then
    if cursorId is not null then
      dbms_sql.close_cursor( cursorId);
    end if;
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� �������� �������.'
        )
      , true
    );
  end createCursor;



  /*
    ��������� ������ � ����.
  */
  procedure saveCursor
  is

    -- ���� ������� � ����
    cursorKey CursorCacheKeyT;

    -- ������ �� ������� ��� ���������� � ����
    ci CursorCacheItemT;

    -- ������ ������������� ������� ��� ������������� ����
    cbslItem CursorBySqlLengthItemT;
    cckCol CursorCacheKeyColT;

  begin
    cursorKey := to_char( cursorId);

    ci.cacheId      := cacheId;
    ci.sqlText      := sqlText;
    ci.cursorId     := cursorId;
    ci.isUsed       := true;
    ci.usedCount    := 1;
    setLastUsed(
      lastUsedKey => ci.lastUsedKey
      , cursorKey => cursorKey
    );

    cursorCache( cursorKey) := ci;
    if not cursorBySqlLength.exists( cacheIdString) then
      cursorBySqlLength( cacheIdString) := cbslItem;
    end if;
    if not cursorBySqlLength( cacheIdString).exists( sqlLength) then
      cursorBySqlLength( cacheIdString)( sqlLength) := cckCol;
    end if;
    cursorBySqlLength( cacheIdString)( sqlLength)( cursorKey) := cursorKey;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ���������� ������� � ����.'
        )
      , true
    );
  end saveCursor;



-- getCursor
begin
  if sqlText is not null then
    cacheIdString := to_char( cacheId);
    sqlLength := length( sqlText);
    findCursor();

    -- ������� ����� ������, ���� �� ��� ������ ���������� ������ � ����
    if cursorId is null then
      createCursor();

      -- �������� ��������� ������ � ����
      if isAllowSave then
        if cursorCache.count() < maxCachedCursor
            or closeUnusedCursor(
                cursorCache.count() - maxCachedCursor + 1
              )
            then
          saveCursor();
        end if;
      end if;
    end if;
  end if;
  return cursorId;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ��������� ������� ��� ���������� ������������� SQL ('
        || ' cacheId=' || cacheId
        || ', isSave=' || isSave
        || ').'
      )
    , true
  );
end getCursor;

/* proc: freeCursor
  ����������� ������ ����� ���������� ���������� � ��� SQL.

  ���������:
  cacheId                     - Id ������� ���� ��������
  cursorId                    - Id �������
                                ( �������� ��������������� � null)

  ���������:
  - ���� ������ �� ��� �������� � ���� �������� <getCursor>, �� ��
    ����������� ����� ������ ����������� ��� ���������� �������������;
*/
procedure freeCursor(
  cacheId integer
  , cursorId in out integer
)
is

  -- ���� ������� � ����
  cursorKey CursorCacheKeyT;

begin
  cursorKey := to_char( cursorId);
  if cursorCache.exists( cursorKey) then
    if cursorCache( cursorKey).cacheId != cacheId then
      raise_application_error(
        pkg_Error.IllegalArgument
        , '������ ��������� � ������� ���� ('
          || ' cacheId=' || cursorCache( cursorKey).cacheId
          || ').'
      );
    end if;
    cursorCache( cursorKey).isUsed := false;
  else
    closeCursor(
      cursorId  => cursorId
      , cacheId => cacheId
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ������������ ������� ('
        || ' cacheId=' || cacheId
        || ', cursorId=' || cursorId
        || ').'
      )
    , true
  );
end freeCursor;

/* proc: clear
  ������� ��������� ��� ��������, �������� ��� ����������� � ���� �������.

  ���������:
  cacheId                     - Id ������� ���� ��������
*/
procedure clear(
  cacheId integer
)
is

  -- Id ���� � ���� ������
  cacheIdString IntegerStringT;

  -- ����� ������ SQL
  sqlLength pls_integer;

  -- ���� �������� �������
  cursorKey CursorCacheKeyT;

  -- Id ������� ��� ��������
  cursorId integer;

  -- ����� �������� ��������
  nClosed pls_integer := 0;

begin
  cacheIdString := to_char( cacheId);
  if cursorBySqlLength.exists( cacheIdString) then
    sqlLength := cursorBySqlLength( cacheIdString).first();
    while sqlLength is not null loop
      cursorKey := cursorBySqlLength( cacheIdString)( sqlLength).first();
      while cursorKey is not null loop
        cursorId := cursorCache( cursorKey).cursorId;

        -- ��������� �� �������� ��������
        cursorKey := cursorBySqlLength( cacheIdString)( sqlLength)
          .next( cursorKey)
        ;
        closeCursor( cursorId);
        nClosed := nClosed + 1;
      end loop;
      sqlLength := cursorBySqlLength( cacheIdString).next( sqlLength);
    end loop;
    cursorBySqlLength.delete( cacheIdString);
  end if;
  logger.debug(
    'clear: close cached cursor: ' || nClosed
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ������� ���� �������� ('
        || ' cacheId=' || cacheId
        || ').'
      )
    , true
  );
end clear;

/* func: getCursorUsedCount
  ���������� ����� ������������� �������.

  ���������:
  cacheId                     - Id ������� ���� ��������
  cursorId                    - Id �������

  �������:
  ����� ������������� ������� ( ����� ������� ������� <getCursor>, � ����������
  ������� ��� ��������� ������), 0 � ������ ���������� ������� � ��������� Id
  � ����.
*/
function getCursorUsedCount(
  cacheId integer
  , cursorId integer
)
return integer
is

  -- ���� ������� � ����
  cursorKey CursorCacheKeyT;

  usedCount integer := 0;

begin
  cursorKey := to_char( cursorId);
  if cursorCache.exists( cursorKey) then
    if cursorCache( cursorKey).cacheId != cacheId then
      raise_application_error(
        pkg_Error.IllegalArgument
        , '������ ��������� � ������� ���� ('
          || ' cacheId=' || cursorCache( cursorKey).cacheId
          || ').'
      );
    end if;
    usedCount := cursorCache( cursorKey).usedCount;
  end if;
  return usedCount;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ����������� ����� ������������� ������� ('
        || ' cacheId=' || cacheId
        || ', cursorId=' || cursorId
        || ').'
      )
    , true
  );
end getCursorUsedCount;



/* group: ���������� ������� */

/* proc: setMaxCachedCursor
  ������������� ������������ ����� ���������� �������� ( �������� �� ����
  �������� ����).


  ���������:
  cursorCount                 - ����� ��������
*/
procedure setMaxCachedCursor(
  cursorCount pls_integer
)
is
begin
  if cursorCount < 0 then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '������� ������������ ����� ��������.'
    );
  end if;
  maxCachedCursor := cursorCount;
  if cursorCache.count() > maxCachedCursor then
    if not closeUnusedCursor( cursorCache.count() - maxCachedCursor) then
      logger.debug(
        'setMaxCachedCursor: used cursors exceed limit: ' || cursorCache.count()
      );
    end if;
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ��������� ������������� ����� ���������� �������� ('
        || ' cursorCount=' || cursorCount
        ||').'
      )
    , true
  );
end setMaxCachedCursor;

/* func: getCachedCursorCount
  ���������� ����� ������������ �������� ( �������� �� ���� �������� ����).

  �������:
  ����� ��������.
*/
function getCachedCursorCount
return integer
is
begin
  return cursorCache.count();
end getCachedCursorCount;

end pkg_DynamicSqlCache;
/
