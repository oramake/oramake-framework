set feedback off

timing start

begin
  pkg_FileTest.unitTest(
    fileSize => 1 * 1024 * 1024
  );
end;
/

timing stop

set feedback on
