--script: oms-get-db-link.sql
--���������� ��� ���������� ��� ������������ ����� � �� �� ���������� ������ �
--���������� ��� � �������� �������� �� ��������� ��� ���������������.
--
--��������� ��� ������ � ������, ���� ������� ��������� ����������
--������:
--  - ��� ����� ( ������, ����� ���������);
--  - �������� ���������� ( �� �����, ����� �� �������� ( �� ����������� �����)
--    �����);
--  - ������� � ������ ( ������ ����� ������� ���������)
--
--���������:
--varName                     - ��� ���������������, � ������� ����������� ���
--                              ����� � �������� �������� �� ���������
--prodLinkList                - ������ ���� ������ ��� ������������ �� ( �����
--                              �������, ��� ����� ��������, �������
--                              ������������)
--testLinkList                - ������ ���� ������ ��� �������� �� ( �����
--                              �������, ��� ����� ��������, �������
--                              ������������)
--
--���������:
--  - ���������� ������, ������������ ��� ������ �� ���������������� ��������;
--  - ��� �� ( ������������ ��� ��������) ������������ �� ������ ����������
--    ���������� ������� pkg_Common.IsProduction ( 1 ������������, �����
--    ��������) ������ Common ( SVN root: Oracle/Module/Common);
--  - ���� ��������������� ��� ��������� �������� ��������, �� ��� ��
--    ����������, ��� ��������� ���� ������ �������� ��������������� ���
--    ��������� � ������� ��������� SQL_DEFINE ( ��. <��������� ������ � ��>);
--  - ���� ���������������, � ������ ����������� ������ �������, �� ���������
--    ��������, ���� ������������ ���������� ����, ��������� � ���������������,
--    ������������� ����������;
--  - ������ ���������� ��������� ����, ������� ��������� � ��������������
--    �������� ������� ���� �� ��������������� OMS_TEMP_FILE_PREFIX;
--  - ��� ��������� �������� ��������������� ������������ ������
--    <oms-default.sql>;
--
--
--
--�������:
--  - ����������� ����� � ��
--
--(code)
--
--@oms-get-db-link.sql dbLink ProdDb TestDb
--
--(end)
--

define oms_gdl_varName = "&1"
define oms_gdl_prodLinkList = "&2"
define oms_gdl_testLinkList = "&3"

                                       --������������ bind-���������� ������
                                       --��������������� ��� ���������� �����
                                       --�������� ������������� ����� SQL
var oms_gdl_link_list varchar2(1024)

set feedback off

begin
  :oms_gdl_link_list :=
    ','
    || upper(
        replace(
          case pkg_Common.IsProduction
            when 1 then
              '&oms_gdl_prodLinkList'
            else
              '&oms_gdl_testLinkList'
          end
          , ' ', ''
        )
      )
    || ','
  ;
end;
/

set feedback on

                                        --��������� ��������� ��� oms-default
define 1 = "&oms_gdl_varName"
                                        --SQL ������� �� ����� � �����
                                        --������������ �� ����� ���������������
define 2 = "' || ( -
select-
  b.db_link-
from-
  (-
  select-
    a.*-
  from-
    (-
    select-
      dl.owner-
      , $(1)-
      , $(2)-
      , dl.db_link-
    from-
      all_db_links dl-
    ) a-
  $(3)-
  ) b-
where-
  rownum <= 1-
) || '"

define 3 = "-
nullif( instr( :oms_gdl_link_list, ',' || upper( dl.db_link) || ','), 0)-
as name_pos-
"

define 4 = "-
nullif( instr(-
  :oms_gdl_link_list-
  , ',' || upper(-
      substr( dl.db_link, 1, instr( dl.db_link || '.', '.') - 1)-
    ) || ','-
), 0)-
as base_name_pos-
"

define 5 = "-
where-
  a.name_pos > 0 or a.base_name_pos > 0-
order by-
  nullif( a.owner, user) nulls first-
  , a.name_pos nulls last-
  , a.base_name_pos nulls last-
"

                                        --��������� ���������� ������, �.�.
                                        --��� ������ � ������� "@@" �����
                                        --��������� ������ ��� ������������
                                        --��������� ����������
@@oms-default.sql

                                        --��������� �������� ��������
                                        --���������������

define oms_temp_file_name = "&OMS_TEMP_FILE_PREFIX..oms-get-db-link"

set termout off
spool &oms_temp_file_name
prompt  declare
prompt    varName varchar2(200) := '&oms_gdl_varName'; ;
prompt    dbLink varchar2(200) := '&&&oms_gdl_varName'; ;
prompt    isFound integer; ;
prompt  begin
prompt    if dbLink is null then
prompt      raise_application_error(
prompt        -20185
prompt        , '�� ������ �������� ��������������� ' || varName || '.'
prompt      ); ;
prompt    else
prompt      select count(*) into isFound from all_db_links t
prompt      where upper( t.db_link) = upper( dbLink); ;
prompt      if isFound = 0 then
prompt        raise_application_error(
prompt          -20185
prompt          , '���� "' || dbLink || '" �� ������.'
prompt        ); ;
prompt      end if; ;
prompt    end if; ;
prompt  end; ;
spool off
set termout on

get &oms_temp_file_name nolist

set feedback off

/

set feedback on

undefine oms_temp_file_name


undefine oms_gdl_varName
undefine oms_gdl_prodLinkList
undefine oms_gdl_testLinkList
