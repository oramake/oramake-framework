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

pkg_FileHandler.pkb.$(lu):                 \
  pkg_FileHandler.pks.$(lu) \
  pkg_FileHandlerRequest.pks.$(lu)\
  pkg_FileHandlerBase.pks.$(lu)

pkg_FileHandlerUtility.pkb.$(lu):   \
 pkg_FileHandlerUtility.pks.$(lu)

pkg_FileHandlerBase.pkb.$(lu):   \
  pkg_FileHandlerBase.pks.$(lu)

pkg_FileHandlerRequest.pks.$(lu): \
  pkg_FileHandlerBase.pks.$(lu) \

pkg_FileHandlerRequest.pkb.$(lu):           \
  pkg_FileHandlerRequest.pks.$(lu)\
  pkg_FileHandlerBase.pks.$(lu) \
  pkg_FileHandlerCachedDirectory.pks.$(lu) \
  pkg_FileHandlerUtility.pks.$(lu)

pkg_FileHandlerCachedDirectory.pkb.$(lu):   \
  pkg_FileHandlerCachedDirectory.pks.$(lu) \
  pkg_FileHandlerBase.pks.$(lu)\
  pkg_FileHandlerRequest.pks.$(lu)\
  pkg_FileHandlerUtility.pks.$(lu)