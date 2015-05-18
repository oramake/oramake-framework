--script: OmsInternal/finish-install-file.sql
--��������� ���������� � ���������� ��������� ����� � ��.
--��� ���������� ���������� ���������� ��������� FinishInstallFile ������
--pkg_ModuleInstall ( ������ Oracle/Module/ModuleInfo).
--
--������ ���������� ������������� ��� �������� ����� ����� <oms-load> � �������
--SQL*Plus � ������ ������������� ���������� ���������� �� ��������� ������
--( ��. <OMS_SAVE_FILE_INSTALL_INFO>).
--
--���������:
--  - ���������� ������, ������������ ������ OMS;
--  - ������, ����������� ��-�� ������������� ������ pkg_ModuleInstall,
--    ������������;
--

set feedback off

begin
  execute immediate '
begin
  pkg_ModuleInstall.FinishInstallFile;
end;
'
  ;
exception when others then
  raise_application_error(
    -20001
    , 'OMS: ������ ��� ���������� ���������� � ���������� ��������� ����� � ��'
      || ' ( ������ OmsInternal/finish-install-file.sql).'
    , true
  );
end;
/

set feedback on
