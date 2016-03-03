prompt * Saving first header...

begin
  pkg_Logging.SetDestination( destinationCode => 
    pkg_Logging.DbmsOutput_DestinationCode
  );   
  pkg_DataSize.SaveDataSize;
end;
/