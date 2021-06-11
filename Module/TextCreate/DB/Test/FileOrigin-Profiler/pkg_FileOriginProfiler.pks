create or replace package pkg_FileOriginProfiler is

procedure AppendUnloadData(
  str varchar2 := null
);
procedure DeleteUnloadData;

end pkg_FileOriginProfiler;
/
