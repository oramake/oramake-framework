#
# ����������� ��� �������� ������ � ��.
#
# ����� � ������������ ������ ����������� � �������������� ���������:
# .$(lu)      - �������� ��� ������ �������������
# .$(lu2)     - �������� ��� ������ �������������
# .$(lu3)     - �������� ��� ������� �������������
# ...         - ...
#
# ������ ( ����������� ���� ������ pkg_TestModule �� ����������� ������������
# � ������������ ������ pkg_TestModule2 ��� �������� ��� ������ �������������):
#
# pkg_TestModule.pkb.$(lu): \
#   pkg_TestModule.pks.$(lu) \
#   pkg_TestModule2.pks.$(lu)
#
#
# ���������:
# - � ������ ����� �� ������ �������������� ������ ��������� ( ������ ���� ���
#   �������������� ����� ������������ �������), �.�. ������ ��������� �����
#   ����������� �������� ��� make � ��� ��������� ��������� ����� �������� �
#   �������������������� �������;
# - � ������, ���� ��������� ������ ����������� ����� ����������� ��������
#   ������������� ( �������� ����� ������), �� ����� �����������
#   ������ ���� ��� ������� ���� ������ ������, ����� ��� �������� �����
#   ��������� ������ "*** No rule to make target ` ', needed by ...";
# - ����� � ����������� ������ ����������� � ����� ������������ �������� DB
#   � ������ ��������, �������� "Install/Schema/Last/test_view.vw.$(lu): ...";
#

pkg_FileBase.pkb.$(lu): \
  pkg_FileBase.pks.$(lu) \
  pkg_FileOrigin.pks.$(lu) \


pkg_FileOrigin.pkb.$(lu): \
  pkg_FileOrigin.pks.$(lu) \
  pkg_File.jav.$(lu) \


pkg_FileUtility.pkb.$(lu): \
  pkg_FileUtility.pks.$(lu) \
  pkg_FileOrigin.pks.$(lu) \


pkg_File.jav.$(lu): \
  Java/Lib/NetFile.jav.$(lu) \


Java/Lib/NetFile.jav.$(lu): \
  pkg_FileBase.pks.$(lu) \
  $(addsuffix .$(lu),$(loadJavaUsedLibJar)) \


$(HTTPCLIENT_DIR)/lib/httpclient-4.3.6.jar.$(lu): \
  $(HTTPCLIENT_DIR)/lib/commons-codec-1.6.jar.$(lu) \
  $(addsuffix .ignore.$(lu),$(HTTPCLIENT_DIR)/lib/commons-logging-1.1.3.jar) \
  $(HTTPCLIENT_DIR)/lib/httpcore-4.3.3.jar.$(lu) \


$(HTTPCLIENT_DIR)/lib/fluent-hc-4.3.6.jar.$(lu): \
  $(HTTPCLIENT_DIR)/lib/commons-codec-1.6.jar.$(lu) \
  $(addsuffix .ignore.$(lu),$(HTTPCLIENT_DIR)/lib/commons-logging-1.1.3.jar) \
  $(HTTPCLIENT_DIR)/lib/httpcore-4.3.3.jar.$(lu) \
  $(HTTPCLIENT_DIR)/lib/httpclient-4.3.6.jar.$(lu) \


