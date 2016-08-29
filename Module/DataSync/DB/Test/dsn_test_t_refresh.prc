/* proc: dsn_test_t_refresh
  ������� ��� ��������� refresh ���� <dsn_test_t>, ��������������
  ���������� ������ ��������� � ������� ��������� ������������ ������
  ( ��� ��������� ���������� �� ��������� �������).
*/
create or replace procedure dsn_test_t_refresh(
  forTableName varchar2 := null
  , createMViewFlag integer := null
  , forceCreateMViewFlag integer := null
)
is
begin
  dsn_test_t().refresh(
    forTableName            => forTableName
    , createMViewFlag       => createMViewFlag
    , forceCreateMViewFlag  => forceCreateMViewFlag
  );
end dsn_test_t_refresh;
/
