@call ..\env.bat
IF NOT ERRORLEVEL 1 (
  "%JAVA_HOME%\bin\javac" -classpath %CP% UseSFTPChoosingAlgorithms.java
  "%JAVA_HOME%\bin\java" -cp %CP% UseSFTPChoosingAlgorithms %1 %2 %3
)