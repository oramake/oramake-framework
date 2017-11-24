-- script: oms-set-lobTablespace.sql
-- Определяет табличное пространство для полей типа LOB и сохраняет его значение
-- в макропеременной lobTablespace.
--
-- Замечания:
--  - прикладной скрипт, предназначен для вызова из пользовательских скриптов;
--  - если макропеременной уже присвоено непустое значение, то оно не
--    изменяется, что позволяет явно задать значение макропеременной при
--    установке с помощью параметра SQL_DEFINE ( см. <Установка модуля в БД>);
--  - табличное пространство выбирается из доступных пользователю
--    табличных пространств на основании действующих соглашений по именованию;
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
