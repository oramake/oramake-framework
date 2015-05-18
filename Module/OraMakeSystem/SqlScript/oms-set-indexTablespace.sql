--script: oms-set-indexTablespace.sql
--���������� ��������� ������������ ��� �������� � ��������� ��� �������� �
--��������������� indexTablespace.
--
--���������:
--  - ���������� ������, ������������ ��� ������ �� ���������������� ��������;
--  - ���� ��������������� ��� ��������� �������� ��������, �� ��� ��
--    ����������, ��� ��������� ���� ������ �������� ��������������� ���
--    ��������� � ������� ��������� SQL_DEFINE ( ��. <��������� ������ � ��>);
--  - ��������� ������������ ��� �������� ���������� �� ��������� ������������
--    ��������� ����������� �� ��������� ����������� ���������� �� ����������;
--

set feedback off

column indexTablespace new_value indexTablespace

select
  coalesce( '&&indexTablespace'
    , (
      select
        b.tablespace_name
      from
        (
        select
          a.*
        from
          (
          select
            t.tablespace_name
            , case
                when t.tablespace_name like user || '%INDEX'
                  then 10
                when t.tablespace_name like user || '\_IDX' escape '\'
                  then 15
                when t.tablespace_name like user || '\_INDEX\_ASSM' escape '\'
                  then 17
                when t.tablespace_name = 'INDX'
                  then 20
              end
              as priority_order
          from
            user_tablespaces t
          ) a
        where
          a.priority_order is not null
        order by
          a.priority_order
        ) b
      where
        rownum <= 1
      )
  )
  as "indexTablespace"
from
  dual
/

column indexTablespace clear

prompt
set feedback on
