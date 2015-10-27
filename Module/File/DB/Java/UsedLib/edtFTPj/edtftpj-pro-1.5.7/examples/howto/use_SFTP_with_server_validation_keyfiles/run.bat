@call ..\env.bat
IF NOT ERRORLEVEL 1 (
  "%JAVA_HOME%\bin\javac" -classpath %CP% UseSFTPWithServerValidationKeyFile.java
  "%JAVA_HOME%\bin\java" -cp %CP% UseSFTPWithServerValidationKeyFile %1 %2 %3 %4
)