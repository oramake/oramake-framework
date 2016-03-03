--script: Install/Schema/Last/run.sql
--Выполняет установку последней версии объектов схемы

@oms-set-indexTablespace.sql

@@dsz_header.tab
@@dsz_segment.tab
@@dsz_segment_group_tmp.tab

@@dsz_header.con
@@dsz_segment.con

