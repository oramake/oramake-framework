-- script: Install/Schema/Last/revert.sql
-- �������� ��������� ������, ������ ��������� ������� �����.


-- ������

drop package pkg_Subversion
/


-- Java sources

drop java source "Subversion"
/


-- ������� �����

@oms-drop-foreign-key svn_file_tmp


-- �������

drop table svn_file_tmp
/


-- ������������������

drop sequence svn_file_tmp_seq
/
