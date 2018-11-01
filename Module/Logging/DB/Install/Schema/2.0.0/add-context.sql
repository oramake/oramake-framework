@oms-run Install/Schema/Last/lg_context_type.tab
@oms-run Install/Schema/Last/lg_context_type.con
@oms-run Install/Schema/Last/lg_context_type_seq.sqs

-- add *context* columns
@oms-run add-context-cols.sql
