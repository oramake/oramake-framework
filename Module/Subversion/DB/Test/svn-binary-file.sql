declare
  fileText clob;
  fileData blob;
begin
  pkg_SvnSearcherTest.openConnection(
    repositoryUrl => 'svn://srvbl08/Exchange'
    , login => 'LysyonokE'
    , password => '&password'
  );
  pkg_SvnSearcherTest.getSvnFile(
    fileData => fileData
    , fileSvnPath => 'Module/COLA/Trunk/Doc/P026.T0376 Загрузка данных в Debt Manager.doc'
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

