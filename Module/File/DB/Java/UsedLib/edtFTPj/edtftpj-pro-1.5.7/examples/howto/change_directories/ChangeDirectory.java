/*
 * 
 * Copyright (C) 2006 Enterprise Distributed Technologies Ltd
 * 
 * www.enterprisedt.com
 */

import com.enterprisedt.net.ftp.FTPClient;
import com.enterprisedt.util.debug.Level;
import com.enterprisedt.util.debug.Logger;

public class ChangeDirectory {

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
        String dir = args[3];

        // set up logger so that we get some output
        Logger log = Logger.getLogger(ChangeDirectory.class);
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

            log.info("Current dir: " + ftp.pwd());
            log.info("Changing directory");
            ftp.chdir(dir);
            log.info("Current dir: " + ftp.pwd());

            log.info("Changing up");
            ftp.cdup();
            log.info("Current dir: " + ftp.pwd());

            // Shut down client
            log.info("Quitting client");
            ftp.quit();

            log.info("Example complete");

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

}
