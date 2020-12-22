LOAD_FILE_MASK = \
  Mail.jav \
  pkg_Mail.pk? \
  pkg_MailHandler.pk? \


override SKIP_FILE_MASK += \
  Install/Batch/Last/[CFNR]* \
  */PublicJob/send_mail_message.job.sql \
  */PublicJob/fetch_mail_handler.job.sql \
  Install/Data/* \

