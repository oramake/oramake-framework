create or replace and compile java source named "Subversion" as

import java.io.*;
import java.sql.SQLException;
import java.math.BigDecimal;
import java.util.Collection;
import java.util.Iterator;
import java.util.logging.*;
import org.tmatesoft.svn.core.SVNException;
import org.tmatesoft.svn.core.SVNAuthenticationException;
import org.tmatesoft.svn.core.SVNNodeKind;
import org.tmatesoft.svn.core.SVNURL;
import org.tmatesoft.svn.core.auth.ISVNAuthenticationManager;
import org.tmatesoft.svn.core.auth.BasicAuthenticationManager;
import org.tmatesoft.svn.core.internal.io.dav.DAVRepositoryFactory;
import org.tmatesoft.svn.core.internal.io.fs.FSRepositoryFactory;
import org.tmatesoft.svn.core.internal.io.svn.SVNRepositoryFactoryImpl;
import org.tmatesoft.svn.core.io.SVNRepository;
import org.tmatesoft.svn.core.io.SVNRepositoryFactory;
import org.tmatesoft.svn.core.wc.SVNWCUtil;
import org.tmatesoft.svn.core.SVNProperties;
import org.tmatesoft.svn.core.SVNDirEntry;
import java.sql.*;
import oracle.jdbc.*;
import oracle.jdbc.driver.*;
import oracle.sql.*;


/* class: Subversion
 * SVN root: Exchange/Module/Subversion
 */
public class Subversion {

  // ��� ������
  static public String LOGGER_NAME = "Subversion.java";

  /** var: logger
   * ������ ������
   **/
  final private static java.util.logging.Logger logger =
    java.util.logging.Logger.getLogger( LOGGER_NAME)
  ;

  /* ivar: internalServerConnection
   * Current own DB connection. Initialized in static initialization
   * block.
   */
  private static Connection internalServerConnection = null;

  /** var: svnRepository
   * �����������.
   */
  private static SVNRepository svnRepository;

/** proc: openConnection
 *  �������� ���������� � ������������.
 *
 *  svnRepositoryUrl             - URL ����������� ( �������������� ���������
 *                              ��������� svn, http, file)
 *  login                     - ����� � �����������
 *  password                  - ������
 */
public static void openConnection(
  String svnRepositoryUrl
  , String login
  , String password
)
  throws IOException, SQLException, SVNException
{
  if ( svnRepository != null) {
    closeConnection();
    logger.info( "The connection to svnRepository was closed");
  }
  try {
    // connections type: svn and svn+ssh
    SVNRepositoryFactoryImpl.setup();
    // connections type DAV (svn + http/https)
    DAVRepositoryFactory.setup();
    // initializing connections type file://
    FSRepositoryFactory.setup();
    svnRepository =
       SVNRepositoryFactory.create( SVNURL.parseURIEncoded( svnRepositoryUrl));
    ISVNAuthenticationManager authManager = new BasicAuthenticationManager( login, password);
    svnRepository.setAuthenticationManager(authManager);
    logger.fine( "revision: " + svnRepository.getLatestRevision());
    logger.fine( "Bye!");
  } finally {
    svnRepository.closeSession();
  }
}

/** proc: closeConnection
 * �������� ���������� � ������������.
 */
public static void closeConnection()
  throws SVNException
{
  if ( svnRepository != null) {
    svnRepository.closeSession();
  }
  svnRepository = null;
}

/** func: checkAccess
 * �������� ������� � ����� � �����������.
 *
 * fileSvnPath                - ���� � ����� � �����������
 *
 * �������:
 * 0                          - ���� ������� ���
 * 1                          - ���� ������ ����
 */
public static BigDecimal checkAccess(
  String fileSvnPath
)
  throws IOException, SQLException, SVNException
{
  try {
    SVNNodeKind nodeKind = svnRepository.checkPath( fileSvnPath , -1);
    return new BigDecimal(1);
  } catch (  SVNAuthenticationException e) {
    return new BigDecimal(0);
  }
}


/** func: getSvnFile
 * ��������� ����� �����.
 *
 * fileData                   - ������ �����
 * fileSvnPath                - ���� � ����� � �����������
 */
public static void getSvnFile(
  oracle.sql.BLOB fileData[]
  , String fileSvnPath
)
  throws IOException, SQLException, SVNException
{
  SVNNodeKind nodeKind = svnRepository.checkPath( fileSvnPath , -1);
  if ( nodeKind == SVNNodeKind.NONE ) {
    throw new IOException( "There is no entry at '" + fileSvnPath + "'." );
  } else if ( nodeKind == SVNNodeKind.DIR ) {
    throw new IOException( "The entry at '" + fileSvnPath + "' is a directory while a file was expected." );
  }
  OutputStream outputStream = fileData[0].setBinaryStream( 0);
  // Get file contents and properties
  SVNProperties fileProperties = new SVNProperties();
  try  {
    svnRepository.getFile( fileSvnPath , -1, fileProperties, outputStream);
  }
  finally {
    outputStream.close();
  }
}


/** proc: getFileTree
 * ��������� ������ ������ � ���������� � �������.
 *
 * dirSvnPath                 - ���� � ����� � SVN
 * maxRecursiveLevel          - ����������� ������� �������� ( 1 - ������ �����
 *                              �� ���������� ��������, ��-��������� null ���
 *                              �����������)
 * directoryRecordFlag        - ��������� �� ����������, ��-��������� null ���
 */
public static void getFileTree(
  String dirSvnPath
  , BigDecimal maxRecursiveLevel
  , BigDecimal directoryRecordFlag
)
  throws IOException, SQLException, SVNException
{
  SVNNodeKind nodeKind = svnRepository.checkPath( dirSvnPath,  -1);
  if ( nodeKind == SVNNodeKind.NONE) {
    throw new RuntimeException( "There is no entry at '" + dirSvnPath + "'." );
  } else if ( nodeKind == SVNNodeKind.FILE) {
    throw new RuntimeException( "The entry at '" + dirSvnPath + "' is a file while a directory was expected." );
  }
  // �������� ����� ��� ���������� � �������
  String svnPath;
  String fileName;
  int directoryFlag;
  long revision;
  String author;
  long fileSize, lastModified;
  Collection entries = svnRepository.getDir( dirSvnPath, -1 , null , (Collection) null );
  Iterator iterator = entries.iterator();
  while ( iterator.hasNext()) {
    SVNDirEntry entry = ( SVNDirEntry) iterator.next();
    fileName = entry.getName();
    svnPath = ( dirSvnPath != null ? dirSvnPath + "/" : "") + fileName;
    directoryFlag = ( entry.getKind() == SVNNodeKind.DIR ? 1 : 0);
    revision = entry.getRevision();
    author = entry.getAuthor();
    fileSize = entry.getSize();
    lastModified = entry.getDate().getTime();
    if (
      directoryFlag == 0
      || ( directoryRecordFlag == null ? false : directoryRecordFlag.intValue() == 1)
    ) {
      PreparedStatement statement = internalServerConnection.prepareStatement(
      "  insert into svn_file_tmp(\n"
    + "    file_tmp_id\n"
    + "    , svn_path\n"
    + "    , file_name\n"
    + "    , directory_flag\n"
    + "    , revision\n"
    + "    , author\n"
    + "    , last_modification\n"
    + "    , file_size\n"
    + "  )\n"
    + "  values(\n"
    + "    svn_file_tmp_seq.nextval\n"
    + "    , :svnPath\n"
    + "    , :fileName\n"
    + "    , :directoryFlag\n"
    + "    , :revision\n"
    + "    , :author\n"
    + "    , TIMESTAMP '1970-01-01 00:00:00 +00:00'\n"
    + "       + NumToDSInterval( :lastModified / 1000, 'SECOND')\n"
    + "    , :fileSize\n"
    + "  )"
      );
      statement.setString(1, svnPath);
      statement.setString(2, fileName);
      statement.setInt(3, directoryFlag);
      statement.setLong(4, revision);
      statement.setString(5, author);
      statement.setLong(6, lastModified);
      statement.setLong(7, fileSize);
      statement.executeUpdate();
      statement.close();
    }
    if ( directoryFlag == 1
     && ( maxRecursiveLevel == null ? true : 1 < maxRecursiveLevel.intValue())) {
       getFileTree(
         svnPath
         , ( maxRecursiveLevel == null ? null : new BigDecimal( maxRecursiveLevel.intValue() - 1))
         , directoryRecordFlag
       );
    }
  }
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

}
/
