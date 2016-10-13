-- script: Install/Schema/Last/revert.sql
-- Отменяет установку модуля, удаляя созданные объекты схемы.

-- Удаление пакетных заданий
declare

  cursor batchCur is
    select
      t.batch_short_name
    from
      sch_batch t
    where
      t.module_id =
        (
        select
          md.module_id
        from
          v_mod_module md
        where
          md.module_name = 'Mail'
        )
    order by
      t.batch_short_name
  ;

begin
  for rec in batchCur loop
    dbms_output.put_line(
      'delete batch: ' || rec.batch_short_name
    );
    pkg_SchedulerLoad.deleteBatch(
      batchShortName => rec.batch_short_name
    );
  end loop;
  commit;
end;
/

-- Удаление параметров модуля
begin
  opt_option_list_t( moduleName => 'Mail').deleteAll();
end;
/

-- Удаление тестовых объектов ( при наличии)
begin
  opt_plsql_object_option_t(
    moduleName        => 'Mail'
    , objectName      => 'pkg_MailTest'
  ).deleteAll();
  for rec in (
        select
          ob.object_name
          , ob.object_type
        from
          user_objects ob
        where
          ob.object_type = 'PACKAGE'
          and ob.object_name = 'PKG_MAILTEST'
      )
      loop
    dbms_output.put_line(
      'drop: ' || rec.object_type || ': ' || rec.object_name
    );
    execute immediate
      'drop ' || rec.object_type || ' ' || rec.object_name
    ;
  end loop;
end;
/

-- Пакеты

drop package pkg_Mail
/
drop package pkg_MailHandler
/
drop package pkg_MailInternal
/
drop package pkg_MailUtility
/


-- Java sources

drop java source "Mail"
/
drop java source "OraUtil"
/


-- Представления

drop view v_ml_attachment
/
drop view v_ml_fetch_request_wait
/
drop view v_ml_message
/


-- Внешние ключи

@oms-drop-foreign-key ml_attachment
@oms-drop-foreign-key ml_fetch_request
@oms-drop-foreign-key ml_message
@oms-drop-foreign-key ml_message_state
@oms-drop-foreign-key ml_request_state


-- Таблицы

drop table ml_attachment
/
drop table ml_fetch_request
/
drop table ml_message
/
drop table ml_message_state
/
drop table ml_request_state
/


-- Последовательности

drop sequence ml_attachment_seq
/
drop sequence ml_fetch_request_seq
/
drop sequence ml_message_seq
/
