-- script: Test/get-text-file.sql
-- Получение данных текстового файла из SVN.
declare
  fileText clob;
  fileData blob;
begin
  pkg_Subversion.openConnection(
    repositoryUrl => '&repoPath'
    , login => 'guest'
    , password => '&password'
  );
  pkg_Subversion.getSvnFile(
    fileData => fileData
    , fileSvnPath => '&filePath'
  );
  pkg_Subversion.closeConnection();
  fileText := pkg_TextCreate.convertToClob( fileData);
  pkg_Common.outputMessage( fileText);
end;
/
