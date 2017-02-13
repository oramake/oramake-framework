create or replace package pkg_TextService is
/* package: pkg_TextService
  Интерфейсный пакет модуля TextService.

  SVN root: Oracle/Module/TextService
*/

/* const: Module_Name
  Название модуля, к которому относится пакет.
*/
Module_Name constant varchar2(30) := 'TextService';

/* group: Методы пакета CTX_DDL */

/* pproc: syncIndex
  Прокси-метод процедуры SYNC_INDEX.
  
  ( <body::syncIndex>)    
*/
procedure syncIndex(
  idx_name in varchar2 default null
  , memory in varchar2 default null
  , part_name in varchar2 default null
  , parallel_degree in number default 1
  , maxtime in number default null
  , locking in number default CTX_DDL.LOCK_WAIT
);

/* pproc: optimizeIndex
  Прокси-метод процедуры OPTIMIZE_INDEX.
  
  ( <body::optimizeIndex>)    
*/
procedure optimizeIndex(
  idx_name in varchar2
  , optlevel in varchar2
  , maxtime in number default null
  , token in varchar2 default null
  , part_name in varchar2 default null
  , token_type in number default null
  , parallel_degree in number default 1
);

end pkg_TextService;
/
