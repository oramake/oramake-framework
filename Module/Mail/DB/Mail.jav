create or replace and compile java source named "Mail" as
// title: Mail
// Реализация процедур для работы с e-mail модуля Mail.
//

import java.io.*;
import java.math.BigDecimal;
import java.sql.*;
import java.util.Properties;
import java.util.Date;
import java.util.Calendar;
import java.util.GregorianCalendar;
import javax.activation.*;
import javax.mail.*;
import javax.mail.internet.*;
import oracle.jdbc.driver.*;
import oracle.sql.*;
import com.technology.oramake.mail.orautil.ReaderInputStream;

/** class: Mail
 *  Реализация процедур для работы с e-mail модуля Mail.
 **/
public class Mail
{

  // const: RETRY_SEND_TIMEOUT_SECOND
  // Таймаут между попытками отправки сообщения ( в секундах).
  static final long RETRY_SEND_TIMEOUT_SECOND = 180;

  // const: PLAIN_TEXT_MIME_TYPE
  // Название MIME-типа для текстовых данных.
  static final String PLAIN_TEXT_MIME_TYPE = "text/plain";

  // const: HTML_TEXT_MIME_TYPE
  // Название MIME-типа для данных HTМL.
  static final String HTML_TEXT_MIME_TYPE = "text/html";

  // const: MAILBOX_INCORRECT_ERROR_MASK
  // Маска для сообщения исключения, возникающего
  // при некорректных адресах
  static final String MAILBOX_INCORRECT_ERROR_MASK =
    "%" + "javax.mail.SendFailedException: Sending failed;"
    + "%" + "class javax.mail.SendFailedException: Invalid Addresses;"
    + "%" + "class javax.mail.SendFailedException: "
    + "%" + "553 Mailbox syntax incorrect or mailbox not allowed"
    + "%";

  // const: MAILBOX_ROUTED_MAIL_ERROR_MASK
  // Маска для сообщения исключения, возникающего
  // при некоторых некорректных адресах с символами кириллицы
  static final String MAILBOX_ROUTED_MAIL_ERROR_MASK =
    "%" + "javax.mail.SendFailedException: Sending failed;"
    + "%" + "class javax.mail.SendFailedException: Invalid Addresses;"
    + "%" + "class javax.mail.SendFailedException: "
    + "%" + "553 This server does not accept routed mail"
    + "%";

  /** ivar: systemProperties
   *  Используемые свойства.
   **/
  static private Properties systemProperties = null;


  // Nested class that implements a DataSource.
  static class CLOBDataSource implements DataSource
  {
    private CLOB   data;
    private String type;

    CLOBDataSource( CLOB data, String type)
    {
      this.type = type;
      this.data = data;
    }

    public InputStream getInputStream() throws IOException
    {
      try {
        if ( data == null)
          throw new IOException("No data.");
        return new ReaderInputStream( data.getCharacterStream());
      }
      catch( SQLException e) {
        throw new IOException(
          "Cannot get input stream from CLOB.\n" + e
        );
      }
    }

    public OutputStream getOutputStream() throws IOException
    {
      throw new IOException("Cannot do this.");
    }

    public String getContentType()
    {
      return type;
    }

    public String getName()
    {
      return "CLOBDataSource";
    }

  } // CLOBDataSource



  // Nested class that implements a DataSource.
  static class BLOBDataSource implements DataSource
  {
    private BLOB   data;
    private String type;

    BLOBDataSource(BLOB data, String type)
    {
        this.type = type;
        this.data = data;
    }

    public InputStream getInputStream() throws IOException
    {
      try {
        if ( data == null)
          throw new IOException( "No data.");
        return data.getBinaryStream();
      }
      catch( SQLException e) {
        throw new IOException(
          "Cannot get input stream from BLOB.\n" + e
        );
      }
    }

    public OutputStream getOutputStream() throws IOException
    {
      throw new IOException( "Cannot do this.");
    }

    public String getContentType()
    {
      return type;
    }

    public String getName()
    {
      return "BLOBDataSource";
    }

  } // BLOBDataSource

/** func: logDebug
 * Добавляет отладочную запись в лог
 *
 * Параметры:
 * messageText                - текст сообщения
 **/
static void
logDebug(
  String messageText
)
throws SQLException
{
  #sql {
    begin
      pkg_MailInternal.LogJava(
        levelCode => pkg_Logging.Debug_LevelCode
        , messageText => :messageText
      );
    end;
  };
}

/** func: logDebug
 * Добавляет отладочную запись уровня TRACE в лог
 *
 * Параметры:
 * messageText                - текст сообщения
 **/
static void
logTrace(
  String messageText
)
throws SQLException
{
  #sql {
    begin
      pkg_MailInternal.LogJava(
        levelCode => pkg_Logging.Trace_LevelCode
        , messageText => :messageText
      );
    end;
  };
}

/** func: errorStack
 * Добавляет запись об ошибке в лог,
 * возвращая переданную в параметре строку
 *
 * Параметры:
 * messageText                - текст ошибки
 **/
static String
errorStack(
  String messageText
)
throws SQLException
{
  logDebug( messageText );
  return messageText;
}

/** func: exceptionDebug
 * Добавляет отладочную запись об ошибке в лог,
 * возвращая переданную в параметре строку
 *
 * Параметры:
 * messageText                - текст ошибки
 **/
static String
exceptionDebug(
  String messageText
)
throws SQLException
{
  logDebug( "Java exception: \"" + messageText + "\"" );
  return messageText;
}

/** func: initProperties
 * Инициализирует и возвращает используемые свойства.
 **/
static private Properties
initProperties()
throws SQLException
{
  try
  {
    if ( systemProperties == null) {
      systemProperties = System.getProperties();
                                        //Устанавливаем правильное название
                                        //для Windows-кодировки
      if ( systemProperties.getProperty( "file.encoding")
            .compareToIgnoreCase( "cp1251") == 0
          )
        systemProperties.put( "mail.mime.charset", "Windows-1251");
    }
    return systemProperties;
  }
  catch( Exception e) {
    throw new RuntimeException(
      errorStack(
        "Error during properties initialization"
        + "\n" + e
      )
    );
  }
}


/** func: getSmtpSession
 * Возвращает сессию для установки SMTP-соединения.
 *
 * Параметры:
 * smtpServer                 - используемый SMTP-сервер ( обязательно должен
 *                              быть указан)
 **/
static Session
getSmtpSession(
  String smtpServer
)
throws SQLException
{
  try
  {
    if ( smtpServer == null)
      throw new java.lang.IllegalArgumentException(
        "No SMTP sever to use."
      );
    Properties props = initProperties();
                                        //Устанавливаем SMTP-сервер
    props.put(
      "mail.smtp.host"
      , smtpServer
    );
    return ( Session.getDefaultInstance( props, null));
  }
  catch( Exception e) {
    throw new RuntimeException(
      errorStack(
        "Error while getting smtp session"
        + "\n" + e
      )
    );
  }
}

/** func: makeMessage( DATA)
 * Создает сообщение с указанными параметрами.
 **/
static Message
makeMessage(
  Session session
  , String sender
  , String recipient
  , String copyRecipient
  , String subject
  , oracle.sql.CLOB messageText
  , boolean isMultipart
  , boolean isHTML
)
throws java.lang.Exception
{
  Message msg = new MimeMessage( session);
                                        //Устанавливаем параметры сообщения
  if ( sender != null)
    msg.setFrom( new InternetAddress( sender));
  if ( recipient != null)
    msg.setRecipients(
      Message.RecipientType.TO
      , InternetAddress.parse( recipient, false)
    );
  if ( copyRecipient != null)
    msg.setRecipients(
      Message.RecipientType.CC
      , InternetAddress.parse( copyRecipient, false)
    );
  if ( subject != null)
    msg.setSubject( MimeUtility.encodeText( subject));
  msg.setSentDate( new Date());
  DataHandler textHandler =
    new DataHandler( new CLOBDataSource( messageText,
      ( isHTML ? HTML_TEXT_MIME_TYPE : PLAIN_TEXT_MIME_TYPE )));

  if ( isMultipart || isHTML ) {
                                        //Добавляем текст составного сообщения
    MimeMultipart mp =
      ( isHTML
          ? new MimeMultipart( "related" )
          : new MimeMultipart()
      );
    MimeBodyPart mbpText = new MimeBodyPart();
    if ( !isHTML ) {
      mbpText.setDisposition( Part.INLINE);
    }
    mbpText.setDataHandler( textHandler);
    mp.addBodyPart( mbpText);
    msg.setContent( mp );
  }
  else {                                //Добавляем текст простого сообщения
    msg.setDataHandler( textHandler);
  }

  return msg;
                                       // Не логируем исключение
                                       // так как процедура вызывается массово
}

/** func: addAttachment
 * Добавляет вложение.
 **/
static void
addAttachment(
  Multipart mp
  , String fileName
  , String contentType
  , oracle.sql.BLOB data
  , boolean isImageContent
)
throws java.lang.Exception
{
  MimeBodyPart mbp = new MimeBodyPart();
  if ( isImageContent ) {
    logDebug( "addAttachment: isImageContent");
    mbp.setDisposition( null);
    mbp.setHeader( "Content-ID", "<image>");
  }
  else {
    logDebug( "addAttachment: fileName=\"" + fileName + "\"");
    mbp.setDisposition( Part.ATTACHMENT);
    mbp.setFileName( MimeUtility.encodeText( fileName));
  }
  mbp.setDataHandler( new DataHandler(
    new BLOBDataSource( data, contentType))
  );
  mp.addBodyPart( mbp);
                                       // Не логируем исключение
                                       // так как процедура вызывается массово
}

/** func: send
 * Отправляет письмо ( немедленно).
 **/
public static void
send(
  String sender
  , String recipient
  , String copyRecipient
  , String subject
  , oracle.sql.CLOB messageText
  , String attachmentFileName
  , String attachmentType
  , oracle.sql.BLOB attachmentData
  , String smtpServer
  , oracle.sql.NUMBER isHTML
)
throws java.lang.Exception
{
try
{
  boolean isMultipart = attachmentData != null;
  Message msg = makeMessage(
    getSmtpSession( smtpServer)
    , sender
    , recipient
    , copyRecipient
    , subject
    , messageText
    , isMultipart
    , ( isHTML == null ? false : isHTML.intValue() == 1 )
  );
  if ( attachmentData != null)
    addAttachment(
      ( Multipart) msg.getContent()
      , attachmentFileName
      , attachmentType
      , attachmentData
      , false
    );
  Transport.send( msg);
}
  catch( Exception e) {
    throw new RuntimeException(
      errorStack(
        "Error while sending message"
        + "\n" + e
      )
    );
  }
} // send

/** func: changeUrlPassword
 * Возвращает URL с измененным паролем.
 **/
public static String
changeUrlPassword(
  String url
  , String password
)
throws java.lang.Exception
{
try
{
  URLName un = null;
  if ( url != null) {
    un = new URLName( url);
    un = new URLName(
      un.getProtocol()
      , un.getHost()
      , un.getPort()
      , un.getFile()
      , un.getUsername()
      , password
    );
  }
  return ( un != null ? un.toString() : null);
}
  catch( Exception e) {
    throw new RuntimeException(
      errorStack(
        "Error while getting url with password"
        + "\n" + e
      )
    );
  }
}



/** func: getMailboxAddress
 * Определяет почтовый адрес на основе URL для подключения к почтовому ящику.
 **/
public static String
getMailboxAddress(
  String url
)
throws java.lang.Exception
{
try
{
  String mailboxAddress = null;
  if ( url != null) {
    URLName urln = new URLName( url);
    if ( urln != null) {
      mailboxAddress = getMailboxAddress( urln);
    }
  }
  return mailboxAddress;
}
  catch( Exception e) {
    throw new RuntimeException(
      errorStack(
        "Error while getting mailbox address by url"
        + "\n" + e
      )
    );
  }
}

/** func: getMailboxAddress( URL)
 * Определяет почтовый адрес на основе URL для подключения к почтовому ящику.
 **/
static String
getMailboxAddress(
  URLName urln
)
throws java.lang.Exception
{
try
{
  String mailboxAddress = urln.getHost();
  mailboxAddress = (
      urln.getUsername() + "@"
      + mailboxAddress.substring( mailboxAddress.indexOf( '.') + 1)
    ).toLowerCase()
  ;
  return mailboxAddress;
}
  catch( Exception e) {
    throw new RuntimeException(
      errorStack(
        "Error while getting mailbox address by URLName"
        + "\n" + e
      )
    );
  }
}

/** func: getAddress
 * Возвращает нормализованный почтовый адрес.
 * по массиву Address[]
 * При наличии нескольких адресов, возвращается первый из них.
 **/
public static String
getAddress(
  Address[] adr
)
throws java.lang.Exception
{
try
{
  String address = null;
  if ( adr != null
       && adr.length > 0
       && adr[0] instanceof InternetAddress
     ) {
    address = ( (InternetAddress) adr[0]).getAddress().toLowerCase();
  }
  return address;
}
  catch( Exception e) {
    throw new RuntimeException(
      errorStack(
        "Error while getting main address"
        + "by Address[] \n" + e
      )
    );
  }
}

/** func: getAddress
 * Возвращает нормализованный почтовый адрес.
 * При наличии нескольких адресов, возвращается первый из них.
 **/
public static String
getAddress(
  String addressText
)
throws java.lang.Exception
{
try
{
  if ( addressText != null ) {
    InternetAddress[] ia = InternetAddress.parse( addressText);
    return getAddress( ia);
  } else {
    return null;
  }
}
  catch( Exception e) {
    throw new RuntimeException(
      errorStack(
        "Error while getting main address"
        + "\n" + e
      )
    );
  }
}

/** func: getEncodedAddressList
 * Возвращает кодированный список адресов
 * по массиву объектов Address
 **/
public static String
getEncodedAddressList(
  Address[] adr
)
throws java.lang.Exception
{
try
{
  if ( adr != null) {
                                       // Необходимо установить charset
                                       // до вызова MimeUtility.encodeText
    initProperties();
    for ( int i = 0; i < adr.length; i++) {
      if ( adr[i] instanceof InternetAddress) {
        InternetAddress iadr = ( InternetAddress) adr[i];
        String personal = iadr.getPersonal();
        if ( personal != null)
          iadr.setPersonal( MimeUtility.encodeText( personal));
      }
    }
  }
  return ( adr != null ? InternetAddress.toString( adr) : null);
}
  catch( Exception e) {
    throw new RuntimeException(
      errorStack(
        "Error while getting encoded address list"
        + "by Address[] \n" + e
      )
    );
  }
}

/** func: getEncodedAddressList
 * Возвращает кодированный список адресов
 **/
public static String
getEncodedAddressList(
  String textAddressList
)
throws java.lang.Exception
{
try
{
  InternetAddress[] ia = null;
  if ( textAddressList != null) {
    ia = InternetAddress.parse(
      textAddressList.replace( ';', ',')
    );
    return
      getEncodedAddressList( ia);
  }
  else {
    return null;
  }
}
  catch( Exception e) {
    throw new RuntimeException(
      errorStack(
        "Error while getting encoded address list"
        + "\n" + e
      )
    );
  }
}

/** func: getTextAddressList(InternetAddress[])
 * Возвращает текстовый список адресов по
 * массиву объектов Address
 **/
public static String
getTextAddressList(
  Address[] adr
)
throws java.lang.Exception
{
try
{
  StringBuffer textList = null;
  if ( adr != null) {
    textList = new StringBuffer();
    for ( int i = 0; i < adr.length; i++) {
      if ( adr[i] instanceof InternetAddress) {
        InternetAddress iadr = ( InternetAddress) adr[i];
        if ( textList.length() != 0)
          textList.append( ", ");
        String personal = iadr.getPersonal();
        if ( personal != null) {
          boolean isQuoted =
            personal.indexOf( ',') != -1 || personal.indexOf( ';') != -1
          ;
          if ( isQuoted)
            textList.append( '"');
          textList.append( personal);
          if ( isQuoted)
            textList.append( '"');
          textList.append( " <");
        }
        textList.append( iadr.getAddress());
        if ( personal != null) {
          textList.append( '>');
        }
      } // if instance of InternetAddress
    } // for
  }  // if adr!=null
  return ( textList != null ? textList.toString() : null);
}
  catch( Exception e) {
    throw new RuntimeException(
      errorStack(
        "Error while getting text address list by Address[]"
        + "\n" + e
      )
    );
  }
}

/** func: getTextAddressList
 * Возвращает текстовый список адресов.
 **/
public static String
getTextAddressList(
  String addressList
)
throws java.lang.Exception
{
try
{
  if ( addressList != null) {
    InternetAddress[] ia = InternetAddress.parse( addressList);
    return getTextAddressList( ia);
  }
  else {
    return null;
  }
}
  catch( Exception e) {
    throw new RuntimeException(
      errorStack(
        "Error while getting text address list"
        + "\n" + e
      )
    );
  }
}

/** func: processFetchError
 * Обрабатывает ошибку получения сообщения
 **/
static void processFetchError(
  Message msg
  , StringBuffer processMessage
  , int maxProcessMessageLength
  , Exception e
)
throws
  java.lang.Exception
{
  String sender = null;
  String sendDate = null;
  String recipient = null;
  String messageUid = null;
  String deleteMessageUid = null;
  boolean deleted = false;
  try {
    sender = InternetAddress.toString( msg.getFrom());
    sendDate = getTimestamp(msg.getSentDate());
    recipient = InternetAddress.toString(
      msg.getRecipients( Message.RecipientType.TO)
    );
    messageUid = getMessageUId( msg);
    logDebug( "processFetchError: messageUid=" + messageUid);
    #sql {
      begin
        :OUT( deleteMessageUid) := pkg_MailUtility.GetDeleteErrorMessageUid;
      end;
    };
    logDebug( "processFetchError: deleteMessageUid=" + deleteMessageUid);
    if ( deleteMessageUid != null && messageUid.equals( deleteMessageUid)){
      deleted = true;
      msg.setFlag( Flags.Flag.DELETED, true);
    }
  }
  catch( Exception e0) {
    logDebug( "processFetchError: exception: " + e0);
  }
  if ( processMessage.length() < maxProcessMessageLength)
    processMessage.append(
      ( deleted ? "\nMessage deleted (" : "\nError on message (" )
      + " sender='" + sender + "'"
      + ", send_date='" + sendDate + "'"
      + ", messageUid='" + messageUid + "'"
      + ").\n"
      + e
    );
}

/** func: fetchMessage
 * Получает почтовые сообщения и сохраняет их содержимое в БД.
 **/
public static oracle.sql.NUMBER
fetchMessage(
  String url
  , String recipientAddress
  , oracle.sql.NUMBER isGotMessageDeleted
  , BigDecimal fetchMessageId
  , String[] errorMessage
)
throws
  java.lang.Exception
{
try
{
  logDebug( "fetchMessage(recipientAddress="
    + recipientAddress + "): start"
  );
  if ( url == null) {
    throw new java.lang.IllegalArgumentException(
      "No mailbox connect URL."
    );
  }
  int ERROR_MESSAGE_LENGTH = 4000;      //Максимальная длина текста ошибки
                                        //Подключаемся к серверу
  Properties props = System.getProperties();
                                        //Для эксперимента устанавливаем
                                        //свойство, подсмотренное в примере
  props.put("mail.mime.address.strict", "false");
  Session session = Session.getInstance( props, null);
  URLName urln = new URLName( url);
  Store store = session.getStore( urln);
  store.connect();
  Folder folder = store.getDefaultFolder();
  if ( folder == null)
    throw new java.lang.IllegalArgumentException(
      "No default folder"
    );
  folder = folder.getFolder( "INBOX");
  folder.open( Folder.READ_WRITE);
                                        //Определяем адрес почтового ящика
  if ( recipientAddress == null)
    recipientAddress = getMailboxAddress( urln);
                                        //Обработка сообщений
  int nSaved = 0;
  int nError = 0;
  StringBuffer processMessage = new StringBuffer();
  Message[] msgs = folder.getMessages();
  if ( msgs != null) {
                                        //Сохраняем сообщения
	for ( int i = 0; i < msgs.length; i++) {
      #sql { begin savepoint pkg_MailJava_SaveMessage; end; };
      try {
        if ( saveMessage(
          recipientAddress
          , msgs[i]
          , null
          , fetchMessageId
        ))
          ++nSaved;
        if
          ( isGotMessageDeleted == null
            ? true
            : isGotMessageDeleted.intValue() == 1
          ) {
    	    msgs[i].setFlag( Flags.Flag.DELETED, true);
        }
      }
      catch( Exception e) {
        #sql { begin rollback to pkg_MailJava_SaveMessage; end; };
        ++nError;
        processFetchError(
          msgs[i]
          , processMessage
          , ERROR_MESSAGE_LENGTH
          , e
        );
      } // try
	} // for
                                        //Фиксируем изменения
    #sql { commit };
  }
                                        //Закрываем соединение и чистим
                                        //удаленные сообщения
  folder.close( true);
  store.close();
                                        //Возвращаем результат
  if ( nError == 0) {
    errorMessage[0] = null;
  }
  else {
    processMessage.insert( 0,
      "Errors during message processing ( "
      + nSaved + " loaded, " + nError + " error"
      + ")."
    );
    if ( processMessage.length() > ERROR_MESSAGE_LENGTH)
      processMessage.setLength( ERROR_MESSAGE_LENGTH);
    errorMessage[0] = processMessage.toString();
  }
  return new oracle.sql.NUMBER( nSaved);

}
  catch( Exception e) {
    throw new RuntimeException(
                                       // Не логируем как ошибку
                                       // так как исключение может гаситься
      exceptionDebug(
        "Error while fetching messages"
          + "\n" + e
      )
    );
  }
}


/** func: lpad
 * Возвращает число в виде строки, дополненной ведущими нулями.
 **/
static String
lpad( int num, int len)
throws Exception
{
try
{
  String base = "" + num;
  StringBuffer str = new StringBuffer();
  for( int i = len - base.length(); i > 0; i--)
    str.append( '0');
  str.append( base);
  return str.toString();
}
catch( Exception e) {
  throw e;
}
}


/** func: getTimestamp
 * Возвращает строку с датой в стандартном виде ( YYYY-MM-DD HH24:MI:SS TH:TM)
 **/
static String
getTimestamp( Date dt)
throws SQLException
{
try
{
  GregorianCalendar cl = new GregorianCalendar();
  cl.setTime( dt);
  int minuteOffset = cl.get( Calendar.ZONE_OFFSET) / ( 60 * 1000);
  String zoneSign = "+";
  if ( minuteOffset < 0) {
    minuteOffset = - minuteOffset;
    zoneSign = "-";
  }
  String s = null;
  s = ""
    + cl.get( Calendar.YEAR)
    + "-" + lpad( cl.get( Calendar.MONTH), 2)
    + "-" + lpad( cl.get( Calendar.DATE), 2)
    + " " + lpad( cl.get( Calendar.HOUR_OF_DAY), 2)
    + ":" + lpad( cl.get( Calendar.MINUTE), 2)
    + ":" + lpad( cl.get( Calendar.SECOND), 2)
    + " " + zoneSign
    + lpad( minuteOffset / 60, 2)
    + ":" + lpad( minuteOffset % 60, 2)
  ;
  return s;
}
  catch( Exception e) {
    throw new RuntimeException(
      errorStack(
        "Error while getting timestamp"
        + "\n" + e
      )
    );
  }
}

/** func: saveMessage
 * Пытается сохранять сообщение и возвращает результат.
 **/
static boolean
saveMessage(
  String recipientAddress
  , Part p
  , BigDecimal parentMessageId
  , BigDecimal fetchRequestId
)
throws java.lang.Exception
{
  String contentType = null;
try
{
  logDebug( "saveMessage: (recipientAddress="
    + recipientAddress + "): start"
  );
  contentType = p.getContentType();
  if ( contentType.indexOf( "\n") > 0) {
                                       // Оставляем только одну строку
    contentType
      = contentType.substring( 0, contentType.indexOf( "\n")-1);
  }
  BigDecimal messageId = parentMessageId;
                                       // Пытаемся добавить сообщение
  logDebug( "saveMessage: contentType=" + contentType);
  if ( p instanceof Message) {
    messageId = createMessage(
      recipientAddress
      , (Message)p
      , parentMessageId
      , fetchRequestId
    );
    if ( messageId == null) {
      logDebug( "Message not unique in ml_message" );
    }
    if ( messageId == null && parentMessageId != null) {
      throw new java.lang.RuntimeException(
        "Not saved nested message ( not unique)."
      );
    }
  }
  if ( messageId != null) {
    if ( p.isMimeType( "message/rfc822")) {
      logDebug("saveMessage: getting message/rfc822");
      saveMessage( null, (Part) p.getContent()
        , messageId, fetchRequestId
      );
    }
    else if ( p.isMimeType( "multipart/*")) {
      logDebug("saveMessage: getting multipart");
      Multipart mp = (Multipart) p.getContent();
      int count = mp.getCount();
      for (int i = 0; i < count; i++)
        saveMessage( recipientAddress, mp.getBodyPart(i)
          , messageId, fetchRequestId
        );
    }
    else {
      String fileName = p.getFileName();
	String disp = p.getDisposition();
      if ( fileName == null && disp == null
            && p.isMimeType( PLAIN_TEXT_MIME_TYPE)
          ) {
        logDebug("saveMessage: getting text");
        saveMessageText( messageId, p);
      }
      else if ( fileName != null
                || ( disp != null && disp.equalsIgnoreCase( Part.ATTACHMENT))
              ) {
        logDebug("saveMessage: getting attachment");
        saveAttachment( messageId, p);
	    }
      else {                            //Игнорируемые части сообщения
        logDebug( "saveMessage: ignore message part");
      }
    }
  }
  return ( messageId != null);
}
  catch( Exception e) {
    throw new RuntimeException(
                                       // Не логируем как ошибку
                                       // так как исключение может гаситься
      exceptionDebug(
        "Error while saving message object(contentType="
        + contentType +")"
        + "\n" + e
      )
    );
  }
}

/** func: createMessage(parameters)
 * Пытается добавить новое сообщение в таблицу и
 * возвращает Id записи в случае успеха.
 **/
static BigDecimal
createMessage(
  String sender
  , String senderAddress
  , String senderText
  , String recipient
  , String recipientAddress
  , String recipientText
  , String messageStateCode
  , String messageUId
  , long sendDate
  , String subject
  , int messageSize
  , String contentType
  , String copyRecipient
  , String copyRecipientText
  , String errorMessage
  , BigDecimal parentMessageId
  , BigDecimal fetchRequestId
)
throws SQLException
{
try
{
                                        //Сохраняем информацию в таблице
  BigDecimal messageId = null;
  #sql {
    declare
      senderAddressClob clob := :senderAddress;
      recipientAddressClob clob := :recipientAddress;
      senderClob clob := :sender;
      recipientClob clob := :recipient;
      copyRecipientClob clob := :copyRecipient;
      senderTextClob clob := :senderText;
      recipientTextClob clob := :recipientText;
      copyRecipientTextClob clob := :copyRecipientText;
      messageId integer;
      duplicateCount integer;
      messageStateCode ml_message.message_state_code%type
        := :messageStateCode;
    begin
                                       -- Для исключения TX-блокировки
                                       -- при вставке уникального ключа
      select /*+index(m)*/
        count(1)
      into
        duplicateCount
      from
        ml_message m
      where
                                       -- Обратный порядок аргументов
                                       -- для dbms_lob.substr
        substr( sender, 1, 1000 ) = dbms_lob.substr( senderClob, 1000, 1)
        and substr( recipient, 1, 1000 ) = dbms_lob.substr( recipientClob, 1000, 1)
        and send_date = TIMESTAMP '1970-01-01 00:00:00 +00:00'
          + NumToDSInterval( nullif( :sendDate, -1) / 1000, 'SECOND')
        and message_uid = :messageUId
                                       -- Соответствие уникальному индексу
        and not( messageStateCode in ( 'N', 'WS', 'S', 'SE'))
      ;
      if duplicateCount = 0 then
        insert into ml_message
        (
          message_state_code
          , sender_address
          , recipient_address
          , sender
          , recipient
          , copy_recipient
          , sender_text
          , recipient_text
          , copy_recipient_text
          , send_date
          , subject
          , content_type
          , message_size
          , message_uid
          , message_text
          , error_message
          , parent_message_id
          , fetch_request_id
        )
        values
        (
                                       -- В случае необходимости
                                       -- следует пересмотреть хранение
                                       -- обрезаемых полей
          messageStateCode
          , senderAddressClob
          , recipientAddressClob
          , substr( senderClob, 1, 2000)
          , substr( recipientClob, 1, 2000)
          , substr( copyRecipientClob, 1, 2000)
          , substr( senderTextClob, 1, 2000)
          , substr( recipientTextClob, 1, 2000)
          , substr( copyRecipientTextClob, 1, 2000)
          , TIMESTAMP '1970-01-01 00:00:00 +00:00'
            + NumToDSInterval( nullif( :sendDate, -1) / 1000, 'SECOND')
          , substr( :subject, 1, 100)
          , substr(
              replace( :contentType, chr( 13) || chr( 10) || chr( 9), ' ')
              , 1
              , 512
            )
          , nullif( :messageSize, -1)
          , :messageUId
          , empty_clob()
          , substr( :errorMessage, 1, 4000)
          , :parentMessageId
          , :fetchRequestId
        )
        returning message_id into messageId;
        :OUT( messageId) := messageId;
      else
        pkg_MailInternal.LogJava(
          levelCode => pkg_Logging.Debug_LevelCode
          , messageText => 'createMessage: Found duplicates( by select)'
        );
      end if;
    exception when DUP_VAL_ON_INDEX then
      null;
    end;
  };
  return messageId;
}
catch( Exception e) {
  throw new RuntimeException(
                                       // Не логируем как ошибку
                                       // так как исключение может гаситься
    exceptionDebug(
      "Error while inserting record into ml_message"
      + "\n" + e.toString()
    )
  );
} // try
}

/** func: createMessage
 * Пытается добавить новое сообщение и возвращает Id записи в случае успеха.
 **/
static BigDecimal
createMessage(
  String recipientAddress
  , Message msg
  , BigDecimal parentMessageId
  , BigDecimal fetchRequestId
)
throws java.lang.Exception
{
try
{
                                       // Получаем обязательные поля
  logDebug( "createMessage: (recipientAddress="
    + recipientAddress + "): start"
  );
  logDebug( "createMessage(parentMessageId="
    + parentMessageId + "): start"
  );
  logDebug( "createMessage: getting <from>" );
  Address[] fromAddresses = msg.getFrom();
  String sender = InternetAddress.toString( fromAddresses);
  logDebug( "createMessage: sender: " + sender );
  String senderAddress = getAddress( fromAddresses);
  logDebug( "createMessage: senderAddress: " + senderAddress );
  String senderText = getTextAddressList( fromAddresses);
  logDebug( "createMessage: senderText: " + senderText );
  logDebug( "createMessage: getting <to>" );
  StringBuffer errorMessage = null;
  Address[] toAddresses =
     msg.getRecipients( Message.RecipientType.TO);
  logDebug( "createMessage: got <to> address array" );
                                       // Берем первого адресата, если не задан
  if ( recipientAddress == null) {
    recipientAddress = getAddress( toAddresses);
  }
  logDebug( "createMessage: recipientAddress: " + recipientAddress );
  String recipient = InternetAddress.toString( toAddresses);
  logDebug( "createMessage: recipient: " + recipient );
  String recipientText = getTextAddressList( toAddresses);
  logDebug( "createMessage: recipientText: " + recipientText );
  String messageStateCode = ( parentMessageId == null ? "R" : "N");
  String messageUId = getMessageUId( msg);
  logDebug( "createMessage: messageUId: " + messageUId );
  Date dt = msg.getSentDate();
  long sendDate = ( dt != null ? dt.getTime() : -1);
  String subject = msg.getSubject();
  logDebug( "createMessage: subject: " + subject );
  int messageSize = msg.getSize();
  String contentType = msg.getContentType();
  logDebug( "createMessage: contentType: " + contentType );
  String copyRecipient = null;
  String copyRecipientText = null;
  try
  {
    Address[] copyAddresses =
      msg.getRecipients( Message.RecipientType.CC);
    copyRecipient = InternetAddress.toString( copyAddresses);
    logDebug( "createMessage: copyRecipient: " + copyRecipient );
    copyRecipientText = getTextAddressList( copyAddresses);
    logDebug( "createMessage: copyRecipientText: " + copyRecipientText );
  }
  catch( Exception e) {
    if ( errorMessage == null) {
      errorMessage = new StringBuffer();
    } else {
      errorMessage.append( " ");
    }
    errorMessage.append( "Error while getting copyRecipient: "
      + e.toString()
    );
  } // try
  if ( errorMessage != null) {
    logDebug( "createMessage: Errors while saving message: " + errorMessage);
  }
  BigDecimal messageId =
    createMessage(
      sender
      , senderAddress
      , senderText
      , recipient
      , recipientAddress
      , recipientText
      , messageStateCode
      , messageUId
      , sendDate
      , subject
      , messageSize
      , contentType
      , copyRecipient
      , copyRecipientText
      , ( errorMessage == null ? null : errorMessage.toString())
      , parentMessageId
      , fetchRequestId
    );
  logDebug( "createMessage: messageId=" + messageId);
  return messageId;
}
  catch( Exception e) {
    throw new RuntimeException(
                                       // Не логируем как ошибку
                                       // так как исключение может гаситься
      exceptionDebug(
        "Error while creating message record"
        + "\n" + e
      )
    );
  }
} // createMessage


/** func: getMessageUId
 * Возвращает глобально-уникальный ID сообщения.
 **/
static String getMessageUId(
  Message msg
)
throws java.lang.Exception
{
try
{
  String uid = null;
  if ( msg instanceof MimeMessage) {
    MimeMessage mm = ( MimeMessage) msg;
    uid = mm.getMessageID();
    if ( uid == null)
      uid = mm.getContentID();
  }
  if ( uid == null) {
    Folder folder = msg.getFolder();
    if ( folder instanceof UIDFolder) {
      UIDFolder uf =  ( UIDFolder)folder;
      uid = String.valueOf( uf.getUID( msg));
    }
    else if ( folder instanceof com.sun.mail.pop3.POP3Folder) {
      com.sun.mail.pop3.POP3Folder pf =  (com.sun.mail.pop3.POP3Folder)folder;
      uid = pf.getUID( msg);
    }
  }
  return uid;
}
  catch( Exception e) {
    throw new RuntimeException(
      errorStack(
        "Error while getting message uid"
        + "\n" + e
      )
    );
  }
}


/** func: saveMessageText
 * Сохраняет текст сообщения.
 **/
static void
saveMessageText(
  BigDecimal messageId
  , Part p
)
throws java.lang.Exception
{
try
{
                                        //Получаем CLOB
  CLOB messageText = null;
  #sql {
    select
      msg.message_text
    into :messageText
    from
      ml_message msg
    where
      msg.message_id = :messageId
  };
                                        //Исключаем перезапись текста сообщения
  if ( messageText.length() != 0) {
    throw new java.lang.RuntimeException(
      "Dublicate message text detected."
    );
  }
                                        //Пишем в CLOB
  java.io.Writer writer = messageText.getCharacterOutputStream();
  writer.write( (String) p.getContent());
  writer.flush();
  writer.close();
}
  catch( Exception e) {
    throw new RuntimeException(
      errorStack(
        "Error while saving message text"
        + "\n" + e
      )
    );
  }
} // saveMessageText



/** func: saveAttachment
 * Сохраняет вложение
 **/
static void
saveAttachment(
  BigDecimal messageId
  , Part p
)
throws java.lang.Exception
{
try
{
                                        //Добавляем запись
  String fileName = MimeUtility.decodeText( p.getFileName());
  String contentType = p.getContentType();
  BigDecimal attachmentId = null;
  #sql {
    declare
      attachmentId ml_attachment.attachment_id%type;
    begin
      insert into
        ml_attachment
      (
        message_id
        , file_name
        , content_type
        , attachment_data
      )
      values
      (
        :messageId
        , :fileName
        , replace( :contentType, chr( 13) || chr( 10) || chr( 9), ' ')
        , empty_blob()
      )
      returning attachment_id into attachmentId;
      :OUT attachmentId := attachmentId;
    end;
  };
                                        //Получаем BLOB
  BLOB attachmentData = null;
  #sql {
    select
      atc.attachment_data
    into :attachmentData
    from
      ml_attachment atc
    where
      atc.attachment_id = :attachmentId
  };
                                        //Пишем в BLOB
  java.io.OutputStream os = new BufferedOutputStream(
    attachmentData.getBinaryOutputStream()
  );
  InputStream is = p.getInputStream();
  int c;
  while ((c = is.read()) != -1)
    os.write(c);
  os.close();
  is.close();
}
  catch( Exception e) {
    throw new RuntimeException(
                                       // Не логируем как ошибку
                                       // так как исключение может гаситься
      exceptionDebug(
        "Error while saving attachment"
        + "\n" + e
      )
    );
  }
} // saveAttachment



  //Итератор по списку сообщений
  #sql static private iterator MsgIter( java.math.BigDecimal messageId);

/** func: sendMessage
 * Отправляет ожидающие отправки сообщения.
 **/
public static java.math.BigDecimal
sendMessage(
  String smtpServer
  , java.math.BigDecimal maxMessageCount
)
throws java.lang.Exception
{
try
{
  int nSend = 0;
  Session ss = null;
  Transport tr = null;
  MsgIter msgIter;
  #sql msgIter = {
    select
      ms.message_id as messageId
    from
      ml_message ms
    where
      ms.message_state_code = 'WS'
      and
                                       -- Если SMTP-сервер для записи
                                       -- совпадает с параметром
      ( :smtpServer is not null
        and ms.smtp_server = :smtpServer
                                       -- Если поле в таблице не заполнено
                                       -- и параметр равен
                                       -- значению имени SMTP-сервера
                                       -- по умолчанию
        or :smtpServer = pkg_Common.GetSmtpServer
        and ms.smtp_server is null
      )
      and ms.send_date <= systimestamp
                                       -- Ограничение по количеству
                                       -- отправляемых сообщений
      and ( rownum <= :maxMessageCount
            or :maxMessageCount is null
          )
    order by
      ms.send_date
      , ms.message_id
  };
  while ( msgIter.next()) {
    if ( lockSendingMessage( msgIter.messageId())) {
                                        //Открываем SMTP-соединение
      BigDecimal messageId = msgIter.messageId();
      if ( tr == null) {
        ss = getSmtpSession( smtpServer);
        tr = ss.getTransport( "smtp");
        tr.connect();
      }
      #sql { begin savepoint pkg_MailJava_sendMessage; end; };
      String recipient = null;
      try {
        Message msg = makeMessage( ss, messageId);
        recipient =
          InternetAddress.toString(
            msg.getRecipients( Message.RecipientType.TO)
          );
        tr.send( msg);
        setSendResult(
          messageId
          , msg.getSentDate()
          , getMessageUId( msg)
          , null
          , recipient
        );
        #sql { commit };                //Фиксируем изменения
        ++nSend;
      }
      catch ( Exception e) {
        try {
          #sql { begin rollback to pkg_MailJava_sendMessage; end; };
          setSendResult(
            messageId
            , null
            , null
            , e.toString()
            , recipient
          );
          #sql { commit};               //Фиксируем ошибочный результат
        }
        catch( Exception e2) {
          throw new java.lang.RuntimeException(
            "Error during rollback after message processing error ("
            + " message_id=" + messageId
            + ")\n"
            + e2 + "\n" + e
          );
        }
      }
    }
  }
  msgIter.close();
  if ( tr != null)                      //Закрываем SMTP-соединение
    tr.close();
  #sql { commit };                      //Завершаем транзакцию
  return new java.math.BigDecimal( nSend);
}
  catch( Exception e) {
    throw new RuntimeException(
      errorStack(
        "Error while sending messages"
        + "\n" + e
      )
    );
  }
} // sendMessage



/** func: lockSendingMessage
 * Блокирует отправляемое сообщение.
 **/
static boolean
lockSendingMessage(
  BigDecimal messageId
)
throws java.lang.Exception
{
try
{
  Integer isLock = null;
  #sql {
    declare
      messageId ml_message.message_id%type := :messageId;
    begin
      select
        ms.message_id
      into messageId
      from
        ml_message ms
      where
        ms.message_id = messageId
        and ms.message_state_code = pkg_Mail.WaitSend_MessageStateCode
      for update nowait;
      :OUT isLock := 1;
    exception
      when NO_DATA_FOUND then
        null;
      when others then
        if SQLCODE <> pkg_Error.ResourceBusyNowait then
          raise_application_error(
            pkg_Error.ErrorStackInfo
            , 'Error during lock message ('
              || ' message_id=' || to_char( messageId)
              || ').'
            , true
          );
        end if;
    end;
  };
  return ( isLock != null && isLock.intValue() != 0);
}
  catch( Exception e) {
    throw new RuntimeException(
      errorStack(
        "Error while locking message"
        + "\n" + e
      )
    );
  }
}


  //Итератор по списку сообщений
  #sql static private iterator AttachIter(
    java.math.BigDecimal attachmentId
    , String fileName
    , String contentType
    , BLOB attachmentData
    , java.math.BigDecimal isImageContentId
  );



/** func: makeMessage( ID)
 * Создает сообщение по данным из БД.
 * Замечание: вложенные сообщения игнорируются.
 **/
static Message
makeMessage(
  Session session
  , BigDecimal messageId
)
throws java.lang.Exception
{
  // Получаем данные сообщения
  String sender = null;
  String recipient = null;
  String copyRecipient = null;
  String subject = null;
  CLOB messageText = null;
  BigDecimal isHTML = null;
  #sql {
    select
      ms.sender
      , ms.recipient
      , ms.copy_recipient
      , ms.subject
      , ms.message_text
      , ms.is_html
    into
      :sender
      , :recipient
      , :copyRecipient
      , :subject
      , :messageText
      , :isHTML
    from
      ml_message ms
    where
      ms.message_id = :messageId
  };
  AttachIter attachIter;
  #sql attachIter = {
    select
      atc.attachment_id as attachmentId
      , atc.file_name as fileName
      , atc.content_type as contentType
      , atc.attachment_data as attachmentData
      , atc.is_image_content_id as isImageContentId
    from
      ml_attachment atc
    where
      atc.message_id = :messageId
    order by
      atc.attachment_id
  };
  boolean isNextAttachment = attachIter.next();
  boolean isMultipart = isNextAttachment;
  //Создаем сообщение

  Message msg = makeMessage(
    session
    , sender
    , recipient
    , copyRecipient
    , subject
    , messageText
    , isMultipart
    // Значение null приравнивается к false
    , ( isHTML == null ? false : isHTML.intValue() == 1 )
  );



  Multipart mp = ( isMultipart ? ( Multipart) msg.getContent() : null);
  while ( isNextAttachment) {
    addAttachment(
      mp
      , attachIter.fileName()
      , attachIter.contentType()
      , attachIter.attachmentData()
      // Значение null приравнивается к false
      , ( attachIter.isImageContentId() == null
          ? false
          : attachIter.isImageContentId().intValue() == 1
        )
    );
    isNextAttachment = attachIter.next();
  }
  attachIter.close();
  return msg;
  // Не логируем исключение так как функция вызывается массово
}

/** func: setSendResult
 * Устанавливает результат попытки отправки сообщения.
 **/
static void
setSendResult(
  BigDecimal messageId
  , java.util.Date sendDate
  , String messageUId
  , String errorMessage
  , String recipient
)
throws java.lang.Exception
{
try
{
  long sendTime = ( sendDate != null ? sendDate.getTime() : -1);
  #sql {
    declare
      errorMessage ml_message.error_message%type := :errorMessage;

      messageStateCode ml_message.message_state_code%type;
      sendDate ml_message.send_date%type;
      errorCode ml_message.error_code%type;

    begin
      if errorMessage is null then
        messageStateCode := pkg_Mail.Send_MessageStateCode;
        sendDate := TIMESTAMP '1970-01-01 00:00:00 +00:00'
          + NumToDSInterval( nullif( :sendTime, -1) / 1000, 'SECOND')
        ;
                                       -- Отменяем отправку при некорректном
                                       -- адресе
      elsif errorMessage like :MAILBOX_INCORRECT_ERROR_MASK escape '\'
        or errorMessage like :MAILBOX_ROUTED_MAIL_ERROR_MASK escape '\'
      then
        messageStateCode := pkg_Mail.SendCanceled_MessageStateCode;
        sendDate := systimestamp;
        errorCode := pkg_Error.ProcessError;
        pkg_MailInternal.LogJava(
          levelCode => pkg_Logging.Debug_LevelCode
          , messageText =>
             'Send canceled: (messageId=' || to_char( :messageId)
             || ', recipient="' || :recipient || '"'
             || ')'
        );
      else
        messageStateCode := pkg_Mail.WaitSend_MessageStateCode;
        sendDate := systimestamp
          + NumToDSInterval( :RETRY_SEND_TIMEOUT_SECOND, 'SECOND');
        errorCode := pkg_Error.ProcessError;
      end if;
      update
        ml_message ms
      set
        ms.message_state_code = messageStateCode
        , ms.send_date = sendDate
        , ms.message_uid = :messageUId
        , ms.error_code = errorCode
        , ms.error_message = errorMessage
        , ms.process_date = sysdate
      where
        ms.message_id = :messageId
      ;
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , 'Error during set send result.'
        , true
      );
    end;
  };
}
  catch( Exception e) {
    throw new RuntimeException(
      errorStack(
        "Error while checking sending results"
        + "\n" + e
      )
    );
  }
}


}
/
