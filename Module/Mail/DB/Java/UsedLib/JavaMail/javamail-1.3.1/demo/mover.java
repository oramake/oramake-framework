/*
 * @(#)mover.java	1.8 03/04/22
 *
 * Copyright 1996-2003 Sun Microsystems, Inc. All Rights Reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 
 * - Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 * 
 * - Redistribution in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the distribution.
 * 
 * Neither the name of Sun Microsystems, Inc. or the names of contributors
 * may be used to endorse or promote products derived from this software
 * without specific prior written permission.
 * 
 * This software is provided "AS IS," without a warranty of any kind. ALL
 * EXPRESS OR IMPLIED CONDITIONS, REPRESENTATIONS AND WARRANTIES,
 * INCLUDING ANY IMPLIED WARRANTY OF MERCHANTABILITY, FITNESS FOR A
 * PARTICULAR PURPOSE OR NON-INFRINGEMENT, ARE HEREBY EXCLUDED. SUN AND
 * ITS LICENSORS SHALL NOT BE LIABLE FOR ANY DAMAGES OR LIABILITIES
 * SUFFERED BY LICENSEE AS A RESULT OF  OR RELATING TO USE, MODIFICATION
 * OR DISTRIBUTION OF THE SOFTWARE OR ITS DERIVATIVES. IN NO EVENT WILL
 * SUN OR ITS LICENSORS BE LIABLE FOR ANY LOST REVENUE, PROFIT OR DATA, OR
 * FOR DIRECT, INDIRECT, SPECIAL, CONSEQUENTIAL, INCIDENTAL OR PUNITIVE
 * DAMAGES, HOWEVER CAUSED AND REGARDLESS OF THE THEORY OF LIABILITY,
 * ARISING OUT OF THE USE OF OR INABILITY TO USE SOFTWARE, EVEN IF SUN HAS
 * BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
 * 
 * You acknowledge that Software is not designed, licensed or intended
 * for use in the design, construction, operation or maintenance of any
 * nuclear facility.
 */

import java.io.*;
import java.util.*;
import javax.mail.*;
import javax.mail.internet.*;

/* MOVE messages between mailboxes */

public class mover {

    static String protocol = "imap";
    static String host = null;
    static String user = null;
    static String password = null;
    static String src = null;
    static String dest = null;
    static boolean expunge = false;
    static String url = null;

    public static void main(String argv[]) {
	int start = 1; int end = -1;
	int optind;

	for (optind = 0; optind < argv.length; optind++) {
	    if (argv[optind].equals("-T")) { 	    // protocol
		protocol = argv[++optind];
	    } else if (argv[optind].equals("-H")) { // host
		host = argv[++optind];
	    } else if (argv[optind].equals("-U")) { // user
		user = argv[++optind];
	    } else if (argv[optind].equals("-P")) { // password
		password = argv[++optind];
	    } else if (argv[optind].equals("-L")) {
		url = argv[++optind];
	    } else if (argv[optind].equals("-s")) { // Source mbox
		src = argv[++optind];
	    } else if (argv[optind].equals("-d")) { // Destination mbox
		dest = argv[++optind];
	    } else if (argv[optind].equals("-x")) { // Expunge ?
		expunge = true;
	    } else if (argv[optind].equals("--")) {
		optind++;
		break;
	    } else if (argv[optind].startsWith("-")) {
		System.out.println(
"Usage: mover [-T protocol] [-H host] [-U user] [-P password] [-v]");
		System.out.println(
"\t[-s source mbox] [-d destination mbox] [-x] [msgnum1] [msgnum2]");
		System.out.println(
"\t The -x option => EXPUNGE deleted messages");
		System.out.println(
"\t msgnum1 => start of message-range; msgnum2 => end of message-range");
		System.exit(1);
	    } else {
		break;
	    }
	}

	if (optind < argv.length)
	    start = Integer.parseInt(argv[optind++]); // start msg

	if (optind < argv.length)
	    end = Integer.parseInt(argv[optind++]);   // end msg

	try {
	    // Get a Properties object
	    Properties props = System.getProperties();

	    // Get a Session object
	    Session session = Session.getInstance(props, null);

	    // Get a Store object
	    Store store = null;
	    if (url != null) {
		URLName urln = new URLName(url);
		store = session.getStore(urln);
		store.connect();
	    } else {
		if (protocol != null)		
		    store = session.getStore(protocol);
		else
		    store = session.getStore();

		// Connect
		if (host != null || user != null || password != null)
		    store.connect(host, user, password);
		else
		    store.connect();
	    }
	    

	    // Open source Folder
	    Folder folder = store.getFolder(src);
	    if (folder == null || !folder.exists()) {
	        System.out.println("Invalid folder: " + folder.getName());
	        System.exit(1);
	    }

	    folder.open(Folder.READ_WRITE);

	    int count = folder.getMessageCount();
	    if (count == 0) { // No messages in the source folder
		System.out.println(folder.getName() + " is empty");
		// Close folder, store and return
		folder.close(false);
		store.close();
		return;
	    }

	    // Open destination folder, create if reqd
	    Folder dfolder = store.getFolder(dest);
	    if (!dfolder.exists())
		dfolder.create(Folder.HOLDS_MESSAGES);

	    if (end == -1)
		end = count;

	    // Get the message objects to copy
	    Message[] msgs = folder.getMessages(start, end);
	    System.out.println("Moving " + msgs.length + " messages");

	    if (msgs.length != 0) {
		folder.copyMessages(msgs, dfolder);
		folder.setFlags(msgs, new Flags(Flags.Flag.DELETED), true);

		// Dump out the Flags of the moved messages, to insure that
		// all got deleted
		for (int i = 0; i < msgs.length; i++) {
		    if (!msgs[i].isSet(Flags.Flag.DELETED))
			System.out.println("Message # " + msgs[i] + 
						" not deleted");
		}
	    }
	    
	    // Close folders and store
	    folder.close(expunge);
	    dfolder.close(false);
	    store.close();

	} catch (MessagingException mex) {
	    Exception ex = mex;
	    do {
		System.out.println(ex.getMessage());
		if (ex instanceof MessagingException)
		    ex = ((MessagingException)ex).getNextException();
		else
		    ex = null;
	    } while (ex != null);
	}
    }
}
