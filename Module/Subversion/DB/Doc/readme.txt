title: Описание

Клиент Subversion в БД Oracle, использующий Java-библиотеку <svnkit>;

Возможности:

- получение списка файлов в репозитории ( <pkg_Subversion::getFileTree>);
- получение данных файла ( <pkg_Subversion::getSvnFile>);

Примеры:

- <Test/get-file-list.sql>;

(code)
-- Получение списка файлов.
begin
  pkg_SubVersion.openConnection(
    repositoryUrl => 'svn://srvbl08/Scoring'
    , login => '&login'
    , password => '&password'
  );
  pkg_SubVersion.getFileTree(
    dirSvnPath => 'Module/Anketa/Trunk/DB/Install/Schema/Last'
    , maxRecursiveLevel => 1
  );
  pkg_SubVersion.closeConnection();
end;
/
select * from ss_file_tmp
/

(end code)

- <Test/get-text-file.sql>

(code)
-- Получение данных текстового файла из SVN.
declare
  fileText clob;
  fileData blob;
begin
  pkg_Subversion.openConnection(
    repositoryUrl => 'svn://msk-dit-20532/Scoring'
    , login => 'guest'
    , password => '&password'
  );
  pkg_Subversion.getSvnFile(
    fileData => fileData
    , fileSvnPath => 'Module/AccessOperator/Trunk/DB/Doc/readme.txt'
  );
  pkg_Subversion.closeConnection();
  fileText := pkg_TextCreate.convertToClob( fileData);
  pkg_Common.outputMessage( fileText);
end;
/
(end code)

Автоматизированное тестирование:

- обеспечивается целью <test> сборки модуля:

(code)

make test LOAD_USERID=???/???@???

(end code)

См. также пакет <pkg_SubversionTest>;

- перед выполнением автоматизированных тестов следует
  пролить тестовые объекты <Установка::Установка тестовых объектов>;

