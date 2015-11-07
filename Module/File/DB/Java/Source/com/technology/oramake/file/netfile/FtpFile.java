package com.technology.oramake.file.netfile;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Locale;

import java.security.Security;
import java.security.KeyFactory;
import java.security.NoSuchAlgorithmException;

import com.enterprisedt.net.ftp.FTPClient;
import com.enterprisedt.net.ftp.FTPClientInterface;
import com.enterprisedt.net.ftp.FTPConnectMode;
import com.enterprisedt.net.ftp.FTPException;
import com.enterprisedt.net.ftp.FTPFile;
import com.enterprisedt.net.ftp.FTPFileFactory;
import com.enterprisedt.net.ftp.FTPInputStream;
import com.enterprisedt.net.ftp.FTPOutputStream;
import com.enterprisedt.net.ftp.FTPTransferType;
import com.enterprisedt.net.ftp.UnixFileParser;
import com.enterprisedt.net.ftp.WindowsFileParser;

import com.enterprisedt.util.debug.Logger;
import com.enterprisedt.util.debug.Level;

import org.bouncycastle.jce.provider.BouncyCastleProvider;




/** class: FtpFile
 * ����� ��� ������ � ������� ����� FTP
 * ( ������� ����� <NetFileImpl>).
 *
 * ������ ����� FTP ����������� � ������� ���������� <edtFTPj>.
 */
class FtpFile extends NetFileImpl {

  /** const: TCP_TIMEOUT
   * TCP �������
   **/
  final public static int TCP_TIMEOUT = 60 * 1000;

  /** const: DEFAULT_USER
   * ��� ������������ �� ���������
   **/
  final private static String DEFAULT_USER = "anonymous";

  /** const: DEFAULT_PASSWORD
   * ������ �� ���������
   **/
  final private static String DEFAULT_PASSWORD = "ftp";

  /** const: REPLAY_NOT_EXIST_PREFIX
   * ������ ��� ����� ������ ���������� CWD �� �������������� �������
   **/
  final private static int REPLAY_NOT_EXIST_PREFIX = 55;

  /** const: OS400_SYSTEM_PREFIX
   * ������� � ������ ���������� � ������� ��� OS/400
   **/
  final private static String OS400_SYSTEM_PREFIX = "OS/400";

  /** const: MSFTPS_SYSTEM
   * ��� ������� ��� Microsoft FTP Service
   **/
  final private static String MSFTPS_SYSTEM = "XXXXXXXXXX";



  /** var: baseUrl_
   * �������� URL �����.
   **/
  protected String baseUrl_;

  /** var: url_
   * ����������� URL �����.
   **/
  protected java.net.URL url_;

  /** var: path_
   * ��������� ���� � �����
   **/
  protected String path_;

  /** var: dirPath_
   * ���� � ���������� ��������, ����������� ����
   **/
  protected String dirPath_;

  /** var: name_
   * ��� �����
   **/
  protected String name_;

  /** var: ftp_
   * ��������� � ������� ��� ������ � FTP
   **/
  protected FTPClientInterface ftp_;

  /** var: ftpClient_
   * ������ ��� ������ � FTP
   **/
  protected FTPClient ftpClient_;

  /** var: fileFactory_
   * ������ ��� ������� �������� � FTP
   **/
  protected FTPFileFactory fileFactory_;



  /** func: FtpFile
   * ������� ������ �� ������� ���� ( ftp://[user[:password]@]host[/path] )
   */
  public FtpFile( java.lang.String path)
    throws IOException, FTPException, java.net.MalformedURLException
  {
    // Logger log = Logger.getLogger( "");
    // Logger.setLevel( Level.DEBUG);
    baseUrl_ = path;
                                        // ������ URL
    url_ = new java.net.URL( path);
                                        // ���������� ������� � ��� �����
    dirPath_ = url_.getPath();          // �������� ���� �� �����
    if( dirPath_.startsWith( "/"))      // ������� ��������� �����������
      dirPath_ = dirPath_.substring( 1);
                                        // ������� ���������� �����������
    if( dirPath_.endsWith( "/"))
      if( dirPath_.length() > 1)
        dirPath_ = dirPath_.substring( 0, dirPath_.length() - 1);
    path_ = dirPath_;                   // ��������� ���� �� �����
    if( dirPath_.length() != 0) {       // �������� ���, ���� ��� ������
                                        // ��������� ��� � ������������ �������
      int iSep = dirPath_.lastIndexOf( '/');
      name_ = dirPath_.substring( iSep + 1);
      if( name_.equals( ".") || name_.equals( ".."))
        name_ = "";
      else
        dirPath_ = iSep != -1 ? dirPath_.substring( 0, ( iSep > 0 ? iSep : 1))
                   : "";
    }
    else
      name_ = "";
    String user, password;              // ���������� ������������/������
    String userInfo = url_.getUserInfo();
    int len = userInfo.length();
    if( len > 0) {
      int iSep = userInfo.indexOf( ":");
      if( iSep != -1) {
        user = userInfo.substring( 0, iSep);
        password = userInfo.substring( iSep + 1);
      }
      else {
        user = userInfo;
        password = DEFAULT_PASSWORD;
      }
    }
    else {
      user = DEFAULT_USER;
      password = DEFAULT_PASSWORD;
    }
                                        // ������������ � �������
    ftpClient_ = connectFtp( user, password);
    ftp_ = ftpClient_;
                                        // ������������� ��������� ����������
    ftp_.setType( FTPTransferType.BINARY);
    ftp_.setDetectTransferMode( false);
  }



  /** func: getPath
   * ���������� ���� �� �����.
   */
  final public String getPath()
  {
    return ( baseUrl_);
  }



  /** func: getName
   * ���������� ��� �����.
   */
  final public String getName()
  {
    return ( name_);
  }



  /** func: connectFtp
   * ������������� ���������� � FTP-�������� � ������������
   */
  protected FTPClient connectFtp( String user, String password)
    throws IOException, FTPException
  {
    FTPClient fc = new FTPClient();
    fc.setRemoteHost( url_.getHost());  // ������������� ����
    int port = url_.getPort();          // ������������� ����, ���� �����
    if( port != -1)
      fc.setRemotePort( port);
    fc.setTimeout( TCP_TIMEOUT);        // ������������� TCP-�������
    fc.setControlEncoding("Windows-1251");
    fc.connect();                       // ���������� � FTP
    fc.login( user, password);          // ��������� login �� FTP
                                        // ��������� � ��������� �����
    fc.setConnectMode(FTPConnectMode.PASV);

                                        // ����������� ��������� ��� OS/400
    String system = fc.system();
    boolean isOS400 = system.trim().startsWith( OS400_SYSTEM_PREFIX);
    if( isOS400) {
                                        // ����������� ������� ��������
      String[] validCodes = {"250"};    // ��������� ������ �������� �����
                                        // ������������� ������ ��������
      fc.quote( "SITE LIST 1", validCodes);
                                        // ������������� Unix-������ ��������
      fileFactory_ = new FTPFileFactory( new UnixFileParser());
    }
                                        // ����������� ��������� ��� MS FTP
    else if ( system.trim().equals( MSFTPS_SYSTEM)) {
                                        // ������������� Windows-������ ��������
      fileFactory_ = new FTPFileFactory( new WindowsFileParser());
    }
    else
      fileFactory_ = new FTPFileFactory( system);
    fc.setFTPFileFactory( fileFactory_);
                                        // ������������� ������ ��� ��������
                                        // ������ ������ ��������.
    fileFactory_.setLocale( new Locale( "en", "RU"));
    return fc;
  }



  /** func: dirDetails
   * ���������� ������ ������ ��������.
   */
  protected FTPFile[] dirDetails(String dirname)
      throws IOException, FTPException
  {
    FTPFile ftpFile[] = null;
    String data[] = null;
    try {
      if ( fileFactory_ != null) {
        data = ftp_.dir( dirname, true);
        ftpFile = fileFactory_.parse( data);
      }
      else
        ftpFile = ftp_.dirDetails( dirname);
    }
    catch( java.text.ParseException e) {
      StringBuffer msg = new StringBuffer(
          data == null
            ? "Error on dirDetails.\n"
            : "Unparseable LIST answer:\n"
      );
      if( data != null) {
        for( int i = 0; i < data.length; ++i) {
          msg.append( data[i]);
          msg.append( '\n');
        }
      }
      msg.append( e.toString());
      msg.append( " (errorOffset=" + e.getErrorOffset() + ").\n");
      throw new FTPException( msg.toString());
    }
    return ftpFile;
  }


  /** func: checkState
   * ��������� ���������� � ����� � ��������� ��� ��� ���� null, ���� ���� ��
   * ����������.
   */
  public FileType checkState()
    throws IOException, FTPException
  {
    FileType fileType = null;
    if( name_.length() > 0) {           // �������� ������� �������� ��������
                                        // ��������� LIST ��� ��������
      FTPFile[] files;
      files = dirDetails( dirPath_);
                                        // ���� ���� �� �����
      for (int i = 0; i < files.length; i++)
        if( name_.equalsIgnoreCase( files[i].getName())) {
                                        // ���������� ��� �����
          fileType = files[i].isDir() ? FileType.DIRECTORY : FileType.FILE ;
          break;
        }
    }
    else if( dirPath_.length() > 0 ) {  // �������� ������������� ��������
      String curDir = ftp_.pwd();       // ��������� �������� �������
      try {                             // �������� ������� � ������ �������
        ftp_.chdir( dirPath_);
        fileType = FileType.DIRECTORY;
      } catch( FTPException e) {
        int replyCode = e.getReplyCode();
        if( replyCode / 10 != REPLAY_NOT_EXIST_PREFIX)
          throw e;
      }
      if( fileType != null)             // ��������������� �������� �������
        ftp_.chdir( curDir);
    }
    else                                // ��� ������� �������, �.�. ��� ����
      fileType = FileType.DIRECTORY;
    return ( fileType);
  }



  /** func: dir
   * ���������� ������ � ����������� � ������ �������� ��� null, ���� ���� ��
   * �������� ��������� ���� �� ����������.
   * */
  public FileInfo[] dir()
    throws IOException, FTPException
  {
    FileInfo[] infos = null;
    FTPFile[] files = null;
    String curDir = null;
    if( path_.length() > 0) {
      curDir = ftp_.pwd();              // ��������� �������� �������
      ftp_.chdir( path_);
    }
    try {
      files = dirDetails( "");
    }
    finally {
      if( curDir != null)
        ftp_.chdir( curDir);
    }
    if( files != null) {
      infos = new FileInfo[ files.length];
      for( int i = 0; i < infos.length; ++i)
        infos[ i] = new FtpFileInfo( files[ i]);
    }
    return ( infos);
  }

  /** func: getInputStream
   * ���������� ����� ��� ������ �� �����
   */
  public InputStream getInputStream()
    throws IOException, FTPException
  {
     return new FTPInputStream( ftpClient_, path_);
  }

  /** func: getOutputStream
   * ���������� ����� ��� ������ � ����
   */
  public OutputStream getOutputStream( boolean append)
    throws IOException, FTPException
  {
     return new FTPOutputStream( ftpClient_, path_, append);
  }

  /** proc: copy
   * �������� ����
   */
  public void copy( String toPath, boolean overwrite)
    throws IOException, FTPException
  {
    File newPath = new File( toPath);
    if( newPath.isDirectory()) {          //��������� ��� ��� ����������� �
                                          //�������
      newPath = new File( newPath, name_);
    }
    if( newPath.exists()) {
                                          //��������� ���� ����������
      if( !overwrite) {
        throw new java.lang.IllegalArgumentException(
          "Destination file '" + newPath.getPath() + "' already exist"
          );
      }
    }
    ftp_.get( newPath.getPath(), path_);
  }

  /** proc: delete
   * ������� ����
   */
  public void delete()
    throws IOException, FTPException
  {
    ftp_.delete( path_);
  }



  /** proc: renameTo
   * �������� ��������� �������������� �����.
   *
   * ���������:
   * toPath                   - ����� ���� ( URL) � �����
   * overwrite                - ������� ���������� �����
   *
   * �������:
   * true                     - � ������ ������
   * false                    - � ������ �������
   */
  public boolean renameTo( String toPath, boolean overwrite)
    throws IOException, FTPException
  {
    return false;
  }



  /** proc: makeDirectory
   * ������ ����������
   *
   * raiseException           - ���� ��������� ���������� � ������
   *                            �������������
   **/
  public void makeDirectory( boolean raiseException)
    throws IOException, FTPException
  {
    if ( ftp_.exists( path_)) {
      if ( raiseException) {
        throw new java.io.IOException(
          "Directory already exists : '" + path_ + '"'
        );
      }
    } else {
      ftp_.mkdir( path_);
    }
  }

} // FtpFile
