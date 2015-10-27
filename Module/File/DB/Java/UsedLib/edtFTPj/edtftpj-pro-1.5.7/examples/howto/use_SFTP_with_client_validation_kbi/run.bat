@call ..\env.bat
IF NOT ERRORLEVEL 1 (
  "%JAVA_HOME%\bin\javac" -classpath %CP% UseSFTPWithClientValidationKBI.java
  "%JAVA_HOME%\bin\java" -cp %CP% UseSFTPWithClientValidationKBI %1 %2 %3
)