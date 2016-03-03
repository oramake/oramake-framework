-- script: Install/Grant/Last/text-utility-privs.sql
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
  pkg_TextUtility
to
  &toUserName
/

declare
  -- ������������ ��� ������ ����
  toUserName varchar2(30) := lower( '&toUserName' );

  -- ����� ������� �� ������ ����
  grantText varchar2(100) := '
    create or replace $(synonymType) synonym $(synonymName)
    for pkg_TextUtility';

  -- ��� ��������
  synonymType varchar2(30);
  -- ������������ ��������
  synonymName varchar2(30);

begin

  if toUserName = 'public' then
    synonymType := 'public';
    synonymName := 'pkg_TextUtility';
  else
    synonymType := null;
    synonymName := '&toUserName..pkg_TextUtility';
  end if;

  execute immediate
    replace(
      replace( grantText, '$(synonymType)', synonymType )
      , '$(synonymName)', synonymName
      );

end;
/



undefine toUserName
