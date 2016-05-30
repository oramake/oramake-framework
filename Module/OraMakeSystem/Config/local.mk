# makefile: Локальная инициализация OMS



#
# group: Константы
#

# build var: LOCAL_OMS_VERSION
# Версия OMS, установленная локально.
LOCAL_OMS_VERSION=1.8.0

# Номер ревизии файла в OMS
localOmsRevisionKeyword    := \$$Revision:: 24409882 $$

localOmsRevision := $(call getRevisionFromKeyword,$(localOmsRevisionKeyword))

# Дата последнего изменения файла в OMS
localOmsChangeDateKeyword  := \$$Date:: 2016-05-30 10:22:40 +0300 #$$

localOmsChangeDate := $(call getDateFromKeyword,$(localOmsChangeDateKeyword))
