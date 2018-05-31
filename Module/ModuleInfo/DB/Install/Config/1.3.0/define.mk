LOAD_FILE_MASK = \
  pkg_ModuleInstall.pk? \
  pkg_ModuleInfoInternal.pk? \


override SKIP_FILE_MASK += \
  Install/Data/Last/* \
  */oms-check-install-version.sql \


