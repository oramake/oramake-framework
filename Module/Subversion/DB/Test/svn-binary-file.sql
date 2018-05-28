declare
  fileText clob;
  fileData blob;
begin
  pkg_SvnSearcherTest.openConnection(
    repositoryUrl => '&repositoryUrl'
    , login => '&login'
    , password => '&password'
  );
  pkg_SvnSearcherTest.getSvnFile(
    fileData => fileData
    , fileSvnPath => '&binaryFilePath'
  );
  pkg_SvnSearcherTest.closeConnection();
--  fileText := pkg_EmailTemplate.convertToClob( fileData);
-- pkg_Common.outputMessage( fileText);
  insert into t (
    a
  )
  values (
    fileData
  );
end;
/

