--trigger: lg_after_server_error
--������� �� ��������� ������� ������ �� �������, ���������� ��������� ��
--������ ��� �������� ���������� �������
--
--����������:
--	- �������� <pkg_LoggingErrorStack.LogErrorStack>
create or replace trigger lg_after_server_error
  after servererror
  on schema
begin
  pkg_LoggingErrorStack.LogErrorStack(
    messageText => '������ �������� ������� Oracle'
  );
end;
/
