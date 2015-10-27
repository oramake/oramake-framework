@call ..\env.bat
IF NOT ERRORLEVEL 1 (
  "%JAVA_HOME%\bin\javac" -classpath %CP% UseSFTPWithClientValidationPublicKey.java
  "%JAVA_HOME%\bin\java" -cp %CP% UseSFTPWithClientValidationPublicKey %1 %2 %3 %4
)