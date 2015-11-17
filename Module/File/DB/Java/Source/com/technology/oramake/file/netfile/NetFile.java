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
 * Предоставляет набор операции для работы с файлами, расположенными в локальной
 * файловой системе ( либо на Windows-шарах через UNC), доступным по FTP или
 * HTTP.
 */
public class NetFile
{

  /** var: logger
   * Логгер класса
   **/
  private static java.util.logging.Logger logger =
    java.util.logging.Logger.getLogger( "com.technology.oramake.file.netfile.NetFile")
  ;

  /** var: tempFileDir_
   * Каталог для временных файлов.
   **/
  private static String tempFileDir_ = "C:\\TEMP";

  /** var: class_
   * Тип файла
   **/
  private FileClass class_;

  /** var: file_
   * Объект для работы с файлом
   **/
  private NetFileImpl file_;

  /** var: type_
   * Тип файла
   **/
  private FileType type_;



  /** func: NetFile
   * Создает объект для работы с файлом
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
   * Устанавливает каталог для временных файлов.
   **/
  public static void setTempFileDir( String tempFileDir)
  {
    tempFileDir_ = tempFileDir;
  }



  /** func: getPath
   * Возвращает путь до файла.
   */
  final public String getPath()
  {
    return ( file_.getPath());
  }



  /** func: getName
   * Возвращает имя файла.
   */
  final public String getName()
  {
    return ( file_.getName());
  }



  /** func: checkType
   * Возвращет истину, если тип файла соотвествует заданному
   **/
  protected boolean checkType( FileType expectedType)
    throws IOException, FTPException
  {
    if( type_ == null)
      type_ = file_.checkState();
    return ( type_ == expectedType);
  }



  /** func: exists
   * Возвращет истину, если файл существует
   **/
  final public boolean exists()
    throws IOException, FTPException
  {
    return ( ! checkType( null));
  }



  /** func: isFile
   * Возвращет истину, если файл является регулярным файлом
   **/
  final public boolean isFile()
    throws IOException, FTPException
  {
    return ( checkType( FileType.FILE));
  }



  /** func: isDirectory
   * Возвращет истину, если файл является каталогом
   **/
  final public boolean isDirectory()
    throws IOException, FTPException
  {
    return ( checkType( FileType.DIRECTORY));
  }



  /** func: dir
   * Возвращает массив с информацией о файлах каталога или null, если файл не
   * является каталогом либо не существует.
   */
  public FileInfo[] dir()
    throws IOException, FTPException
  {
    return ( file_.dir());
  }



  /** func: getInputStream
   * Возвращает поток для чтения из файла
   */
  public InputStream getInputStream()
    throws IOException, FTPException
  {
     return file_.getInputStream();
  }



  /** func: getOutputStream
   * Возвращает поток для записи в файл
   */
  public OutputStream getOutputStream(boolean append)
    throws IOException, FTPException
  {
     return file_.getOutputStream(append);
  }



  /** proc: copy
   * Копирует файл
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

      // Добавляем имя при копировании в каталог
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

      // Путь к загружаемому файлу
      String inputPath;

      // Временный файл
      File tmpFile = null;

      // Копируем данные во временный файл если источник не FS-файл
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

      // Загружаем данные из файла
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

      // Удаляем временный файл
      if( tmpFile != null) {
        tmpFile.delete();
        logger.fine( "deleted temp file: " + tmpFile.getPath());
      }
    }
  }



  /** proc: delete
   * Удаляет файл
   */
  public void delete()
    throws IOException, FTPException
  {
    file_.delete();
  }



  /** proc: move
   * Перемещает файл
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
   * Создаёт директорию
   */
  public void makeDirectory( boolean raiseExceptionFlag)
    throws IOException, FTPException
  {
    file_.makeDirectory( raiseExceptionFlag);
  }

} // NetFile
