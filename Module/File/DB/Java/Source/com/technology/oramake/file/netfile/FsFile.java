package com.technology.oramake.file.netfile;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.io.BufferedWriter;
import java.io.BufferedReader;
import java.util.zip.ZipOutputStream;
import java.util.zip.ZipEntry;


/** class: FsFile
 * ����� ��� ������ � ������� �������� ������� ( ���������� � UNC)
 * ( �������� ������ <NetFileImpl>).
 *
 * ������ ����������� � ������� �������������� ������� java.io.File.
 */
class FsFile extends NetFileImpl {

  /** const: READ_BUFFER_SIZE
   * ������ ������ ��� ������ �����
   **/
  final private static int READ_BUFFER_SIZE = 1024 * 16;

  /** const: WRITE_BUFFER_SIZE
   * ������ ������ ��� ������ � ����
   **/
  final private static int WRITE_BUFFER_SIZE = 1024 * 16;

  /** var: logger
   * ������ ������
   **/
  private static java.util.logging.Logger logger =
    java.util.logging.Logger.getLogger( "com.technology.oramake.file.netfile.FsFile")
  ;

  /** var: file_
   * ���� �������� �������
   **/
  private java.io.File file_;



  /** func: FsFile
   * ������� ������ ��� ������ � ������ �� ������� ���� (���������� ��� UNC)
   */
  public FsFile( java.lang.String path)
  {
    file_ = new java.io.File( path);
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



  /** func: checkState
   * ��������� ���������� � ����� � ��������� ��� ��� ���� null, ���� ���� ��
   * ����������.
   */
  public FileType checkState()
    throws IOException
  {
    FileType fileType = null;
    if ( file_.exists()) {
      fileType =
        file_.isFile()       ? FileType.FILE :
        file_.isDirectory()  ? FileType.DIRECTORY
                             : FileType.UNKNOWN
      ;
    }
    return ( fileType);
  }


  /** func: dir
   * ���������� ������ � ����������� � ������ �������� ��� null, ���� ���� ��
   * �������� ��������� ���� �� ����������.
   */
  public FileInfo[] dir()
    throws IOException
  {
    FileInfo[] infos = null;
    File[] files = file_.listFiles();
    if( files != null) {
      infos = new FileInfo[ files.length];
      for( int i = 0; i < infos.length; ++i)
        infos[ i] = new FsFileInfo( files[ i]);
    }
    return ( infos);
  }


  /** func: getInputStream
   * ���������� ����� ��� ������ �� �����
   */
  public InputStream getInputStream()
    throws IOException
  {
     return new FileInputStream( file_.getPath());
  }

  /** func: getOutputStream
   * ���������� ����� ��� ������ � ����
   */
  public OutputStream getOutputStream(boolean append)
    throws IOException
  {
     return new FileOutputStream( file_.getPath(), append);
  }


  /** proc: copy
   * �������� ����
   */
  public void copy( String toPath, boolean overwrite)
    throws IOException
  {
    File newPath = new File( toPath);

    // ��������� ��� ��� ����������� � �������
    if( newPath.isDirectory())
      newPath = new File( newPath, file_.getName());

    if( newPath.exists()) {
      if( !overwrite) {
        throw new java.lang.IllegalArgumentException(
          "Destination file '" + newPath.getPath() + "' already exist"
          );
      }
    }
    FileInputStream src = new FileInputStream( file_);
    int size = 0;
    try {
      FileOutputStream dst = new FileOutputStream( newPath);
      try {
        byte buffer[] = new byte[ READ_BUFFER_SIZE];
        int count;
        while( ( count = src.read( buffer)) != -1) {
          dst.write( buffer, 0, count);
          size += count;
        }
      }
      finally {
        dst.close();
      }
    }
    finally {
      src.close();
    }
    logger.fine(
      "copied file: '"
      + file_.getPath() + "' -> '" + newPath.getPath()
      + "' ( " + size + " bytes)"
    );
  }



  /** proc: delete
   * ������� ����
   */
  public void delete()
    throws IOException
  {
    if( !file_.delete()) {                //������� ����
      throw new java.io.IOException(      //���������� ��� ���������� ��������
        "File '" + file_.getPath() + "' not deleted"
        );
    }
    logger.fine( "deleted file: " + file_.getPath());
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
    boolean isOk = false;
    File newPath = new File( toPath);

    // ��������� ��� ��� ����������� � �������
    if( newPath.isDirectory())
      newPath = new File( newPath, file_.getName());

    if( newPath.exists()) {
      if( ! overwrite)
        throw new java.lang.IllegalArgumentException(
          "Destination file '" + newPath.getPath() + "' already exist"
          );
      else if( ! newPath.delete())
        throw new java.io.IOException(
          "Destination file '" + newPath.getPath() + "' not deleted"
        );
      logger.fine( "exists destination file deleted: " + newPath.getPath());
    }

    isOk = file_.renameTo( newPath);
    logger.fine(
      "rename result: " + isOk
      + " ( '" + file_.getPath() + "' -> '" + newPath.getPath() + "')"
    );

    return isOk;
  }



  /** proc: makeDirectory
   * ������ ����������
   *
   * raiseException           - ���� ��������� ���������� � ������
   *                            ������������� ��� ���������� ������������
   *                            ����������
   **/
  public void makeDirectory( boolean raiseException)
    throws IOException
  {
    if ( raiseException) {
      if ( !file_.mkdir()) {
        throw new java.io.IOException(
          // ���������� ��� ���������� ��������
          "Could not create directory: '" + file_.getPath() + '"'
        );
      }
      logger.fine( "make directory: " + file_.getPath());
    } else {
      boolean isOk = file_.mkdirs();
      logger.fine(
        "make directories result: " + isOk + " ( '" + file_.getPath() + "')"
      );
    }
  }

} // FsFile
