
override SKIP_FILE_MASK += ,*oms-check-lock*

ifneq ($(MAKECMDGOALS),install-save-info)
  override SKIP_FILE_MASK += ,*oms-save-install-info*
endif

OMS_SAVE_FILE_INSTALL_INFO = 0
