--script: oms-set-lobTablespace.sql
--���������� ��������� ������������ ��� ����� ���� LOB � ��������� ��� ��������
--� ��������������� lobTablespace.
--
--���������:
--  - ���������� ������, ������������ ��� ������ �� ���������������� ��������;
--  - ���� ��������������� ��� ��������� �������� ��������, �� ��� ��
--    ����������, ��� ��������� ���� ������ �������� ��������������� ���
--    ��������� � ������� ��������� SQL_DEFINE ( ��. <��������� ������ � ��>);
--  - ��������� ������������ ���������� �� ��������� ������������
--    ��������� ����������� �� ��������� ����������� ���������� �� ����������;
--

set feedback off

column lobTablespace new_value lobTablespace

select
  coalesce( '&&lobTablespace'
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
                when t.tablespace_name like user || '%LOB_DATA'
                  then 10
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
  as "lobTablespace"
from
  dual
/

column lobTablespace clear

prompt
set feedback on
