create or replace package pkg_ModuleInfoInternal is
/* package: pkg_ModuleInfoInternal
  Внутренние функции модуля.

  SVN root: Oracle/Module/ModuleInfo 
*/



/* group: Константы */

/* const: Module_Name
  Название модуля, к которому относится пакет.
*/
Module_Name constant varchar2(30) := 'ModuleInfo';



/* group: Коды ошибок
  Собственные константы используются для избежания зависимости от пакета
  pkg_Error модуля Common.
  Значения констант совпадают с соответствующими ( по первой части имени)
  константами из пакета pkg_Error.
*/

/* const: ErrorStackInfo_Error
  Код ошибки, используемый для вывода информации о месте возникновения ошибки 
  в стек ошибок.
*/
ErrorStackInfo_Error constant integer := -20150;

/* const: IllegalArgument_Error
  Код ошибки, вызванной указанием некорректных аргументов для функции.
*/
IllegalArgument_Error constant integer := -20195;

/* const: ProcessEror
  Код ошибки, выявленной при выполнении функции. 
*/
ProcessError_Error constant integer := -20185;



/* group: Функции */

/* pfunc: compareVersion
  Сравнивает номера версий.

  Параметры:
  version1                    - Первый номер версии
  version2                    - Второй номер версии

  Возврат:
  -  -1 если version1 < version2
  -   0 если version1 = version2
  -   1 если version1 > version2
  - null если version1 или version2 имеют значение null

  Замечания:
  - номера версий, отличающиеся лишь нулевыми подномерами, считаются равными,
    например, "1.0" и "1.00" и "1.0.0" равны;

  ( <body::compareVersion>)
*/
function compareVersion(
  version1 varchar2
  , version2 varchar2
)
return integer;

/* pfunc: getCurrentOperatorId
  Возвращает Id текущего зарегистрированного оператора при доступности модуля
  AccessOperator.

  Возврат:
  Id текущего оператора либо null в случае недоступности модуля AccessOperator.

  Замечания:
  - в случае доступности модуля AccessOperator и отсутствия текущего
    зарегистрированного оператора выбрасывается исключение;

  ( <body::getCurrentOperatorId>)
*/
function getCurrentOperatorId
return integer;

/* pfunc: getModuleId
  Возвращает Id модуля.

  Параметры:
  svnRoot                     - путь к корневому каталогу модуля в Subversion
                                ( начиная с имени репозитария, например
                                "Oracle/Module/ModuleInfo")
  initialSvnPath              - первоначальный путь к корневому каталогу
                                модуля в Subversion ( начиная с имени
                                репозитария и влючая номер правки, в которой
                                он был создан, например
                                "Oracle/Module/ModuleInfo@711")
  isCreate                    - создать запись в случае отсутствия подходящей
                                ( 1 да, 0 нет ( по умолчанию))
  operatorId                  - Id оператора, выполняющего операцию
                                ( по умолчанию текущий)

  Возврат:
  Id модуля ( значение module_id из таблицы <mod_module>) либо null если
  запись не найдена и не указан isCreate = 1.

  Замечания:
  - для поиска модуля должно быть указано отличное от null значение svnRoot
    либо initialSvnPath, при этом в случае указания initialSvnPath значение
    svnRoot игнорируется, регистр значений указанных параметров для поиска
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
