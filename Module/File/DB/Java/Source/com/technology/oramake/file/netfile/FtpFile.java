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
 * Класс для работы с файлами через FTP
 * ( базовый класс <NetFileImpl>).
 *
 * Работа через FTP реализована с помощью библиотеки <edtFTPj>.
 */
class FtpFile extends NetFileImpl {

  /** const: TCP_TIMEOUT
   * TCP таймаут
   **/
  final public static int TCP_TIMEOUT = 60 * 1000;

  /** const: DEFAULT_USER
   * Имя пользователя по умолчанию
   **/
  final private static String DEFAULT_USER = "anonymous";

  /** const: DEFAULT_PASSWORD
   * Пароль по умолчанию
   **/
  final private static String DEFAULT_PASSWORD = "ftp";

  /** const: REPLAY_NOT_EXIST_PREFIX
   * Первые две цифры ошибки выполнения CWD на несуществующий каталог
   **/
  final private static int REPLAY_NOT_EXIST_PREFIX = 55;

  /** const: OS400_SYSTEM_PREFIX
   * Префикс в строке информации о системе для OS/400
   **/
  final private static String OS400_SYSTEM_PREFIX = "OS/400";

  /** const: MSFTPS_SYSTEM
   * Имя системы для Microsoft FTP Service
   **/
  final private static String MSFTPS_SYSTEM = "XXXXXXXXXX";



  /** var: baseUrl_
   * Исходный URL файла.
   **/
  protected String baseUrl_;

  /** var: url_
   * Разобранный URL файла.
   **/
  protected java.net.URL url_;

  /** var: path_
   * Локальный путь к файлу
   **/
  protected String path_;

  /** var: dirPath_
   * Путь к локальному каталогу, содержащему файл
   **/
  protected String dirPath_;

  /** var: name_
   * Имя файла
   **/
  protected String name_;

  /** var: ftp_
   * Интерфейс к клиенту для работы с FTP
   **/
  protected FTPClientInterface ftp_;

  /** var: ftpClient_
   * Клиент для работы с FTP
   **/
  protected FTPClient ftpClient_;

  /** var: fileFactory_
   * Парсер для разбора листинга с FTP
   **/
  protected FTPFileFactory fileFactory_;



  /** func: FtpFile
   * Создает объект по полному пути ( ftp://[user[:password]@]host[/path] )
   */
  public FtpFile( java.lang.String path)
    throws IOException, FTPException, java.net.MalformedURLException
  {
    // Logger log = Logger.getLogger( "");
    // Logger.setLevel( Level.DEBUG);
    baseUrl_ = path;
                                        // Разбор URL
    url_ = new java.net.URL( path);
                                        // Определяем каталог и имя файла
    dirPath_ = url_.getPath();          // Получаем путь до файла
    if( dirPath_.startsWith( "/"))      // Удаляем начальный разделитель
      dirPath_ = dirPath_.substring( 1);
                                        // Удаляем незначимый разделитель
    if( dirPath_.endsWith( "/"))
      if( dirPath_.length() > 1)
        dirPath_ = dirPath_.substring( 0, dirPath_.length() - 1);
    path_ = dirPath_;                   // Сохраняем путь до файла
    if( dirPath_.length() != 0) {       // Выделяем имя, если оно задано
                                        // Разделяем имя и родительский каталог
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
    String user, password;              // Определяем пользователя/пароль
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
                                        // Подключаемся к серверу
    ftpClient_ = connectFtp( user, password);
    ftp_ = ftpClient_;
                                        // Устанавливаем параметры соединения
    ftp_.setType( FTPTransferType.BINARY);
    ftp_.setDetectTransferMode( false);
  }



  /** func: getPath
   * Возвращает путь до файла.
   */
  final public String getPath()
  {
    return ( baseUrl_);
  }



  /** func: getName
   * Возвращает имя файла.
   */
  final public String getName()
  {
    return ( name_);
  }



  /** func: connectFtp
   * Устанавливает соединение с FTP-сервером и авторизуется
   */
  protected FTPClient connectFtp( String user, String password)
    throws IOException, FTPException
  {
    FTPClient fc = new FTPClient();
    fc.setRemoteHost( url_.getHost());  // Устанавливаем хост
    int port = url_.getPort();          // Устанавливаем порт, если задан
    if( port != -1)
      fc.setRemotePort( port);
    fc.setTimeout( TCP_TIMEOUT);        // Устанавливаем TCP-таймаут
    fc.setControlEncoding("Windows-1251");
    fc.connect();                       // Соединение с FTP
    fc.login( user, password);          // Выполняем login на FTP
                                        // Переходим в пассивный режим
    fc.setConnectMode(FTPConnectMode.PASV);

                                        // Специальные настройки для OS/400
    String system = fc.system();
    boolean isOS400 = system.trim().startsWith( OS400_SYSTEM_PREFIX);
    if( isOS400) {
                                        // Настраиваем парсинг листинга
      String[] validCodes = {"250"};    // Допускаем только успешный ответ
                                        // Устанавливаем формат листинга
      fc.quote( "SITE LIST 1", validCodes);
                                        // Устанавливаем Unix-парсер листинга
      fileFactory_ = new FTPFileFactory( new UnixFileParser());
    }
                                        // Специальные настройки для MS FTP
    else if ( system.trim().equals( MSFTPS_SYSTEM)) {
                                        // Устанавливаем Windows-парсер листинга
      fileFactory_ = new FTPFileFactory( new WindowsFileParser());
    }
    else
      fileFactory_ = new FTPFileFactory( system);
    fc.setFTPFileFactory( fileFactory_);
                                        // Устанавливаем локаль для парсинга
                                        // списка файлов каталога.
    fileFactory_.setLocale( new Locale( "en", "RU"));
    return fc;
  }



  /** func: dirDetails
   * Возвращает список файлов каталога.
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
   * Обновляет информацию о файле и возвращет его тип либо null, если файл не
   * существует.
   */
  public FileType checkState()
    throws IOException, FTPException
  {
    FileType fileType = null;
    if( name_.length() > 0) {           // Проверка наличия элемента каталога
                                        // Выполняем LIST для каталога
      FTPFile[] files;
      files = dirDetails( dirPath_);
                                        // Ищем файл по имени
      for (int i = 0; i < files.length; i++)
        if( name_.equalsIgnoreCase( files[i].getName())) {
                                        // Определяем тип файла
          fileType = files[i].isDir() ? FileType.DIRECTORY : FileType.FILE ;
          break;
        }
    }
    else if( dirPath_.length() > 0 ) {  // Проверка существования каталога
      String curDir = ftp_.pwd();       // Сохраняем исходный каталог
      try {                             // Пытаемся перейти в нужный каталог
        ftp_.chdir( dirPath_);
        fileType = FileType.DIRECTORY;
      } catch( FTPException e) {
        int replyCode = e.getReplyCode();
        if( replyCode / 10 != REPLAY_NOT_EXIST_PREFIX)
          throw e;
      }
      if( fileType != null)             // Восстанавливаем исходный каталог
        ftp_.chdir( curDir);
    }
    else                                // Это текущий каталог, т.к. нет пути
      fileType = FileType.DIRECTORY;
    return ( fileType);
  }



  /** func: dir
   * Возвращает массив с информацией о файлах каталога или null, если файл не
   * является каталогом либо не существует.
   * */
  public FileInfo[] dir()
    throws IOException, FTPException
  {
    FileInfo[] infos = null;
    FTPFile[] files = null;
    String curDir = null;
    if( path_.length() > 0) {
      curDir = ftp_.pwd();              // Сохраняем исходный каталог
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
   * Возвращает поток для чтения из файла
   */
  public InputStream getInputStream()
    throws IOException, FTPException
  {
     return new FTPInputStream( ftpClient_, path_);
  }

  /** func: getOutputStream
   * Возвращает поток для записи в файл
   */
  public OutputStream getOutputStream( boolean append)
    throws IOException, FTPException
  {
     return new FTPOutputStream( ftpClient_, path_, append);
  }

  /** proc: copy
   * Копирует файл
   */
  public void copy( String toPath, boolean overwrite)
    throws IOException, FTPException
  {
    File newPath = new File( toPath);
    if( newPath.isDirectory()) {          //Добавляем имя при копировании в
                                          //каталог
      newPath = new File( newPath, name_);
    }
    if( newPath.exists()) {
                                          //Проверяем флаг перезаписи
      if( !overwrite) {
        throw new java.lang.IllegalArgumentException(
          "Destination file '" + newPath.getPath() + "' already exist"
          );
      }
    }
    ftp_.get( newPath.getPath(), path_);
  }

  /** proc: delete
   * Удаляет файл
   */
  public void delete()
    throws IOException, FTPException
  {
    ftp_.delete( path_);
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
    return false;
  }



  /** proc: makeDirectory
   * Создаёт директорию
   *
   * raiseException           - флаг генерации исключения в случае
   *                            существования
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
