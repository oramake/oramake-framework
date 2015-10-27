@call ..\env.bat
IF NOT ERRORLEVEL 1 (
  "%JAVA_HOME%\bin\javac" -classpath %CP% TransferToFromMemory.java
  "%JAVA_HOME%\bin\java" -cp %CP% TransferToFromMemory %1 %2 %3
)