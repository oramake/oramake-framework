-- script: ModuleConfig/Option/set-optDbRoleSuffixList.sql
-- ���������� �������� ��� �����, � ������� ������� �������� ����� �� ���
-- ���������, ��������� � ������������ ������������ �� ( ��������� �����
-- ���������������� � ���������������� ������).
--
-- �������:
-- bind-���������� optDbRoleSuffixList ���� refcursor � �������� ��������,
-- ���������� ��������� ( �� ����� ������ ��� ������ �� ( ����� ��)).
--
-- ������� �������:
-- production_db_name         - ��� ������������ �� ( �������� � ���������
--                              �����)
-- local_role_suffix          - ������ �����, �������� ����� �� ��� ���������,
--                              ��������� � ������ �� ( ������ ����� ��)
--                              ( ��.
--                              <pkg_OptionMain.LocalRoleSuffix_OptionSName>)
--
--

var optDbRoleSuffixList refcursor

begin
  open :optDbRoleSuffixList for
select
  a.production_db_name
  , coalesce(
      a.local_role_suffix
      -- ���������� �������� �� ���������
      , a.production_db_name
    )
    as local_role_suffix
from
  (
  select
    trim( pkg_Common.getStringByDelimiter( t.column_value, ':', 1))
      as production_db_name
    , trim( pkg_Common.getStringByDelimiter( t.column_value, ':', 2))
      as local_role_suffix
  from
    table( cmn_string_table_t(
      -- ��������� � �������
      -- "<production_db_name>[@schemaName][:<local_role_suffix>]",
      --
      -- ���������:
      --  - ���� ������� ��� ����� ( schemaName), �� ��������� �����������
      --    ������ ��� ��������� ����� � ����� ��������� ��� ���������� ���
      --    ��� �� �� ��� �������� �����;
      --  - ���� local_role_suffix �� �����, �� ��� ����� ��������� ��������
      --    ��-��������� ( ��. ����);
      'ProdDb: Prod'
      , 'tst_om_main@ProdDb: ProdMain'
      , 'ProdDb2'
      --
    )) t
  ) a
;
end;
/
