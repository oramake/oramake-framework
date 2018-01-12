-- script: Install/Data/Last/Custom/set-schDbRoleSuffixList.sql
-- ���������� �������� ��� �����, � ������� ������� �������� ����� �� ���
-- ���������, ��������� � ������������ ������������ �� ( ��������� �����
-- ���������������� � ���������������� ������).
--
-- �������:
-- bind-���������� schDbRoleSuffixList ���� refcursor � �������� ��������,
-- ���������� ��������� ( �� ����� ������ ��� ������ �� ( ����� ��)).
--
-- ������� �������:
-- production_db_name         - ��� ������������ �� ( �������� � ���������
--                              �����)
-- local_role_suffix          - ������ �����, �������� ����� �� ��� ���������,
--                              ��������� � ������ �� ( ������ ����� ��)
--                              ( ��.
--                              <pkg_SchedulerMain.LocalRoleSuffix_OptSName>)
--
--

var schDbRoleSuffixList refcursor

begin
  open :schDbRoleSuffixList for
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
