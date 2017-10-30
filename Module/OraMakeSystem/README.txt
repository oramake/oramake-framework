  Installation on Windows
  ========================

1a. In case of installation from OraMakeSystem-X.X.X-win32.zip archive:

  - unpack the contents of the archive ( for example, into C:\).

1b. In case of installation from OraMakeSystem-X.X.X.zip archive:

  - unpack the contents of the archive ( into any folder);
  - execute from Windows command prompt:

cd OraMakeSystem-X.X.X
.\make install

  ( will be installed in the default directory C:\OraMakeSystem, to install to
  a different directory you need to use WIN_ROOT, for example
  ".\make install WIN_ROOT=D:/OraMakeSystem")

2. It is recommended to add the full path to root directory of installation to
  PATH environment variable ( PATH=C:\OraMakeSystem;...).



  Installation on Cygwin
  ========================

Run-time dependencies:
- bash
- make
- coreutils
- findutils
- dos2unix
- gawk
- sed
- grep
- patch
- perl ( for generating documentation using NaturalDocs)


Installation:

1a. In case of installation from OraMakeSystem-X.X.X-cygwin.tar.gz archive:

  - unpack the contents of the archive in Cygwin terminal:

tar xf OraMakeSystem-X.X.X-cygwin.tar.gz

1b. In case of installation from OraMakeSystem-X.X.X.zip archive:

  - unpack the contents of the archive from Explorer

2. Execute from the Cygwin terminal:

cd OraMakeSystem-X.X.X
make install

  ( will be installed into Cygwin with prefix /usr/local)

3. Add /usr/local/bin to PATH environment variable ( PATH=/usr/local/bin:...).

