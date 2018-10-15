create or replace package pkg_ModuleDependency is
/* package: pkg_ModuleDependency
  Интерфейсный пакет модуля ModuleDependency.
  Пакет содержит функции вычисления схему зависимосте модулей 
  изходя из содержания файлов map.xml 
  и системных представлений Oracle
  
  SVN root: Oracle/Module/ModuleDependency
*/



/* group: Константы */

/* const: Module_Name
  Название модуля, к которому относится пакет.
*/
Module_Name constant varchar2(30) := 'ModuleDependency';



/* group: Типы источников вычисления зависимостей */

/* const: MapXML_SourceTypeCode
  Код истчника вычисления зависимости из MAP.XML файла.
*/
MapXML_SourceTypeCode constant varchar2(10) := 'MAP.XML';

/* const: Sys_SourceTypeCode
  Код источника вычисления зависимости исходя из системных представлений Oracle.
*/
Sys_SourceTypeCode constant varchar2(10) := 'SYS';



/* group: Функции */

/* pproc: refreshDependencyFromMapXML
  Обновляет список зависимостей модуля от других модулей
  по содержанию map.xml.

  Параметры:
  svnRoot                     - Путь к корневому каталогу модуля в Subversion
*/
procedure refreshDependencyFromMapXML(
  svnRoot varchar2
);

/* pproc: refreshDependencyFromMapXML
  Обновляет список зависимостей модуля от других модулей
  по содержанию системного представления all_dependencies.

  Параметры:
  svnRoot                     - Путь к корневому каталогу модуля в Subversion
*/
procedure refreshDependencyFromSYS(
  svnRoot varchar2
);

/* pproc: createDependency
  Создает зависимость модуля от модуля.

  Параметры:
  svnRoot                     - Путь к корневому каталогу модуля в Subversion
  referencedSvnRoot varchar2  - Путь к корневому каталогу модуля, от которого зависит
  buildSource varchar2        - Источник, из которого вычислена зависимость.
                              - допустимые значения: SYS, MAP.XML
*/
procedure createDependency(
  svnRoot varchar2
  , referencedSvnRoot varchar2
  , buildSource varchar2
);

/* pproc: findDependency
  Функция возвращает список зависимостей для модуля,
  предварительно вычисленный и сохраненный в таблице md_module_dependency

  Параметры:
  svnRoot                     - Путь к корневому каталогу модуля в Subversion
  referencedSvnRoot varchar2  - Путь к корневому каталогу модуля, от которого зависит
  buildSource varchar2        - Источник, из которого вычислена зависимость.
                              - допустимые значения: SYS, MAP.XML

  Возврат ( курсор ):
  svnRoot                     - Путь к корневому каталогу модуля в Subversion
  referencedSvnRoot varchar2  - Путь к корневому каталогу модуля, от которого зависит
  buildSource varchar2        - Источник, из которого вычислена зависимость.
                              - допустимые значения: SYS, MAP.XML
  last_refresh_date           - Дата последнего обновления данных
  date_ins                    - Дата добавления записи

*/
function findDependency(
  svnRoot varchar2
  , referencedSvnRoot varchar2
  , buildSource varchar2
)
return sys_refcursor;

/* pproc: deleteDependency
  Функция удаляет зависимость модуля, сохраненную в таблице md_module_dependency

  Параметры:
  svnRoot                     - Путь к корневому каталогу модуля в Subversion
  referencedSvnRoot varchar2  - Путь к корневому каталогу модуля, от которого зависит
*/
procedure deleteDependency(
  svnRoot varchar2
  , referencedSvnRoot varchar2
);

/* pproc: refreshAllDependencyFromSVN
  Обновляет список зависимостей ВСЕХ модулей из SVN
  по содержанию map.xml.
*/
procedure refreshAllDependencyFromSVN;

/* pproc: refreshAllDependencyFromSYS
  Обновляет список зависимостей ВСЕХ модулей из SVN
  по содержанию системного представления all_dependencies.
*/
procedure refreshAllDependencyFromSYS;


end pkg_ModuleDependency;
/
