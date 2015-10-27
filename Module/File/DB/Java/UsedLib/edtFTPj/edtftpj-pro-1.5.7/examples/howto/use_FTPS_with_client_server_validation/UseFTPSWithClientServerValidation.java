/*
 * 
 * Copyright (C) 2006 Enterprise Distributed Technologies Ltd
 * 
 * www.enterprisedt.com
 */

import java.io.File;

import com.enterprisedt.net.ftp.FTPClientInterface;
import com.enterprisedt.net.ftp.FTPConnectMode;
import com.enterprisedt.net.ftp.FTPTransferType;
import com.enterprisedt.net.ftp.ssl.SSLFTPClient;
import com.enterprisedt.net.ftp.ssl.SSLFTPStandardValidator;
import com.enterprisedt.util.debug.Level;
import com.enterprisedt.util.debug.Logger;

public class UseFTPSWithClientServerValidation {

	public static void main(String[] args) {

		// we want remote host, user name and password
		if (args.length < 4) {
			System.out.println(
				"Usage: run remote-host username password server-cert-file client-cert-file clientpassphrase");
			System.exit(1);
		}

		// extract command-line arguments
		String host = args[0];
		String username = args[1];
		String password = args[2];
        String serverCertFilename = args[3];
        String clientCertFilename = args[4];
        String clientKeyPassphrase = args[5];
        String filename = "UseFTPSWithClientServerValidation.java";

		// set up logger so that we get some output
		Logger log = Logger.getLogger(UseFTPSWithClientServerValidation.class);
		Logger.setLevel(Level.INFO);

        SSLFTPClient ftp = null;

		try {
			// create client
            log.info("Creating FTPS (explicit) client");
            ftp = new SSLFTPClient();
            
            // disable standard SSL closure
            log.info("Setting configuration flags");
            ftp.setConfigFlags(SSLFTPClient.ConfigFlags.DISABLE_SSL_CLOSURE);
            // NOTE: The DISABLE_SSL_CLOSURE flag is included in this example
            // for the sake of compatibility with as wide a range of servers as
            // possible. If possible it should be avoided as it opens the
            // possibility of truncation attacks (i.e. attacks where data is
            // compromised through premature disconnection).
			
			// set remote host
			log.info("Setting remote host");
			ftp.setRemoteHost(host);

            // load root certificates/server certificate
            log.info("Loading server certificate from " + serverCertFilename);
            ftp.getRootCertificateStore().importPEMFile(serverCertFilename);

            // Disable host-name checking (only recommended when testing)
            log.info("Disable host-name checking (only recommended when testing)");
            ftp.setCustomValidator(new SSLFTPStandardValidator(false));
            
            // load client's private key and certificate
            log.info(
                "Loading client key and certificate from "
                    + clientCertFilename
                    + " with password "
                    + clientKeyPassphrase);
            ftp.loadClientCertificate(clientCertFilename, clientKeyPassphrase);
 
            // connect to the server
            log.info("Connecting to server " + host);
            ftp.connect();

            // switch to SSL on control channel
            log.info("Switching to FTPS (explicit mode)");
            ftp.auth(SSLFTPClient.AUTH_TLS);

            // log in
            log.info(
                "Logging in with username="
                    + username
                    + " and password="
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
     * @param name  original filename
     * @param ftp   reference to FTP client
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
