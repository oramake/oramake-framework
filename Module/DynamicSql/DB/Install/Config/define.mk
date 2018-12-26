SQL_DEFINE += ,maxBatchWait=$(BATCH_WAIT)
SQL_DEFINE += ,forcedJobQueueProcesses=$(JOB_QUEUE_PROCESSES)


ifeq ($(strip $(NO_ACCESSOPERATOR)),1)

override SKIP_FILE_MASK += Install/Schema/Last/AccessOperatorAddon/*

endif

