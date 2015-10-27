package ru.company.netfile;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.math.BigDecimal;
import java.net.URL;
import java.util.Arrays;
import java.util.Locale;

import org.apache.http.HttpEntity;
import org.apache.http.HttpHost;
import org.apache.http.HttpResponse;
import org.apache.http.StatusLine;
import org.apache.http.auth.AuthScope;
import org.apache.http.auth.NTCredentials;
import org.apache.http.client.CredentialsProvider;
import org.apache.http.client.HttpResponseException;
import org.apache.http.client.config.AuthSchemes;
import org.apache.http.client.config.RequestConfig;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpHead;
import org.apache.http.client.protocol.HttpClientContext;
import org.apache.http.impl.client.BasicCredentialsProvider;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;



/** class: NetFileImpl
 * Класс для работы с файлами через HTTP
 * ( подкласс класса <NetFileImpl>).
 *
 * Работа по HTTP реализована с помощью библиотеки <HttpClient>.
 */
class HttpFile extends NetFileImpl {

  /** var: baseUrl_
   * Исходный URL файла
   **/
  protected String baseUrl_;

  /** var: name_
   * Имя файла ( по умолчанию default.html)
   **/
  protected String name_;

  /** var: httpContext_
   * Контекст для выполнения HTTP-запросов ( null при использовании
   * контекста по-умолчанию)
   **/
  protected  HttpClientContext httpContext_;


  /** func: HttpFile
   * Создает объект по полному пути ( http://host[/path])
   */
  public HttpFile( java.lang.String path)
    throws
      IOException
      , java.net.MalformedURLException
      , java.sql.SQLException
  {
    baseUrl_ = path;
    URL url = new java.net.URL( path);
    if ( ! url.getProtocol().equalsIgnoreCase( "http"))
      throw new java.lang.IllegalArgumentException(
        "URL '" + path + "' does not use HTTP protocol."
      );
    name_ = url.getFile();
    if ( name_.length() == 0)
      name_ = "default.html";
    String targetProtocol = url.getProtocol();
    String targetHost = url.getHost();
    BigDecimal targetPort = new BigDecimal( ( double)(
      url.getPort() != -1 ? url.getPort() : url.getDefaultPort()
    ));
    String proxyServer;
    BigDecimal proxyPort;
    String proxyUsername;
    String proxyPassword;
    String proxyDomain;
    #sql {
      begin
        pkg_FileBase.getProxyConfig(
          serverAddress     => :OUT( proxyServer)
          , serverPort      => :OUT( proxyPort)
          , username        => :OUT( proxyUsername)
          , password        => :OUT( proxyPassword)
          , domain          => :OUT( proxyDomain)
          , targetProtocol  => :targetProtocol
          , targetHost      => :targetHost
          , targetPort      => :targetPort
        );
      end;
    };
    if ( proxyServer == null) {
      httpContext_ = null;
    }
    else {
      httpContext_ = HttpClientContext.create();
      HttpHost proxyHost = new HttpHost( proxyServer, proxyPort.intValue());
      String proxyWorkstation = "";
      CredentialsProvider credsProvider = new BasicCredentialsProvider();
      credsProvider.setCredentials(
        new AuthScope( proxyHost)
        , new NTCredentials(
            proxyUsername, proxyPassword, proxyWorkstation, proxyDomain
          )
      );
      httpContext_.setCredentialsProvider( credsProvider);
      httpContext_.setRequestConfig(
        RequestConfig.custom()
        .setProxy( proxyHost)
        .setProxyPreferredAuthSchemes( Arrays.asList( AuthSchemes.NTLM))
        .build()
      );
    }
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



  /** func: checkState
   * Обновляет информацию о файле и возвращет его тип либо null, если файл не
   * существует.
   */
  public FileType checkState()
    throws IOException, FTPException
  {
    FileType fileType = null;

    CloseableHttpClient client = HttpClients.createDefault();
    HttpHead request = new HttpHead( baseUrl_);
    CloseableHttpResponse response = client.execute( request, httpContext_);
    try {
      int statusCode = response.getStatusLine().getStatusCode();
      if ( statusCode == 200)
        fileType = FileType.FILE;
      else if ( statusCode != 404)
        throw new HttpResponseException(
          statusCode
          , response.getStatusLine().getReasonPhrase()
        );
    }
    finally {
      response.close();
    }

    return ( fileType);
  }



  /** func: dir
   * Возвращает массив с информацией о файлах каталога или null, если файл не
   * является каталогом либо не существует.
   * */
  public FileInfo[] dir()
    throws IOException, FTPException
  {
    return ( null);
  }



  /** func: getInputStream
   * Возвращает поток для чтения из файла
   */
  public InputStream getInputStream()
    throws IOException, FTPException
  {
    CloseableHttpClient client = HttpClients.createDefault();
    HttpGet request = new HttpGet( baseUrl_);
    CloseableHttpResponse response = client.execute( request, httpContext_);
    HttpEntity entity = response.getEntity();
    if ( entity == null) {
      response.close();
      throw new java.io.IOException(
        "Null HTTP entity."
      );
    }
    return ( entity.getContent());
  }



  /** func: getOutputStream
   * Возвращает поток для записи в файл
   */
  public OutputStream getOutputStream( boolean append)
    throws IOException, FTPException
  {
    throw new java.lang.UnsupportedOperationException(
      "Writing is not implemented for HTTP"
    );
  }



  /** proc: copy
   * Копирует файл
   */
  public void copy( String toPath, boolean overwrite)
    throws IOException, FTPException
  {
    File dstFile = new File( toPath);
    if ( dstFile.isDirectory()) {
      // Добавляем имя при копировании в каталог
      dstFile = new File( dstFile, name_);
    }
    if( dstFile.exists()) {
      if( !overwrite) {
        throw new java.lang.IllegalArgumentException(
          "Destination file '" + dstFile.getPath() + "' already exist"
          );
      }
    }

    CloseableHttpClient client = HttpClients.createDefault();
    HttpGet request = new HttpGet( baseUrl_);
    CloseableHttpResponse response = client.execute( request, httpContext_);
    try {
      final StatusLine statusLine = response.getStatusLine();
      if ( statusLine.getStatusCode() >= 300)
        throw new HttpResponseException(
          statusLine.getStatusCode()
          , statusLine.getReasonPhrase()
        );
      final FileOutputStream out = new FileOutputStream( dstFile);
      try {
        final HttpEntity entity = response.getEntity();
        if ( entity != null)
          entity.writeTo( out);
      }
      finally {
        out.close();
      }
    }
    finally {
      response.close();
    }
  }



  /** proc: delete
   * Удаляет файл
   */
  public void delete()
    throws IOException, FTPException
  {
    throw new java.lang.UnsupportedOperationException(
      "Deletion is not implemented for HTTP"
    );
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
    throw new java.lang.UnsupportedOperationException(
      "Making directory is not implemented for HTTP"
    );
  }

} // HttpFile
