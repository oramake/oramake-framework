-- script: Do/exec.sql
-- Выполняет команду ОС на сервере.
--
-- Параметры:
-- commandString              - командная строка для выполнения
--

define commandString   = "&1"



declare
  output CLOB;
  error CLOB;
begin
  dbms_lob.createTemporary( output, false);
  dbms_lob.createTemporary( error, false);
  dbms_output.put_line(
    'Exit code: ' || pkg_File.ExecCommand( '&commandString', output, error)
  );
  dbms_output.put_line( '----- STDOUT START ( first 4000 char) -----');
  pkg_Common.outputMessage( substr( output, 1, 4000));
  dbms_output.put_line( '----- STDOUT END -----');
  dbms_output.put_line( '----- STDERR START ( first 4000 char) -----');
  pkg_Common.outputMessage( substr( error, 1, 4000));
  dbms_output.put_line( '----- STDERR END -----');
end;
/



undefine commandString
