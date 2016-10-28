LOAD_FILE_MASK = \
  */v_sch_role_privilege.vw \
  pkg_SchedulerMain.pk? \
  pkg_SchedulerLoad.pk? \


override SKIP_FILE_MASK += \
  Install/Batch/* \
  Install/Data/Last/sch_* \


