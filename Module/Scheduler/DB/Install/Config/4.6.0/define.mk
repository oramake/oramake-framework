LOAD_FILE_MASK = \
  */v_sch_batch_root_log.vw \
  */v_sch_batch_root_log_old.vw \
  */v_sch_batch_result.vw \
  */v_sch_batch_operation.vw \
  pkg_Scheduler.pk? \
  pkg_SchedulerLoad.pk? \
  pkg_SchedulerMain.pk? \


override SKIP_FILE_MASK += \
  Install/Data/Last/sch_* \


