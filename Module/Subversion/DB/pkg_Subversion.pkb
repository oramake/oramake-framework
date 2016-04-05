create or replace package body pkg_Subversion is
/* package body: pkg_Subversion::body */

/* ivar: logger
  Логер пакета.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => pkg_Subversion.Module_Name
  , objectName  => 'pkg_Subversion'
);



/* group: Функции */

/* iproc: openConnectionJava
  Соединение с репозиторием.

  Параметры:
  repositoryUrl               - URL репозитория ( поддерживаются протоколы
                                svn, http, file)
  login                       - логин для доступа к репозиторию
  password                    - пароль для доступа к репозиторию
*/
procedure openConnectionJava(
  repositoryUrl varchar2
  , login varchar2
  , password varchar2
)
is
language java name '
  Subversion.openConnection(
    java.lang.String
    , java.lang.String
    , java.lang.String
  )';

/* iproc: closeConnectionJava
  Закрытие соединения с репозиторием.
*/
procedure closeConnectionJava
is
language java name '
  Subversion.closeConnection()';

/* ifunc: checkAccessJava
  Проверка доступа к файлу в репозитории.

  Параметры:
  svnPath                     - путь в svn-репозитории

  Возврат:
  0                           - если доступа нет
  1                           - если доступ есть
*/
function checkAccessJava(
  svnPath varchar2
)
return number
is
language java name
  'Subversion.checkAccess(
     java.lang.String
   ) return java.math.BigDecimal';

/* iproc: getSvnFileJava
  Получение данных файла.

  Параметры:
  fileData                    - данные файла ( если lob null то
                                инициализируется временный lob)
  fileSvnPath                 - путь к файлу в svn репозитории
*/
procedure getSvnFileJava(
  fileData in out nocopy blob
  , fileSvnPath varchar2
)
is
language java name '
  Subversion.getSvnFile(
    oracle.sql.BLOB[]
    , java.lang.String
  )';

/* iproc: getFileTreeJava
  Получение списка файлов и директорий в таблице.

  dirSvnPath                  - путь к папке в SVN
  maxRecursiveLevel           - максимальны уровень рекурсии ( 1 - только файлы
                                из указанного каталога, по-умолчанию null без
                                ограничений)
  directoryRecordFlag         - добавлять ли директории, по-умолчанию null нет
*/
procedure getFileTreeJava(
  dirSvnPath varchar2
  , maxRecursiveLevel number
  , directoryRecordFlag number
)
is
language java name '
  Subversion.getFileTree(
    java.lang.String
    , java.math.BigDecimal
    , java.math.BigDecimal
  )';

/* proc: openConnection
  Соединение с репозиторием.

  Параметры:
  repositoryUrl               - URL репозитория ( поддерживаются протоколы
                                svn, http, file)
  login                       - логин для доступа к репозиторию
  password                    - пароль для доступа к репозиторию
*/
procedure openConnection(
  repositoryUrl varchar2
  , login varchar2
  , password varchar2
)
is
begin
  openConnectionJava(
    repositoryUrl => repositoryUrl
    , login => login
    , password => password
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка открытия соединения ('
        || ' repositoryUrl="' || repositoryUrl || '"'
        || ', login="' || login || '"'
        || ')'
      )
    , true
  );
end openConnection;

/* proc: closeConnection
  Закрытие соединения с репозиторием.
*/
procedure closeConnection
is
-- closeConnection
begin
  closeConnectionJava();
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка закрытия соединения с репозиторием'
      )
    , true
  );
end closeConnection;

/* proc: getSvnFile
  Получение данных файла.

  Параметры:
  fileData                    - данные файла ( если lob null то
                                инициализируется временный lob)
  fileSvnPath                 - путь к файлу в svn репозитории
*/
procedure getSvnFile(
  fileData in out nocopy blob
  , fileSvnPath varchar2
)
is
-- getSvnFile
begin
  if fileData is null then
    dbms_lob.createTemporary( fileData, true);
  end if;
  getSvnFileJava(
    fileData => fileData
    , fileSvnPath => fileSvnPath
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при загрузке файла из svn'
      )
    , true
  );
end getSvnFile;

/* func: checkAccess
  Проверка доступа к файлу в репозитории.

  Параметры:
  svnPath                     - путь в svn-репозитории

  Возврат:
  0                           - если доступа нет
  1                           - если доступ есть
*/
function checkAccess(
  svnPath varchar2
)
return integer
is
-- checkAccess
begin
  return checkAccessJava( svnPath => svnPath);
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка проверки доступа к файлу в репозитории'
      )
    , true
  );
end checkAccess;

/* proc: getFileTree
  Получение списка файлов и директорий в таблице.

  dirSvnPath                  - путь к папке в SVN
  maxRecursiveLevel           - максимальны уровень рекурсии ( 1 - только файлы
                                из указанного каталога, по-умолчанию null без
                                ограничений)
  directoryRecordFlag         - добавлять ли директории, по-умолчанию null нет
*/
procedure getFileTree(
  dirSvnPath varchar2
  , maxRecursiveLevel integer := null
  , directoryRecordFlag boolean := null
)
is
begin
  getFileTreeJava(
    dirSvnPath => dirSvnPath
    , maxRecursiveLevel => maxRecursiveLevel
    , directoryRecordFlag =>
      case when
        directoryRecordFlag
      then
        1
      when
        not directoryRecordFlag
      then
        0
      end
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка получения списка файлов ('
        || ' dirSvnPath="' || dirSvnPath || '"'
        || ')'
      )
    , true
  );
end getFileTree;

end pkg_Subversion;
/
