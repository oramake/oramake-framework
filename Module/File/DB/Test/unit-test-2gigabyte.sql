-- script: Test/unit-test-2gigabyte.sql
-- Òåñòèğîâàíèå ğàáîòû ìîäóëÿ file ñ ôàéëîâ ğàçìåğîì 2 ìëğä. áàéò.
begin
  pkg_FileTest.unitTest( fileSize => 2000000000);
end;
/
