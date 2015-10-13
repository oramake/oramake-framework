create or replace package pkg_ModuleInfoInternal is
/* package: pkg_ModuleInfoInternal
  ¬нутренние функции модул€.

  SVN root: Oracle/Module/ModuleInfo 
*/



/* group:  онстанты */

/* const: Module_Name
  Ќазвание модул€, к которому относитс€ пакет.
*/
Module_Name constant varchar2(30) := 'ModuleInfo';



/* group:  оды ошибок
  —обственные константы используютс€ дл€ избежани€ зависимости от пакета
  pkg_Error модул€ Common.
  «начени€ констант совпадают с соответствующими ( по первой части имени)
  константами из пакета pkg_Error.
*/

/* const: ErrorStackInfo_Error
   од ошибки, используемый дл€ вывода информации о месте возникновени€ ошибки 
  в стек ошибок.
*/
ErrorStackInfo_Error constant integer := -20150;

/* const: IllegalArgument_Error
   од ошибки, вызванной указанием некорректных аргументов дл€ функции.
*/
IllegalArgument_Error constant integer := -20195;

/* const: ProcessEror
   од ошибки, вы€вленной при выполнении функции. 
*/
ProcessError_Error constant integer := -20185;



/* group: ‘ункции */

/* pfunc: getCurrentOperatorId
  ¬озвращает Id текущего зарегистрированного оператора при доступности модул€
  AccessOperator.

  ¬озврат:
  Id текущего оператора либо null в случае недоступности модул€ AccessOperator.

  «амечани€:
  - в случае доступности модул€ AccessOperator и отсутстви€ текущего
    зарегистрированного оператора выбрасываетс€ исключение;

  ( <body::getCurrentOperatorId>)
*/
function getCurrentOperatorId
return integer;

/* pfunc: getModuleId
  ¬озвращает Id модул€.

  ѕараметры:
  svnRoot                     - путь к корневому каталогу модул€ в Subversion
                                ( начина€ с имени репозитари€, например
                                "Oracle/Module/ModuleInfo")
  initialSvnPath              - первоначальный путь к корневому каталогу
                                модул€ в Subversion ( начина€ с имени
                                репозитари€ и влюча€ номер правки, в которой
                                он был создан, например
                                "Oracle/Module/ModuleInfo@711")
  isCreate                    - создать запись в случае отсутстви€ подход€щей
                                ( 1 да, 0 нет ( по умолчанию))
  operatorId                  - Id оператора, выполн€ющего операцию
                                ( по умолчанию текущий)

  ¬озврат:
  Id модул€ ( значение module_id из таблицы <mod_module>) либо null если
  запись не найдена и не указан isCreate = 1.

  «амечани€:
  - дл€ поиска модул€ должно быть указано отличное от null значение svnRoot
    либо initialSvnPath, при этом в случае указани€ initialSvnPath значение
    svnRoot игнорируетс€, регистр значений указанных параметров дл€ поиска
    несущественен;

  ( <body::getModuleId>)
*/
function getModuleId(
  svnRoot varchar2
  , initialSvnPath varchar2
  , isCreate integer := null
  , operatorId integer := null
)
return integer;

end pkg_ModuleInfoInternal;
/
