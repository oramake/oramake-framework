/*
 * 
 * Copyright (C) 2006 Enterprise Distributed Technologies Ltd
 * 
 * www.enterprisedt.com
 */

import java.io.File;

import com.enterprisedt.net.ftp.FTPClientInterface;
import com.enterprisedt.net.ftp.FTPTransferType;
import com.enterprisedt.net.ftp.ssh.SSHFTPClient;
import com.enterprisedt.util.debug.Level;
import com.enterprisedt.util.debug.Logger;

public class UseSFTPWithClientValidationPublicKey {

    public static void main(String[] args) {

        // we want remote host, user name and password
        if (args.length < 4) {
            System.out
                    .println("Usage: run remote-host username privatekeyfile privatekeypassword");
            System.exit(1);
        }

        // extract command-line arguments
        String host = args[0];
        String username = args[1];
        String keyfile = args[2];
        String password = args[3];
        String filename = "UseSFTPWithClientValidationPublicKey.java";

        // set up logger so that we get some output
        Logger log = Logger
                .getLogger(UseSFTPWithClientValidationPublicKey.class);
        Logger.setLevel(Level.INFO);

        try {
            // create client
            log.info("Creating SFTP client");
            SSHFTPClient ftp = new SSHFTPClient();

            // set remote host
            ftp.setRemoteHost(host);

            // the client's public key file must be in authorized_keys or
            // the equivalent on the server
            log.info("Loading client private-key from " + keyfile);
            log.info("Setting user-name, private key file and password");
            ftp.setAuthentication(keyfile, username, password);

            log.info("Turning off server validation");
            ftp.getValidator().setHostValidationEnabled(false);

            // connect to the server
            log.info("Connecting to server " + host);
            ftp.connect();

            log.info("Setting transfer mode to ASCII");
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
