@call ..\env.bat
IF NOT ERRORLEVEL 1 (
  "%JAVA_HOME%\bin\javac" -classpath %CP% UseFTPSImplicitMode.java
  "%JAVA_HOME%\bin\java" -cp %CP% UseFTPSImplicitMode %1 %2 %3
)