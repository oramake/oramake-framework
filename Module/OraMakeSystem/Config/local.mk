# makefile: Локальная инициализация OMS



#
# group: Константы
#

# build var: LOCAL_OMS_VERSION
# Версия OMS, установленная локально.
LOCAL_OMS_VERSION=1.8.0

# Номер ревизии файла в OMS
localOmsRevisionKeyword    := \$$Revision:: 2134 $$

localOmsRevision := $(call getRevisionFromKeyword,$(localOmsRevisionKeyword))

# Дата последнего изменения файла в OMS
localOmsChangeDateKeyword  := \$$Date:: 2016-05-25 10:00:00 +0400 #$$

localOmsChangeDate := $(call getDateFromKeyword,$(localOmsChangeDateKeyword))
