--script: oms-get-db-link.sql
--Определяет имя доступного для пользователя линка к БД из указанного списка и
--использует его в качестве значения по умолчанию для макропеременной.
--
--Приоритет для выбора в случае, если найдено несколько подходящих
--линков:
--  - тип линка ( личные, затем публичные);
--  - точность совпадения ( по имени, затем по базовому ( до разделяющей точки)
--    имени);
--  - позиция в списке ( первые имеют больший приоритет)
--
--Параметры:
--varName                     - имя макропеременной, в которую сохраняется имя
--                              линка в качестве значения по умолчанию
--prodLinkList                - список имен линков для промышленной БД ( через
--                              запятую, без учета регистра, пробелы
--                              игнорируются)
--testLinkList                - список имен линков для тестовой БД ( через
--                              запятую, без учета регистра, пробелы
--                              игнорируются)
--
--Замечания:
--  - прикладной скрипт, предназначен для вызова из пользовательских скриптов;
--  - тип БД ( промышленная или тестовая) определяется на основе результата
--    выполнения функции pkg_Common.IsProduction ( 1 промышленная, иначе
--    тестовая) модуля Common ( SVN root: Oracle/Module/Common);
--  - если макропеременной уже присвоено непустое значение, то оно не
--    изменяется, что позволяет явно задать значение макропеременной при
--    установке с помощью параметра SQL_DEFINE ( см. <Установка модуля в БД>);
--  - если макропеременной, с учетом результатов работы скрипта, не присвоено
--    значение, либо пользователю недоступен линк, указанный в макропеременной,
--    выбрасывается исключение;
--  - скрипт использует временный файл, который создается с использованием
--    префикса полного пути из макропеременной OMS_TEMP_FILE_PREFIX;
--  - для установки значения макропеременной используется скрипт
--    <oms-default.sql>;
--
--
--
--Примеры:
--  - определение линка к БД
--
--(code)
--
--@oms-get-db-link.sql dbLink ProdDb TestDb
--
--(end)
--

define oms_gdl_varName = "&1"
define oms_gdl_prodLinkList = "&2"
define oms_gdl_testLinkList = "&3"

                                       --Используется bind-переменная вместо
                                       --макропеременной для уменьшения числа
                                       --разборов используемого далее SQL
var oms_gdl_link_list varchar2(1024)

set feedback off

begin
  :oms_gdl_link_list :=
    ','
    || upper(
        replace(
          case pkg_Common.IsProduction
            when 1 then
              '&oms_gdl_prodLinkList'
            else
              '&oms_gdl_testLinkList'
          end
          , ' ', ''
        )
      )
    || ','
  ;
end;
/

set feedback on

                                        --Формируем параметры для oms-default
define 1 = "&oms_gdl_varName"
                                        --SQL поделен на части в связи
                                        --ограничением на длину макропеременной
define 2 = "' || ( -
select-
  b.db_link-
from-
  (-
  select-
    a.*-
  from-
    (-
    select-
      dl.owner-
      , $(1)-
      , $(2)-
      , dl.db_link-
    from-
      all_db_links dl-
    ) a-
  $(3)-
  ) b-
where-
  rownum <= 1-
) || '"

define 3 = "-
nullif( instr( :oms_gdl_link_list, ',' || upper( dl.db_link) || ','), 0)-
as name_pos-
"

define 4 = "-
nullif( instr(-
  :oms_gdl_link_list-
  , ',' || upper(-
      substr( dl.db_link, 1, instr( dl.db_link || '.', '.') - 1)-
    ) || ','-
), 0)-
as base_name_pos-
"

define 5 = "-
where-
  a.name_pos > 0 or a.base_name_pos > 0-
order by-
  nullif( a.owner, user) nulls first-
  , a.name_pos nulls last-
  , a.base_name_pos nulls last-
"

                                        --Параметры передаются неявно, т.к.
                                        --при вызове с помощью "@@" может
                                        --возникать ошибка при определенных
                                        --значениях параметров
@@oms-default.sql

                                        --Проверяем итоговое значение
                                        --макропеременной

define oms_temp_file_name = "&OMS_TEMP_FILE_PREFIX..oms-get-db-link"

set termout off
spool &oms_temp_file_name
prompt  declare
prompt    varName varchar2(200) := '&oms_gdl_varName'; ;
prompt    dbLink varchar2(200) := '&&&oms_gdl_varName'; ;
prompt    isFound integer; ;
prompt  begin
prompt    if dbLink is null then
prompt      raise_application_error(
prompt        -20185
prompt        , 'Не задано значение макропеременной ' || varName || '.'
prompt      ); ;
prompt    else
prompt      select count(*) into isFound from all_db_links t
prompt      where upper( t.db_link) = upper( dbLink); ;
prompt      if isFound = 0 then
prompt        raise_application_error(
prompt          -20185
prompt          , 'Линк "' || dbLink || '" не найден.'
prompt        ); ;
prompt      end if; ;
prompt    end if; ;
prompt  end; ;
spool off
set termout on

get &oms_temp_file_name nolist

set feedback off

/

set feedback on

undefine oms_temp_file_name


undefine oms_gdl_varName
undefine oms_gdl_prodLinkList
undefine oms_gdl_testLinkList
