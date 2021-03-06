/*
 * Copyright (c) 1997-2019 Oracle and/or its affiliates. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 *   - Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *
 *   - Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *
 *   - Neither the name of Oracle nor the names of its
 *     contributors may be used to endorse or promote products derived
 *     from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
 * IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import java.io.*;
import java.net.InetAddress;
import java.util.Properties;
import java.util.Date;

import javax.mail.*;
import javax.mail.internet.*;

import com.sun.mail.smtp.*;

/**
 * Demo app that shows how to construct and send an RFC822
 * (singlepart) message.
 *
 * XXX - allow more than one recipient on the command line
 *
 * This is just a variant of msgsend.java that demonstrates use of
 * some SMTP-specific features.
 *
 * @author Max Spivak
 * @author Bill Shannon
 */

public class resend {

    public static void main(String[] argv) {
	String  to = null, url = null;
	String mailhost = null;
	String protocol = null, host = null, user = null, password = null;
	String record = null;	// name of folder in which to record mail
	boolean debug = false;
	boolean verbose = false;
	boolean auth = false;
	String prot = "smtp";
	int optind;

	/*
	 * Process command line arguments.
	 */
	for (optind = 0; optind < argv.length; optind++) {
	    if (argv[optind].equals("-T")) {
		protocol = argv[++optind];
	    } else if (argv[optind].equals("-H")) {
		host = argv[++optind];
	    } else if (argv[optind].equals("-U")) {
		user = argv[++optind];
	    } else if (argv[optind].equals("-P")) {
		password = argv[++optind];
	    } else if (argv[optind].equals("-M")) {
		mailhost = argv[++optind];
	    } else if (argv[optind].equals("-L")) {
		url = argv[++optind];
	    } else if (argv[optind].equals("-d")) {
		debug = true;
	    } else if (argv[optind].equals("-v")) {
		verbose = true;
	    } else if (argv[optind].equals("-A")) {
		auth = true;
	    } else if (argv[optind].equals("-S")) {
		prot = "smtps";
	    } else if (argv[optind].equals("--")) {
		optind++;
		break;
	    } else if (argv[optind].startsWith("-")) {
		System.out.println(
"Usage: smtpsend [[-L store-url] | [-T prot] [-H host] [-U user] [-P passwd]]");
		System.out.println(
"\t[-s subject] [-o from-address] [-c cc-addresses] [-b bcc-addresses]");
		System.out.println(
"\t[-f record-mailbox] [-M transport-host] [-d] [-a attach-file]");
		System.out.println(
"\t[-v] [-A] [-S] [address]");
		System.exit(1);
	    } else {
		break;
	    }
	}

	try {
	    /*
	     */
	    if (optind < argv.length) {
		// XXX - concatenate all remaining arguments
		to = argv[optind];
		System.out.println("To: " + to);
	    } else {
		System.exit(1);
	    }

	    /*
	     * Initialize the Jakarta Mail Session.
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
		"smtpsend$SMTPExtension", "Jakarta Mail demo", "no version");
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
	    Message msg = new MimeMessage(session, System.in);

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
		t.sendMessage(msg, InternetAddress.parse(to));
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
    }
}
