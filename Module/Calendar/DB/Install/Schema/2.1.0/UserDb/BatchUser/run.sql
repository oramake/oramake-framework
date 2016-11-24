-- script: Install/Schema/2.1.0/UserDb/BatchUser/run.sql
-- Обновление объектов схемы пользователя, под которым выполняются пакетные
-- задания в пользовательской БД, до версии 2.1.0.
--
-- Основные изменения:
--  - вместо пакета pkg_Calendar создается синоним;
--

declare

  objectSchema varchar2(30);

begin
  select
    t.table_owner
  into objectSchema
  from
    user_synonyms t
  where
    t.table_name = upper( 'v_cdr_day_type')
    and exists
      (
      select
        null
      from
        all_objects ob
      where
        ob.object_name = upper( 'pkg_Calendar')
        and ob.owner = t.table_owner
        and ob.object_type = 'PACKAGE'
      )
  ;
  execute immediate
    'drop package pkg_Calendar'
  ;
  execute immediate
    'create synonym pkg_Calendar for ' || objectSchema || '.pkg_Calendar'
  ;
end;
/



-- Удаление параметров модуля
begin
  opt_option_list_t( moduleSvnRoot => 'Oracle/Module/Calendar').deleteAll();
  commit;
end;
/

