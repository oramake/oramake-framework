-- script: Install/Schema/Last/UserDb/Custom/set-sourceSchema.sql
-- Определяет схемы в основной БД, в которую установлены объекты модуля,
-- и сохраняет его в качестве значения по умолчанию для макропеременной
-- sourceSchema.
--
-- Используемые макропеременные:
-- sourceDbLink               - линк к исходной БД
--
--
-- Замечания:
--  - если макропеременной уже присвоено непустое значение, то оно не
--    изменяется, что позволяет явно задать значение макропеременной при
--    установке с помощью параметра <SQL_DEFINE>
--    ( см. <Установка модуля в БД>);
--  - в качестве схемы берется схемы таблицы cdr_day из
--    all_tables@<sourceDbLink>;
--

@oms-default sourceSchema ""

var defaultSchema varchar2(100)

declare

  sourceDbLink varchar2(200) := '&sourceDbLink';

begin
  if '&sourceSchema' is null then
    if sourceDbLink is null then
      raise_application_error(
        pkg_Error.IllegalArgument
        , 'Не задан линк к исходной БД в макропеременной sourceDbLink.'
      );
    end if;
    begin
      execute immediate '
        select
          t.owner
        from
          all_tables t
        where
          t.table_name = upper( :tableName)
      '
      into
        :defaultSchema
      using
        'cdr_day'
      ;
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , 'Ошибка при определении схемы по наличию таблицы CDR_DAY'
           || ' в all_tables ('
           || ' sourceDbLink="' || sourceDbLink || '"'
           || ').'
        , true
      );
    end;
  end if;
end;
/

@oms-default sourceSchema "' || :defaultSchema || '"
