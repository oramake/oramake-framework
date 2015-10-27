/*
 * 
 * Copyright (C) 2006 Enterprise Distributed Technologies Ltd
 * 
 * www.enterprisedt.com
 */

import com.enterprisedt.net.ftp.FTPClient;
import com.enterprisedt.net.ftp.FTPClientInterface;
import com.enterprisedt.net.ftp.FTPProgressMonitor;
import com.enterprisedt.net.ftp.FTPMessageListener;
import com.enterprisedt.net.ftp.FTPTransferType;
import com.enterprisedt.util.debug.Level;
import com.enterprisedt.util.debug.Logger;
import java.io.File;

public class MonitorTransfersCommands {

    public static void main(String[] args) {

        // we want remote host, user name and password
        if (args.length < 3) {
            System.out
                    .println("Usage: run remote-host username password");
            System.exit(1);
        }

        // extract command-line arguments
        String host = args[0];
        String username = args[1];
        String password = args[2];

        // set up logger so that we get some output
        Logger log = Logger.getLogger(MonitorTransfersCommands.class);
        Logger.setLevel(Level.INFO);

        FTPClient ftp = null;

        try {
            // create client
            log.info("Creating FTP client");
            ftp = new FTPClient();

            // set remote host
            log.info("Setting remote host");
            ftp.setRemoteHost(host);

            // set transfer buffer size
            // we set this to a number much smaller than the size of the
            // file to be transferred. Progress is only updated when the
            // transfer buffer is emptied
            ftp.setTransferBufferSize(512);

            // log progress every 512 bytes or so - this will only
            // be approximate
            LogProgressMonitor monitor = new LogProgressMonitor();
            ftp.setProgressMonitor(monitor, 512);

            // set up a message listener
            LogMessageListener listener = new LogMessageListener();
            ftp.setMessageListener(listener);

            // connect to the server
            log.info("Connecting to server " + host);
            ftp.connect();
            log.info("Connected to server " + host);

            // log in
            log.info("Logging in with username=" + username + " and password="
                    + password);
            ftp.login(username, password);
            log.info("Logged in");

            // use binary so file sizes can be compared precisely
            ftp.setType(FTPTransferType.BINARY);

            log.info("Uploading file");
            String name = "MonitorTransfersCommands.java";

            // put the file
            ftp.put(name, name);
            log.info("File uploaded");

            // now delete remote file
            ftp.delete(name);

            // Shut down client
            log.info("Quitting client");
            ftp.quit();

            log.info("Example complete");

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

/**
 * Logs bytes transferred
 */
class LogProgressMonitor implements FTPProgressMonitor {

    private Logger log = Logger.getLogger(LogProgressMonitor.class);

    public void bytesTransferred(long bytes) {
        log.info("Bytes transferred=" + bytes);
    }
}

/**
 * Logs messages sent to and from the server
 */
class LogMessageListener implements FTPMessageListener {

    private Logger log = Logger.getLogger(LogMessageListener.class);

    public void logCommand(String cmd) {
        log.info("Command: " + cmd);
    }

    public void logReply(String reply) {
        log.info("Server Reply: " + reply);
    }
}
