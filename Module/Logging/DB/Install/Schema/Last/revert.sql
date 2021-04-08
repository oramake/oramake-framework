-- script: Install/Schema/Last/revert.sql
-- Отменяет установку модуля, удаляя созданные объекты схемы.


-- Удаление тестовых объектов ( при наличии)
begin
  for rec in (
        select
          ob.object_name
          , ob.object_type
        from
          user_objects ob
        where
          ob.object_type = 'PACKAGE'
            and ob.object_name = upper( 'pkg_LoggingTest')
          or ob.object_type = 'JAVA SOURCE'
            and ob.object_name = 'LoggingTest'
      )
      loop
    dbms_output.put_line(
      'drop: ' || rec.object_type || ': ' || rec.object_name
    );
    execute immediate
      'drop ' || rec.object_type || ' "' || rec.object_name || '"'
    ;
  end loop;
end;
/


-- Удаление общих объектов схемы
@oms-run Install/Schema/Last/Common/revert.sql


-- Пакеты

drop package pkg_Logging
/
drop package pkg_LoggingErrorStack
/
drop package pkg_LoggingInternal
/


-- Типы

@oms-drop-type lg_logger_t


-- Представления

drop view v_lg_context_change
/
drop view v_lg_context_change_log
/
drop view v_lg_current_log
/
drop view v_lg_log
/


-- Внешние ключи

@oms-drop-foreign-key lg_context_type
@oms-drop-foreign-key lg_destination
@oms-drop-foreign-key lg_level
@oms-drop-foreign-key lg_log
@oms-drop-foreign-key lg_log_data


-- Таблицы

drop table lg_context_type
/
drop table lg_destination
/
drop table lg_level
/
drop table lg_log
/
drop table lg_log_data
/


-- Последовательности

drop sequence lg_context_type_seq
/
drop sequence lg_log_seq
/
