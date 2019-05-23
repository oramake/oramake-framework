SQL_DEFINE += ,maxBatchWait=$(BATCH_WAIT)


ifeq ($(strip $(NO_ACCESSOPERATOR)),1)

override SKIP_FILE_MASK += Install/Schema/*/AccessOperatorAddon/*

endif

