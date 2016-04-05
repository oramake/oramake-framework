-- script: Test/get-text-file.sql
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
