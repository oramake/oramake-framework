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
import java.sql.*;
import javax.activation.*;
import javax.mail.*;
import javax.mail.internet.*;
import oracle.jdbc.*;
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

  // const: RETRY_SEND_LIMIT
  // Ограничение на количество повторных попыток отправки сообщения.
  static final long RETRY_SEND_LIMIT = 10;

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

  /* ivar: internalServerConnection
   * Подключение к текущей БД. Initialized in the static initialization block.
   */
  private static Connection internalServerConnection = null;

  // Nested class that implements a DataSource.
  static class CLOBDataSource implements DataSource
  {
    private Clob   data;
    private String type;

    CLOBDataSource( Clob data, String type)
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
    private Blob   data;
    private String type;

    BLOBDataSource(Blob data, String type)
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
  PreparedStatement statement = internalServerConnection.prepareStatement(
  " begin\n"
+ "   pkg_MailInternal.logJava(\n"
+ "     levelCode   => pkg_Logging.Debug_LevelCode\n"
+ "   , messageText => ?\n"
+ "   );\n"
+ " end;\n"
  );
  statement.setString( 1, messageText);
  statement.executeUpdate();
  statement.close();
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
  PreparedStatement statement = internalServerConnection.prepareStatement(
  " begin\n"
+ "   pkg_MailInternal.logJava(\n"
+ "     levelCode   => pkg_Logging.Trace_LevelCode\n"
+ "   , messageText => ?\n"
+ "   );\n"
+ " end;\n"
  );
  statement.setString( 1, messageText);
  statement.executeUpdate();
  statement.close();
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
      // Устанавливаем правильное название для Windows-кодировки
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
  , Clob messageText
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
  , Blob data
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
    mbp.setFileName( fileName);
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
  , Clob messageText
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
    CallableStatement statement = internalServerConnection.prepareCall(
    " begin\n"
  + "   ? := pkg_MailUtility.getDeleteErrorMessageUid();\n"
  + " end;\n"
    );
    statement.registerOutParameter( 1, Types.VARCHAR);
    statement.executeUpdate();
    statement.close();
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

/** func: prepareForDelete
 * Проверяет необходимость удаления ранее полученного сообщения и в случае
 * необходимости его удаления устанавливает дату удаления.
 *
 * Возврат:
 * true если сообщение нужно удалить, иначе false.
 **/
static boolean
prepareForDelete(
  Message msg
)
throws java.lang.Exception
{
  try {
    Address[] fromAddresses = msg.getFrom();
    String sender = InternetAddress.toString( fromAddresses);
    Address[] toAddresses = msg.getRecipients( Message.RecipientType.TO);
    String recipient = InternetAddress.toString( toAddresses);
    String messageUId = getMessageUId( msg);
    Date dt = msg.getSentDate();
    long sendDate = ( dt != null ? dt.getTime() : -1);
    BigDecimal messageId = null;
    CallableStatement statement = internalServerConnection.prepareCall(
  "   declare\n"
+ "     senderClob clob := ?;\n"
+ "     recipientClob clob := ?;\n"
+ "     messageId integer;\n"
+ "\n"
+ "     cursor dataCur is\n"
+ "       select /*+ index( m) */\n"
+ "         m.message_id\n"
+ "         , m.mailbox_for_delete_flag\n"
+ "       from\n"
+ "         ml_message m\n"
+ "       where\n"
+ "         substr( m.sender, 1, 1000 )\n"
+ "           = dbms_lob.substr( senderClob, 1000, 1)\n"
+ "         and substr( m.recipient, 1, 1000 )\n"
+ "           = dbms_lob.substr( recipientClob, 1000, 1)\n"
+ "         and (\n"
+ "           ? = -1\n"
+ "             and m.send_date is null\n"
+ "          or ? != -1\n"
+ "             and m.send_date = TIMESTAMP '1970-01-01 00:00:00 +00:00'\n"
+ "               + NumToDSInterval( ? / 1000, 'SECOND')\n"
+ "         )\n"
+ "         and m.message_uid = ?\n"
+ "         and m.incoming_flag = 1\n"
+ "         and m.parent_message_id is null\n"
+ "         -- Необходимо удалить из ящика\n"
+ "         and m.mailbox_for_delete_flag = 1\n"
+ "       for update of mailbox_delete_date nowait\n"
+ "     ;\n"
+ "\n"
+ "   begin\n"
+ "     for rec in dataCur loop\n"
+ "       if messageId is null then\n"
+ "         messageId := rec.message_id;\n"
+ "       else\n"
+ "         raise_application_error(\n"
+ "           pkg_Error.ProcessError\n"
+ "           , 'Found few record for message ('\n"
+ "             || ' message_id=' || messageId\n"
+ "             || ', second message_id=' || rec.message_id\n"
+ "             || ').'\n"
+ "         );\n"
+ "       end if;\n"
+ "       update\n"
+ "         ml_message m\n"
+ "       set\n"
+ "         m.mailbox_delete_date = sysdate\n"
+ "       where current of dataCur;\n"
+ "     end loop;\n"
+ "     ? := messageId;\n"
+ "   end;\n"
    );
    statement.setString( 1, sender);
    statement.setString( 2, recipient);
    statement.setLong( 3, sendDate);
    statement.setLong( 4, sendDate);
    statement.setLong( 5, sendDate);
    statement.setString( 6, messageUId);
    statement.registerOutParameter( 7, Types.INTEGER);
    statement.executeUpdate();
    messageId = statement.getBigDecimal(7);
    statement.close();
    return ( messageId != null);
  }
  catch( Exception e) {
    throw new RuntimeException(
      exceptionDebug(
        "Error while prepareForDelete:"
        + "\n" + e
      )
    );
  }
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
    BigDecimal deleteMessageFlag = new BigDecimal(
        ( isGotMessageDeleted == null
          ? true
          : isGotMessageDeleted.intValue() == 1
        ) ? 1 : 0
      )
    ;
                                        //Сохраняем сообщения
	for ( int i = 0; i < msgs.length; i++) {
      Savepoint messageStartSavePoint =
        internalServerConnection.setSavepoint( "pkg_MailJava_SaveMessage");
      try {
        boolean isDelete = false;
        if ( saveMessage(
              recipientAddress
              , msgs[i]
              , null
              , fetchMessageId
              , deleteMessageFlag
            )) {
          ++nSaved;
          isDelete = deleteMessageFlag.intValue() == 1;
        }
        else {
          isDelete = prepareForDelete( msgs[i]);
        }
        if ( isDelete)
    	    msgs[i].setFlag( Flags.Flag.DELETED, true);
      }
      catch( Exception e) {
        internalServerConnection.rollback( messageStartSavePoint);
        ++nError;
        processFetchError(
          msgs[i]
          , processMessage
          , ERROR_MESSAGE_LENGTH
          , e
        );
      } // try
	} // for
    // Фиксируем изменения
    internalServerConnection.commit();
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
  , BigDecimal deleteMessageFlag
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
      , deleteMessageFlag
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
        , messageId, fetchRequestId, null
      );
    }
    else if ( p.isMimeType( "multipart/*")) {
      logDebug("saveMessage: getting multipart");
      Multipart mp = (Multipart) p.getContent();
      int count = mp.getCount();
      for (int i = 0; i < count; i++)
        saveMessage( recipientAddress, mp.getBodyPart(i)
          , messageId, fetchRequestId, null
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
  , BigDecimal deleteMessageFlag
)
throws SQLException
{
try
{
  // Сохраняем информацию в таблице
  BigDecimal messageId = null;
  CallableStatement statement = internalServerConnection.prepareCall(
  " declare\n"
+ "   senderAddressClob clob := ?;\n"
+ "   recipientAddressClob clob := ?;\n"
+ "   senderClob clob := ?;\n"
+ "   recipientClob clob := ?;\n"
+ "   copyRecipientClob clob := ?;\n"
+ "   senderTextClob clob := ?;\n"
+ "   recipientTextClob clob := ?;\n"
+ "   copyRecipientTextClob clob := ?;\n"
+ "   messageId integer;\n"
+ "   duplicateCount integer;\n"
+ "   messageStateCode ml_message.message_state_code%type\n"
+ "     := ?;\n"
+ " begin\n"
+ "   -- Для исключения TX-блокировки при вставке уникального ключа\n"
+ "   select /*+index(m)*/\n"
+ "     count(1)\n"
+ "   into\n"
+ "     duplicateCount\n"
+ "   from\n"
+ "     ml_message m\n"
+ "   where\n"
+ "   -- Обратный порядок аргументов\n"
+ "   -- для dbms_lob.substr\n"
+ "     substr( sender, 1, 1000 ) = dbms_lob.substr( senderClob, 1000, 1)\n"
+ "     and substr( recipient, 1, 1000 ) = dbms_lob.substr( recipientClob, 1000, 1)\n"
+ "     and (\n"
+ "       ? = -1\n"
+ "         and m.send_date is null\n"
+ "       or ? != -1\n"
+ "         and m.send_date = TIMESTAMP '1970-01-01 00:00:00 +00:00'\n"
+ "           + NumToDSInterval( ? / 1000, 'SECOND')\n"
+ "     )\n"
+ "     and m.message_uid = ?\n"
+ "     and m.incoming_flag = 1\n"
+ "     and m.parent_message_id is null\n"
+ "   ;\n"
+ "   if duplicateCount = 0 then\n"
+ "     insert into ml_message\n"
+ "     (\n"
+ "       incoming_flag\n"
+ "       , message_state_code\n"
+ "       , sender_address\n"
+ "       , recipient_address\n"
+ "       , sender\n"
+ "       , recipient\n"
+ "       , copy_recipient\n"
+ "       , sender_text\n"
+ "       , recipient_text\n"
+ "       , copy_recipient_text\n"
+ "       , send_date\n"
+ "       , subject\n"
+ "       , content_type\n"
+ "       , message_size\n"
+ "       , message_uid\n"
+ "       , message_text\n"
+ "       , error_message\n"
+ "       , parent_message_id\n"
+ "       , fetch_request_id\n"
+ "       , mailbox_delete_date\n"
+ "       , mailbox_for_delete_flag\n"
+ "     )\n"
+ "     values\n"
+ "     (\n"
+ "       -- В случае необходимости следует пересмотреть хранение\n"
+ "       -- обрезаемых полей\n"
+ "       1\n"
+ "       , messageStateCode\n"
+ "       , senderAddressClob\n"
+ "       , recipientAddressClob\n"
+ "       , substr( senderClob, 1, 2000)\n"
+ "       , substr( recipientClob, 1, 2000)\n"
+ "       , substr( copyRecipientClob, 1, 2000)\n"
+ "       , substr( senderTextClob, 1, 2000)\n"
+ "       , substr( recipientTextClob, 1, 2000)\n"
+ "       , substr( copyRecipientTextClob, 1, 2000)\n"
+ "       , TIMESTAMP '1970-01-01 00:00:00 +00:00'\n"
+ "         + NumToDSInterval( nullif( ?, -1) / 1000, 'SECOND')\n"
+ "       , substr( ?, 1, 100)\n"
+ "       , substr(\n"
+ "           replace( ?, chr( 13) || chr( 10) || chr( 9), ' ')\n"
+ "           , 1\n"
+ "           , 512\n"
+ "         )\n"
+ "       , nullif( ?, -1)\n"
+ "       , ?\n"
+ "       , empty_clob()\n"
+ "       , substr( ?, 1, 4000)\n"
+ "       , ?\n"
+ "       , ?\n"
+ "       , case when ? = 1 then sysdate end\n"
+ "       , nullif( ?, 1)\n"
+ "     )\n"
+ "     returning message_id into messageId;\n"
+ "     ? := messageId;\n"
+ "   else\n"
+ "     pkg_MailInternal.logJava(\n"
+ "       levelCode => pkg_Logging.Debug_LevelCode\n"
+ "       , messageText => 'createMessage: Found duplicates( by select)'\n"
+ "     );\n"
+ "   end if;\n"
+ " exception when DUP_VAL_ON_INDEX then\n"
+ "   null;\n"
+ " end;\n"
  );
  statement.setString( 1, senderAddress);
  statement.setString( 2, recipientAddress);
  statement.setString( 3, sender);
  statement.setString( 4, recipient);
  statement.setString( 5, copyRecipient);
  statement.setString( 6, senderText);
  statement.setString( 7, recipientText);
  statement.setString( 8, copyRecipient);
  statement.setString( 9, messageStateCode);
  statement.setLong( 10, sendDate);
  statement.setLong( 11, sendDate);
  statement.setLong( 12, sendDate);
  statement.setString( 13, messageUId);
  statement.setLong( 14, sendDate);
  statement.setString( 15, subject);
  statement.setString( 16, contentType);
  statement.setLong( 17, messageSize);
  statement.setString( 18, messageUId);
  statement.setString( 19, errorMessage);
  statement.setBigDecimal( 20, parentMessageId);
  statement.setBigDecimal( 21, fetchRequestId);
  statement.setBigDecimal( 22, deleteMessageFlag);
  statement.setBigDecimal( 23, deleteMessageFlag);
  statement.registerOutParameter( 24, Types.INTEGER);
  statement.executeUpdate();
  messageId = statement.getBigDecimal( 24);
  statement.close();
  return messageId;
}
catch( Exception e) {
  throw new RuntimeException(
    // Не логируем как ошибку так как исключение может гаситься
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
  , BigDecimal deleteMessageFlag
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
      , deleteMessageFlag
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
  CallableStatement getTextStatement = internalServerConnection.prepareCall(
  "begin\n"
+ " select\n"
+ "   msg.message_text\n"
+ " into\n"
+ "   ?\n"
+ " from\n"
+ "   ml_message msg\n"
+ " where\n"
+ "   msg.message_id = ?\n"
+ " ;\n"
+ "end;  \n"
  );
  getTextStatement.registerOutParameter( 1, Types.CLOB);
  getTextStatement.setBigDecimal( 2, messageId);
  getTextStatement.executeUpdate();
  Clob messageText = getTextStatement.getClob( 1);
  getTextStatement.close();
  // Исключаем перезапись текста сообщения
  if ( messageText.length() != 0) {
    throw new java.lang.RuntimeException(
      "Dublicate message text detected."
    );
  }
  //Пишем в CLOB
  java.io.Writer writer = messageText.setCharacterStream( 0);
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
  logDebug( "saveAttachment: begin");
  // Добавляем запись
  String fileName = MimeUtility.decodeText( p.getFileName());
  String contentType = p.getContentType();
  BigDecimal attachmentId = null;
  CallableStatement insertStatement = internalServerConnection.prepareCall(
  " declare\n"
+ "   attachmentId ml_attachment.attachment_id%type;\n"
+ " begin\n"
+ "   insert into\n"
+ "     ml_attachment\n"
+ "   (\n"
+ "     message_id\n"
+ "     , file_name\n"
+ "     , content_type\n"
+ "     , attachment_data\n"
+ "   )\n"
+ "   values\n"
+ "   ( ?\n"
+ "     , ?\n"
+ "     , replace( ?, chr( 13) || chr( 10) || chr( 9), ' ')\n"
+ "     , empty_blob()\n"
+ "   )\n"
+ "   returning attachment_id into attachmentId;\n"
+ "   ? := attachmentId;\n"
+ " end;\n"
  );
  insertStatement.setBigDecimal( 1, messageId);
  insertStatement.setString( 2, fileName);
  insertStatement.setString( 3, contentType);
  insertStatement.registerOutParameter( 4, Types.INTEGER);
  insertStatement.executeUpdate();
  attachmentId = insertStatement.getBigDecimal(4);
  insertStatement.close();
  logDebug( "saveAttachment: inserted attachement record");
  // Получаем BLOB
  CallableStatement attachmentStatement = internalServerConnection.prepareCall(
  " begin\n"
+ "   select\n"
+ "     atc.attachment_data\n"
+ "   into ?\n"
+ "   from\n"
+ "     ml_attachment atc\n"
+ "   where\n"
+ "     atc.attachment_id = ?\n"
+ "   ;\n"
+ " end;\n"
  );
  attachmentStatement.registerOutParameter( 1, Types.BLOB);
  attachmentStatement.setBigDecimal( 2, attachmentId);
  attachmentStatement.executeUpdate();
  Blob attachmentData = attachmentStatement.getBlob( 1);
  // Пишем в BLOB
  java.io.OutputStream os = new BufferedOutputStream(
    attachmentData.setBinaryStream( 0)
  );
  InputStream is = p.getInputStream();
  int c;
  while ((c = is.read()) != -1)
    os.write(c);
  os.close();
  is.close();
  attachmentStatement.close();
}
  catch( Exception e) {
    throw new RuntimeException(
      // Не логируем как ошибку так как исключение может гаситься
      exceptionDebug(
        "Error while saving attachment"
        + "\n" + e
      )
    );
  }
} // saveAttachment



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
  PreparedStatement messageSelect = internalServerConnection.prepareStatement(
  " select\n"
+ "   ms.message_id as messageId\n"
+ " from\n"
+ "   ml_message ms\n"
+ " where\n"
+ "   ms.message_state_code = 'WS'\n"
+ "   and\n"
+ "   -- Если SMTP-сервер для записи\n"
+ "   -- совпадает с параметром\n"
+ "   ( ? is not null\n"
+ "     and ms.smtp_server = ?\n"
+ "   -- Если поле в таблице не заполнено\n"
+ "   -- и параметр равен\n"
+ "   -- значению имени SMTP-сервера\n"
+ "   -- по умолчанию\n"
+ "     or ? = pkg_Common.getSmtpServer()\n"
+ "     and ms.smtp_server is null\n"
+ "   )\n"
+ "   and ms.send_date <= systimestamp\n"
+ "   -- Ограничение по количеству отправляемых сообщений\n"
+ "   and ( rownum <= ?\n"
+ "         or ? is null\n"
+ "       )\n"
+ " order by\n"
+ "   ms.send_date\n"
+ "   , ms.message_id\n"
  );
  messageSelect.setString( 1, smtpServer);
  messageSelect.setString( 2, smtpServer);
  messageSelect.setString( 3, smtpServer);
  messageSelect.setBigDecimal( 4, maxMessageCount);
  messageSelect.setBigDecimal( 5, maxMessageCount);
  ResultSet resultSet = messageSelect.executeQuery();
  while ( resultSet.next()) {
    BigDecimal messageId = resultSet.getBigDecimal( "messageId");
    if ( lockSendingMessage( messageId)) {
      // Открываем SMTP-соединение
      if ( tr == null) {
        ss = getSmtpSession( smtpServer);
        tr = ss.getTransport( "smtp");
        tr.connect();
      }
      Savepoint messageStartSavePoint =
        internalServerConnection.setSavepoint( "pkg_MailJava_sendMessage");
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
        internalServerConnection.commit();
        ++nSend;
      }
      catch ( Exception e) {
        try {
          internalServerConnection.rollback( messageStartSavePoint);
          setSendResult(
            messageId
            , null
            , null
            , e.toString()
            , recipient
          );
          // Фиксируем ошибочный результат
          internalServerConnection.commit();
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
  resultSet.close();
  messageSelect.close();
  //Закрываем SMTP-соединение
  if ( tr != null) {
    tr.close();
  }
  //Завершаем транзакцию
  internalServerConnection.commit();
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
  CallableStatement statement = internalServerConnection.prepareCall(
  " declare\n"
+ "   messageId ml_message.message_id%type := ?;\n"
+ " begin\n"
+ "   select\n"
+ "     ms.message_id\n"
+ "   into messageId\n"
+ "   from\n"
+ "     ml_message ms\n"
+ "   where\n"
+ "     ms.message_id = messageId\n"
+ "     and ms.message_state_code = pkg_Mail.WaitSend_MessageStateCode\n"
+ "   for update nowait;\n"
+ "   ? := 1;\n"
+ " exception\n"
+ "   when NO_DATA_FOUND then\n"
+ "     null;\n"
+ "   when others then\n"
+ "     if SQLCODE <> pkg_Error.ResourceBusyNowait then\n"
+ "       raise_application_error(\n"
+ "         pkg_Error.ErrorStackInfo\n"
+ "         , 'Error during lock message ('\n"
+ "           || ' message_id=' || to_char( messageId)\n"
+ "           || ').'\n"
+ "         , true\n"
+ "       );\n"
+ "     end if;\n"
+ " end;\n"
  );
  statement.setBigDecimal( 1, messageId);
  statement.registerOutParameter( 2, Types.INTEGER);
  statement.executeUpdate();
  BigDecimal isLock = statement.getBigDecimal( 2);
  statement.close();
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
  CallableStatement statement = internalServerConnection.prepareCall(
  " begin\n"
+ " select\n"
+ "   ms.sender\n"
+ "   , ms.recipient\n"
+ "   , ms.copy_recipient\n"
+ "   , ms.subject\n"
+ "   , ms.message_text\n"
+ "  , ms.is_html\n"
+ " into\n"
+ "   ?\n"
+ "   , ?\n"
+ "   , ?\n"
+ "   , ?\n"
+ "   , ?\n"
+ "   , ?\n"
+ " from\n"
+ "   ml_message ms\n"
+ " where\n"
+ "   ms.message_id = ?;\n"
+ " end;\n"
  );
  statement.registerOutParameter( 1, Types.VARCHAR);
  statement.registerOutParameter( 2, Types.VARCHAR);
  statement.registerOutParameter( 3, Types.VARCHAR);
  statement.registerOutParameter( 4, Types.VARCHAR);
  statement.registerOutParameter( 5, Types.CLOB);
  statement.registerOutParameter( 6, Types.INTEGER);
  statement.setBigDecimal( 7, messageId);
  statement.executeUpdate();
  // Получаем данные сообщени
  String sender = statement.getString( 1);
  String recipient = statement.getString( 2);
  String copyRecipient = statement.getString( 3);
  String subject = statement.getString( 4);
  Clob messageText = statement.getClob( 5);
  BigDecimal isHTML = statement.getBigDecimal( 6);
  statement.close();
  // Iterate through attachments
  PreparedStatement attachmentStatement = internalServerConnection.prepareStatement(
  " select\n"
+ "   atc.attachment_id as attachmentId\n"
+ "   , atc.file_name as fileName\n"
+ "   , atc.content_type as contentType\n"
+ "   , atc.attachment_data as attachmentData\n"
+ "   , atc.is_image_content_id as isImageContentId\n"
+ " from\n"
+ "   ml_attachment atc\n"
+ " where\n"
+ "    atc.message_id = ?\n"
+ " order by\n"
+ "  atc.attachment_id"
  );
  attachmentStatement.setBigDecimal( 1, messageId);
  ResultSet resultSet = attachmentStatement.executeQuery();
  boolean isNextAttachment = resultSet.next();
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
      , resultSet.getString( "fileName")
      , resultSet.getString( "contentType")
      , resultSet.getBlob( "attachmentData")
      // Значение null приравнивается к false
      , ( resultSet.getBigDecimal( "isImageContentId") == null
          ? false
          : resultSet.getBigDecimal( "isImageContentId").intValue() == 1
        )
    );
    isNextAttachment = resultSet.next();
  }
  attachmentStatement.close();
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
  PreparedStatement statement = internalServerConnection.prepareStatement(
  " declare\n"
+ "   errorMessage ml_message.error_message%type := ?;\n"
+ "   messageId ml_message.message_id%type := ?;\n"
+ "   messageUid ml_message.message_uid%type := ?;\n"
+ "   sendDateInterval integer := ?;\n"
+ "   recipient varchar2(4000) := ?;\n"
+ "   messageStateCode ml_message.message_state_code%type;\n"
+ "   sendDate ml_message.send_date%type;\n"
+ "   errorCode ml_message.error_code%type;\n"
+ "\n"
+ " begin\n"
+ "   if errorMessage is null then\n"
+ "     messageStateCode := pkg_Mail.Send_MessageStateCode;\n"
+ "     sendDate := TIMESTAMP '1970-01-01 00:00:00 +00:00'\n"
+ "       + NumToDSInterval( nullif( sendDateInterval, -1) / 1000, 'SECOND')\n"
+ "     ;\n"
+ "     update\n"
+ "       ml_message ms\n"
+ "     set\n"
+ "       ms.message_state_code = messageStateCode\n"
+ "       , ms.send_date = sendDate\n"
+ "       , ms.message_uid = messageUid\n"
+ "       , ms.retry_send_count = coalesce(retry_send_count, 0) + 1\n"
+ "       , ms.error_code = errorCode\n"
+ "       , ms.error_message = errorMessage\n"
+ "       , ms.process_date = sysdate\n"
+ "     where\n"
+ "       ms.message_id = messageId\n"
+ "     ;\n"
+ "   -- Отменяем отправку при некорректном -- адресе\n"
+ "   elsif errorMessage like '" + MAILBOX_INCORRECT_ERROR_MASK + "'\n"
+ "     or errorMessage like '" + MAILBOX_ROUTED_MAIL_ERROR_MASK + "'\n"
+ "   then\n"
+ "     messageStateCode := pkg_Mail.SendCanceled_MessageStateCode;\n"
+ "     sendDate := systimestamp;\n"
+ "     errorCode := pkg_Error.ProcessError;\n"
+ "     pkg_MailInternal.logJava(\n"
+ "       levelCode => pkg_Logging.Debug_LevelCode\n"
+ "       , messageText =>\n"
+ "          'Send canceled: (messageId=' || to_char( messageId)\n"
+ "          || ', recipient=\"' || to_char(recipient) || '\"'\n"
+ "          || ')'\n"
+ "     );\n"
+ "     update\n"
+ "       ml_message ms\n"
+ "     set\n"
+ "       ms.message_state_code = messageStateCode\n"
+ "       , ms.send_date = sendDate\n"
+ "       , ms.message_uid = messageUid\n"
+ "       , ms.retry_send_count = coalesce(retry_send_count, 0) + 1\n"
+ "       , ms.error_code = errorCode\n"
+ "       , ms.error_message = errorMessage\n"
+ "       , ms.process_date = sysdate\n"
+ "     where\n"
+ "       ms.message_id = messageId\n"
+ "     ;\n"
+ "   else\n"
+ "   -- При наличии ошибки выполним специализированный update\n"
+ "   -- с контролем превышения лимита на количество попыток отправки\n"
+ "     errorCode := pkg_Error.ProcessError;\n"
+ "     update\n"
+ "       ml_message ms\n"
+ "     set\n"
+ "       ms.message_state_code = \n"
+ "         case \n"
+ "           when retry_send_count < " + RETRY_SEND_LIMIT + "\n"
+ "             then 'WS'\n" // pkg_Mail.WaitSend_MessageStateCode
+ "           else \n"
+ "             'SE'\n" //pkg_Mail.SendError_MessageStateCode
+ "         end\n"
+ "       , ms.send_date = systimestamp\n"
+ "         + NumToDSInterval( " + RETRY_SEND_TIMEOUT_SECOND + "\n"
+ "                            * power(2, retry_send_count), 'SECOND')\n"
+ "       , ms.message_uid = messageUid\n"
+ "       , ms.retry_send_count = coalesce(retry_send_count, 0) + 1\n"
+ "       , ms.error_code = errorCode\n"
+ "       , ms.error_message = \n"
+ "         case \n"
+ "           when retry_send_count < " + RETRY_SEND_LIMIT + "\n"
+ "             then errorMessage\n"
+ "           else \n"
+ "             'Превышено максимальное количество попыток отправки сообщения: '\n"
+ "             || retry_send_count || '. '\n"
+ "             || errorMessage\n"
+ "         end\n"
+ "       , ms.process_date = sysdate\n"
+ "     where\n"
+ "       ms.message_id = messageId\n"
+ "     ;\n"
+ "   end if;\n"
+ " exception when others then\n"
+ "   raise_application_error(\n"
+ "     pkg_Error.ErrorStackInfo\n"
+ "     , 'Error during set send result.'\n"
+ "     , true\n"
+ "   );\n"
+ " end;\n"
  );
  statement.setString( 1, errorMessage);
  statement.setBigDecimal( 2, messageId);
  statement.setString( 3, messageUId);
  statement.setBigDecimal( 4, new BigDecimal( sendTime));
  statement.setString( 5, recipient);
  statement.executeUpdate();
  statement.close();
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

static {
  try {
    OracleDriver ora = new OracleDriver();
    internalServerConnection = ora.defaultConnection();
  }
  catch( SQLException e) {
    throw new RuntimeException(
      "Error while opening internal server connection"
      + "\n" + e
    );
  }
}

}
/
