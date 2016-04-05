create or replace package pkg_Subversion is
/* package: pkg_Subversion
  Интерфейсный пакет модуля Subversion.

  SVN root: Oracle/Module/Subversion
*/

/* const: Module_Name
  Название модуля, к которому относится пакет.
*/
Module_Name constant varchar2(30) := 'Subversion';



/* group: Функции */

/* pproc: openConnection
  Соединение с репозиторием.

  Параметры:
  repositoryUrl               - URL репозитория ( поддерживаются протоколы
                                svn, http, file)
  login                       - логин для доступа к репозиторию
  password                    - пароль для доступа к репозиторию

  ( <body::openConnection>)
*/
procedure openConnection(
  repositoryUrl varchar2
  , login varchar2
  , password varchar2
);

/* pproc: closeConnection
  Закрытие соединения с репозиторием.

  ( <body::closeConnection>)
*/
procedure closeConnection;

/* pproc: getSvnFile
  Получение данных файла.

  Параметры:
  fileData                    - данные файла ( если lob null то
                                инициализируется временный lob)
  fileSvnPath                 - путь к файлу в svn репозитории

  ( <body::getSvnFile>)
*/
procedure getSvnFile(
  fileData in out nocopy blob
  , fileSvnPath varchar2
);

/* pfunc: checkAccess
  Проверка доступа к файлу в репозитории.

  Параметры:
  svnPath                     - путь в svn-репозитории

  Возврат:
  0                           - если доступа нет
  1                           - если доступ есть

  ( <body::checkAccess>)
*/
function checkAccess(
  svnPath varchar2
)
return integer;

/* pproc: getFileTree
  Получение списка файлов и директорий в таблице.

  dirSvnPath                  - путь к папке в SVN
  maxRecursiveLevel           - максимальны уровень рекурсии ( 1 - только файлы
                                из указанного каталога, по-умолчанию null без
                                ограничений)
  directoryRecordFlag         - добавлять ли директории, по-умолчанию null нет

  ( <body::getFileTree>)
*/
procedure getFileTree(
  dirSvnPath varchar2
  , maxRecursiveLevel integer := null
  , directoryRecordFlag boolean := null
);

end pkg_Subversion;
/
