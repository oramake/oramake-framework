create or replace package body pkg_TextService is
/* package body: pkg_TextService::body */

/* group: Методы пакета CTX_DDL */

/* proc: syncIndex
  Прокси-метод процедуры SYNC_INDEX.
*/
procedure syncIndex(
  idx_name in varchar2 default null
  , memory in varchar2 default null
  , part_name in varchar2 default null
  , parallel_degree in number default 1
  , maxtime in number default null
  , locking in number default CTX_DDL.LOCK_WAIT
)
is
begin
  CTX_DDL.SYNC_INDEX(
    idx_name => idx_name
    , memory => memory
    , part_name => part_name
    , parallel_degree => parallel_degree
    , maxtime => maxtime
    , locking => locking
  );
end syncIndex;

/* proc: optimizeIndex
  Прокси-метод процедуры OPTIMIZE_INDEX.
*/
procedure optimizeIndex(
  idx_name in varchar2
  , optlevel in varchar2
  , maxtime in number default null
  , token in varchar2 default null
  , part_name in varchar2 default null
  , token_type in number default null
  , parallel_degree in number default 1
)
is
begin
  CTX_DDL.OPTIMIZE_INDEX(
    idx_name => idx_name
    , optlevel => optlevel
    , maxtime => maxtime
    , token => token
    , part_name => part_name
    , token_type => token_type
    , parallel_degree => parallel_degree
  );
end optimizeIndex;

end pkg_TextService;
/
