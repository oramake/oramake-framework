--script: Install/Schema/Last/revert.sql
--�������� ��������� ������, ������ ��������� ������� �����.
--


                                        --������
drop package pkg_FormatData
/
drop package pkg_FormatBase
/


                                        --�������������
drop view v_fd_first_name_alias
/
drop view v_fd_middle_name_alias
/
drop view v_fd_no_value_alias
/


                                        --�������
drop table fd_alias
/ 
drop table fd_alias_type
/
