/*
 * 
 * Copyright (C) 2006 Enterprise Distributed Technologies Ltd
 * 
 * www.enterprisedt.com
 */

import java.io.File;

import com.enterprisedt.net.ftp.FTPClientInterface;
import com.enterprisedt.net.ftp.FTPTransferType;
import com.enterprisedt.net.ftp.ssh.SSHFTPAlgorithm;
import com.enterprisedt.net.ftp.ssh.SSHFTPClient;
import com.enterprisedt.util.debug.Level;
import com.enterprisedt.util.debug.Logger;

public class UseSFTPWithServerValidationKeyFile {

    public static void main(String[] args) {

        // we want remote host, user name and password
        if (args.length < 4) {
            System.out
                    .println("Usage: run remote-host username password keyfile");
            System.out
                    .println("keyfile = file containing the public key of the server in OpenSSH or SECSH format");
            System.exit(1);
        }

        // extract command-line arguments
        String host = args[0];
        String username = args[1];
        String password = args[2];
        String keyfile = args[3];
        String filename = "UseSFTPWithServerValidationKeyFile.java";

        // set up logger so that we get some output
        Logger log = Logger.getLogger(UseSFTPWithServerValidationKeyFile.class);
        Logger.setLevel(Level.INFO);

        try {
            // create client
            log.info("Creating SFTP client");
            SSHFTPClient ftp = new SSHFTPClient();

            // set remote host
            ftp.setRemoteHost(host);

            // now if your keyfile is a DSA public key, then you
            // should disable all keypairs, and then enable DSA. This
            // forces the server to send its DSA public key - if it sent
            // an RSA public key and your keyfile is DSA, server validation
            // will fail
            ftp.disableAllAlgorithms(SSHFTPAlgorithm.KEY_PAIR);
            ftp.setAlgorithmEnabled(SSHFTPAlgorithm.KEY_DSA, true);

            log.info("Setting user-name and password");
            ftp.setAuthentication(username, password);

            log.info("Loading server public-key from " + keyfile);
            ftp.getValidator().addKnownHost(host, keyfile);

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
