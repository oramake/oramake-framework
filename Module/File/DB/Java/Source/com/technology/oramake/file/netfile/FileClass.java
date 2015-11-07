package com.technology.oramake.file.netfile;



/** class: FileClass
 * Классы файлов ( каждому классу соответствует собственный подкласс
 * класса <NetFileImpl>)
 */
class FileClass {

  /** const: FS
   * Файл файловой системы
   **/
  public static final FileClass FS = new FileClass();

  /** const: FTP
   * Файл доступный по FTP
   **/
  public static final FileClass FTP = new FileClass();

  /** const: HTTP
   * Файл доступный по HTTP
   **/
  public static final FileClass HTTP = new FileClass();



  /** func: FileClass
   * Конструктор для предотвращения некорректного создания объектов
   **/
  private FileClass() {
  }



  /** func: getFileClass
   * Возвращает класс файла, соответствующий указанному пути ( URL).
   *
   * Параметры:
   * path                     - путь ( или URL) к файлу
   **/
  public static FileClass getFileClass( String path)
  {
    return
      path.startsWith( "ftp://")
        ? FTP
      : path.startsWith( "http://")
        ? HTTP
      : FS
    ;
  }



  /** func: makeNetFileImpl
   * Создает и возвращает объект для работы с файлом.
   *
   * Параметры:
   * path                     - путь ( или URL) к файлу
   **/
  public NetFileImpl makeNetFileImpl( String path)
    throws
      IOException
      , FTPException
      , java.sql.SQLException
  {
    return
      this == FS
        ? new FsFile( path)
      : this == FTP
        ?  new FtpFile( path)
      : this == HTTP
        ? new HttpFile( path)
      : null
    ;
  }

}
