/*
 * 
 * Copyright (C) 2006 Enterprise Distributed Technologies Ltd
 * 
 * www.enterprisedt.com
 */

import com.enterprisedt.net.ftp.FTPClient;
import com.enterprisedt.net.ftp.FTPClientInterface;
import com.enterprisedt.net.ftp.FTPProgressMonitor;
import com.enterprisedt.net.ftp.FTPTransferType;
import com.enterprisedt.util.debug.Level;
import com.enterprisedt.util.debug.Logger;
import java.io.File;

public class PauseResumeTransfers {

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
        Logger log = Logger.getLogger(PauseResumeTransfers.class);
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
            // file to be transferred. When cancelTransfer() is called,
            // the current transfer buffer is emptied before the transfer
            // is cancelled
            ftp.setTransferBufferSize(64);

            // use cancel progress monitor to abort after about 512+ bytes
            // have been transferred. This will be only approximate
            CancelProgressMonitor monitor = new CancelProgressMonitor(ftp);
            ftp.setProgressMonitor(monitor, 512);

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
            String name = "PauseResumeTransfers.java";

            // the put will be interrupted by the monitor - it will call
            // cancelTransfer()
            ftp.put(name, name);
            int len = (int) ftp.size(name);
            File file = new File(name);
            log.info("Bytes transferred=" + monitor.getBytesTransferred());
            log.info("File partially uploaded (localsize=" + file.length()
                    + " remotesize=" + len);

            log.info("Completing upload by resuming");
            ftp.resume();
            ftp.put(name, name);
            len = (int) ftp.size(name);

            // only the remaining bytes are transferred as can be seen
            log.info("Bytes transferred=" + monitor.getBytesTransferred());
            log.info("File uploaded (localsize=" + file.length()
                    + " remotesize=" + len);

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
 * As soon it receives notification of bytes transferred, it cancels the
 * transfer
 */
class CancelProgressMonitor implements FTPProgressMonitor {

    private Logger log = Logger.getLogger(CancelProgressMonitor.class);

    /**
     * True if cancelled
     */
    private boolean cancelled = false;

    /**
     * FTPClient reference
     */
    private FTPClientInterface ftpClient;

    /**
     * Keep the last reported byte count
     */
    private long bytesTransferred = 0;

    /**
     * Constructor
     * 
     * @param ftp
     *            FTP client reference
     */
    public CancelProgressMonitor(FTPClientInterface ftp) {
        this.ftpClient = ftp;
    }

    /*
     * First callback we get, cancel the transfer
     */
    public void bytesTransferred(long bytes) {
        if (!cancelled) {
            ftpClient.cancelTransfer();
            cancelled = true;
        }
        bytesTransferred = bytes;
    }

    /**
     * Will contain the total bytes transferred once the transfer is complete
     */
    public long getBytesTransferred() {
        return bytesTransferred;
    }
}
