package com.technology.oramake.file.netfile;

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.io.Reader;
import java.io.Writer;

import com.enterprisedt.net.ftp.FTPException;



/** class: NetFile
 * ������������� ����� �������� ��� ������ � �������, �������������� � ���������
 * �������� ������� ( ���� �� Windows-����� ����� UNC), ��������� �� FTP ���
 * HTTP.
 */
public class NetFile
{

  /** var: logger
   * ������ ������
   **/
  private static java.util.logging.Logger logger =
    java.util.logging.Logger.getLogger( "com.technology.oramake.file.netfile.NetFile")
  ;

  /** var: tempFileDir_
   * ������� ��� ��������� ������.
   **/
  private static String tempFileDir_ = "C:\\TEMP";

  /** var: class_
   * ��� �����
   **/
  private FileClass class_;

  /** var: file_
   * ������ ��� ������ � ������
   **/
  private NetFileImpl file_;

  /** var: type_
   * ��� �����
   **/
  private FileType type_;



  /** func: NetFile
   * ������� ������ ��� ������ � ������
   **/
  public NetFile( String path)
    throws
      IOException
      , FTPException
      , java.net.MalformedURLException
      , java.sql.SQLException
  {
    class_ = FileClass.getFileClass( path);
    file_ = class_.makeNetFileImpl( path);
  }



  /** proc: setTempFileDir
   * ������������� ������� ��� ��������� ������.
   **/
  public static void setTempFileDir( String tempFileDir)
  {
    tempFileDir_ = tempFileDir;
  }



  /** func: getPath
   * ���������� ���� �� �����.
   */
  final public String getPath()
  {
    return ( file_.getPath());
  }



  /** func: getName
   * ���������� ��� �����.
   */
  final public String getName()
  {
    return ( file_.getName());
  }



  /** func: checkType
   * ��������� ������, ���� ��� ����� ������������ ���������
   **/
  protected boolean checkType( FileType expectedType)
    throws IOException, FTPException
  {
    if( type_ == null)
      type_ = file_.checkState();
    return ( type_ == expectedType);
  }



  /** func: exists
   * ��������� ������, ���� ���� ����������
   **/
  final public boolean exists()
    throws IOException, FTPException
  {
    return ( ! checkType( null));
  }



  /** func: isFile
   * ��������� ������, ���� ���� �������� ���������� ������
   **/
  final public boolean isFile()
    throws IOException, FTPException
  {
    return ( checkType( FileType.FILE));
  }



  /** func: isDirectory
   * ��������� ������, ���� ���� �������� ���������
   **/
  final public boolean isDirectory()
    throws IOException, FTPException
  {
    return ( checkType( FileType.DIRECTORY));
  }



  /** func: dir
   * ���������� ������ � ����������� � ������ �������� ��� null, ���� ���� ��
   * �������� ��������� ���� �� ����������.
   */
  public FileInfo[] dir()
    throws IOException, FTPException
  {
    return ( file_.dir());
  }



  /** func: getInputStream
   * ���������� ����� ��� ������ �� �����
   */
  public InputStream getInputStream()
    throws IOException, FTPException
  {
     return file_.getInputStream();
  }



  /** func: getOutputStream
   * ���������� ����� ��� ������ � ����
   */
  public OutputStream getOutputStream(boolean append)
    throws IOException, FTPException
  {
     return file_.getOutputStream(append);
  }



  /** proc: copy
   * �������� ����
   */
  public void copy( String toPath, boolean overwrite)
    throws
      IOException
      , FTPException
      , java.sql.SQLException
  {
    if( FileClass.getFileClass( toPath) == FileClass.FS)
      file_.copy( toPath, overwrite);
    else {
      NetFile dstFile = new NetFile( toPath);

      // ��������� ��� ��� ����������� � �������
      if( dstFile.isDirectory()) {
        String path = dstFile.getPath();
        path += ( path.length() > 0 ? "/" : "") + file_.getName();
        dstFile = new NetFile( path);
      }

      if( !overwrite) {
        if( dstFile.exists()) {
          throw new java.lang.IllegalArgumentException(
            "Destination file '" + dstFile.getPath() + "' already exist."
          );
        }
      }

      // ���� � ������������ �����
      String inputPath;

      // ��������� ����
      File tmpFile = null;

      // �������� ������ �� ��������� ���� ���� �������� �� FS-����
      if ( class_ != FileClass.FS) {
        File tmpDir = new File( tempFileDir_);
        String tmpName = "ora_jnf." + System.currentTimeMillis() + ".tmp";
        tmpFile = new File( tmpDir, tmpName);
        inputPath = tmpFile.getPath();
        file_.copy( inputPath, false);
      }
      else {
        inputPath = file_.getPath();
      }

      // ��������� ������ �� �����
      FileInputStream input = new FileInputStream( inputPath);
      try {
        OutputStream outputStream = dstFile.getOutputStream( false);
        try {
          StreamConverter.binaryToBinary( outputStream, input);
          logger.fine(
            "copied file by streams: '"
            + inputPath + "' -> '" + dstFile.getPath() + "'"
          );
        }
        finally {
          outputStream.close();
        }
      }
      finally {
        input.close();
      }

      // ������� ��������� ����
      if( tmpFile != null) {
        tmpFile.delete();
        logger.fine( "deleted temp file: " + tmpFile.getPath());
      }
    }
  }



  /** proc: delete
   * ������� ����
   */
  public void delete()
    throws IOException, FTPException
  {
    file_.delete();
  }



  /** proc: move
   * ���������� ����
   */
  public void move( String toPath, boolean overwrite)
    throws
      IOException
      , FTPException
      , java.sql.SQLException
  {
    boolean isOk = false;
    if ( class_ == FileClass.getFileClass( toPath))
      isOk = file_.renameTo( toPath, overwrite);
    if ( ! isOk) {
      copy( toPath, overwrite);
      delete();
    }
  }



  /** proc: makeDirectory
   * ������ ����������
   */
  public void makeDirectory( boolean raiseExceptionFlag)
    throws IOException, FTPException
  {
    file_.makeDirectory( raiseExceptionFlag);
  }

} // NetFile
