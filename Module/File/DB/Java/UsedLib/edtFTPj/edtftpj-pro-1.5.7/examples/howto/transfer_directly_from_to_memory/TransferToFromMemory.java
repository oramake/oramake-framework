/*
 * 
 * Copyright (C) 2006 Enterprise Distributed Technologies Ltd
 * 
 * www.enterprisedt.com
 */

import java.io.FileInputStream;
import java.io.InputStream;
import java.io.FileOutputStream;
import java.io.OutputStream;
import java.io.File;

import com.enterprisedt.net.ftp.FTPClient;
import com.enterprisedt.util.debug.Level;
import com.enterprisedt.util.debug.Logger;

public class TransferToFromMemory {

    public static void main(String[] args) {

        // we want remote host, user name and password
        if (args.length < 3) {
            System.out
                    .println("Usage: run remote-host username password directory");
            System.exit(1);
        }

        // extract command-line arguments
        String host = args[0];
        String username = args[1];
        String password = args[2];

        // set up logger so that we get some output
        Logger log = Logger.getLogger(TransferToFromMemory.class);
        Logger.setLevel(Level.INFO);

        FTPClient ftp = null;

        try {
            // create client
            log.info("Creating FTP client");
            ftp = new FTPClient();

            // set remote host
            log.info("Setting remote host");
            ftp.setRemoteHost(host);

            // connect to the server
            log.info("Connecting to server " + host);
            ftp.connect();
            log.info("Connected to server " + host);

            // log in
            log.info("Logging in with username=" + username + " and password="
                    + password);
            ftp.login(username, password);
            log.info("Logged in");

            // byte array transfers
            String s1 = "Hello world";

            log.info("Putting s1");
            ftp.put(s1.getBytes(), "Hello.txt");

            log.info("Retrieving as s2");
            byte[] result = ftp.get("Hello.txt");
            String s2 = new String(result);

            log.info("s1 == s2: " + s1.equals(s2));

            // stream transfers
            // this example uses file streams, but any streams, including custom
            // streams could be used
            log.info("Stream transfers");
            InputStream srcStream = new FileInputStream(
                    "TransferToFromMemory.java");
            ftp.put(srcStream, "TransferToFromMemory.java");

            OutputStream outStream = new FileOutputStream(
                    "TransferToFromMemory.java.copy");
            ftp.get(outStream, "TransferToFromMemory.java");

            File copy = new File("TransferToFromMemory.java.copy");
            File orig = new File("TransferToFromMemory.java");
            log.info("Original length=" + orig.length() + ", copy length="
                    + copy.length());
            copy.delete();

            // Shut down client
            log.info("Quitting client");
            ftp.quit();

            log.info("Example complete");

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

}
