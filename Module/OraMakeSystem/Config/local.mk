# makefile: ��������� ������������� OMS



#
# group: ���������
#

# build var: LOCAL_OMS_VERSION
# ������ OMS, ������������� ��������.
LOCAL_OMS_VERSION=1.8.0

# ����� ������� ����� � OMS
localOmsRevisionKeyword    := \$$Revision:: 24409882 $$

localOmsRevision := $(call getRevisionFromKeyword,$(localOmsRevisionKeyword))

# ���� ���������� ��������� ����� � OMS
localOmsChangeDateKeyword  := \$$Date:: 2016-05-30 10:22:40 +0300 #$$

localOmsChangeDate := $(call getDateFromKeyword,$(localOmsChangeDateKeyword))
