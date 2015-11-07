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
 * Класс для работы с файлами файловой системы ( локальными и UNC)
 * ( подкласс класса <NetFileImpl>).
 *
 * Методы реализованы с помощью соответсвующих методов java.io.File.
 */
class FsFile extends NetFileImpl {

  /** const: READ_BUFFER_SIZE
   * Размер буфера для чтения файла
   **/
  final private static int READ_BUFFER_SIZE = 1024 * 16;

  /** const: WRITE_BUFFER_SIZE
   * Размер буфера для записи в файл
   **/
  final private static int WRITE_BUFFER_SIZE = 1024 * 16;

  /** var: logger
   * Логгер класса
   **/
  private static java.util.logging.Logger logger =
    java.util.logging.Logger.getLogger( "com.technology.oramake.file.netfile.FsFile")
  ;

  /** var: file_
   * Файл файловой системы
   **/
  private java.io.File file_;



  /** func: FsFile
   * Создает объект для работы с файлом по полному пути (локальному или UNC)
   */
  public FsFile( java.lang.String path)
  {
    file_ = new java.io.File( path);
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



  /** func: checkState
   * Обновляет информацию о файле и возвращет его тип либо null, если файл не
   * существует.
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
   * Возвращает массив с информацией о файлах каталога или null, если файл не
   * является каталогом либо не существует.
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
   * Возвращает поток для чтения из файла
   */
  public InputStream getInputStream()
    throws IOException
  {
     return new FileInputStream( file_.getPath());
  }

  /** func: getOutputStream
   * Возвращает поток для записи в файл
   */
  public OutputStream getOutputStream(boolean append)
    throws IOException
  {
     return new FileOutputStream( file_.getPath(), append);
  }


  /** proc: copy
   * Копирует файл
   */
  public void copy( String toPath, boolean overwrite)
    throws IOException
  {
    File newPath = new File( toPath);

    // Добавляем имя при копировании в каталог
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
   * Удаляет файл
   */
  public void delete()
    throws IOException
  {
    if( !file_.delete()) {                //Удаляем файл
      throw new java.io.IOException(      //Исключение при неуспешном удалении
        "File '" + file_.getPath() + "' not deleted"
        );
    }
    logger.fine( "deleted file: " + file_.getPath());
  }



  /** proc: renameTo
   * Пытается выполнить переименование файла.
   *
   * Параметры:
   * toPath                   - новый путь ( URL) к файлу
   * overwrite                - признак перезаписи файла
   *
   * Возврат:
   * true                     - в случае успеха
   * false                    - в случае неудачи
   */
  public boolean renameTo( String toPath, boolean overwrite)
    throws IOException, FTPException
  {
    boolean isOk = false;
    File newPath = new File( toPath);

    // Добавляем имя при копировании в каталог
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
   * Создаёт директорию
   *
   * raiseException           - флаг генерации исключения в случае
   *                            существования или отсутствия родительской
   *                            директории
   **/
  public void makeDirectory( boolean raiseException)
    throws IOException
  {
    if ( raiseException) {
      if ( !file_.mkdir()) {
        throw new java.io.IOException(
          // Исключение при неуспешном удалении
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
