create or replace package body pkg_SubversionTest is
/* package body: pkg_SubversionTest::body */



/* group: Переменные */

/* ivar: logger
  Логер пакета.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => pkg_Subversion.Module_Name
  , objectName  => 'pkg_SubversionTest'
);




/* group: Функции */

/* proc: openConnection
  Открытие соединения с репозиторием с тестовой авторизацией.
*/
procedure openConnection
is
-- openConnection
begin
  pkg_Subversion.openConnection(
    repositoryUrl => Test_RepositoryUrl
    , login => Test_Login
    , password => Test_Pasword
  );
end openConnection;

/* proc: closeConnection
  Закрытие соединения с репозиторием с тестовой авторизацией.
*/
procedure closeConnection
is
-- closeConnection
begin
  pkg_Subversion.closeConnection();
end closeConnection;

/* proc: testGetList
  Тестирование получения списка файлов.

  Описание:
  - функция получает список файлов в каталоге DB/Test данного модуля
    в случае нахождения файла "pkg_SubversionTest.pkb" считается, что тест
    завершился успешно;
*/
procedure testGetList
is
  -- Флаг успешного теста
  successFlag number(1,0) := 0;
-- testGetList
begin
  openConnection();
  pkg_TestUtility.beginTest( 'testGetList');
  pkg_Subversion.getFileTree(
    dirSvnPath => TestDir_SvnPath
    , maxRecursiveLevel => 1
  );
  select
    count(1)
  into
    successFlag
  from
    svn_file_tmp
  where
    file_name = 'pkg_SubversionTest.pkb'
  ;
  if successFlag = 0 then
    pkg_TestUtility.failTest( 'file not found');
  end if;
  pkg_TestUtility.endTest();
  closeConnection();
exception when others then
  closeConnection();
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка тестирования получения списка файлов'
      )
    , true
  );
end testGetList;

/* proc: testGetFile
  Тестирование получения файла.

  Описание:
  - функция получает текст файла тела данного пакета и пытается найти в
    тексте определённую строку; в случае нахождения считается, что тест
    завершился успешно;
*/
procedure testGetFile
is
  -- Текст пакета
  packageBodyData blob;
  packageBodyText clob;
-- testGetFile
begin
  openConnection();
  pkg_TestUtility.beginTest( 'testGetFile');
  pkg_Subversion.getSvnFile(
    fileData => packageBodyData
    , fileSvnPath => TestDir_SvnPath || '/pkg_SubversionTest.pkb'
  );
  packageBodyText := pkg_TextCreate.convertToClob( packageBodyData);
  if ( instr( coalesce( packageBodyText, ' '), 'Искомая строка') = 0) then
    pkg_TestUtility.failTest( 'the string not found');
  end if;
  pkg_TestUtility.endTest();
  closeConnection();
exception when others then
  closeConnection();
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка тестирования получения файла'
      )
    , true
  );
end testGetFile;

end pkg_SubversionTest;
/
