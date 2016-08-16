-- Для Oracle 11.2 и выше для пересоздания типа используется опция "force"
-- в create type, для более ранних версий используется "drop type force"
set define on

@oms-default forceOption "' || case when to_number( '&_O_RELEASE') >= 1102000000 then 'force' else '--' end || '"

@oms-default dropTypeScript "' || case when '&forceOption' = '--' then './oms-drop-type.sql' else '' end || '"

@oms-run "&dropTypeScript" opt_plsql_object_option_t

create or replace type
  opt_plsql_object_option_t
&forceOption
under opt_option_list_t
(
/* db object type: opt_plsql_object_option_t
  Настроечные параметры PL/SQL объекта
  ( интерфейс для прикладных модулей, базовый класс <opt_option_list_t>).

  SVN root: Oracle/Module/Option
*/




/* group: Функции */



/* group: Конструкторы */

/* pfunc: opt_plsql_object_option_t
  Создает набор настроечных параметров PL/SQL объекта и устанавливает его
  свойства.

  Параметры:
  findModuleString            - строка для поиска модуля (
                                может совпадать с одним из трех атрибутов
                                модуля: названием, путем к корневому каталогу,
                                первоначальным путем к корневому каталогу в
                                Subversion)
  objectName                  - имя PL/SQL объекта ( пакета, SQL-типа
                                и т.д.), к которому относятся параметры
  moduleName                  - наименование модуля ( например "ModuleInfo")
  moduleSvnRoot               - путь к корневому каталогу модуля в Subversion
                                ( начиная с имени репозитария, например
                                "Oracle/Module/ModuleInfo")

  Замечания:
  - имя PL/SQL объекта ( objectName) используется как краткое наименование
    объекта, к которому относятся параметры ( поле object_short_name таблицы
    <opt_option>);
  - для определения модуля должен быть задан один из параметров
    findModuleString, moduleName, moduleSvnRoot и модуль по нему
    должен определяться однозначно, иначе будет выброшено исключение;

  ( <body::opt_plsql_object_option_t>)
*/
constructor function opt_plsql_object_option_t(
  findModuleString varchar2 := null
  , objectName varchar2
  , moduleName varchar2 := null
  , moduleSvnRoot varchar2 := null
)
return self as result,

/* pfunc: opt_plsql_object_option_t( moduleId)
  Создает набор настроечных параметров PL/SQL объекта и устанавливает его
  свойства.

  Параметры:
  moduleId                    - Id модуля, к которому относятся параметры
  objectName                  - имя PL/SQL объекта ( пакета, SQL-типа
                                и т.д.), к которому относятся параметры

  Замечания:
  - имя PL/SQL объекта ( objectName) используется как краткое наименование
    объекта, к которому относятся параметры ( поле object_short_name таблицы
    <opt_option>);

  ( <body::opt_plsql_object_option_t( moduleId)>)
*/
constructor function opt_plsql_object_option_t(
  moduleId integer
  , objectName varchar2
)
return self as result

)
/
