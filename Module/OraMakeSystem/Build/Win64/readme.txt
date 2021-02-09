Описание подготовки дистрибутива для Windows на базе 64-bit MSYS2

Бинарники, необходимые для использования OraMakeSystem:
- make
- mkdir
- find
- iconv
- gawk
- sed
- grep
- patch
- perl (используется в NaturalDocs)

Для определения списка необходимых пакетов использовались:
- ранее полученный список для 32-bit MSYS2 (dependencies.Win32.txt);
- набор пакетов, используемых в дистрибутиве MinGit-2.30.0.2-64-bit.zip
  (MinGit-package-versions.txt, из /etc/package-versions.txt дистрибутива)

Пакеты, необходимые для использования OraMakeSystem:
msys2-runtime 3.1.7-4
bash 4.4.023-2
gcc-libs 10.2.0-1
libintl 0.19.8.1-1
libiconv 1.16-2
make 4.3-1
gmp 6.2.1-1
coreutils 8.32-1
findutils 4.7.0-1
mpfr 4.1.0-1
libreadline 8.1.0-1
ncurses 6.2-1
gawk 5.1.0-1
sed 4.8-1
libpcre 8.44-1
grep 3.0-2
patch 2.7.6-1
libcrypt 2.1-2
perl 5.32.0-2
  (исключены из установки требуемые для perl пакеты:
    libgdbm 1.19-1, gdbm 1.19-1, libdb 5.3.28-3, db 5.3.28-3)

Пакеты для генерации файлов дистрибутива ( не включаются в дистрибутив):
p7zip 17.03-1

В качестве источника пакетов используется проект MSYS2 (http://www.msys2.org),
дистрибутивы из https://repo.msys2.org/msys/x86_64.
Добавление пакета MSYS2 выполняется скриптом add-package.sh.
