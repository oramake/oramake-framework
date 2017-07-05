begin
  pkg_File.unloadClobToFile(
    fileText     => '1'
  , toPath       => '&1'
  , writeMode    => pkg_File.Mode_Rewrite
  , charEncoding => pkf_File.Encoding_Utf8
  );
end;
/
