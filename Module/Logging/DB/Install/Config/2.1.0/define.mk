LOAD_FILE_MASK = \
  */v_lg_context_change_log.vw \
  */v_lg_current_log.vw \
  pkg_Logging.pk? \
  pkg_LoggingInternal.pk? \
  lg_logger_t.ty? \


override SKIP_FILE_MASK += \
  Install/Data/Last/lg_destination.sql \


