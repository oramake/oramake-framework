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

/* class: Subversion
 * SVN root: Exchange/Module/Subversion
 */
public class Subversion {

  // Имя логера
  static public String LOGGER_NAME = "Subversion.java";

  /** var: logger
   * Логгер класса
   **/
  final private static java.util.logging.Logger logger =
    java.util.logging.Logger.getLogger( LOGGER_NAME)
  ;

  /** var: svnRepository
   * Репозиторий.
   */
  private static SVNRepository svnRepository;

/** proc: openConnection
 *  Открытие соединения с репозиторием.
 *
 *  svnRepositoryUrl             - URL репозитория ( поддерживаются протоколы
 *                              обращения svn, http, file)
 *  login                     - логин к репозиторию
 *  password                  - пароль
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
 * Закрытие соединения с репозиториям.
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
 * Проверка доступа к файлу в репозитории.
 *
 * fileSvnPath                - путь к файлу в репозитории
 *
 * Возврат:
 * 0                          - если доступа нет
 * 1                          - если доступ есть
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
 * Получение имени файла.
 *
 * fileData                   - данные файла
 * fileSvnPath                - путь к файлу в репозитории
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
 * Получение списка файлов и директорий в таблице.
 *
 * dirSvnPath                 - путь к папке в SVN
 * maxRecursiveLevel          - максимальны уровень рекурсии ( 1 - только файлы
 *                              из указанного каталога, по-умолчанию null без
 *                              ограничений)
 * directoryRecordFlag        - добавлять ли директории, по-умолчанию null нет
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
  // Атрибуты файла для добавления в таблицу
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
      #sql {
         insert into svn_file_tmp(
           file_tmp_id
           , svn_path
           , file_name
           , directory_flag
           , revision
           , author
           , last_modification
           , file_size
         )
         values(
           svn_file_tmp_seq.nextval
           , :svnPath
           , :fileName
           , :directoryFlag
           , :revision
           , :author
           , TIMESTAMP '1970-01-01 00:00:00 +00:00'
              + NumToDSInterval( :lastModified / 1000, 'SECOND')
           , :fileSize
         )
      };
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

}
/


