--trigger: lg_after_server_error
--Триггер на системное событие ошибки на сервере, логирующий сообщение об
--ошибке при передаче исключения клиенту
--
--Примечание:
--	- вызывает <pkg_LoggingErrorStack.LogErrorStack>
create or replace trigger lg_after_server_error
  after servererror
  on schema
begin
  pkg_LoggingErrorStack.LogErrorStack(
    messageText => 'Ошибка передана клиенту Oracle'
  );
end;
/
