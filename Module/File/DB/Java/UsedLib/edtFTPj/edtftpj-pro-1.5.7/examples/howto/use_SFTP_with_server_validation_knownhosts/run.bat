@call ..\env.bat
IF NOT ERRORLEVEL 1 (
  "%JAVA_HOME%\bin\javac" -classpath %CP% UseSFTPWithServerValidationKnownHosts.java
  "%JAVA_HOME%\bin\java" -cp %CP% UseSFTPWithServerValidationKnownHosts %1 %2 %3 %4
)