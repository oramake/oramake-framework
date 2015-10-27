/*
 * 
 * Copyright (C) 2006 Enterprise Distributed Technologies Ltd
 * 
 * www.enterprisedt.com
 */

import com.enterprisedt.net.ftp.FTPClient;
import com.enterprisedt.net.ftp.pro.ProFTPClient;
import com.enterprisedt.util.debug.Level;
import com.enterprisedt.util.debug.Logger;
import java.io.File;

public class TransferMultipleFilesDirectories {

    public static void main(String[] args) {

        // we want remote host, user name and password
        if (args.length < 5) {
            System.out
                    .println("Usage: run remote-host username password localdir remotedir");
            System.exit(1);
        }

        // extract command-line arguments
        String host = args[0];
        String username = args[1];
        String password = args[2];
        String localDir = args[3];
        String remoteDir = args[4];

        // set up logger so that we get some output
        Logger log = Logger.getLogger(TransferMultipleFilesDirectories.class);
        Logger.setLevel(Level.DEBUG);

        ProFTPClient ftp = null;

        try {
            // create client
            log.info("Creating FTP client");
            ftp = new ProFTPClient();

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

            log.info("Uploading directory");
            ftp.mput(localDir, remoteDir, "*.html", true);
            log.info("Directory uploaded");
            
            log.info("Downloading directory");
            ftp.mget(localDir + ".copy", remoteDir, "*.html", true);
            log.info("Directory downloaded");
            
            log.info("Deleting remote directory");
            ftp.rmdir(remoteDir, true);
            log.info("Remote directory deleted");

            // Shut down client
            log.info("Quitting client");
            ftp.quit();

            log.info("Example complete");

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

}
