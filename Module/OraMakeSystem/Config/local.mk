# makefile: ��������� ������������� OMS



#
# group: ���������
#

# build var: LOCAL_OMS_VERSION
# ������ OMS, ������������� ��������.
LOCAL_OMS_VERSION=1.8.0

# ����� ������� ����� � OMS
localOmsRevisionKeyword    := \$$Revision:: 2134 $$

localOmsRevision := $(call getRevisionFromKeyword,$(localOmsRevisionKeyword))

# ���� ���������� ��������� ����� � OMS
localOmsChangeDateKeyword  := \$$Date:: 2016-05-25 10:00:00 +0400 #$$

localOmsChangeDate := $(call getDateFromKeyword,$(localOmsChangeDateKeyword))
