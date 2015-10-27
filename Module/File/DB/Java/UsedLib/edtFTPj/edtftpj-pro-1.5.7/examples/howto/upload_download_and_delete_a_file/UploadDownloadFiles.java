/*
 * 
 * Copyright (C) 2006 Enterprise Distributed Technologies Ltd
 * 
 * www.enterprisedt.com
 */

import com.enterprisedt.net.ftp.FTPClient;
import com.enterprisedt.util.debug.Level;
import com.enterprisedt.util.debug.Logger;
import java.io.File;

public class UploadDownloadFiles {

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
        String filename = "UploadDownloadFiles.java";

        // set up logger so that we get some output
        Logger log = Logger.getLogger(UploadDownloadFiles.class);
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

            log.info("Uploading file");
            ftp.put(filename, filename);
            log.info("File uploaded");

            log.info("Downloading file");
            ftp.get(filename + ".copy", filename);
            log.info("File downloaded");

            log.info("Deleting remote file");
            ftp.delete(filename);
            log.info("Deleted remote file");

            File file = new File(filename + ".copy");
            file.delete();
            log.info("Deleted local file copy");

            // Shut down client
            log.info("Quitting client");
            ftp.quit();

            log.info("Example complete");

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

}
