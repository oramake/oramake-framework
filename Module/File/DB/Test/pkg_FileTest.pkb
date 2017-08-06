create or replace package body pkg_FileTest is
/* package body: pkg_FileTest::body */



/* group: ���������� */

/* ivar: logger
  ����� ������.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => pkg_FileOrigin.Module_Name
  , objectName  => 'pkg_FileTest'
);

/* iconst: testDirectory
  ���������� ��� ������������ ( ������������ �������� �����
  <TestDirectoryPath_OptionSName>).
*/
testDirectory varchar2(1024) := null;

/* iconst: Max_CharSize
  ������������ ���������� �������� ��� ���������� ����.
*/
Max_CharSize constant integer := 32767;

/* iconst: Symbol
  ������ ��� ���������� ��������� ������.
*/
Symbol constant char := '�';

/* itype: TestStepTimeColT
  ������ ��������� ����� ����� ( ���).
*/
type TestStepTimeColT is table of timestamp with time zone;

/* ivar: testStepTimeCol
  ������ ��������� ����� �����.
*/
testStepTimeCol TestStepTimeColT := TestStepTimeColT();



/* group: ������� */



/* group: ������� */

/* ifunc: getTestDirectory
  ��������� ������ �������� ����������.
*/
function getTestDirectory
return varchar2
is
-- getTestDirectory
begin
  if testDirectory is null then
    testDirectory :=
      opt_plsql_object_option_t(
        moduleName    => pkg_File.Module_Name
      , objectName    => 'pkg_FileTest'
      ).getString( TestDirectoryPath_OptionSName)
    ;
  end if;
  if testDirectory is null then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '���������� ������ �������� ���������� ( ����� TestDirectoryPath)'
    );
  end if;
  return
    testDirectory
  ;
end getTestDirectory;

/* iproc: saveTestStep
  ���������� ����� ������������.
*/
procedure saveTestStep
is
-- saveTestStep
begin
  testStepTimeCol.extend(1);
  testStepTimeCol( testStepTimeCol.last) := systimestamp;
end saveTestStep;

/* iproc: beginPerformanceTest
  ������ ����� ������������������.

  ���������:
  messageText                 - ����� ���������
*/
procedure beginPerformanceTest(
  messageText varchar2
)
is
-- beginPerformanceTest
begin
  pkg_TestUtility.beginTest( messageText => messageText);
  testStepTimeCol.delete();
  saveTestStep();
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ������ ����� ������������������ ('
        || ' messageText="' || messageText || '"'
        || ').'
      )
    , true
  );
end beginPerformanceTest;

/* iproc: endPerformanceTest
  ���������� ����� ������������������.
*/
procedure endPerformanceTest
is
  testTimeMessage varchar2(32767);
-- endPerformanceTest
begin
  saveTestStep();
  for i in testStepTimeCol.first + 1 .. testStepTimeCol.last loop
    testTimeMessage :=
      testTimeMessage
        || ' : ' ||
           to_char(
              extract(
                second from testStepTimeCol( i) - testStepTimeCol( i - 1)
              )
              , 'FM990.000'
           )
    ;
  end loop;
  pkg_TestUtility.addTestInfo( testTimeMessage, 20);
  pkg_TestUtility.endTest();
end endPerformanceTest;

/* iproc: appendUnloadTest
  ������������ ������.

  ���������:
  stringSize                  - ������ ������
  stringEnd                   - ������, ����������� � ����� ������
  stringCount                 - ���������� �����
  lastStringSize              - ������ ��������� ������
*/
procedure appendUnloadTest(
  stringSize integer
  , stringEnd varchar2
  , stringCount integer
  , lastStringSize integer
)
is
begin
  pkg_FileOrigin.deleteUnloadData();
  for i in 1 .. stringCount loop
    pkg_FileOrigin.appendUnloadData(
      rpad( Symbol, stringSize , Symbol) || stringEnd
    );
  end loop;
  if lastStringSize > 0 then
    pkg_FileOrigin.appendUnloadData(
      rpad( Symbol, lastStringSize, Symbol) || stringEnd
    );
  end if;
end appendUnloadTest;

/* iproc: createTextFile
  �������� ���������� �����.

  ���������:
  filePath                    - ���� � �����
  fileSize                    - ������ �����
  charEncoding                - ��������� ��� �������� �����
*/
procedure createTextFile(
  filePath varchar2
  , fileSize integer
  , charEncoding varchar2 := null
)
is

  fileText clob;

  String_Size constant integer := 20000;

-- createTextFile
begin
  appendUnloadTest(
    stringSize => String_Size
    , stringCount => trunc( fileSize / String_Size)
    , stringEnd => ''
    , lastStringSize => mod( fileSize, String_Size)
  );
  pkg_File.unloadTxt(
    toPath => filePath
    , writeMode => pkg_FileOrigin.Mode_Rewrite
    , charEncoding => charEncoding
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ �������� ���������� ����� ('
        || ' filePath="' || filePath || '"'
        || ', fileSize=' || to_char( fileSize)
        || ').'
      )
    , true
  );
end createTextFile;

/* iproc: createTextFile(lineSize)
  �������� ���������� �����.

  ���������:
  filePath                    - ���� � �����
  lineSize                    - ������ ������
  lineCount                   - ���������� �����
*/
procedure createTextFile(
  filePath varchar2
  , lineSize integer
  , lineCount integer
)
is
-- createTextFile
begin
  appendUnloadTest(
    stringSize => lineSize
    , stringCount => lineCount
    , stringEnd => chr(13) || chr(10)
    , lastStringSize => 0
  );
  pkg_File.unloadTxt(
    toPath => filePath
    , writeMode => pkg_FileOrigin.Mode_Rewrite
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ �������� ���������� �����'
      )
    , true
  );
end createTextFile;

/* ifunc: getOracleEncoding
  ���������� ��� ��������� � Oracle, ��������������� ��������� ��������� �����.

  ���������:
  charEncoding                - ��������� �����

  �������:
  ��� ��������� � Oracle ���� null, ���� �������� ��������� charEncoding
  ���� ����� null.
*/
function getOracleEncoding(
  charEncoding varchar2
)
return varchar2
is

  -- ��� ��������� � Oracle
  oracleEncoding varchar2(30);

-- getOracleEncoding
begin
  if charEncoding is not null then
    oracleEncoding :=
      case lower( charEncoding)
        when 'cp866' then 'RU8PC866'
        when 'cp1251' then 'CL8MSWIN1251'
        when 'koi8-r' then 'CL8KOI8R'
        when 'utf8' then 'UTF8'
      end
    ;
    if oracleEncoding is null then
      raise_application_error(
        pkg_Error.IllegalArgument
        , '�� ������� ���������� ��� ��������� � Oracle ��� ��������� �����: '
          || '"' || charEncoding || '".'
      );
    end if;
  end if;
  return oracleEncoding;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ����������� ��������� � Oracle ('
        || ' charEncoding="' || charEncoding || '"'
        || ').'
      )
    , true
  );
end getOracleEncoding;

/* func: convertToClob
  ����������� �������� ������ � ����������.

  ���������:
  fileData                    - ������ �����
  charEncoding                - ��������� �����
                                ( �� ��������� ���������, ��� ���� � ���������
                                ��)
*/
function convertToClob(
  fileData in out nocopy blob
  , charEncoding varchar2 := null
)
return clob
is

  -- ��������� ��
  DB_OracleEncoding constant varchar2(30) := 'CL8MSWIN1251';

  -- ��������� ����� ( �������� ���������, �������� � Oracle)
  oracleEncoding varchar2(30);

  -- ��������� ������ �����
  textData clob;
  -- ����� ��� ���������� �����
  bufferRaw raw(32767);
  -- ��������������� �����
  bufferString varchar2(32767);
  offset integer := 1;
  amount integer;
  sourceLength integer;

  -- ������ ������
  chunkSize integer;

-- convertToClob
begin
  if charEncoding is not null then
    oracleEncoding :=
      nullif( getOracleEncoding( charEncoding), DB_OracleEncoding)
    ;
  end if;
  chunkSize :=
    least( dbms_lob.getChunkSize( fileData), 32767)
  ;
  sourceLength := dbms_lob.getlength( fileData);
  dbms_lob.createtemporary( textData, true);
  loop
    amount :=
      least(
        chunkSize
        , sourceLength - offset + 1
      );
    exit when
      amount <= 0
    ;
    logger.trace( 'loadClobFromFile: read: offset=' || to_char( offset));
    dbms_lob.read(
      lob_loc => fileData
      , amount => amount
      , offset => offset
      , buffer => bufferRaw
    );
    logger.trace( 'loadClobFromFile: bufferRaw: amount=' || to_char( amount));
    if oracleEncoding is not null then
      logger.trace( 'loadClobFromFile: convert');
      bufferRaw :=
        utl_raw.convert(
          bufferRaw
          , 'RUSSIAN_CIS.' || DB_OracleEncoding
          , 'RUSSIAN_CIS.' || oracleEncoding
        )
      ;
    end if;
    logger.trace( 'loadClobFromFile: bufferString');
    bufferString := utl_raw.cast_to_varchar2( bufferRaw);
    logger.trace( 'loadClobFromFile: writeappend');
    dbms_lob.writeappend(
      lob_loc => textData
      , amount => length( bufferString)
      , buffer => bufferString
    );
    offset := offset + amount;
  end loop;
  return
    textData
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ����������� �������� ������ � ���������� ('
        || ' oracleEncoding="' || oracleEncoding || '"'
        || ').'
      )
    , true
  );
end convertToClob;

/* iproc: deleteFileSafe
  �������� ����� ���� �� ����������.

  ���������:
  filePath                    - ���� � �����
*/
procedure deleteFileSafe(
  filePath varchar2
)
is
-- deleteFileSafe
begin
  if pkg_File.checkExists( filePath) then
    pkg_File.fileDelete(
      filePath
    );
  end if;
end deleteFileSafe;



/* group: ������������ �������� ������ */

/* proc: setTestDirectory
  ��������� �������� ����������.

  ���������:
  directoryPath               - ���� � ����������
*/
procedure setTestDirectory(
  directoryPath varchar2
)
is
-- setTestDirectory
begin
  testDirectory := directoryPath;
end setTestDirectory;

/* proc: testBinaryFile
  ������������ �������� � �������� ��������� �����
  ( <pkg_FileOrigin.unloadBlobToFile>, <pkg_FileOrigin.loadBlobFromFile>).

  ���������:
  fileSize                    - ������ ����� ( � ������)
*/
procedure testBinaryFile(
  fileSize integer
)
is
  filePath varchar2(1024) :=
    pkg_File.getFilePath( getTestDirectory, 'binary_file_6.dat')
  ;

  fileData blob;

  /*
    �������� �������� ������.
  */
  procedure createBinaryData
  is
    stringSize integer := 10000;
    stringCount integer := trunc( fileSize / stringSize);
    lastStringSize integer := fileSize - stringCount * stringSize;
  begin
    dbms_lob.createtemporary( fileData, true);
    for i in 1 .. stringCount loop
      dbms_lob.append(
        fileData
        , utl_raw.cast_to_raw( rpad( Symbol, stringSize , Symbol))
      );
    end loop;
    if lastStringSize > 0 then
      dbms_lob.append(
        fileData
        , utl_raw.cast_to_raw( rpad( Symbol, lastStringSize, Symbol))
      );
    end if;
  end createBinaryData;

-- testBinaryFile
begin
  beginPerformanceTest( 'testBinaryFile');
  dbms_lob.createtemporary( fileData, true);
  createBinaryData();
  saveTestStep();
  pkg_FileOrigin.unloadBlobToFile(
    binaryData => fileData
    , toPath => filePath
  );
  saveTestStep();
  pkg_FileOrigin.loadBlobFromFile(
    fromPath => filePath
    , dstLob => fileData
  );
  pkg_TestUtility.compareChar(
    to_char( dbms_lob.getlength( fileData))
    , to_char( fileSize)
    , 'fileSize'
  );
  endPerformanceTest();
  pkg_FileOrigin.fileDelete( filePath);
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ������������ �������� � �������� ��������� ����� ('
        || ' fileSize=' || to_char( fileSize)
        || ').'
      )
    , true
  );
end testBinaryFile;

/* proc: testTextFile
  ������������ �������� � �������� ���������� �����
  ( <pkg_FileOrigin.unloadClobToFile>, <pkg_FileOrigin.loadClobFromFile>).

  ���������:
  fileSize                    - ������ ����� ( � ������)
*/
procedure testTextFile(
  fileSize integer
)
is
  filePath varchar2(1024) :=
    pkg_File.getFilePath( getTestDirectory, 'text_file.2.dat')
  ;

  fileText clob;

  /*
    �������� ��������� ������.
  */
  procedure createText
  is
    amount integer;
    actualFileSize integer := 0;
  begin
    dbms_lob.createtemporary( fileText, true);
    loop
      amount :=
        least(
          dbms_lob.getChunkSize( fileText)
          , fileSize - actualFileSize
        );
      exit when
        amount <= 0
      ;
      dbms_lob.writeappend(
        lob_loc => fileText
        , amount => amount
        , buffer => lpad( '1', amount, '1')
      );
      actualFileSize := actualFileSize + amount;
    end loop;
  end createText;

-- testTextFile
begin
  beginPerformanceTest( 'testTextFile');
  dbms_lob.createtemporary( fileText, true);
  createText();
  saveTestStep();
  pkg_FileOrigin.unloadClobToFile(
    toPath => filePath
    , fileText => fileText
    , writeMode => pkg_FileOrigin.Mode_Rewrite
  );
  saveTestStep();
  pkg_FileOrigin.loadClobFromFile(
    fromPath => filePath
    , dstLob => fileText
  );
  pkg_TestUtility.compareChar(
    to_char( dbms_lob.getlength( fileText))
    , to_char( fileSize)
    , 'fileSize'
  );
  endPerformanceTest();
  pkg_FileOrigin.fileDelete( filePath);
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ������������ ������ � ���������� �������'
      )
    , true
  );
end testTextFile;

/* proc: testLoadTxt
  ������������ �������� ���������� ����� � ������� <pkg_FileOrigin.loadTxt>;

  ���������:
  fileSize                    - ������ ����� ( � ������)
*/
procedure testLoadTxt(
  fileSize integer
)
is

  filePath varchar2(1024) :=
    pkg_File.getFilePath( getTestDirectory, 'load_txt.txt')
  ;
  textData clob;

  /*
    ��������� clob.
  */
  procedure getClob
  is
  begin
    select
      input_document
    into
      textData
    from
      doc_input_document
    ;
  end getClob;

-- testLoadTxt
begin
  beginPerformanceTest( 'testLoadTxt');
  createTextFile(
    filePath => filePath
    , fileSize => fileSize
  );
  saveTestStep();
  delete from
    doc_input_document
  ;
  pkg_FileOrigin.loadTxt(
    fromPath => filePath
    , byLine => 0
  );
  getClob();
  pkg_TestUtility.compareChar(
    to_char( dbms_lob.getlength( textData))
    , to_char( fileSize)
    , 'fileSize'
  );
  endPerformanceTest();
  pkg_FileOrigin.fileDelete( filePath);
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ������������ �������� ���������� ����� ('
        || ' fileSize=' || to_char( fileSize)
        || ')'
      )
    , true
  );
end testLoadTxt;

/* proc: testLoadTxtByLine
  ������������ �������� ���������� ����� � ������� <pkg_FileOrigin.loadTxt>;

  ���������:
  lineCount                   - ���������� ����� � �����
*/
procedure testLoadTxtByLine(
  lineCount integer
)
is

  filePath varchar2(1024) :=
    pkg_File.getFilePath( getTestDirectory, 'load_txt_by_line.txt')
  ;
  Line_Size constant integer := 1000;

  /*
    �������� ������� �����.
  */
  procedure checkLineSize
  is
    actualLineSize integer;
    actualLineCount integer;
  begin
    select
      avg( dbms_lob.getlength( input_document))
      , count( dbms_lob.getlength( input_document))
    into
      actualLineSize
      , actualLineCount
    from
      doc_input_document
    ;
    pkg_TestUtility.compareChar(
      to_char( actualLineSize)
      , to_char( Line_Size + 2)
      , 'lineSize'
    );
    pkg_TestUtility.compareChar(
      to_char( actualLineCount)
      , to_char( lineCount)
      , 'lineCount'
    );
  end checkLineSize;

begin
  beginPerformanceTest( 'testLoadTxt');
  createTextFile(
    filePath => filePath
    , lineCount => lineCount
    , lineSize => Line_Size
  );
  saveTestStep();
  delete from
    doc_input_document
  ;
  pkg_FileOrigin.loadTxt(
    fromPath => filePath
    , byLine => 1
  );
  checkLineSize();
  endPerformanceTest();
  pkg_FileOrigin.fileDelete( filePath);
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ������������ �������� ���������� ����� ('
        || ' lineCount=' || to_char( lineCount)
        || ').'
      )
    , true
  );
end testLoadTxtByLine;

/* proc: testUnloadData
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
*/
procedure testUnloadData(
  unloadFunctionName varchar2 := null
, skip0x98CheckFlag  integer := null
, charEncoding       varchar2 := null
, fileName           varchar2 := null
)
is

  -- ������ ���� � ��������� �����
  File_Path constant varchar2(32767) :=
    pkg_FileOrigin.getFilePath(
      getTestDirectory
      , coalesce( fileName, 'testUnloadData.txt')
    )
  ;

  -- ����� ������� ��� ������������
  UnloadBlob_FuncName constant varchar2(30) := 'unloadBlobToFile';
  UnloadClob_FuncName constant varchar2(30) := 'unloadClobToFile';
  UnloadTxt_FuncName  constant varchar2(30) := 'unloadTxt';

  -- ����� ���������������� �������
  testedFunctionCount integer := 0;

  -- �������� ������ ��� �������� � ����
  testData varchar2(256);



  /*
    �������������� �������� ������ ��� �������� � ����.
    ��������� ������ �� 256 �������� � ������ �� 0 �� 255 ( ���������������).
  */
  procedure fillTestData
  is
  begin
    testData := '';
    for i in 0 .. 255 loop
      if coalesce( skip0x98CheckFlag, 1) = 0
            or i != 9 * 16 + 8 -- 0x98
          then
        testData := testData || chr( i);
      end if;
    end loop;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ���������� �������� ������.'
        )
      , true
    );
  end fillTestData;



  /*
    �������� �����.
  */
  procedure checkFile(
    charEncoding varchar2 := null
  )
  is

    -- ��� ��������� ����� � Oracle
    oracleEncoding varchar2(30);

    -- ������ ����� � ��������� ����� ( ��� ���������)
    encodedTestData varchar2(1000);

    -- ������ �� ����� ( ��������, ��� ��������������)
    fileData blob;



    /*
      ���������� ��������� � ����������� �� ���������.

      ���������:
      fileText                - ������ �� �����, ����������� � varchar2
                                ( ��� ��������������)
    */
    function getDiffMessage(
      fileText varchar2
    )
    return varchar2
    is

      diffMessage varchar2(4000);

      -- ����������� ������
      testChar varchar2(1);

      -- ���������� ��� ������� ( � ��������� �����)
      goodCharCode varchar2(10);

      -- ��� ������� �� �����
      fileCharCode varchar2(10);

      -- ����� ���� �������
      codeLength pls_integer;

      -- ������� �������� � ������ �����
      k pls_integer := 1;

    begin
      diffMessage :=
        '������� � �������: "�������� ������" ( ���):'
        || ' ���������� ��� -> ����������� ���:'
      ;
      for i in 1 .. length( testData) loop
        testChar := substr( testData, i, 1);
        goodCharCode := utl_raw.cast_to_varchar2(
          utl_i18n.string_to_raw( testChar, oracleEncoding)
        );
        codeLength := length( goodCharCode);
        fileCharCode := substr( fileText, k, codeLength);
        k := k + codeLength;
        if fileCharCode = goodCharCode then
          null;
        else
          diffMessage :=
            diffMessage
            || chr(10)
            || '"' || testChar || '" ( 0x'
              || utl_raw.cast_to_raw( testChar)
              || ')'
            || ': 0x'
              || utl_raw.cast_to_raw( goodCharCode)
            || ' -> '
            || ' 0x'
              || utl_raw.cast_to_raw( fileCharCode)
          ;
        end if;
      end loop;

      return diffMessage;
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.errorStack(
            '������ ��� ������������ ��������� �� ��������.'
          )
        , true
      );
    end getDiffMessage;



  -- checkFile
  begin
    if charEncoding is not null then
      oracleEncoding := getOracleEncoding( charEncoding);
      encodedTestData := utl_raw.cast_to_varchar2(
        utl_i18n.string_to_raw( testData, oracleEncoding)
      );
    else
      encodedTestData := testData;
    end if;

    pkg_FileOrigin.loadBlobFromFile(
      dstLob      => fileData
      , fromPath  => File_Path
    );

    if pkg_TestUtility.compareChar(
          to_char( dbms_lob.getlength( fileData))
          , to_char( length( encodedTestData))
          , '������������ ������ �����'
        )
        then
      if utl_raw.cast_to_varchar2( fileData) != encodedTestData then
        pkg_TestUtility.failTest(
          '������ ��������� �����������.'
          || chr(10) || getDiffMessage( utl_raw.cast_to_varchar2( fileData))
        );
      end if;
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� �������� ������������ ����� ('
          || ' charEncoding="' || charEncoding || '"'
          || ', filePath="' || File_Path || '"'
          || ').'
        )
      , true
    );
  end checkFile;



  /*
    ��������� �������� � ������� ��������� ������� ��� ���������.
  */
  procedure testUnloadFunction(
    functionName varchar2
    , charEncoding varchar2 := null
  )
  is
  begin
    if testData is null then
      fillTestData();
    end if;

    pkg_TestUtility.beginTest(
      messageText =>
        'testUnloadData: ' || functionName
        || case when charEncoding is not null then
            ':' || charEncoding
          end
        || case when fileName is not null then
            ':' || fileName
          end
    );

    case functionName
      when UnloadBlob_FuncName then
        pkg_File.unloadBlobToFile(
          binaryData  => utl_raw.cast_to_raw( testData)
          , toPath    => File_Path
          , writeMode => pkg_FileOrigin.Mode_Rewrite
        );
      when UnloadClob_FuncName then
        pkg_File.unloadClobToFile(
          fileText        => testData
          , toPath        => File_Path
          , writeMode     => pkg_FileOrigin.Mode_Rewrite
          , charEncoding  => charEncoding
        );
      when UnloadTxt_FuncName then
        pkg_FileOrigin.deleteUnloadData();
        pkg_FileOrigin.appendUnloadData( testData);
        pkg_FileOrigin.unloadTxt(
          toPath      => File_Path
          , writeMode => pkg_FileOrigin.Mode_Rewrite
        );
    end case;
    checkFile(
      charEncoding      => charEncoding
    );

    pkg_TestUtility.endTest();
    pkg_File.fileDelete( File_Path);

    testedFunctionCount := testedFunctionCount + 1;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ������������ ������� �������� "' || functionName || '" ('
          || ' charEncoding="' || charEncoding || '"'
          || ').'
        )
      , true
    );
  end testUnloadFunction;



-- testUnloadData
begin
  if nullif( lower( unloadFunctionName), lower( UnloadBlob_FuncName)) is null
      then
    testUnloadFunction( UnloadBlob_FuncName);
  end if;
  if nullif( lower( unloadFunctionName), lower( UnloadClob_FuncName)) is null
      then
    if charEncoding is not null then
      testUnloadFunction(
        UnloadClob_FuncName
        , charEncoding => charEncoding
      );
    else
      testUnloadFunction( UnloadClob_FuncName);
      testUnloadFunction(
        UnloadClob_FuncName
        , charEncoding => 'utf8'
      );
    end if;
  end if;
  if nullif( lower( unloadFunctionName), lower( UnloadTxt_FuncName)) is null
      then
    testUnloadFunction( UnloadTxt_FuncName);
  end if;
  if testedFunctionCount = 0 then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '������� ������������ ��� ������� ��� ������������.'
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ������������ �������� ������ � ���� ('
        || ' unloadFunctionName="' || unloadFunctionName || '"'
        || ', skip0x98CheckFlag=' || skip0x98CheckFlag
        || ', charEncoding="' || charEncoding || '"'
        || ').'
      )
    , true
  );
end testUnloadData;

/* proc: testUnloadTxt
  ������������ �������� ����� � ������� <pkg_FileOrigin.unloadTxt>;

  ���������:
  fileSize                    - ������ �����
  stringSize                  - ������ ������
*/
procedure testUnloadTxt(
  fileSize integer
  , stringSize integer
)
is

  File_Path constant varchar2(32767) :=
    pkg_FileOrigin.getFilePath( getTestDirectory, 'testUnloadTxt_2.txt')
  ;

  /*
    �������� �����.
  */
  procedure checkFile
  is
    fileText clob;
  begin
    pkg_FileOrigin.loadClobFromFile(
      fileText
      , File_Path
    );
    pkg_TestUtility.compareChar(
      to_char( dbms_lob.getlength( fileText))
      , to_char( fileSize)
      , 'fileSize'
    );
  end checkFile;

-- testUnloadTxt
begin
  beginPerformanceTest( 'testUnloadTxt');
  appendUnloadTest(
    stringSize => stringSize
    , stringCount => trunc( fileSize / stringSize)
    , stringEnd => ''
    , lastStringSize => mod( fileSize, stringSize)
  );
  saveTestStep();
  pkg_FileOrigin.unloadTxt(
    toPath => File_Path
    , writeMode => pkg_FileOrigin.Mode_Rewrite
  );
  saveTestStep();
  checkFile();
  endPerformanceTest();
  pkg_File.fileDelete( File_Path);
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ������������ �������� ���������� ����� ('
        || ' fileSize=' || to_char( fileSize)
        || ').'
      )
    , true
  );
end testUnloadTxt;

/* proc: testExecCommand
  ������������ ������� ������ OS ( <pkg_FileOrigin.execCommand>);
*/
procedure testExecCommand
is
  ot clob;
  er clob;
  commandResult integer;
  hostNamePos integer;
  endOfLinePos integer;
-- testExecCommand
begin
  dbms_lob.createtemporary( ot, true);
  dbms_lob.createtemporary( er, true);
  beginPerformanceTest( 'testExecCommand');
  commandResult :=
    pkg_FileOrigin.execCommand(
      'ipconfig /all'
      , output => ot
      , error => er
    );
  hostNamePos :=  dbms_lob.instr( ot, 'Host Name');
  if hostNamePos = 0 then
    pkg_TestUtility.failTest( 'hostNamePos=0');
  end if;
  endOfLinePos := dbms_lob.instr( ot, chr(10), hostNamePos);
  logger.debug( 'hostName: ' || dbms_lob.substr( ot, endOfLinePos - hostNamePos - 1, hostNamePos));
  endPerformanceTest();
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ������������ ������� ������ OS'
      )
    , true
  );
end testExecCommand;

/* proc: testEncodingLoad
  ������������ �������� ����� � ����������� ���������.

  ���������:
  fileSize                    - ������ �����
  charEncoding                - ��������� �����
*/
procedure testEncodingLoad(
  fileSize integer
  , charEncoding varchar2
)
is

  filePath varchar2(1024) :=
    pkg_File.getFilePath( getTestDirectory, 'encoding_load.txt')
  ;
  textData clob;

-- testEncodingLoad
begin
  beginPerformanceTest( 'testEncodingLoad');
  createTextFile(
    filePath => filePath
    , fileSize => fileSize
    , charEncoding => charEncoding
  );
  saveTestStep();
  pkg_FileOrigin.loadClobFromFile(
    dstLob => textData
    , fromPath => filePath
    , charEncoding => charEncoding
  );
  pkg_TestUtility.compareChar(
    to_char( dbms_lob.getlength( textData))
    , to_char( fileSize)
    , 'fileSize'
  );
  pkg_TestUtility.compareChar(
    to_char( dbms_lob.substr( textData, 1, 1))
    , Symbol
    , 'symbol: "' || Symbol || '"'
  );
  endPerformanceTest();
  pkg_FileOrigin.fileDelete( filePath);
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ������������ �������� ����� � ��������� ('
        || ' fileSize=' || to_char( fileSize)
        || ', charEncoding="' || charEncoding || '"'
        || ').'
      )
    , true
  );
end testEncodingLoad;

/* proc: testWriteMode
  ������������ ������ ���������� �����.
*/
procedure testWriteMode(
  writeMode integer
  , expectedExceptionFlag1 number
  , expectedExceptionFlag2 number
)
is
  File_Path constant varchar2(32767) :=
    pkg_FileOrigin.getFilePath( getTestDirectory, 'testWriteMode.txt')
  ;
  fileText clob := '1';
  actualExceptionFlag1 number(1,0);
  actualExceptionFlag2 number(1,0);
-- testWriteMode
begin
  pkg_TestUtility.beginTest( 'testWriteMode');
  deleteFileSafe( filePath => File_Path);
  begin
    pkg_File.unloadClobToFile(
      fileText
      , File_Path
      , writeMode => writeMode
    );
    actualExceptionFlag1 := 0;
  exception when others then
    actualExceptionFlag1 := 1;
  end;
  pkg_TestUtility.compareChar(
    expectedString => to_char( expectedExceptionFlag1)
    , actualString => to_char( actualExceptionFlag1)
    , failMessageText => 'Exception flags differ'
  );
  begin
    pkg_File.unloadClobToFile(
      fileText
      , File_Path
      , writeMode => writeMode
    );
    actualExceptionFlag2 := 0;
  exception when others then
    actualExceptionFlag2 := 1;
  end;
  pkg_TestUtility.compareChar(
    expectedString => to_char( expectedExceptionFlag2)
    , actualString => to_char( actualExceptionFlag2)
    , failMessageText => 'Exception flags differ'
  );
  pkg_TestUtility.endTest();
end testWriteMode;

/* proc: testMakeDirectory
  ������������ �������� ����������.

  ���������:
  parentDirectory             - ������������ ���������� ��� ��������
*/
procedure testMakeDirectory(
  parentDirectory varchar2
)
is
  directoryPath varchar2(1024) :=
    pkg_File.getFilePath( parentDirectory, 'MakeDirTest');

  /*
    ���������� ����� � �������� ����������.
  */
  procedure safeTest
  is
    exceptionText varchar2(32767);
  begin
    pkg_File.makeDirectory( directoryPath, raiseExceptionFlag => true);
    pkg_File.makeDirectory( directoryPath);
    pkg_File.fileDelete( directoryPath);
  exception when others then
    exceptionText := pkg_Logging.getErrorStack() ;
    logger.trace( 'safeTest: "' || exceptionText || '"');
    pkg_TestUtility.failTest( failMessageText => exceptionText);
  end safeTest;

-- testMakeDirectory
begin
  pkg_TestUtility.beginTest( 'testMakeDirectory');
  deleteFileSafe( directoryPath);
  safeTest();
  pkg_TestUtility.endTest();
end testMakeDirectory;

/* proc: unitTest
  ����� ����.

  ���������:
  fileSize                    - ������ �����
*/
procedure unitTest(
  fileSize integer
)
is
-- unitTest
begin

  -- ����� ������������
  testUnloadData(
    skip0x98CheckFlag => 1
  );
  testMakeDirectory( parentDirectory => getTestDirectory);

  -- ����� � ������� ������������������
  testBinaryFile( fileSize => fileSize);
  testTextFile( fileSize => fileSize);
  testLoadTxt( fileSize => fileSize);
  testUnloadTxt( fileSize => fileSize, stringSize => 10000);
  testExecCommand();
  testEncodingLoad(
    fileSize          => fileSize
    , charEncoding    => 'cp866'
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ������ �����'
      )
    , true
  );
end unitTest;



/* group: ����� �� ������� ������ */

/* ifunc: getFileSize
  ���������� ������ ����� � ������ ( ��� ����������� ������� �����������
  �������� � BLOB).
  � ������ ������ ( ��������, ��-�� ���������� �����) ������������ null.
*/
function getFileSize(
  filePath varchar2
)
return integer
is

  fileData blob;

begin
  pkg_FileOrigin.loadBlobFromFile(
    dstLob      => fileData
    , fromPath  => filePath
  );
  return dbms_lob.getlength( fileData);
exception when others then
  pkg_Logging.clearErrorStack();
  return null;
end getFileSize;

/* iproc: createTestFile
  ������� �������� ���� ( � ������� ��������� unloadClobToFile).
  �� ����� �������� ����� ����������� �����������.

  ���������:
  filePath                    - ���� � �����
  fileSize                    - ������ ����� ( �� ��������� 5 ����)
*/
procedure createTestFile(
  filePath varchar2
  , fileSize pls_integer := null
)
is

  fileLogger lg_logger_t := lg_logger_t.getLogger( pkg_FileOrigin.Module_Name);

  oldLevel varchar2(100);

begin
  oldLevel := fileLogger.getLevel();
  fileLogger.setLevel( pkg_Logging.Info_LevelCode);
  pkg_FileOrigin.unloadClobToFile(
    toPath      => filePath
    , fileText  => rpad( '*', coalesce( fileSize, 5), '*')
    , writeMode => pkg_FileOrigin.Mode_Rewrite
  );
  fileLogger.setLevel( oldLevel);
exception when others then
  fileLogger.setLevel( oldLevel);
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� �������� ��������� ����� ('
        || ' filePath="' || filePath || '"'
        || ', fileSize=' || fileSize
        || ').'
      )
    , true
  );
end createTestFile;

/* proc: testFsOperation
  ������������ ���������� �������� � ������� �������� �������.
*/
procedure testFsOperation
is

  num integer;
  str varchar2(1000);
  errorMessage varchar2(32767);



  /*
    ������������ ������� checkExists.
  */
  procedure checkExistsTest
  is



    /*
      ��������� �������� ������.
    */
    procedure checkCase(
      caseName varchar2
      , fromPath varchar2
      , returnValue boolean
    )
    is

      isExists boolean;

    begin
      logger.trace( 'testFsOperation: checkExists: "' || caseName || '"');
      isExists := pkg_FileOrigin.checkExists(
        fromPath => fromPath
      );
      pkg_TestUtility.compareChar(
        case isExists
            when true then 'true'
            when false then 'false'
          end
        , case returnValue
            when true then 'true'
            when false then 'false'
          end
        , 'checkExists( ' || caseName || '): ������������ ������������ ��������'
          || ' ( "' || fromPath || '")'
      );
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.errorStack(
            '������ ��� �������� ��������� ������ ('
            || ' caseName="' || caseName || '"'
            || ', fromPath="' || fromPath || '"'
            || ').'
          )
        , true
      );
    end checkCase;



  -- checkExistsTest
  begin
    checkCase(
      'dir'
      , getTestDirectory
      , true
    );
    checkCase(
      'bad dir'
      , getTestDirectory || '$notexist$'
      , false
    );

    str := pkg_FileOrigin.getFilePath( getTestDirectory, 'fs-file.tmp');
    createTestFile( str, 5);
    checkCase(
      'file'
      , str
      , true
    );

    checkCase(
      'bad file'
      , pkg_FileOrigin.getFilePath( getTestDirectory, '$notexist$')
      , false
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ������������ ������� checkExists.'
        )
      , true
    );
  end checkExistsTest;



  /*
    ������������ ������� fileMove.
  */
  procedure fileMoveTest
  is

    srcPath varchar2(1000);
    dstPath varchar2(1000);
    subdirPath varchar2(1000);


    /*
      ��������� �������� ������.
    */
    procedure checkCase(
      caseName varchar2
      , fromPath varchar2
      , toPath varchar2
      , overwrite integer := null
      , fileSize integer := null
      , errorMask varchar2 := null
    )
    is

      caseInfo varchar2(100) := 'fileMove( ' || caseName || '): ';

      isExists boolean;

    begin
      logger.trace( 'testFsOperation: fileMove: "' || caseName || '"');
      begin
        pkg_FileOrigin.fileMove(
          fromPath      => fromPath
          , toPath      => toPath
          , overwrite   => overwrite
        );
        if errorMask is not null then
          pkg_TestUtility.failTest(
            caseInfo || '�������� ���������� ������ ������'
          );
        end if;
      exception when others then
        errorMessage := logger.getErrorStack();
        if errorMessage like errorMask then
          if not logger.isTraceEnabled() then
            -- ������� Java-output, �������� � dbms_output ( ����������
            -- ����������� ������ ����� �������������� � dbms_output)
            dbms_output.get_line( errorMessage, num);
          end if;
        elsif errorMask is null then
          pkg_TestUtility.failTest(
            caseInfo || '������ ��� ����������:'
            || chr(10) || errorMessage
          );
        else
          pkg_TestUtility.compareChar(
            errorMessage
            , errorMask
            , caseInfo || '����������� ����� ������'
          );
        end if;
      end;
      if fileSize is not null then
        pkg_TestUtility.compareChar(
          getFileSize( toPath)
          , to_char( fileSize)
          , caseInfo || '������������ ������ �����'
        );
      end if;

      if errorMask is not null then

        -- � ������ �������� ������
        if not pkg_FileOrigin.checkExists( fromPath) then
          pkg_TestUtility.failTest(
            caseInfo || '�������� ���� ��� ������'
          );
        end if;

      else

        -- ���� ��������� ����������
        if not pkg_FileOrigin.checkExists( toPath) then
          pkg_TestUtility.failTest(
            caseInfo || '���� �� ��� ����������'
          );
        end if;
        if pkg_FileOrigin.checkExists( fromPath) then
          pkg_TestUtility.failTest(
            caseInfo || '�������� ���� �� ��� ������'
          );
        end if;
      end if;
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.errorStack(
            '������ ��� �������� ��������� ������ ('
            || ' caseName="' || caseName || '"'
            || ', fromPath="' || fromPath || '"'
            || ', toPath="' || toPath || '"'
            || ', overwrite=' || overwrite
            || ').'
          )
        , true
      );
    end checkCase;



  -- fileMoveTest
  begin

    ---- ����� ������ ��������
    srcPath := pkg_FileOrigin.getFilePath( getTestDirectory, 'fs-file.tmp');
    dstPath := pkg_FileOrigin.getFilePath( getTestDirectory, 'fs-file2.tmp');

    -- ��������������
    createTestFile( srcPath, 15);
    createTestFile( dstPath, 5);
    pkg_FileOrigin.fileDelete( dstPath);
    checkCase(
      'in dir'
      , srcPath, dstPath
      , fileSize      => 15
    );

    -- ������ ��� ������� �����
    createTestFile( srcPath, 15);
    createTestFile( dstPath, 5);
    checkCase(
      'exists file error'
      , srcPath, dstPath
      , fileSize      => 5
      , errorMask     => '%ORA-20175: ���� ��� ����������%'
    );

    -- ���������� �����
    checkCase(
      'overwrite'
      , srcPath, dstPath
      , overwrite     => 1
      , fileSize      => 15
    );

    ---- �� �� ����� � ������ �������� �����������
    subdirPath := pkg_FileOrigin.getFilePath( getTestDirectory, 'Fs-Test-Dir');
    if not pkg_FileOrigin.checkExists( subdirPath) then
      pkg_FileOrigin.makeDirectory( subdirPath);
    end if;
    srcPath := pkg_FileOrigin.getFilePath( getTestDirectory, 'fs-file.tmp');
    dstPath := pkg_FileOrigin.getFilePath( subdirPath, 'fs-file2.tmp');

    -- ��������������
    createTestFile( srcPath, 15);
    createTestFile( dstPath, 5);
    pkg_FileOrigin.fileDelete( dstPath);
    checkCase(
      'subdir'
      , srcPath, dstPath
      , fileSize      => 15
    );

    -- ������ ��� ������� �����
    createTestFile( srcPath, 15);
    createTestFile( dstPath, 5);
    checkCase(
      'subdir: exists file error'
      , srcPath, dstPath
      , fileSize      => 5
      , errorMask     => '%ORA-20175: ���� ��� ����������%'
    );

    -- ���������� �����
    checkCase(
      'subdir: overwrite'
      , srcPath, dstPath
      , overwrite     => 1
      , fileSize      => 15
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ������������ ������� fileMove.'
        )
      , true
    );
  end fileMoveTest;



-- testFsOperation
begin
  pkg_TestUtility.beginTest( 'testFsOperation');
  checkExistsTest();
  fileMoveTest();
  pkg_TestUtility.endTest();
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ������������ ���������� �������� � �������� ��������.'
      )
    , true
  );
end testFsOperation;

/* proc: testHttpOperation
  ������������ ���������� �������� �� HTTP.

  ���������:
  httpInternetFileTest        - ���� ������������ ���������� �������� �� HTTP
                                c ������� � �������� ( 1 ��, 0 ��� ( ��
                                ���������))
*/
procedure testHttpOperation(
  httpInternetFileTest integer := null
)
is

  -- URL � ������ ��������� �����, ���������� �� HTTP
  binaryFile constant varchar2(200) :=
    'http://yastatic.net/morda-logo/i/arrow2/logo_simple.svg'
  ;

  binaryFileSize constant integer :=
    2240
  ;

  -- URL, ��������� � ����� ��� �������� ������ ���������� �����
  textFile varchar2(200) :=
    'http://ya.ru'
  ;
  textFileEncoding varchar2(100) := pkg_FileOrigin.Encoding_Utf8;
  textFileDataPattern varchar2(100) := '%�����%';

  -- ������������� ���� �� ��������� �����
  notexistFile varchar2(200) :=
    'http://intranet/jjj-not-exists.html'
  ;

  -- ���� �� �������������� ����� ( � ���������)
  notexistHostFile varchar2(200) :=
    'http://badhost.intranet/region.png'
  ;

  -- ���� � ��������� ( �� � ���������)
  internetFile constant varchar2(200) :=
    'http://ya.ru'
  ;

  errorMessage varchar2(32767);
  num integer;



  /*
    ������������ ��������� getProxyConfig.
  */
  procedure getProxyConfigTest
  is



    /*
      ��������� �������� ������.
    */
    procedure checkCase(
      targetUrl varchar2
      , useProxyFlag pls_integer
    )
    is

      targetProtocol varchar2(100);
      targetHost varchar2(1000);
      targetPort varchar2(100);

      serverAddress varchar2(100);
      serverPort integer;
      username varchar2(100);
      password varchar2(100);
      domain varchar2(100);

      badVariable varchar2(30);

    begin
      logger.trace( 'testHttpOperation: getProxyConfig: "' || targetUrl || '"');
      targetProtocol := substr( targetUrl, 1, instr( targetUrl, '://') - 1);
      targetHost := substr( targetUrl, length( targetProtocol) + 4);
      targetHost := substr( targetHost, 1, instr( targetHost || '/', '/') - 1);
      if targetHost like '%:%' then
        targetPort := substr( targetHost, instr( targetHost, ':') + 1);
        targetHost := substr( targetHost, 1, instr( targetHost, ':') - 1);
      else
        targetPort := '80';
      end if;

      pkg_FileBase.getProxyConfig(
        serverAddress     => serverAddress
        , serverPort      => serverPort
        , username        => username
        , password        => password
        , domain          => domain
        , targetProtocol  => targetProtocol
        , targetHost      => targetHost
        , targetPort      => to_number( targetPort)
      );
      badVariable :=
        case
          when case when serverAddress is null then 0 else 1 end
              != useProxyFlag
            then 'serverAddress'
          when case when serverPort is null then 0 else 1 end
              != useProxyFlag
            then 'serverPort'
          when case when username is null then 0 else 1 end
              != useProxyFlag
            then 'username'
          when case when password is null then 0 else 1 end
              != useProxyFlag
            then 'password'
          when case when domain is null then 0 else 1 end
              != useProxyFlag
            then 'domain'
        end
      ;
      if badVariable is not null then
        pkg_TestUtility.failTest(
          'getProxyConfig:'
          || case when useProxyFlag = 1 then
              ' �����������'
            else
              ' ������������'
            end
            || ' �������� out-��������� ' || badVariable
          || ' ('
          || ' targetProtocol="' || targetProtocol || '"'
          || ' targetHost="' || targetHost || '"'
          || ' targetPort="' || targetPort || '"'
          || ', url="' || targetUrl || '"'
          || ')'
        );
      end if;
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.errorStack(
            '������ ��� �������� ��������� ������ ('
            || ' targetUrl="' || targetUrl || '"'
            || ').'
          )
        , true
      );
    end checkCase;



  -- getProxyConfigTest
  begin
    checkCase( binaryFile, 0);
    checkCase( textFile, 0);
    if httpInternetFileTest = 1 then
      checkCase( internetFile, 1);
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ������������ ��������� getProxyConfig.'
        )
      , true
    );
  end getProxyConfigTest;



  /*
    ������������ ������� checkExists.
  */
  procedure checkExistsTest
  is

    isExists boolean;

  begin
    logger.trace( 'testHttpOperation: checkExists( exists)');
    isExists := pkg_FileOrigin.checkExists(
      fromPath => binaryFile
    );
    pkg_TestUtility.compareChar(
      case isExists
          when true then 'true'
          when false then 'false'
        end
      , 'true'
      , 'checkExists( exists): ������������ ������������ ��������'
    );

    logger.trace( 'testHttpOperation: checkExists( not exists)');
    isExists := pkg_FileOrigin.checkExists(
      fromPath => notexistFile
    );
    pkg_TestUtility.compareChar(
      case isExists
          when true then 'true'
          when false then 'false'
        end
      , 'false'
      , 'checkExists( not exists): ������������ ������������ ��������'
    );

    if httpInternetFileTest = 1 then
      logger.trace( 'testHttpOperation: checkExists( internetFile)');
      isExists := pkg_FileOrigin.checkExists(
        fromPath => internetFile
      );
      pkg_TestUtility.compareChar(
        case isExists
            when true then 'true'
            when false then 'false'
          end
        , 'true'
        , 'checkExists( internetFile): ������������ ������������ ��������'
      );
    end if;

    begin
      logger.trace( 'testHttpOperation: checkExists( bad host)');
      isExists := pkg_FileOrigin.checkExists(
        fromPath => notexistHostFile
      );
      pkg_TestUtility.failTest(
        'checkExists( bad host): �������� ���������� ������ ������ UnknownHost'
        || ' ('
        || ' isExists='
          || case isExists
              when true then 'true'
              when false then 'false'
            end
        || ')'
      );
    exception when others then
      errorMessage := logger.getErrorStack();
      if errorMessage not like '%java.net.UnknownHostException%' then
        pkg_TestUtility.compareChar(
          errorMessage
          , '%java.net.UnknownHostException%'
          , 'checkExists: ����������� ����� ������'
        );
      else
        if not logger.isTraceEnabled() then
          -- ������� Java-output, �������� � dbms_output ( ����������
          -- ����������� ������ ����� �������������� � dbms_output)
          dbms_output.get_line( errorMessage, num);
        end if;
      end if;
    end;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ������������ ������� checkExists.'
        )
      , true
    );
  end checkExistsTest;



  /*
    ������������ ��������� fileCopy.
  */
  procedure fileCopyTest
  is

    fileData blob;

    testFileName varchar2(50) := 'httpFileCopy.tmp';
    testFilePath varchar2(1000) :=
      pkg_File.getFilePath( getTestDirectory, testFileName)
    ;
    testFileSize integer;

  begin
    if pkg_FileOrigin.checkExists( testFilePath) then
      pkg_FileOrigin.fileDelete( testFilePath);
    end if;
    logger.trace( 'testHttpOperation: fileCopy');
    pkg_FileOrigin.fileCopy(
      fromPath    => binaryFile
      , toPath    => testFilePath
      , overwrite => 1
    );
    pkg_FileOrigin.fileList(
      fromPath    => getTestDirectory
      , fileMask  => testFileName
    );
    select
      max( file_size)
    into testFileSize
    from
      tmp_file_name t
    where
      t.file_name = testFileName
    ;
    if testFileSize is null then
      pkg_TestUtility.failTest(
        'fileCopy: ���� �� ��� ����������'
      );
    else
      pkg_TestUtility.compareChar(
        testFileSize
        , binaryFileSize
        , 'fileCopy: ������������ ������ �������������� �����'
      );
    end if;

    if httpInternetFileTest = 1 then
      if pkg_FileOrigin.checkExists( testFilePath) then
        pkg_FileOrigin.fileDelete( testFilePath);
      end if;
      logger.trace( 'testHttpOperation: fileCopy( internetFile)');
      pkg_FileOrigin.fileCopy(
        fromPath    => internetFile
        , toPath    => testFilePath
        , overwrite => 1
      );
      if not pkg_FileOrigin.checkExists( testFilePath) then
        pkg_TestUtility.failTest(
          'fileCopy( internetFile): ���� �� ��� ����������'
        );
      end if;
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ������������ ��������� fileCopy.'
        )
      , true
    );
  end fileCopyTest;



  /*
    ������������ ��������� loadBlobFromFile.
  */
  procedure loadBlobFromFileTest
  is

    fileData blob;

  begin
    logger.trace( 'testHttpOperation: loadBlobFromFile');
    pkg_FileOrigin.loadBlobFromFile(
      dstLob      => fileData
      , fromPath  => binaryFile
    );
    pkg_TestUtility.compareChar(
      to_char( dbms_lob.getlength( fileData))
      , to_char( binaryFileSize)
      , 'loadBlobFromFile: ������������ ������ ����������� ������'
    );

    if httpInternetFileTest = 1 then
      logger.trace( 'testHttpOperation: loadBlobFromFile( internetFile)');
      pkg_FileOrigin.loadBlobFromFile(
        dstLob      => fileData
        , fromPath  => internetFile
      );
      if coalesce( dbms_lob.getlength( fileData), 0) = 0 then
        pkg_TestUtility.failTest(
          'loadBlobFromFile( internetFile): ������ �� ���� ���������'
        );
      end if;
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ������������ ��������� loadBlobFromFile.'
        )
      , true
    );
  end loadBlobFromFileTest;



  /*
    ������������ ��������� loadClobFromFile.
  */
  procedure loadClobFromFileTest
  is

    fileData clob;

  begin
    logger.trace( 'testHttpOperation: loadClobFromFile');
    pkg_FileOrigin.loadClobFromFile(
      dstLob          => fileData
      , fromPath      => textFile
      , charEncoding  => textFileEncoding
    );
    if fileData like textFileDataPattern then
      null;
    else
      pkg_TestUtility.compareChar(
        fileData
        , textFileDataPattern
        , 'loadClobFromFile: ����������� ����� �� ������������� �����'
      );
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ������������ ��������� loadClobFromFile.'
        )
      , true
    );
  end loadClobFromFileTest;



-- testHttpOperation
begin
  pkg_TestUtility.beginTest( 'testHttpOperation');
  getProxyConfigTest();
  checkExistsTest();
  fileCopyTest();
  loadBlobFromFileTest();
  loadClobFromFileTest();
  pkg_TestUtility.endTest();
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ������������ ���������� �������� �� HTTP ('
        || ' httpInternetFileTest=' || httpInternetFileTest
        || ').'
      )
    , true
  );
end testHttpOperation;

end pkg_FileTest;
/
