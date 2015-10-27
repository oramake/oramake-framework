@call ..\env.bat
IF NOT ERRORLEVEL 1 (
  "%JAVA_HOME%\bin\javac" -classpath %CP% UseFTPSWithoutServerValidation.java
  "%JAVA_HOME%\bin\java" -cp %CP% UseFTPSWithoutServerValidation %1 %2 %3
)