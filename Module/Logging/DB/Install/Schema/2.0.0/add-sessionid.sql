alter table
  lg_log
add (
  sessionid                     number
)
/

alter table
  lg_log
modify (
  sessionid  not null
      enable novalidate
)
/




comment on column lg_log.sessionid is
  '������������� ������ (�������� v$session.audsid ���� ���������� ������������� �������� ���� v$session.audsid ����� 0)'
/
