-- script: Test/Schema/run.sql
-- �������� �������� �������� �����.
--

@@dsn_test_source.tab



-- ����� ��������� ������
@@dsn_test_compare.tab

-- � ��������������� ������
@@dsn_test_compare_ext.tab
@@dsn_test_compare_ext_bu_chg.trg

@@v_dsn_test_compare.vw



-- ����� ��������� ������ � �������������� ��������� �������
@@dsn_test_cmptemp.tab
@@dsn_test_cmptemp_tmp.tab

-- � ��������������� ������
@@dsn_test_cmptemp_ext.tab

@@v_dsn_test_cmptemp.vw



-- ����� � ������� �-�������������
@@dsn_test_mview.tab

-- � ��������������� ������
@@dsn_test_mview_ext.tab
@@dsn_test_mview_ext_bu_chg.trg

@@v_dsn_test_mview.vw
