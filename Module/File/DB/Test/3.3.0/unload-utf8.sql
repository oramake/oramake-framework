begin
  pkg_File.unloadClobToFile(
    fileText     => '���2'
  , toPath       => '&1'
  , writeMode    => pkg_File.Mode_Rewrite
  , charEncoding => pkg_File.Encoding_Utf8
  );
end;
/
