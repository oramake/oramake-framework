--script: Install/Schema/Last/run.sql
--Выполняет установку последней версии объектов схемы

@oms-set-indexTablespace.sql

@@pkg_file-synonym.sql

prompt * creating tables...

@@flh_request_operation.tab
@@flh_request_state.tab
@@flh_file_data.tab
@@flh_text_data.tab
@@flh_request.tab
@@flh_request_file_list.tab
@@flh_request_tmp.tab
@@flh_cached_directory.tab
@@flh_cached_file_mask.tab
@@flh_cached_file.tab
@@flh_batch_config.tab

prompt * creating foreign keys...

@@flh_request_operation.con
@@flh_request_state.con
@@flh_text_data.con
@@flh_request.con
@@flh_request_file_list.con
@@flh_cached_directory.con
@@flh_cached_file_mask.con
@@flh_cached_file.con
@@flh_batch_config.con

prompt * creating triggers...

@@flh_request_operation_bi_def.trg
@@flh_request_state_bi_define.trg
@@flh_file_data_bi_define.trg
@@flh_request_bi_define.trg
@@flh_request_file_list_bi.trg
@@flh_text_data_bi_define.trg	
@@flh_cached_directory_bi_def.trg
@@flh_cached_file_mask_bi_def.trg
@@flh_cached_file_bi_define.trg
@@flh_batch_config_bi_define.trg

prompt * creating views...

@@v_flh_request_wait.vw
@@v_flh_cached_directory_wait.vw

