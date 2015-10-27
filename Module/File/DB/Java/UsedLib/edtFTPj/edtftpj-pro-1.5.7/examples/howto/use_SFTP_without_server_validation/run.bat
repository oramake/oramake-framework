@call ..\env.bat
IF NOT ERRORLEVEL 1 (
  "%JAVA_HOME%\bin\javac" -classpath %CP% UseSFTPWithoutServerValidation.java
  "%JAVA_HOME%\bin\java" -cp %CP% UseSFTPWithoutServerValidation %1 %2 %3
)