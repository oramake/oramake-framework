/*
 * 
 * Copyright (C) 2006 Enterprise Distributed Technologies Ltd
 * 
 * www.enterprisedt.com
 */

import java.io.File;

import com.enterprisedt.net.ftp.FTPClientInterface;
import com.enterprisedt.net.ftp.FTPConnectMode;
import com.enterprisedt.net.ftp.FTPException;
import com.enterprisedt.net.ftp.FTPTransferType;
import com.enterprisedt.net.ftp.ssl.SSLFTPClient;
import com.enterprisedt.util.debug.Level;
import com.enterprisedt.util.debug.Logger;

public class UseFTPSImplicitMode {

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
        String filename = "UseFTPSImplicitMode.java";

        // set up logger so that we get some output
        Logger log = Logger.getLogger(UseFTPSImplicitMode.class);
        Logger.setLevel(Level.INFO);

        SSLFTPClient ftp = null;

        try {
            // create client
            log.info("Creating FTPS (explicit) client");
            ftp = new SSLFTPClient();

            ftp.setConfigFlags(SSLFTPClient.ConfigFlags.DISABLE_SSL_CLOSURE);
            // NOTE: The DISABLE_SSL_CLOSURE flag is included in this example
            // for the sake of compatibility with as wide a range of servers as
            // possible. If possible it should be avoided as it opens the
            // possibility of truncation attacks (i.e. attacks where data is
            // compromised through premature disconnection).

            // set remote host
            log.info("Setting remote host");
            ftp.setRemoteHost(host);

            // set implicit mode
            ftp.setImplicitFTPS(true);

            // turn off server validation
            log.info("Turning off server validation");
            ftp.setValidateServer(false);

            // connect to the server
            log.info("Connecting to server " + host);
            ftp.connect();

            // some servers supporting implicit SSL require
            // this to be called. You may need to comment these
            // lines out
            try {
                ftp.auth(SSLFTPClient.PROT_PRIVATE);
                log.info("auth() succeeded");
            } catch (FTPException ex) {
                log.warn("auth() not supported or failed", ex);
            }

            // log in
            log.info("Logging in with username=" + username + " and password="
                    + password);
            ftp.login(username, password);
            log.info("Logged in");

            ftp.setConnectMode(FTPConnectMode.PASV);
            ftp.setType(FTPTransferType.ASCII);

            putGetDelete(filename, ftp);
            log.info("Successfully transferred in ASCII mode");

            // Shut down client
            log.info("Quitting client");
            ftp.quit();

            log.info("Example complete");

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * Put a file, get it back as a copy and delete the local copy and the
     * remote copy
     * 
     * @param name
     *            original filename
     * @param ftp
     *            reference to FTP client
     */
    private static void putGetDelete(String name, FTPClientInterface ftp)
            throws Exception {
        ftp.put(name, name);
        ftp.get(name + ".copy", name);
        ftp.delete(name);
        File file = new File(name + ".copy");
        file.delete();
    }

}
