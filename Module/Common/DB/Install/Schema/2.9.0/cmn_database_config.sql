alter table
  cmn_database_config
add
(
  test_notify_flag              number(1,0)
  , sender_domain               varchar2(100)
  , default_flag                number(1,0)               default 0 not null
  , constraint cmn_database_config_chk_not_fl check
    (test_notify_flag in ( 0, 1))
  , constraint cmn_database_config_chk_if_def check
    (default_flag in ( 0, 1))
)
/



comment on table cmn_database_config is
  '��������� ��� ���� ������ [ SVN root: Oracle/Module/Common]'
/
comment on column cmn_database_config.instance_name is
  '��� ��������� ��, � ������� ��������� ��������� ( ������������ ��� ����� ��������, � ������ ���������� �������� ���� ������ ��������� ��������)'
/
comment on column cmn_database_config.is_production is
  '���� ������������ �� ( 1 ������������, 0 ��������)'
/
comment on column cmn_database_config.ip_address_production is
  'IP-����� ������������� ������� �� ( ���� ������, �� �� ����� ��������� ������������ ������ � ������ ���������� IP-������ ������� � ���������, ��� ���������� IP-����� ������� �� �� �����������)'
/
comment on column cmn_database_config.test_notify_flag is
  '���� �������� ����������� � �������� ����� ( 1 ����, 0 �� ����, �� ��������� ����������� �� ����)'
/
comment on column cmn_database_config.sender_domain is
  '����� �����������, ����������� ��� ���������� � SMTP-�������� ( ��� ���������� ������������ SMTP-������ �� ���������, �������� � ������ �� ���������)'
/
comment on column cmn_database_config.smtp_server is
  '������������ SMTP-������ ( ��� ��� ip-�����, ��� ���������� ������������ SMTP-������ �� ���������, �������� � ������ �� ���������)'
/
comment on column cmn_database_config.notify_email is
  '����� ��� �������� ����������� �� e-mail ( ��� ���������� ������������ ����� �� ���������, �������� � ������ �� ���������)'
/
comment on column cmn_database_config.default_flag is
  '������� ����, ��� ��� ������ � ������� �� ���������'
/
