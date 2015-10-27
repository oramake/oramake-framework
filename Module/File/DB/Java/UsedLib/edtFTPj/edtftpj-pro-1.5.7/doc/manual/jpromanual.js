// You can find instructions for this file here:
// http://www.treeview.net

// Decide if the names are links or just the icons
USETEXTLINKS = 1  //replace 0 with 1 for hyperlinks

// Decide if the tree is to start all open or just showing the root folders
STARTALLOPEN = 0 //replace 0 with 1 to show the whole tree

ICONPATH = 'images/' //change if the gif's folder is a subfolder, for example: 'images/'


foldersTree = gFld("edtFTPj/PRO", "html/intro.html")

// Getting started
aux1 = insFld(foldersTree, gFld("Getting started", "html/productoverview.html"))
  insDoc(aux1, gLnk("R", "Product Overview", "html/productoverview.html"))
  insDoc(aux1, gLnk("R", "Installation", "html/installation.html"))
  insDoc(aux1, gLnk("R", "Feature List", "html/featurelist.html"))
  insDoc(aux1, gLnk("R", "Key Classes", "html/usingedtftpjpro.html"))
  insDoc(aux1, gLnk("R", "License Agreement", "html/licenseagreement.html"))
  
// File Transfer Essentials
aux1 = insFld(foldersTree, gFld("File Transfer Essentials", "javascript:parent.op()"))
  // File Transfer Essentials -> FTP Protocol Overview
  aux2 = insFld(aux1, gFld("FTP Protocol Overview", "html/ftpprotocoloverview.html"))
    insDoc(aux2, gLnk("R", "Active and Passive modes", "html/activeandpassivemodes.html"))
    insDoc(aux2, gLnk("R", "FTP Commands", "html/ftpcommands.html"))
    insDoc(aux2, gLnk("R", "Sample Scenarios", "html/samplescenarios.html"))
    insDoc(aux2, gLnk("R", "Data types", "html/datatypes.html"))
    insDoc(aux2, gLnk("R", "Session commands", "html/sessioncommands.html"))
    insDoc(aux2, gLnk("R", "File commands", "html/filecommands.html"))
    insDoc(aux2, gLnk("R", "Directory commands", "html/directorycommands.html"))
  // File Transfer Essentials -> FTPS - Securing FTP with TLS
  aux2 = insFld(aux1, gFld("FTPS - Securing FTP with TLS", "html/ftpssecuringftpwithtls.html"))
    insDoc(aux2, gLnk("R", "Implicit FTPS and Explicit FTPS", "html/implicitftpsandexplicitftps.html"))
    insDoc(aux2, gLnk("R", "Securing Control and Data Channels", "html/securingcontrolanddatachannels.html"))
    insDoc(aux2, gLnk("R", "FTPS Commands", "html/ftpscommands.html"))
    insDoc(aux2, gLnk("R", "FTPS Usage", "html/ftpsusage.html"))
  // File Transfer Essentials -> The Essentials of FTP Security
  aux2 = insFld(aux1, gFld("The Essentials of FTP Security", "html/theessentialsofftpsecurity.html"))
    insDoc(aux2, gLnk("R", "Public Key Cryptography", "html/publickeycryptography.html"))
    insDoc(aux2, gLnk("R", "Certificates and Certificate Authorities (CAs)", "html/certificatesandcertificateauthoritiescas.html"))
    insDoc(aux2, gLnk("R", "Obtaining Keys and Certificates", "html/obtainingkeysandcertificates.html"))
    insDoc(aux2, gLnk("R", "Server and Client Validation", "html/serverandclientvalidation.html"))
    insDoc(aux2, gLnk("R", "Hostname Checking", "html/hostnamechecking.html"))
    insDoc(aux2, gLnk("R", "Selecting Ciphers", "html/selectingciphers.html"))
  // File Transfer Essentials -> SFTP - SSH File Transfer Protocol
  aux2 = insFld(aux1, gFld("SFTP - SSH File Transfer Protocol", "html/sftpsshfiletransferprotocol.html"))
    insDoc(aux2, gLnk("R", "SSH - Secure Shell", "html/sshsecureshell.html"))
    insDoc(aux2, gLnk("R", "SFTP – SSH File Transfer Protocol", "html/sftpsshfiletransferprotocol2.html"))
    insDoc(aux2, gLnk("R", "Comparison of FTPS and SFTP", "html/comparisonofftpsandsftp.html"))
  // File Transfer Essentials -> SOCKS Proxies
  aux2 = insFld(aux1, gFld("SOCKS Proxies", "html/socksproxies.html"))
    insDoc(aux2, gLnk("R", "SOCKS4 and SOCKS4A", "html/socks4andsocks4a.html"))
    insDoc(aux2, gLnk("R", "SOCKS5", "html/socks5.html"))
    
// How To...
aux1 = insFld(foldersTree, gFld("How To...", "html/howto.html"))
  insDoc(aux1, gLnk("R", "...use the license file", "html/howtousethelicensefile.html"))
  insDoc(aux1, gLnk("R", "...run the examples", "html/howtorunexamples.html"))
  insDoc(aux1, gLnk("R", "...connect to an FTP server", "html/howtocreateanftpconnection.html"))
  insDoc(aux1, gLnk("R", "...get a directory listing", "html/howtogetadirectorylisting.html"))
  insDoc(aux1, gLnk("R", "...change directories", "html/howtochangedirectories.html"))
  insDoc(aux1, gLnk("R", "...upload, download and delete a file", "html/howtouploadafile.html"))
  insDoc(aux1, gLnk("R", "...use binary or ASCII mode", "html/howtotransfermodes.html"))
  insDoc(aux1, gLnk("R", "...use active or passive mode", "html/howtoconnectmodes.html"))
  insDoc(aux1, gLnk("R", "...transfer directly from/to memory", "html/howtotransferstreams.html"))
  insDoc(aux1, gLnk("R", "...transfer using FTP streams", "html/howtotransferstreams2.html"))
  insDoc(aux1, gLnk("R", "...monitor transfers and commands", "html/howtomonitortransfers.html"))
  insDoc(aux1, gLnk("R", "...pause and resume transfers", "html/howtopauseresumetransfers.html"))
  insDoc(aux1, gLnk("R", "...transfer multiple files and directories", "html/howtotransfermultiplefilesdirectories.html"))
  insDoc(aux1, gLnk("R", "...FTP through a NAT router/firewall", "html/howtoftpthroughafilewall.html"))
  insDoc(aux1, gLnk("R", "...FTP through a SOCKS proxy", "html/howtoftpthroughasocksproxy.html"))
  insDoc(aux1, gLnk("R", "...FTP through other proxy servers", "html/howtoftpthroughotherproxyservers.html"))
  insDoc(aux1, gLnk("R", "...use different character encodings", "html/howtousedifferentcharacterencodings.html"))
  insDoc(aux1, gLnk("R", "...use FXP for server-to-server transfers", "html/howtousefxp.html"))
  insDoc(aux1, gLnk("R", "...use FTPS (introduction)", "html/howtouseftpsintroduction.html"))
  insDoc(aux1, gLnk("R", "...use FTPS (without server validation)", "html/howtouseftpswithoutservervalidation.html"))
  insDoc(aux1, gLnk("R", "...use FTPS (with server validation - part A)", "html/howtouseftpswithservervalidationparta.html"))
  insDoc(aux1, gLnk("R", "...use FTPS (with server validation - part B)", "html/howtouseftpswithservervalidationpartb.html"))
  insDoc(aux1, gLnk("R", "...use FTPS (with server validation - part C)", "html/howtouseftpswithservervalidationpartc.html"))
  insDoc(aux1, gLnk("R", "...use FTPS (with client/server validation)", "html/howtouseftpswithclientservervalidation.html"))
  insDoc(aux1, gLnk("R", "...use FTPS (implicit)", "html/howtouseftpsimplicit.html"))
  insDoc(aux1, gLnk("R", "...use SFTP (introduction)", "html/howtousesftpintroduction.html"))
  insDoc(aux1, gLnk("R", "...use SFTP (without server validation)", "html/howtousesftpwithoutservervalidation.html"))
  insDoc(aux1, gLnk("R", "...use SFTP (with server validation - known hosts)", "html/howtousesftpwithservervalidationknownhosts.html"))
  insDoc(aux1, gLnk("R", "...use SFTP (with server validation - public key files)", "html/howtousesftpwithservervalidationpublickeyfile.html"))
  insDoc(aux1, gLnk("R", "...use SFTP (with client validation - password authentication)", "html/howtousesftpwithclientvalidation.html"))
  insDoc(aux1, gLnk("R", "...use SFTP (with client validation - public key authentication)", "html/howtousesftpwithclientvalidationpublickeyauthentication.html"))
  insDoc(aux1, gLnk("R", "...use SFTP (with client validation - keyboard-interactive authentication)", "html/howtousesftpwithclientvalidationkeyboardinteractiveauthentication.html"))
  insDoc(aux1, gLnk("R", "...use SFTP (choosing algorithms)", "html/howtousesftpchoosingalgorithms.html"))
  insDoc(aux1, gLnk("R", "...use SFTP (data compression)", "html/howtousesftpcompression.html"))
  insDoc(aux1, gLnk("R", "...use SFTP (keypair generation)", "html/howtousesftpkeypairgeneration.html"))
  insDoc(aux1, gLnk("R", "...use scripting", "html/howtousescripting.html"))
  insDoc(aux1, gLnk("R", "...set up logging", "html/howtosetuplogging.html"))
  insDoc(aux1, gLnk("R", "...set up extended logging", "html/howtosetuploggingextended.html"))
  insDoc(aux1, gLnk("R", "...create a certificate", "html/howtocreateacertificate.html"))
  insDoc(aux1, gLnk("R", "...diagnose problems", "html/howtodiagnoseproblems.html"))
  insDoc(aux1, gLnk("R", "...resolve common problems", "html/howtoresolvecommonproblems.html"))
  insDoc(aux1, gLnk("R", "...get help", "html/support.html"))
 
// Other Documentation
aux1 = insFld(foldersTree, gFld("Other Documentation", "javascript:parent.op()"))  
  insDoc(aux1, gLnk("N", "API Documentation", "../api/index.html"))
  insDoc(aux1, gLnk("R", "RFC 959 - FILE TRANSFER PROTOCOL (FTP)", "rfc/rfc959.txt"))
  insDoc(aux1, gLnk("R", "RFC 2228 - FTP Security Extensions", "rfc/rfc2228.txt"))
  insDoc(aux1, gLnk("R", "RFC 4217 - Securing FTP with TLS", "rfc/rfc4217.txt"))
  insDoc(aux1, gLnk("R", "SSH File Transfer Protocol", "rfc/draft-ietf-secsh-filexfer.txt")) 
  insDoc(aux1, gLnk("R", "About this manual", "html/about.html")) 
  