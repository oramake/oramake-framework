title: ��������

������ Subversion � �� Oracle, ������������ Java-���������� <svnkit>;

�����������:

- ��������� ������ ������ � ����������� ( <pkg_Subversion::getFileTree>);
- ��������� ������ ����� ( <pkg_Subversion::getSvnFile>);

�������:

- <Test/get-file-list.sql>;

(code)
-- ��������� ������ ������.
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
-- ��������� ������ ���������� ����� �� SVN.
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

������������������ ������������:

- �������������� ����� <test> ������ ������:

(code)

make test LOAD_USERID=???/???@???

(end code)

��. ����� ����� <pkg_SubversionTest>;

- ����� ����������� ������������������ ������ �������
  ������� �������� ������� <���������::��������� �������� ��������>;

