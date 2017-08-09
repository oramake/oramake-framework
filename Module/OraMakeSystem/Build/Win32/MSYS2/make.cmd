@echo off
setlocal

rem Set PATH to default Windows path ( used in MSYS2)
set PATH=C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0

rem Add path to MSYS2 binaries
set PATH=%~dp0usr\bin;%PATH%

rem Use current directory as working directory in MSYS2 bash
set CHERE_INVOKING=enabled_from_arguments

rem Use full currnent PATH variable instead of triming to minimal in MSYS2 bash
set MSYS2_PATH_TYPE=inherit

rem Run install script
bash -c 'make %*'
