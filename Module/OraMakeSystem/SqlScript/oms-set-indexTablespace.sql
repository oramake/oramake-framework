--script: oms-set-indexTablespace.sql
--Определяет табличное пространство для индексов и сохраняет его значение в
--макропеременной indexTablespace.
--
--Замечания:
--  - прикладной скрипт, предназначен для вызова из пользовательских скриптов;
--  - если макропеременной уже присвоено непустое значение, то оно не
--    изменяется, что позволяет явно задать значение макропеременной при
--    установке с помощью параметра SQL_DEFINE ( см. <Установка модуля в БД>);
--  - табличное пространство для индексов выбирается из доступных пользователю
--    табличных пространств на основании действующих соглашений по именованию;
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
