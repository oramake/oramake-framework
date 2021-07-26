declare
  c clob;
  l integer;
begin
  pkg_Operator.setCurrentUserId(9);
  c := pkg_DataSize.getReport(
    toSaveDataSize => false
  , dateFrom => date '2018-05-01'
  );
  l := dbms_lob.getlength(c);
  pkg_Common.outputMessage(dbms_lob.substr(c, 32767, 1));
  pkg_Common.outputMessage(dbms_lob.substr(c, 32767, 32768));
  pkg_Common.outputMessage(dbms_lob.substr(c, 32767, 32768*2));
--   pkg_Common.outputMessage(c);,
end;
/
