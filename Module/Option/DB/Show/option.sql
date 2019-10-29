-- script: Show/option.sql
-- ���������� ����������� ��������� � �������� ������������� ����������
-- (�� <v_opt_option_value>).
--
-- ���������:
-- findString                 - ������ ��� ������ ����������
--                              (������ ��� like ��� ����� ��������)
--
-- ��� ����������� ��������� �������� ���������� ������ �� �������:
-- - ��� ��������� (option_short_name) �������� ��� findString (���������
--  �� like ��� ����� ��������);
-- - ��� ������ (module_name) ��� ��� ������� (object_short_name) ��� ��� ����
--  ������� (object_type_short_name) ����� findString (��� ����� ��������);
-- - � findString ������������ ����� � ������ ����
--  "<module_name>.<object_short_name>.<object_type_short_name>.<option_short_name>"
--  �������� ��� findString (�� like ��� ����� ��������, ��� ����
--  ���� findString ����������/������������� �� �����, �� � ������/�����
--  ������ findString ����������� ������ "%", ���� ������� ��� ����� ������,
--  �� ����� ���� ����������� ������ "%", ��������� ".-." ���������� �� "...");
--
--  �������:
--
--  - �������� ��������� � �������, ��������������� �� "DbLink"
--
--    > SQL> @option.sql %DbLink
--
--  - �������� ��������� ��������� ������� "ClearOldLog"
--
--    > SQL> @option.sql ClearOldLog
--
--    ��� ����� �����
--
--    > SQL> @option.sql .ClearOldLog.batch.
--
--  - �������� ��������� �������� ������� � �������, ����������� "Mail"
--
--    > SQL> @option.sql .%Mail%.batch.
--
--  - �������� ��������� ������ "Scheduler"
--
--    > SQL> @option.sql scheduler
--
--    ��� ����� �����
--
--    > SQL> @option.sql scheduler.
--
--  - �������� ��������� ������ "Scheduler", �� ����������� � ��������
--    (� �.�. �������� ��������)
--
--    > SQL> @option.sql scheduler.-.
--

var findString varchar2(255)
exec :findString := trim( '&1')


select
  t.*
from
  v_opt_option_value t
where
  upper( t.module_name) = upper( :findString)
  or upper( t.object_short_name) = upper( :findString)
  or upper( t.object_type_short_name) = upper( :findString)
  or upper( t.option_short_name) like upper( :findString)
  or :findString like '%.%'
    and upper(
      t.module_name
      || '.' || t.object_short_name
      || '.' || t.object_type_short_name
      || '.' || t.option_short_name
    )
    like upper(
      case when :findString like '.%' then
        '%'
      end
      || replace( replace( replace(
          :findString, '...', '.%.%.'), '..', '.%.'), '.-.', '...')
      || case when :findString like '%.' then
          '%'
        end
    )
order by
  t.module_name
  , t.module_svn_root
  , t.object_short_name nulls first
  , t.option_short_name
/



undefine findString
