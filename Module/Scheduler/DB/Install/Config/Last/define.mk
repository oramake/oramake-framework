# При первоначальной установке не нужно отключать батчи
override SKIP_FILE_MASK += \
  Install/Config/before-action.sql \
  Install/Config/after-action.sql \

