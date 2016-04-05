-- script: Test/get-file-list.sql
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

select * from svn_file_tmp
/

