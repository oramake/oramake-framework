
override SKIP_FILE_MASK += ,*oms-check-lock*,*oms-save-uninstall-info.sql

ifneq ($(MAKECMDGOALS),install-save-info)
  override SKIP_FILE_MASK += ,*oms-save-install-info*, *oms-check-install-version*
endif

OMS_SAVE_FILE_INSTALL_INFO = 0
