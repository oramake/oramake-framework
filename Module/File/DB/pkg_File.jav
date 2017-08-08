create or replace and compile java source named "pkg_File" as

import java.io.*;
import java.lang.*;
import java.math.BigDecimal;
import java.sql.*;
import java.util.*;
import java.util.NoSuchElementException;
import java.util.logging.LogManager;
import java.util.zip.GZIPOutputStream;
import oracle.jdbc.*;
import oracle.jdbc.driver.*;
import oracle.sql.*;

import com.technology.oramake.file.netfile.*;

/** class: pkg_File
 * Java-���������� ������� ������ <pkg_File>.
 **/
public class pkg_File
{

  // ��� SQL-������� ��� Java-����������
  static public String SQL_LOGGER_NAME = "File.pkg_File.java";

  // ���� ������� ������ �����
  static public String WRITE_MODE_CODE_NEW      = "NEW";
  static public String WRITE_MODE_CODE_REWRITE  = "REWRITE";
  static public String WRITE_MODE_CODE_APPEND   = "APPEND";

  // UTF8 BOM Marker
  static public final byte[] UTF8_BOM = { (byte)0xEF, (byte)0xBB, (byte)0xBF};

  /* ivar: internalServerConnection
   * Current own DB connection. Initialized in static initialization
   * block.
   */
  private static Connection internalServerConnection = null;



/** func: updateJavaUtilLoggingLevel
 * ��������� ������� ����������� � java.util.logging �������� �������� ������
 * ����������� ��� ������ � PL/SQL-������ Logging.
 * ���������� ������������� ������ ��������� ���������/���������� �����������.
 *
 * ����� ����� java.util.logging ����������� ����������� ��� ������� �
 * ���������� HttpClient, ������������ ��� ������ �� HTTP.
 *
 * ���������:
 * - ��� �������� ��������� ������ ����������� �������� ������������ �����
 *   ������ �����
 *
 * exec dbms_java.grant_permission( 'SCOTT', 'SYS:java.util.logging.LoggingPermission', 'control', '' )
 *
 **/
public static void
updateJavaUtilLoggingLevel()
  throws
    java.io.IOException
    , SQLException
{
  // ������� ��� ��������� �����������
  java.util.logging.Level javaTraceLevel = java.util.logging.Level.FINEST;

  // ������� ��� ���������� �����������
  java.util.logging.Level javaInfoLevel = java.util.logging.Level.INFO;

  CallableStatement statement = internalServerConnection.prepareCall(
  " begin\n"
+ "   ? := \n"
+ "   case when\n"
+ "     lg_logger_t.getLogger( '" + SQL_LOGGER_NAME + "').isTraceEnabled()\n"
+ "   then\n"
+ "     1\n"
+ "   else\n"
+ "     0\n"
+ "   end;\n"
+ " end;\n"
  );
  statement.registerOutParameter( 1, Types.INTEGER);
  statement.executeUpdate();
  // ���� ��������� ����������� � SQL-������
  BigDecimal isTraceEnabled = statement.getBigDecimal( 1);
  statement.close();
  java.util.logging.Level newLogLevel =
    isTraceEnabled.intValue() == 1 ? javaTraceLevel : javaInfoLevel
  ;
  java.util.logging.Level logLevel =
    java.util.logging.Logger.getLogger( "").getLevel()
  ;
  if ( logLevel != newLogLevel
        // �� ��������� ����������� ���� ������� �� ������� ��� �����������
        && ! ( newLogLevel == javaInfoLevel && logLevel != javaTraceLevel)
      ) {
    boolean isTrace = newLogLevel == javaTraceLevel;
    String config =
      ".level = " + newLogLevel.getName() + "\n"
      + "handlers = java.util.logging.ConsoleHandler\n"
      + "java.util.logging.ConsoleHandler.level = "
        + ( isTrace ? "ALL" : newLogLevel.getName()) + "\n"
      + ( isTrace
          ? "org.apache.http.level = FINEST\n"
            + "org.apache.http.wire.level = SEVERE\n"
          : ""
        )
    ;
    try {
      if ( newLogLevel != javaTraceLevel) {
        java.util.logging.Logger logger =
          java.util.logging.Logger.getAnonymousLogger()
        ;
        logger.log(
          javaTraceLevel
          , "Set logging trace OFF ("
            + " level: " + logLevel.getName() + " -> " + newLogLevel.getName()
            + ")"
        );
      }
      LogManager lm = LogManager.getLogManager();
      lm.reset();
      lm.readConfiguration( new ByteArrayInputStream( config.getBytes()));
      if ( newLogLevel == javaTraceLevel) {
        java.util.logging.Logger logger =
          java.util.logging.Logger.getAnonymousLogger()
        ;
        logger.log(
          javaTraceLevel
          , "Set logging trace ON ("
            + " level: " + logLevel.getName() + " -> " + newLogLevel.getName()
            + ")"
        );
      }
    }
    catch ( SecurityException e) {
      // ��������� ������ ��-�� ���������� ���� �������
      e.printStackTrace();
    }
  }
}



/** func: logTrace
 * ��������� ���������� ������ � ��� ����������.
 *
 * ���������:
 * messageText                - ����� ���������
 **/
public static void
logTrace( java.lang.String messageText)
  throws
    SQLException
{
  PreparedStatement statement = internalServerConnection.prepareStatement(
  " declare\n"
+ "   lg lg_logger_t := lg_logger_t.getLogger( '" + SQL_LOGGER_NAME + "');\n"
+ " begin\n"
+ "   lg.trace( :messageText);\n"
+ " end;\n"
  );
  statement.setString( 1, messageText);
  statement.executeUpdate();
  statement.close();
}

/** func: saveList
 * ���������� ������ ������ � tmp_file_name
 *
 * ���������:
 * list                       - ������ �������� ���������� � ������
 * etype                      - ��� ��������� ������ ( 0 ��� ��������,
 *                              1 �����, 2 ��������)
 * mask 				              - ����� ��� ��� ������. ������������
 *					                    sql-�������� like escape '\'
 * maxCount                   - � ������ ������� ���������, ��������
 * 					                    ������ �� �� ����� maxCount ���������� ������
 **/
public static int saveList(
  FileInfo[] list
  , int etype
  , java.lang.String mask
  , java.math.BigDecimal maxCount
)
  throws
    SQLException
    , java.io.IOException
{
  logTrace( "dir: save list...");
  int nFound = 0;
  // ��� �����
  String fileName;
  // ��������� �����
  long fileSize, lastModified;
  // ���� ��� ����������
  boolean isFile;
  // ������������� �� ���� �����(0,1)
  BigDecimal maskCondition = null;
  logTrace( "dir: list.length...(" + list.length + ")");
  CallableStatement maskConditionStatement = internalServerConnection.prepareCall(
 "begin \n"
+ "  ? := \n"
+ "    case when\n"
+ "      lower( ?) like lower( ?) escape '\' \n"
+ "    then \n"
+ "      1 \n"
+ "    else \n"
+ "      0 \n"
+ "    end; \n"
+ "end ;\n"
  );
  maskConditionStatement.registerOutParameter( 1, Types.INTEGER);
  PreparedStatement insertStatement = internalServerConnection.prepareCall(
  " insert into tmp_file_name\n"
+ " (\n"
+ "   file_name\n"
+ "   , file_size\n"
+ "   , last_modification\n"
+ " )\n"
+ " values\n"
+ " ( \n"
+ "   ? \n"
+ "   , ? \n"
+ "   , TIMESTAMP '1970-01-01 00:00:00 +00:00'\n"
+ "     + NumToDSInterval( ? / 1000, 'SECOND')\n"
+ " )\n"
  );
  for(int
     i = 0
     ; i < list.length
       && ( maxCount != null ? nFound < maxCount.intValue() : true )
     ; i++
  ){
    logTrace( "dir: list[i]...(" + i + ")");
    if ( mask != null ) {
      logTrace( "dir: get fileName...");
      fileName = list[i].name();       //�������� ��� �����
      logTrace( "dir: fileName=" + fileName);
      logTrace( "dir: get isOfMask");
      maskConditionStatement.setString( 2, fileName);
      maskConditionStatement.setString( 3, mask);
      maskConditionStatement.executeUpdate();
      maskCondition = maskConditionStatement.getBigDecimal(1);
      logTrace( "dir: maskCondition=" + maskCondition);
    } else {
      fileName = null;
    }
    // ���� ������� �� ����� ���������
    if(
      maskCondition == null
      || maskCondition.intValue() == 1
    ){
      logTrace( "dir: get isFile...");
      isFile = list[i].isFile();
      // ���� ������� �� ���� ����� ���������
      if
      ( etype == 0
        || etype == 1 && isFile
        || etype == 2 && !isFile
      ){
        if ( fileName == null ){
          logTrace( "dir: get fileName...");
          fileName = list[i].name();   //�������� ��� �����
        }
        logTrace( "dir: get fileSize...");
        fileSize = list[i].length();
        logTrace( "dir: get lastModified...");
        lastModified = list[i].lastModified().getTime();
        logTrace( "dir: list[i] sql...(" + i + ")");
        insertStatement.setString( 1, fileName);
        insertStatement.setLong( 2, fileSize);
        insertStatement.setLong( 3, lastModified);
        insertStatement.executeUpdate();
        ++nFound;
        logTrace( "dir: nFound = " + nFound);
      } /* if etype*/
    } /* if maskCondition*/
  } /* for */
  maskConditionStatement.close();
  insertStatement.close();
  return ( nFound);
} /* saveList */

/** func: exists
 * ��������� ������������� ����� ��� ��������
 *
 * ���������:
 * fromPath                   - ���� � ����� ��� ��������
**/
public static java.math.BigDecimal
exists(
  java.lang.String fromPath
)
  throws
    java.io.IOException
    , java.sql.SQLException
    , com.enterprisedt.net.ftp.FTPException
{
  updateJavaUtilLoggingLevel();
  NetFile netfile = new NetFile( fromPath);
  int nExists =
    ( netfile.exists() ? 1 : 0 );
  return ( new BigDecimal( (double) nExists ));
}

/** func: dir
 * ��������� ������ ������ ���������� ��������
 *
 * ���������:
 * fromPath                   - ���� � ��������
 * entryType                  - ��� ��������� ������ ( 0 ��� ��������,
 *                              1 �����, 2 ��������)
 * mask 				- ����� ��� ��� ������. ������������
 *					  sql-�������� like escape '\'
 * maxCount                   - � ������ ������� ���������, ��������
 * 					  ������ �� �� ����� maxCount
 *					  ���������� ������
 **/
public static java.math.BigDecimal
dir(
  java.lang.String fromPath
  , java.math.BigDecimal entryType
  , java.lang.String mask
  , java.math.BigDecimal maxCount
)
  throws
    java.sql.SQLException
    , java.io.IOException
    , java.lang.IllegalArgumentException
    , java.net.MalformedURLException
    , java.text.ParseException
    , com.enterprisedt.net.ftp.FTPException
{
  updateJavaUtilLoggingLevel();
  logTrace( "dir: start...");
  int etype = entryType != null ? entryType.intValue() : 0;
  int nFound = 0;
  NetFile netfile = new NetFile( fromPath);
  logTrace( "dir: check exists...");
  if( !netfile.exists()) {                 //��������� ������� �����
    throw new java.io.FileNotFoundException(
      "Directory '" + fromPath + "' does not exist"
      );
  }
  else if( !netfile.isDirectory()) {       //��������� ��� ��� �������
    throw new java.lang.IllegalArgumentException(
      "File '" + fromPath + "' is not directory"
      );
  }
  else {
    logTrace( "dir: get list...");
    logTrace( "dir: mask=<" + mask + ">" );
    logTrace( "dir: maxCount=" + maxCount );
    FileInfo[] list = netfile.dir();       //�������� ������ ��������� ��������
    if( list == null) {                 //��������� ��������� ������
      throw new java.io.IOException(
        "Does not take list of files for '" + fromPath + "'"
        );
    }
    else {                              //��������� ������ � �������
      nFound =
        saveList(
          list
          , etype
          , mask
          , maxCount
        );
    } /* else if list == null */
  } /* else if (!netfile.isDirectory() )*/
  logTrace( "dir: finished: found " + nFound);
  return ( new BigDecimal( (double) nFound));
}

/** func: fileCopy
 * �������� ����.
 *
 * ���������:
 * fromPath                   - ������ ���� � ��������� �����
 * toPath                     - ���� � ���������� ( ������ ���� � ����� ���
 *                              ������ �������), ���� ������ ������ �������,
 *                              ����� ��� ������ ����� ����� ��������� � ������
 *                              ��������� �����
 * overwrite                  - ���� ���������� ������������� �����
 * tempFileDir                - ������� ��� ��������� ������
 **/
public static void
fileCopy( java.lang.String fromPath, java.lang.String unloadPath
        , java.math.BigDecimal overwrite, java.lang.String tempFileDir)
  throws
    SQLException
    , java.io.FileNotFoundException
    , java.io.IOException
    , java.lang.IllegalArgumentException
    , com.enterprisedt.net.ftp.FTPException
{
  updateJavaUtilLoggingLevel();
  NetFile netfile = new NetFile( fromPath);
  if( !netfile.exists()) {                 //��������� ������� �����
    throw new java.io.FileNotFoundException(
      "Source file '" + fromPath + "' does not exist"
      );
  }
  if( !netfile.isFile()) {                 //��������� ��� ��� ����
    throw new java.lang.IllegalArgumentException(
      "Source path '" + fromPath + "' is not a file"
      );
  }

  boolean isOverwrite = overwrite != null && overwrite.intValue() != 0;
  NetFile.setTempFileDir( tempFileDir);
  netfile.copy( unloadPath, isOverwrite);
}

/** func: fileDelete
 * ������� ���� ��� ������ �������.
 *
 * ���������:
 * fromPath                   - ���� � ���������� ����� ( ��������)
 **/
public static void
fileDelete( java.lang.String fromPath)
  throws
    java.sql.SQLException
    , java.io.IOException
    , java.io.FileNotFoundException
    , java.lang.IllegalArgumentException
    , com.enterprisedt.net.ftp.FTPException
{
  updateJavaUtilLoggingLevel();
  NetFile netfile = new NetFile( fromPath);
  if( !netfile.exists()) {                 //��������� ������� �����
    throw new java.io.FileNotFoundException(
      "File '" + fromPath + "' does not exist."
      );
  }
  netfile.delete();
}



/** func: fileMove
 * ���������� ����.
 *
 * ���������:
 * fromPath                   - ������ ���� � ��������� �����
 * toPath                     - ���� � ���������� ( ������ ���� � ����� ���
 *                              ������ �������), ���� ������ ������ �������,
 *                              ����� ��� ������ ����� ����� ��������� � ������
 *                              ��������� �����
 * overwrite                  - ���� ���������� ������������� �����
 * tempFileDir                - ������� ��� ��������� ������
 **/
public static void
fileMove( java.lang.String fromPath, java.lang.String toPath
        , java.math.BigDecimal overwrite, java.lang.String tempFileDir)
  throws
    SQLException
    , java.io.FileNotFoundException
    , java.io.IOException
    , java.lang.IllegalArgumentException
    , com.enterprisedt.net.ftp.FTPException
{
  updateJavaUtilLoggingLevel();
  NetFile netfile = new NetFile( fromPath);
  if( !netfile.exists()) {
    throw new java.io.FileNotFoundException(
      "Source file '" + fromPath + "' does not exist"
      );
  }
  if( !netfile.isFile()) {
    throw new java.lang.IllegalArgumentException(
      "Source path '" + fromPath + "' is not a file"
      );
  }

  boolean isOverwrite = overwrite != null && overwrite.intValue() != 0;
  NetFile.setTempFileDir( tempFileDir);
  netfile.move( toPath, isOverwrite);
}



/** func: makeDirectory
 * ������ ����������.
 *
 * dirPath                    - ���� � ����������
 * raiseExceptionFlag         - ���� ��������� ���������� � ������
 *                              ������������� ���������� ��� ����������
 *                              ������������ ����������
 **/
public static void makeDirectory(
  String dirPath
  , BigDecimal raiseExceptionFlag
)
throws
  java.io.IOException
  , java.sql.SQLException
  , com.enterprisedt.net.ftp.FTPException
{
  updateJavaUtilLoggingLevel();
  NetFile netfile = new NetFile( dirPath);
  netfile.makeDirectory(
    ( raiseExceptionFlag.intValue() == 0 ? false : true)
  );
}

/** func: checkLoadFile
 * �������� ����� ��� ��������.
 *
 * netfile                    - ������ ��� ������ � ������
 * fromPath                   - ���� � �����
 *
 */
private static void
checkLoadFile(
  NetFile netfile
  , String fromPath
)
  throws
    java.io.IOException
    , com.enterprisedt.net.ftp.FTPException
{
  // ��������� ������������� �����
  if ( !netfile.exists()) {
    // ��������� ������� �����
    throw new java.io.FileNotFoundException(
      "File \"" + fromPath + "\" does not exist"
    );
  }
  if ( !netfile.isFile()) {
    // ��������� ��� ��� ����
    throw new java.lang.IllegalArgumentException(
      "Path \"" + fromPath + "\" is not a file"
    );
  }
}

/** func: loadBlobFromFile
 * ��������� �������� ���� � BLOB.
 *
 * ���������:
 * blob                       - LOB ��� ������ ������ ( ������ ���� ��� ������)
 * fromPath                   - ���� ������������ �����
 **/
public static void loadBlobFromFile(
  oracle.sql.BLOB blob[]
  , java.lang.String fromPath
)
  throws
    SQLException
    , java.io.IOException
    , java.io.FileNotFoundException
    , java.lang.IllegalArgumentException
    , com.enterprisedt.net.ftp.FTPException
{
  updateJavaUtilLoggingLevel();
  NetFile netfile = new NetFile( fromPath);
  checkLoadFile( netfile, fromPath);
  if ( blob[0] == null) {
    // �������� �� ������� LOB
    throw new java.lang.IllegalArgumentException(
      "LOB object is null"
    );
  }
  // ������� LOB
  blob[0].trim( 0);
  // ��������� ������
  OutputStream outputStream = blob[0].setBinaryStream( 0);
  try {
    InputStream inputStream = netfile.getInputStream();
    try {
      StreamConverter.binaryToBinary( outputStream, inputStream);
    }
    finally {
      inputStream.close();
    }
  }
  finally {
    outputStream.close();
  }
} // loadBlobFromFile

/** func: loadClobFromFile
 * ��������� ��������� ���� � CLOB.
 *
 * ���������:
 * clob                       - LOB ��� ������ ������ ( ������ ���� ��� ������)
 * fromPath                   - ���� ������������ �����
 * charEncoding               - ��������� �������� ( ��-��������� ��������� ��)
 * bomFlag                    - ���� �������� ������� BOM ��� UTF-8
 **/
public static void loadClobFromFile(
  oracle.sql.CLOB clob[]
, String          fromPath
, String          charEncoding
, BigDecimal      bomFlag
)
  throws
    java.sql.SQLException
    , java.io.IOException
    , java.io.FileNotFoundException
    , java.lang.IllegalArgumentException
    , com.enterprisedt.net.ftp.FTPException
{
  updateJavaUtilLoggingLevel();
  // ���������� ����
  NetFile netfile = new NetFile( fromPath);
  checkLoadFile( netfile, fromPath);
  if ( clob[0] == null) {
    throw new java.lang.IllegalArgumentException(
      "CLOB object is null"
    );
  }
  // ������� LOB
  clob[0].trim( 0);
  // ��������� ������
  Writer writer = clob[0].setCharacterStream( 0);
  try {
    InputStream inputStream = netfile.getInputStream();
    try {
      if ( BigDecimal.ONE.equals( bomFlag)) {
        byte[] bom = new byte[3];
        if ( inputStream.read( bom, 0, 3) != 3) {
          throw new java.io.IOException(
            "File too short for BOM"
          );
        }
        if ( !Arrays.equals( bom, UTF8_BOM)) {
          throw new java.io.IOException(
            "BOM not found"
          );
        }
      }
      StreamConverter.binaryToChar( writer, inputStream, charEncoding);
    }
    finally {
      inputStream.close();
    }
  }
  finally {
    writer.close();
  }
} // loadClobFromFile


/** func: checkUnloadFile
 * �������� ����� ��� ��������.
 *
 * netfile                    - ������ ��� ������ � ������
 * unloadPath                 - ���� � �����
 * overwrite                  - �������������� ���� � ������ �������������
 */
private static void
checkUnloadFile(
  NetFile netfile
  , String unloadPath
  , boolean overwrite
)
  throws
    java.sql.SQLException
    , java.io.IOException
    , com.enterprisedt.net.ftp.FTPException
{
  if ( netfile.exists()) {
    if ( !netfile.isFile()) {
      // ��������� ��� ��� ����
      throw new java.lang.IllegalArgumentException(
        "Path \"" + unloadPath + "\" is not file"
      );
    }
    logTrace( "checkUnloadFile: overwrite=" + overwrite);
    // ���� ���� ������ �������������� � �� ����������
    if ( !overwrite) {
      // ��������� ������� �����
      throw new java.io.IOException(
        "File \"" + unloadPath + "\" already exists"
      );
    }
  }
}

/** func: unloadBlobToFile
 * ��������� �������� ������ � ����.
 *
 * ���������:
 *
 * blob                       - BLOB ��� �������� ( ������ ���� ������)
 * unloadPath                 - ���� � ��������
 * writeModeCode              - ����� ������ ������������� �����
 * gzipFlag                   - ������� ��������� �������� GZIP (1,0)
 */
public static void unloadBlobToFile(
  oracle.sql.BLOB blob
, String          unloadPath
, String          writeModeCode
, BigDecimal      gzipFlag
)
  throws
    java.sql.SQLException
    , java.io.IOException
    , java.lang.Exception
    , java.lang.IllegalArgumentException
    , com.enterprisedt.net.ftp.FTPException
{
  logTrace( "unloadBlobToFile: begin");
  NetFile netfile = new NetFile( unloadPath);
  checkUnloadFile( netfile, unloadPath, writeModeCode.equals( WRITE_MODE_CODE_REWRITE));
  if ( blob == null) {
    throw new java.lang.IllegalArgumentException(
      "BLOB object is null"
    );
  }
  InputStream inputStream = blob.getBinaryStream();
  try {
    OutputStream outputStream =
      netfile.getOutputStream( writeModeCode.equals( WRITE_MODE_CODE_APPEND))
    ;
    try {
      if ( BigDecimal.ONE.equals( gzipFlag)) {
        outputStream = new GZIPOutputStream( outputStream);
      }
      StreamConverter.binaryToBinary( outputStream, inputStream);
    }
    finally {
      outputStream.close();
    }
  }
  finally {
    inputStream.close();
  }
  return;
}

/** func: unloadClobToFile
 * ��������� ��������� ������ � ����.
 *
 * ���������:
 * clob                       - CLOB ��� �������� ( ������ ���� ������)
 * unloadPath                 - ���� � ��������
 * writeModeCode              - ����� ������ ������������ �����
 * charEncoding               - ��������� �������� ( ��-��������� ��������� ��)
 * bomFlag                    - ���� �������� ������� BOM ��� UTF-8
 * gzipFlag                   - ������� ��������� �������� GZIP (1,0)
 */
public static void unloadClobToFile(
  oracle.sql.CLOB   clob
, String            unloadPath
, String            writeModeCode
, String            charEncoding
, BigDecimal        bomFlag
, BigDecimal        gzipFlag
)
  throws
    java.sql.SQLException
    , java.io.IOException
    , java.lang.IllegalArgumentException
    , com.enterprisedt.net.ftp.FTPException
{
  logTrace( "unloadClobToFile: begin ( writeModeCode=\"" + writeModeCode + ")\"");
  NetFile netfile = new NetFile( unloadPath);
  checkUnloadFile( netfile, unloadPath, writeModeCode.equals( WRITE_MODE_CODE_REWRITE));
  if ( clob == null) {
    throw new java.lang.IllegalArgumentException(
      "CLOB object is null"
    );
  }
  Reader reader = clob.getCharacterStream();
  try {
    OutputStream outputStream =
      netfile.getOutputStream( writeModeCode.equals( WRITE_MODE_CODE_APPEND))
    ;
    try {
      if ( BigDecimal.ONE.equals( gzipFlag)) {
        outputStream = new GZIPOutputStream( outputStream);
      }
      if ( BigDecimal.ONE.equals( bomFlag)) {
        outputStream.write( UTF8_BOM);
      }
      StreamConverter.charToBinary( outputStream, reader, charEncoding);
    }
    finally {
      outputStream.close();
    }
  }
  finally {
    reader.close();
  }
  return;
}

/** func: unloadTxt
 * ��������� ��������� ���� �� ������� doc_output_document.
 *
 * ���������:
 * unloadPath                 - ���� � �����
 * writeModeCode              - ����� ������ ������������ �����
 * charEncoding               - ��������� ��������, ��-���������, ��������
 *                              ���������� � ��������� ����
 * bomFlag                    - ���� �������� ������� BOM ��� UTF-8
 * gzipFlag                   - ������� ��������� �������� GZIP (1,0)
 **/
public static void
unloadTxt(
  String unloadPath
  , String writeModeCode
  , String charEncoding
  , BigDecimal bomFlag
  , BigDecimal gzipFlag
)
  throws
    java.sql.SQLException
    , java.io.IOException
    , java.lang.IllegalArgumentException
    , com.enterprisedt.net.ftp.FTPException
{
  logTrace( "unloadTxt: start");
  NetFile netfile = new NetFile( unloadPath);
  checkUnloadFile( netfile, unloadPath, writeModeCode.equals( WRITE_MODE_CODE_REWRITE));
  logTrace( "unloadTxt: iter: begin");
  PreparedStatement outputQuery = internalServerConnection.prepareStatement(
  " select\n"
+ "   output_document\n"
+ " from\n"
+ "   doc_output_document\n"
+ " order by\n"
+ "   output_document_id\n"
  );
  ResultSet outputResult = outputQuery.executeQuery();
  logTrace( "unloadTxt: iter: end");
  OutputStream outputStream =
    netfile.getOutputStream( writeModeCode.equals( WRITE_MODE_CODE_APPEND))
  ;
  try {
    if ( BigDecimal.ONE.equals( gzipFlag)) {
      outputStream = new GZIPOutputStream( outputStream);
    }
    logTrace( "unloadTxt: got outputStream");
    if ( BigDecimal.ONE.equals( bomFlag)) {
      outputStream.write( UTF8_BOM);
    }
    while ( outputResult.next()) {
      Clob clob = outputResult.getClob( "output_document");
      logTrace( "unloadTxt: getCharacterStream");
      Reader reader = clob.getCharacterStream();
      try {
        logTrace( "unloadTxt: charToBinary");
        StreamConverter.charToBinary( outputStream, reader, charEncoding);
      }
      finally {
        reader.close();
      }
    }
  }
  finally {
    outputStream.close();
  }
  outputQuery.close();
  logTrace("unloadTxt: end");
} // unloadTxt

/** func: execCommand
 * ��������� ������� �� �� �������.
 *
 * ���������:
 * command                    - ��������� ������ ��� ����������
 * outClob                    - ��� ���������� ������ ������� ( stdout)
 * errorClob                  - ��� ���������� ������ ������ ������� ( stderr)
 *
 * ���������� ��� ���������� �������.
*/
public static
  java.math.BigDecimal execCommand(
    java.lang.String command
    , oracle.sql.CLOB outClob[]
    , oracle.sql.CLOB errorClob[]
)
  throws
    java.io.IOException
    , java.lang.InterruptedException
    , java.sql.SQLException
{
  int exitCode = -1;
  //��� ���������� �������
  logTrace( "execCommand: getRuntime");
  Runtime rt = Runtime.getRuntime();
  Process process = null;
  try {
    logTrace( "execCommand: exec");
    //��������� �������
    process = rt.exec( command);
  }
  catch( java.io.IOException e) {
    //��������� ������������� ���������.
    throw new IOException( "Could not run command \"" + e.getMessage() + "\"");
  }
  logTrace( "execCommand: outClob");
  // ��������� stdout �������
  if( ! ( outClob == null || outClob[0] == null)) {
    logTrace( "execCommand: getOutputStream");
    // ����� ��� ������ � CLOB
    Writer writer = outClob[0].setCharacterStream( 0);
    try {
      //����� ��� ������ stdout �������
      logTrace( "execCommand: BufferedInputStream");
      InputStream inputStream = process.getInputStream();
      try {
        StreamConverter.binaryToChar( writer, inputStream, null);
      }
      finally {
        logTrace( "execCommand: close streams");
        inputStream.close();
      }
    }
    finally {
      writer.close();
    }
  }
  logTrace( "execCommand: errorClob");
  // ��������� stderr �������
  if ( ! ( errorClob == null || errorClob[0] == null)) {
    //����� ��� ������ � CLOB
    logTrace( "execCommand: getOutputStream");
    // ����� ��� ������ � CLOB
    Writer writer = errorClob[0].setCharacterStream( 0);
    try {
      // ����� ��� ������ stdout �������
      logTrace( "execCommand: BufferedInputStream");
      InputStream inputStream = process.getErrorStream();
      try {
        // ������������ ������
        StreamConverter.binaryToChar( writer, inputStream, null);
      }
      finally {
        logTrace( "execCommand: close streams");
        inputStream.close();
      }
    }
    finally {
      writer.close();
    }
  }
  logTrace( "execCommand: waitFor");
  // ���� ���������� ������ �������
  exitCode = process.waitFor();
  logTrace( "execCommand: end");
  return ( new BigDecimal( (double) exitCode));
}

static {
  try {
    OracleDriver ora = new OracleDriver();
    internalServerConnection = ora.defaultConnection();
  }
  catch( SQLException e) {
    throw new RuntimeException(
      "Error while opening internal server connection"
      + "\n" + e
    );
  }
}

} // pkg_File
/
