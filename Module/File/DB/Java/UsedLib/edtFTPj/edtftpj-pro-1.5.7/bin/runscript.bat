@echo off
rem get the path of this bat file
set FTP_LIB=%~dp0
set FTP_LIB=%FTP_LIB%..\lib

if "%JAVA_HOME%" == "" goto NoJavaHome
if not exist "%JAVA_HOME%\bin\java.exe" goto NoJavaHome
if "%JAVAEXE%" == "" set JAVAEXE=%JAVA_HOME%\bin\java.exe
goto SetCP

:NoJavaHome
if "%JAVAEXE%" == "" set JAVAEXE=java.exe

:SetCP
set CP=%FTP_LIB%\edtftpj-pro.jar;%FTP_LIB%\license.jar

"%JAVAEXE%" -classpath %CP% com.enterprisedt.net.ftp.script.ScriptEngine %*
