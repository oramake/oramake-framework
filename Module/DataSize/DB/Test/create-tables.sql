select lower('
  OWNER           VARCHAR2(30),
  SEGMENT_NAME    VARCHAR2(81),
  PARTITION_NAME  VARCHAR2(30),
  SEGMENT_TYPE    VARCHAR2(18),
  TABLESPACE_NAME VARCHAR2(30),
  HEADER_FILE     NUMBER,
  HEADER_BLOCK    NUMBER,
  BYTES           NUMBER,
  BLOCKS          NUMBER,
  EXTENTS         NUMBER,
  INITIAL_EXTENT  NUMBER,
  NEXT_EXTENT     NUMBER,
  MIN_EXTENTS     NUMBER,
  MAX_EXTENTS     NUMBER,
  PCT_INCREASE    NUMBER,
  FREELISTS       NUMBER,
  FREELIST_GROUPS NUMBER,
  RELATIVE_FNO    NUMBER,
  BUFFER_POOL     VARCHAR2(7)
') from dual;

select * from
(
select d.*, count(1) over( partition by  
  owner,segment_name,partition_name ) as  c from dba_segments d
) where c > 1

select * from dba_objects where object_name = 'SF_FAX_PROJECT_TEMPLATE'

SF_FAX_PROJECT_TEMPLATE

select 
'comment on column ' || lower( table_name || '.' || column_name ) || ' is
''' || 'Поле, в которое записывается dba_segments.' || lower( column_name ) || '''
/'
from all_tab_cols where column_name not in ('HEADER_ID','SEGMENT_ID','DATE_INS') and table_name = 'DSZ_SEGMENT'

begin
  pkg_ScriptUtility.MakeColumnList('dsz_segment', duplicateWithAs => true);
end;
