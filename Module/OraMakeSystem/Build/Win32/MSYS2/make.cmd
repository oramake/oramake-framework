@echo off
setlocal

rem Save original PATH
set OMS_SRC_PATH=%PATH%

rem Set PATH to default Windows path ( used in MSYS2)
set PATH=C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0

rem Add path to Oracle client
set fCmd="sqlplus.exe"
set fPath=""
rem find fCmd in PATH directories
for %%i in (%fCmd%) do set fPath=%%~dp$OMS_SRC_PATH:i
if "x%fPath%" == "x" (
  echo OMS-Warning: %fCmd% not found in PATH
) else (
  rem add fPath without trailing slash
  set PATH=%PATH%;%fPath:~0,-1%
)

rem Add path to Subversion client
set fCmd="svn.exe"
set fPath=""
rem find fCmd in PATH directories
for %%i in (%fCmd%) do set fPath=%%~dp$OMS_SRC_PATH:i
if not "x%fPath%" == "x" (
  rem add fPath without trailing slash
  set PATH=%PATH%;%fPath:~0,-1%
)

rem Delete temporary variables
set fCmd=
set fPath=

rem Add path to MSYS2 binaries
set PATH=%~dp0usr\bin;%PATH%

rem Add path to OraMakeSystem scripts
set PATH=%~dp0usr\local\bin;%PATH%

rem Use current directory as working directory in MSYS2 bash
set CHERE_INVOKING=enabled_from_arguments

rem Use full currnent PATH variable instead of triming to minimal in MSYS2 bash
set MSYS2_PATH_TYPE=inherit

rem Set Windows codepage 1251
chcp 1251 >nul
set LANG=C.CP1251

rem Run install script
bash -c 'make %*'
