create or replace and compile java source named "MailTest" as
// title: MailTest
// Тестовые Java-функции модуля Mail.
//

import java.io.*;
import java.net.InetAddress;
import java.util.Properties;
import java.util.Date;

import javax.mail.*;
import javax.mail.internet.*;

import com.sun.mail.smtp.*;

import oracle.jdbc.*;
import oracle.jdbc.driver.*;
import oracle.sql.*;


/** class: MailTest
 *  Тестовые Java-функции модуля Mail.
 **/
public class MailTest
{

/** func: smtpsend
 * Отправляет письмо ( немедленно).
 **/
public static void
smtpsend(
  final String recipient
  , final String copyRecipient
  , final String subject
  , final String messageText
  , final String sender
  , final String smtpServer
  , final String username
  , final String password
)
throws java.lang.Exception
{
  System.out.println("smtpsend: start...");

	String mailhost = smtpServer;
	String user = username;

	String to = recipient;
  String from = sender;

  String cc = copyRecipient;
  String bcc = null;

  String text = messageText;
	String mailer = "smtpsend";



	boolean auth = true;
	String prot = "smtps";

	boolean debug = true;
	boolean verbose = true;

	try {

		System.out.println("To: " + to);
		System.out.println("Subject: " + subject);

	    /*
	     * Initialize the JavaMail Session.
	     */
	    Properties props = System.getProperties();
	    if (mailhost != null)
		props.put("mail." + prot + ".host", mailhost);
	    if (auth)
		props.put("mail." + prot + ".auth", "true");

	    /*
	     * Create a Provider representing our extended SMTP transport
	     * and set the property to use our provider.
	     *
	    Provider p = new Provider(Provider.Type.TRANSPORT, prot,
		"smtpsend$SMTPExtension", "JavaMail demo", "no version");
	    props.put("mail." + prot + ".class", "smtpsend$SMTPExtension");
	     */

	    // Get a Session object
	    Session session = Session.getInstance(props, null);
	    if (debug)
		session.setDebug(true);

	    /*
	     * Register our extended SMTP transport.
	     *
	    session.addProvider(p);
	     */

	    /*
	     * Construct the message and send it.
	     */
	    Message msg = new MimeMessage(session);
	    if (from != null)
		msg.setFrom(new InternetAddress(from));
	    else
		msg.setFrom();

	    msg.setRecipients(Message.RecipientType.TO,
					InternetAddress.parse(to, false));
	    if (cc != null)
		msg.setRecipients(Message.RecipientType.CC,
					InternetAddress.parse(cc, false));
	    if (bcc != null)
		msg.setRecipients(Message.RecipientType.BCC,
					InternetAddress.parse(bcc, false));

	    msg.setSubject(subject);

		msg.setText(text);

	    msg.setHeader("X-Mailer", mailer);
	    msg.setSentDate(new Date());

	    // send the thing off
	    /*
	     * The simple way to send a message is this:
	     *
	    Transport.send(msg);
	     *
	     * But we're going to use some SMTP-specific features for
	     * demonstration purposes so we need to manage the Transport
	     * object explicitly.
	     */
	    SMTPTransport t =
		(SMTPTransport)session.getTransport(prot);
	    try {
		if (auth)
		    t.connect(mailhost, user, password);
		else
		    t.connect();
		t.sendMessage(msg, msg.getAllRecipients());
	    } finally {
		if (verbose)
		    System.out.println("Response: " +
						t.getLastServerResponse());
		t.close();
	    }

	    System.out.println("\nMail was sent successfully.");

	} catch (Exception e) {
	    /*
	     * Handle SMTP-specific exceptions.
	     */
	    if (e instanceof SendFailedException) {
		MessagingException sfe = (MessagingException)e;
		if (sfe instanceof SMTPSendFailedException) {
		    SMTPSendFailedException ssfe =
				    (SMTPSendFailedException)sfe;
		    System.out.println("SMTP SEND FAILED:");
		    if (verbose)
			System.out.println(ssfe.toString());
		    System.out.println("  Command: " + ssfe.getCommand());
		    System.out.println("  RetCode: " + ssfe.getReturnCode());
		    System.out.println("  Response: " + ssfe.getMessage());
		} else {
		    if (verbose)
			System.out.println("Send failed: " + sfe.toString());
		}
		Exception ne;
		while ((ne = sfe.getNextException()) != null &&
			ne instanceof MessagingException) {
		    sfe = (MessagingException)ne;
		    if (sfe instanceof SMTPAddressFailedException) {
			SMTPAddressFailedException ssfe =
					(SMTPAddressFailedException)sfe;
			System.out.println("ADDRESS FAILED:");
			if (verbose)
			    System.out.println(ssfe.toString());
			System.out.println("  Address: " + ssfe.getAddress());
			System.out.println("  Command: " + ssfe.getCommand());
			System.out.println("  RetCode: " + ssfe.getReturnCode());
			System.out.println("  Response: " + ssfe.getMessage());
		    } else if (sfe instanceof SMTPAddressSucceededException) {
			System.out.println("ADDRESS SUCCEEDED:");
			SMTPAddressSucceededException ssfe =
					(SMTPAddressSucceededException)sfe;
			if (verbose)
			    System.out.println(ssfe.toString());
			System.out.println("  Address: " + ssfe.getAddress());
			System.out.println("  Command: " + ssfe.getCommand());
			System.out.println("  RetCode: " + ssfe.getReturnCode());
			System.out.println("  Response: " + ssfe.getMessage());
		    }
		}
	    } else {
		System.out.println("Got Exception: " + e);
		if (verbose)
		    e.printStackTrace();
	    }
	}

} // smtpsend

}
/
