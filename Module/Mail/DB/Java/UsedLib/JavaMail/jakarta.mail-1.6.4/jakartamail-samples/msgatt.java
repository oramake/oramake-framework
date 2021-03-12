/*
 * Copyright (c) 1997-2012 Oracle and/or its affiliates. All rights reserved.
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

import java.util.*;
import java.io.*;
import javax.mail.*;
import javax.mail.event.*;
import javax.mail.internet.*;

/*
 * Demo app that exercises the Message interfaces.
 * Show information about and contents of messages.
 *
 * @author John Mani
 * @author Bill Shannon
 */

public class msgatt {

    static String protocol;
    static String host = null;
    static String user = null;
    static String password = null;
    static String mbox = null;
    static String url = null;
    static int port = -1;
    static boolean verbose = false;
    static boolean debug = false;
    static boolean showStructure = false;
    static boolean showMessage = false;
    static boolean showAlert = false;
    static boolean saveAttachments = false;
    static int attnum = 1;

    public static void main(String argv[]) {
	int optind;
	InputStream msgStream = System.in;

	for (optind = 0; optind < argv.length; optind++) {
	    if (argv[optind].equals("-T")) {
		protocol = argv[++optind];
	    } else if (argv[optind].equals("-H")) {
		host = argv[++optind];
	    } else if (argv[optind].equals("-U")) {
		user = argv[++optind];
	    } else if (argv[optind].equals("-P")) {
		password = argv[++optind];
	    } else if (argv[optind].equals("-v")) {
		verbose = true;
	    } else if (argv[optind].equals("-D")) {
		debug = true;
	    } else if (argv[optind].equals("-f")) {
		mbox = argv[++optind];
	    } else if (argv[optind].equals("-L")) {
		url = argv[++optind];
	    } else if (argv[optind].equals("-p")) {
		port = Integer.parseInt(argv[++optind]);
	    } else if (argv[optind].equals("-s")) {
		showStructure = true;
	    } else if (argv[optind].equals("-S")) {
		saveAttachments = true;
	    } else if (argv[optind].equals("-m")) {
		showMessage = true;
	    } else if (argv[optind].equals("-a")) {
		showAlert = true;
	    } else if (argv[optind].equals("--")) {
		optind++;
		break;
	    } else if (argv[optind].startsWith("-")) {
		System.out.println(
"Usage: msgshow [-L url] [-T protocol] [-H host] [-p port] [-U user]");
		System.out.println(
"\t[-P password] [-f mailbox] [msgnum ...] [-v] [-D] [-s] [-S] [-a]");
		System.out.println(
"or     msgshow -m [-v] [-D] [-s] [-S] [-f msg-file]");
		System.exit(1);
	    } else {
		break;
	    }
	}

	try {
	    // Get a Properties object
	    Properties props = System.getProperties();

	    // Get a Session object
	    Session session = Session.getInstance(props, null);
	    session.setDebug(debug);

	    if (showMessage) {
		MimeMessage msg;
		if (mbox != null)
		    msg = new MimeMessage(session,
			new BufferedInputStream(new FileInputStream(mbox)));
		else
		    msg = new MimeMessage(session, msgStream);
		findAttachments(msg);
		System.exit(0);
	    }

	    // Get a Store object
	    Store store = null;
	    if (url != null) {
		URLName urln = new URLName(url);
		store = session.getStore(urln);
		if (showAlert) {
		    store.addStoreListener(new StoreListener() {
			public void notification(StoreEvent e) {
			    String s;
			    if (e.getMessageType() == StoreEvent.ALERT)
				s = "ALERT: ";
			    else
				s = "NOTICE: ";
			    System.out.println(s + e.getMessage());
			}
		    });
		}
		store.connect();
	    } else {
		if (protocol != null)		
		    store = session.getStore(protocol);
		else
		    store = session.getStore();

		// Connect
		if (host != null || user != null || password != null)
		    store.connect(host, port, user, password);
		else
		    store.connect();
	    }
	    

	    // Open the Folder

	    Folder folder = store.getDefaultFolder();
	    if (folder == null) {
		System.out.println("No default folder");
		System.exit(1);
	    }

	    if (mbox == null)
		mbox = "INBOX";
	    folder = folder.getFolder(mbox);
	    if (folder == null) {
		System.out.println("Invalid folder");
		System.exit(1);
	    }

	    // try to open read/write and if that fails try read-only
	    try {
		folder.open(Folder.READ_WRITE);
	    } catch (MessagingException ex) {
		folder.open(Folder.READ_ONLY);
	    }
	    int totalMessages = folder.getMessageCount();

	    if (totalMessages == 0) {
		System.out.println("Empty folder");
		folder.close(false);
		store.close();
		System.exit(1);
	    }

	    if (verbose) {
		int newMessages = folder.getNewMessageCount();
		System.out.println("Total messages = " + totalMessages);
		System.out.println("New messages = " + newMessages);
		System.out.println("-------------------------------");
	    }

	    if (optind >= argv.length) {
		// Attributes & Flags for all messages ..
		Message[] msgs = folder.getMessages();

		// Use a suitable FetchProfile
		FetchProfile fp = new FetchProfile();
		fp.add(FetchProfile.Item.ENVELOPE);
		fp.add(FetchProfile.Item.FLAGS);
		fp.add("X-Mailer");
		folder.fetch(msgs, fp);

		for (int i = 0; i < msgs.length; i++) {
		    System.out.println("--------------------------");
		    System.out.println("MESSAGE #" + (i + 1) + ":");
		    findAttachments(msgs[i]);
		}
	    } else {
		while (optind < argv.length) {
		    int msgnum = Integer.parseInt(argv[optind++]);
		    System.out.println("Getting message number: " + msgnum);
		    Message m = null;
		    
		    try {
			m = folder.getMessage(msgnum);
			findAttachments(m);
		    } catch (IndexOutOfBoundsException iex) {
			System.out.println("Message number out of range");
		    }
		}
	    }

	    folder.close(false);
	    store.close();
	} catch (Exception ex) {
	    System.out.println("Oops, got exception! " + ex.getMessage());
	    ex.printStackTrace();
	    System.exit(1);
	}
	System.exit(0);
    }

    public static void findAttachments(Message msg) throws Exception {
	if (msg.isMimeType("multipart/mixed")) {
	    Multipart mp = (Multipart)msg.getContent();
	    BodyPart bp = mp.getBodyPart(0);
	    for (int i = 1; i < mp.getCount(); i++) {
		processAttachment(mp.getBodyPart(i));
	    }
	} else if (msg.isMimeType("multipart/related")) {
	    findatt(msg);
	} else if (msg.isMimeType("multipart/alternative")) {
	    findatt(msg);
	} else if (msg.isMimeType("text/*")) {
	} else {
	    System.out.println("UNEXPECTED Content-Type: " + msg.getContentType());
	}
    }

    public static void findatt(Part p) throws Exception {
	Multipart mp = (Multipart)p.getContent();
	for (int i = 0; i < mp.getCount(); i++) {
	    BodyPart bp = mp.getBodyPart(0);
	    String disp = bp.getDisposition();
	    if (disp != null && disp.equalsIgnoreCase(Part.ATTACHMENT))
		System.out.println("FOUND UNEXPECTED ATTACHMENT: " + bp.getContentType());
	    if (bp.isMimeType("multipart/mixed"))
		System.out.println("FOUND UNEXPECTED multipart/mixed: " + bp.getContentType());
	    if (bp.isMimeType("multipart/*"))
		findatt(bp);
	}
    }

    public static void processAttachment(Part p) throws Exception {
	System.out.println("Found attachment: " + p.getContentType());
	String disp = p.getDisposition();
	if (disp == null || !disp.equalsIgnoreCase(Part.ATTACHMENT))
	    System.out.println("  NOT MARKED AS ATTACHMENT");
    }
}
