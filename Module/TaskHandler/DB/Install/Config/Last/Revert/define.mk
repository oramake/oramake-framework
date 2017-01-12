# При удалении не нужно останавливать выполнение заданий ( модуль не должен
# использоваться)
override SKIP_FILE_MASK += \
  Install/Config/before-action.sql \
  Install/Config/after-action.sql \


