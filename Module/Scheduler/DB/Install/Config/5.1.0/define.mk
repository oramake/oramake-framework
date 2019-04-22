LOAD_FILE_MASK = \
  */v_sch_batch_operation.vw \
  sch_log*_t.ty? \
  pkg_Scheduler.pk? \
  pkg_SchedulerMain.pk? \


override SKIP_FILE_MASK += \
  Install/Batch/Last/ClearOldLog/* \
  */PublicJob/*[^k].job.sql \
  */PublicJob/rollback.job.sql \
  Install/Data/Last/sch* \


