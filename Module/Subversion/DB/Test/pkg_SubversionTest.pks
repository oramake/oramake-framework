create or replace package pkg_SubversionTest is
/* package: pkg_SubversionTest
  Пакет для тестирования модуля.

  SVN root: Oracle/Module/Subversion
*/



/* group: Константы */

/* const: Test_Login
  Пользователь в SVN для тестирования доступа к Subversion.
  Достаточно только доступа на чтение к <TestDir_SvnPath> в репозитории
  <Test_RepositoryUrl>.
*/
Test_Login constant varchar2(10) := 'SvnTest';

/* const: Test_Pasword
  Пароль для тестирования модуля.
*/
Test_Pasword constant varchar2(10) := 'MZiijQ';

/* const: Test_RepositoryUrl
  URL репозитория для тестирования.
*/
Test_RepositoryUrl constant varchar2(100) := 'svn://srvsvn/Oracle';

/* const: TestDir_SvnPath
  Относительный путь к директории SVN.
*/
TestDir_SvnPath constant varchar2(100) := 'Module/Subversion/Trunk/DB/Test';



/* group: Функции */

/* pproc: openConnection
  Открытие соединения с репозиторием с тестовой авторизацией.

  ( <body::openConnection>)
*/
procedure openConnection;

/* pproc: closeConnection
  Закрытие соединения с репозиторием с тестовой авторизацией.

  ( <body::closeConnection>)
*/
procedure closeConnection;

/* pproc: testGetFile
  Тестирование получения файла.

  Описание:
  - функция получает текст файла тела данного пакета и пытается найти в
    тексте определённую строку; в случае нахождения считается, что тест
    завершился успешно;

  ( <body::testGetFile>)
*/
procedure testGetFile;

/* pproc: testGetList
  Тестирование получения списка файлов.

  Описание:
  - функция получает список файлов в каталоге DB/Test данного модуля
    в случае нахождения файла "pkg_SubversionTest.pkb" считается, что тест
    завершился успешно;

  ( <body::testGetList>)
*/
procedure testGetList;

end pkg_SubversionTest;
/
