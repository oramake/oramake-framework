LOAD_FILE_MASK = \
  Common/lg_after_server_error.trg \
  */v_lg_context_change.vw \
  */v_lg_context_change_log.vw \
  */lg_log_bi_define.trg \
  */lg_context_type_bi_define.trg \
  */lg_log.comment.sql \
  lg_logger_t.ty? \
  pkg_Logging.pk? \
  pkg_LoggingInternal.pk? \
  pkg_LoggingErrorStack.pk? \


override SKIP_FILE_MASK += \
  Install/Data/* \


