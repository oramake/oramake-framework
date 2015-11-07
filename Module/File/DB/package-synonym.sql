prompt * checking pkg_File synonym existence...
declare
  synonymObject varchar2(30);
begin
  select
    max( table_name )
  into 
    synonymObject
  from
    user_synonyms
  where
    synonym_name = 'PKG_FILE';
  if synonymObject is null then
    execute immediate
      'create synonym pkg_File for pkg_FileOrigin';
    dbms_output.put_line('synonym pkg_File for pkg_FileOrigin created');
  else
    dbms_output.put_line('synonym pkg_File is already used for "' 
      || synonymObject || '"'
    );
  end if;
end;
/
