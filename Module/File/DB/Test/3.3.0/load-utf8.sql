declare
  fileText clob;
begin
  pkg_File.loadClobFromFile(
  fileText
  , fromPath     => '&1'
  , charEncoding => pkg_File.Encoding_Utf8Bom
  );
  pkg_Common.outputMessage( 'fileText="' || fileText || '"');
end;
/
