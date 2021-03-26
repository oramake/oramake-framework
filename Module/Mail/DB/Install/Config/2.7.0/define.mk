LOAD_FILE_MASK = \
  Mail.jav \
  pkg_*.pk? \
  $(JAVAMAIL_LIB) \


override SKIP_FILE_MASK += \
  Install/Data/Last/ml* \


BATCH_MASK = SendMailHandler
