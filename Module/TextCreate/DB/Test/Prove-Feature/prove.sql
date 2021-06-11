create or replace type test_object is object(

  buffer varchar2( 32767)
  , constructor function test_object   
    return self as result
  , member procedure test_proc( str varchar2)
)
/
create or replace type body test_object
as

 constructor function test_object
 return self as result
 is
 begin
   return;
 end;
 
 member procedure test_proc( str varchar2)
 is
 begin
   null;
    buffer := substr( buffer || str, 1, 32767);
 end;


end;
/
create or replace package pkg_TestPackage is

  procedure test_proc( str varchar2);
end pkg_TestPackage;
/
create or replace package body pkg_TestPackage is

 buffer varchar2( 32767);
  procedure test_proc( str varchar2)
  is 
 begin
   null;
    buffer := substr( buffer || str, 1, 32767);
 end;
   
end pkg_TestPackage;
/
declare
  t test_object := test_object();
  startTime number;
  endTime number;
  avgObject number := 0;
  avgPackage number := 0;
begin
  startTime := dbms_utility.get_time;
  for i in 1..10000 loop
    t.test_proc( '1');
  end loop;  
  avgObject := avgObject + dbms_utility.get_time - startTime;
  startTime := dbms_utility.get_time;
  for i in 1..10000 loop
    pkg_TestPackage.test_proc( '1');
  end loop;  
  avgPackage := avgPackage + dbms_utility.get_time - startTime;

  pkg_Common.OutputMessage( 'avgObject=' || to_char( avgObject));
  pkg_Common.OutputMessage( 'avgPackage=' || to_char( avgPackage));   
  pkg_Common.OutputMessage( 'rel=' || to_char( avgObject/avgPackage));   
end;
