-- script: Test/get-file-list.sql
-- Получение списка файлов.
begin
  pkg_SubVersion.openConnection(
    repositoryUrl => '&repositoryUrl'
    , login => '&login'
    , password => '&password'
  );
  pkg_SubVersion.getFileTree(
    dirSvnPath => '&dirSvnPath'
    , maxRecursiveLevel => 1
  );
  pkg_SubVersion.closeConnection();
end;
/

select * from svn_file_tmp
/

