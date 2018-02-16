LOAD_FILE_MASK = -


override SKIP_FILE_MASK += \
  Install/Config/* \
  */task_handler.job.sql \
  */Data/* \


BATCH_MASK = RestartTaskProcessing

UPDATE_OPTION_VALUE = 1
