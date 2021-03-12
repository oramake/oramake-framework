/*
 * Copyright (c) 1997-2017 Oracle and/or its affiliates. All rights reserved.
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
 *
 * @author John Mani
 * @author Bill Shannon
 */

public class foldersort {

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

	    // Attributes & Flags for all messages ..
	    Message[] msgs = folder.getMessages();

	    // Use a suitable FetchProfile
	    FetchProfile fp = new FetchProfile();
	    fp.add(FetchProfile.Item.ENVELOPE);
	    fp.add(FetchProfile.Item.FLAGS);
	    folder.fetch(msgs, fp);

	    // XXX - sort here

	    folder.close(false);
	    store.close();
	} catch (Exception ex) {
	    System.out.println("Oops, got exception! " + ex.getMessage());
	    ex.printStackTrace();
	    System.exit(1);
	}
	System.exit(0);
    }
}
