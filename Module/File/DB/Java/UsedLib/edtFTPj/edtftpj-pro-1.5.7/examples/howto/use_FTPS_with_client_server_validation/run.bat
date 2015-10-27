@call ..\env.bat
IF NOT ERRORLEVEL 1 (
  "%JAVA_HOME%\bin\javac" -classpath %CP% UseFTPSWithClientServerValidation.java
  "%JAVA_HOME%\bin\java" -cp %CP% UseFTPSWithClientServerValidation %1 %2 %3 %4 %5 %6
)