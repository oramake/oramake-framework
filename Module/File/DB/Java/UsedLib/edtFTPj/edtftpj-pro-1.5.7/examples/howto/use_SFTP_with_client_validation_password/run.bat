@call ..\env.bat
IF NOT ERRORLEVEL 1 (
  "%JAVA_HOME%\bin\javac" -classpath %CP% UseSFTPWithClientValidationPassword.java
  "%JAVA_HOME%\bin\java" -cp %CP% UseSFTPWithClientValidationPassword %1 %2 %3
)