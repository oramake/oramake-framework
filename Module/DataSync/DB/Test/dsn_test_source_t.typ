create or replace type dsn_test_source_t force
under dsn_data_sync_source_t
(
/* db object type: dsn_test_source_t
  ������� ��� ������ � ��������� �������� �����, ������������� ��� ����������
  ������������ ������ ( ���������� �����, ������� ����� dsn_data_sync_source_t).

  ������ �������� � ������� ����������� ( authid current_user, �.�. ���
  ������ � ������� ������).

  SVN root: Oracle/Module/DataSync
*/



/* group: ������� */

/* pfunc: dsn_test_source_t
  ����������� �������.

  ( <body::dsn_test_source_t>)
*/
constructor function dsn_test_source_t
return self as result

)
/
