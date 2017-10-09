#!/bin/bash

# In comparison with MinGit don't remove:
# /usr/bin/bash.exe ( equal to /usr/bin/sh.exe)
# /usr/bin/cygcheck.exe
# /usr/bin/mount.exe
# /usr/bin/umount.exe
# /usr/bin/gawk.exe ( and remove /usr/bin/awk.exe)
#
find * -type f -print \
  | grep -v \
    -e '\.[acho]$' \
    -e '/man/' \
    -e '^usr/share/awk' \
    -e '^usr/include/' \
    -e '^usr/share/doc/' \
    -e '^usr/share/info/' \
    -e '^usr/bin/msys-\(db\|icu\|gfortran\|stdc++\|quadmath\)[^/]*\.dll$' \
    -e '^usr/bin/dumper\.exe$' \
    -e '^usr/share/perl5/core_perl/Unicode/Collate/Locale/' \
    -e '^usr/share/perl5/core_perl/pods/' \
    -e '^usr/share/locale/' \
    -e '^etc/\(DIR_COLORS\|inputrc\|vimrc\)$' \
    -e '^usr/bin/\(astextplain\|bashbug\|c_rehash\|egrep\)$' \
    -e '^usr/bin/\(fgrep\|findssl\.sh\|igawk\|notepad\)$' \
    -e '^usr/bin/\(ssh-copy-id\|updatedb\|vi\|wordpad\)$' \
    -e '^usr/bin/\(\[\|arch\|base32\|base64\|chcon\)\.exe$' \
    -e '^usr/bin/\(chgrp\|chmod\|chown\|chroot\|cksum\)\.exe$' \
    -e '^usr/bin/\(csplit\|cygwin-.*\)\.exe$' \
    -e '^usr/bin/\(dd\|df\|dir\|dircolors\|du\|expand\)\.exe$' \
    -e '^usr/bin/\(factor\|fmt\|fold\|awk\|gawk..*\|getconf\)\.exe$' \
    -e '^usr/bin/\(getfacl\.exe\|gkill\|groups\|host.*\)\.exe$' \
    -e '^usr/bin/\(iconv\|id\|install\|join\|kill\|ldd\)\.exe$' \
    -e '^usr/bin/\(ldh\|link\|ln\|locale\|locate\|yes\)\.exe$' \
    -e '^usr/bin/\(logname\|md5sum\|minidumper\|mkfifo\)\.exe$' \
    -e '^usr/bin/\(mkgroup\|mknod\|mkpasswd\||nice\)\.exe$' \
    -e '^usr/bin/\(nl\|nohup\|nproc\|numfmt\|od\|openssl\)\.exe$' \
    -e '^usr/bin/\(passwd\|paste\|patchchk\|pinky\|pldd\)\.exe$' \
    -e '^usr/bin/\(pr\|printenv\|ps\|ptx\|realpath\)\.exe$' \
    -e '^usr/bin/\(regtool\|runcon\|scp\|seq\|setfacl\)\.exe$' \
    -e '^usr/bin/\(setmetamode\|sftp\|sha.*sum\|shred\)\.exe$' \
    -e '^usr/bin/\(shuf\|sleep\|slogin\|split\|sshd\)\.exe$' \
    -e '^usr/bin/\(ssh-key.*\|ssp\|stat\|stdbuf\|strace\)\.exe$' \
    -e '^usr/bin/\(stty\|sum\|sync\|tac\|tee\|timeout\)\.exe$' \
    -e '^usr/bin/\(truncate\|tsort\|tty\|tzset\)\.exe$' \
    -e '^usr/bin/\(unexpand\|unlink\|users\|vdir\|who.*\)\.exe$' \
    -e '^usr/bin/msys-\(atomic\|charset\|cilkrts\)-.*\.dll$' \
    -e '^usr/bin/msys-\(gmpxx\|gomp.*\|vtv.*\)-.*\.dll$' \
    -e '^usr/lib/\(awk\|coreutils\|gawk\|openssl\|ssh\)/' \
    -e '^usr/libexec/\(bigram\|code\|frcode\)\.exe$' \
    -e '^usr/share/\(cygwin\|git\)/' \
    -e '^usr/bin/\(captoinfo\|clear\|infocmp\|infotocap\)\.exe$' \
    -e '^usr/bin/\(reset\|tabs\|tic\|toe\|tput\|tset\)\.exe$' \
    -e '^usr/bin/msys-\(formw6\|menuw6\|ncurses++w6\)\.dll$' \
    -e '^usr/bin/msys-\(panelw6\|ticw6\)\.dll$' \
    -e '^usr/\(lib\|share\)/terminfo/' -e '^usr/share/tabset/' \
  | grep --perl-regexp -v \
    -e '^usr/(lib|share)/terminfo/(?!.*/(cygwin|dumb|xterm.*)$)' \
  | grep -v \
    -e '^usr/share/oms-msys2/' \


