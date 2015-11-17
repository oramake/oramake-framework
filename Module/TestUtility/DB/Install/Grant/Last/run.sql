-- script: Install/Grant/Last/run.sql
-- ������ ����������� ����� �� ������������� �������� ������
--
-- ���������:
-- toUserName                  - ��� ������������, �������� �������� �����
--
-- ���������:
--  - ������ ����������� ��� �������������, �������� ����������� ������� ������;
--  - ��� ������ ���� public ������������ ������ �������� �������
--    create public synonym
--

define toUserName = "&1"



grant
  execute
on
  pkg_TestUtility
to
  &toUserName
/

declare
  -- ������������ ��� ������ ����
  toUserName varchar2(30) := lower( '&toUserName' );

  -- ����� ������� �� ������ ����
  grantText varchar2(100) := '
    create or replace $(synonymType) synonym $(synonymName)
    for pkg_TestUtility';

  -- ��� ��������
  synonymType varchar2(30);
  -- ������������ ��������
  synonymName varchar2(30);

begin

  if toUserName = 'public' then
    synonymType := 'public';
    synonymName := 'pkg_TestUtility';
  else
    synonymType := null;
    synonymName := '&toUserName..pkg_TestUtility';
  end if;

  execute immediate
    replace(
      replace( grantText, '$(synonymType)', synonymType )
      , '$(synonymName)', synonymName
      );

end;
/



undefine toUserName
