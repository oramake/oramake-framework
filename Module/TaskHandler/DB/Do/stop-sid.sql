--script: Do/stop-sid.sql
--�������� ����������� ������� ���������.
--
--���������:
--sessionSid                  - SID ������ ( null ��� �����������)

define sessionSid = "&1"



begin
  pkg_TaskHandler.sendStopCommand(
    sessionSid => &sessionSid
  );
end;
/



undefine sessionSid
