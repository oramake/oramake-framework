prompt creating synonym pkg_FileOrigin for pkg_File...

begin  
  execute immediate '
create or replace synonym pkg_FileOrigin for pkg_File
';
exception when others then
  dbms_output.put_line( 'Synonym not created: ' || SQLERRM );
end;
/
