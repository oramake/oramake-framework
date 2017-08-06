create or replace package pkg_FileTest is
/* package: pkg_FileTest
  ����� ��� ������������ ������.

  SVN root: Oracle/Module/File
*/



/* group: ��������� */



/* group: ��������� ������������ */

/* const: TestDirectoryPath_OptionSName
  ������������ ������������ ��������� "�����: ����������".
*/
TestDirectoryPath_OptionSName constant varchar2(50) := 'TestDirectoryPath';



/* group: ������� */



/* group: ������� */

/* pfunc: convertToClob
  ����������� �������� ������ � ����������.

  ���������:
  fileData                    - ������ �����
  charEncoding                - ��������� �����
                                ( �� ��������� ���������, ��� ���� � ���������
                                ��)

  ( <body::convertToClob>)
*/
function convertToClob(
  fileData in out nocopy blob
  , charEncoding varchar2 := null
)
return clob;



/* group: ������������ �������� ������ */

/* pproc: setTestDirectory
  ��������� �������� ����������.

  ���������:
  directoryPath               - ���� � ����������

  ( <body::setTestDirectory>)
*/
procedure setTestDirectory(
  directoryPath varchar2
);

/* pproc: testBinaryFile
  ������������ �������� � �������� ��������� �����
  ( <pkg_FileOrigin.unloadBlobToFile>, <pkg_FileOrigin.loadBlobFromFile>).

  ���������:
  fileSize                    - ������ ����� ( � ������)

  ( <body::testBinaryFile>)
*/
procedure testBinaryFile(
  fileSize integer
);

/* pproc: testTextFile
  ������������ �������� � �������� ���������� �����
  ( <pkg_FileOrigin.unloadClobToFile>, <pkg_FileOrigin.loadClobFromFile>).

  ���������:
  fileSize                    - ������ ����� ( � ������)

  ( <body::testTextFile>)
*/
procedure testTextFile(
  fileSize integer
);

/* pproc: testLoadTxt
  ������������ �������� ���������� ����� � ������� <pkg_FileOrigin.loadTxt>;

  ���������:
  fileSize                    - ������ ����� ( � ������)

  ( <body::testLoadTxt>)
*/
procedure testLoadTxt(
  fileSize integer
);

/* pproc: testLoadTxtByLine
  ������������ �������� ���������� ����� � ������� <pkg_FileOrigin.loadTxt>;

  ���������:
  lineCount                   - ���������� ����� � �����

  ( <body::testLoadTxtByLine>)
*/
procedure testLoadTxtByLine(
  lineCount integer
);

/* pproc: testUnloadData
  ������������ ������������ ( ���������� ���������) �������� ������ � ���� �
  ������� �������� <pkg_FileOrigin.unloadBlobToFile>,
  <pkg_FileOrigin.unloadClobToFile>, <pkg_FileOrigin.unloadTxt>.

  ���������:
  unloadFunctionName          - ��� ����������� ��������� ��� �������
                                ( ��������� ��������: "unloadBlobToFile",
                                "unloadClobToFile", "unloadTxt", �� ���������
                                ��� �����������������)
  skip0x98CheckFlag          - ���� ���������� �� �������� �������� ������� �
                                ����� 0x98, ������� �� ��������� � ���������
                                Windows-1251
                                ( 1 �� ( �� ���������), 0 ���)
  charEncoding                - ��������� ��� �������� �����, ����������� ���
                                �������� � ������� ��������� unloadClobToFile
                                ( �� ��������� ����������� �������� ��� ��������
                                  ��������� � �������� � ��������� utf8)
  fileName                    - ��� ����� ( ��-��������� 'testUnloadData.txt')

  ( <body::testUnloadData>)
*/
procedure testUnloadData(
  unloadFunctionName varchar2 := null
, skip0x98CheckFlag  integer := null
, charEncoding       varchar2 := null
, fileName           varchar2 := null
);

/* pproc: testUnloadTxt
  ������������ �������� ����� � ������� <pkg_FileOrigin.unloadTxt>;

  ���������:
  fileSize                    - ������ �����
  stringSize                  - ������ ������

  ( <body::testUnloadTxt>)
*/
procedure testUnloadTxt(
  fileSize integer
  , stringSize integer
);

/* pproc: testExecCommand
  ������������ ������� ������ OS ( <pkg_FileOrigin.execCommand>);

  ( <body::testExecCommand>)
*/
procedure testExecCommand;

/* pproc: testEncodingLoad
  ������������ �������� ����� � ����������� ���������.

  ���������:
  fileSize                    - ������ �����
  charEncoding                - ��������� �����

  ( <body::testEncodingLoad>)
*/
procedure testEncodingLoad(
  fileSize integer
  , charEncoding varchar2
);

/* pproc: testWriteMode
  ������������ ������ ���������� �����.

  ( <body::testWriteMode>)
*/
procedure testWriteMode(
  writeMode integer
  , expectedExceptionFlag1 number
  , expectedExceptionFlag2 number
);

/* pproc: testMakeDirectory
  ������������ �������� ����������.

  ���������:
  parentDirectory             - ������������ ���������� ��� ��������

  ( <body::testMakeDirectory>)
*/
procedure testMakeDirectory(
  parentDirectory varchar2
);

/* pproc: unitTest
  ����� ����.

  ���������:
  fileSize                    - ������ �����

  ( <body::unitTest>)
*/
procedure unitTest(
  fileSize integer
);



/* group: ����� �� ������� ������ */

/* pproc: testFsOperation
  ������������ ���������� �������� � ������� �������� �������.

  ( <body::testFsOperation>)
*/
procedure testFsOperation;

/* pproc: testHttpOperation
  ������������ ���������� �������� �� HTTP.

  ���������:
  httpInternetFileTest        - ���� ������������ ���������� �������� �� HTTP
                                c ������� � �������� ( 1 ��, 0 ��� ( ��
                                ���������))

  ( <body::testHttpOperation>)
*/
procedure testHttpOperation(
  httpInternetFileTest integer := null
);

end pkg_FileTest;
/
