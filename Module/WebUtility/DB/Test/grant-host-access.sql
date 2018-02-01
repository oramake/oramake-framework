-- script: Test/grant-host-access.sql
-- Grant access privileges to host.
--
-- Parameters:
-- hostName                   - host
-- userName                   - oracle user
--

define hostName = "&1"
define userName = "&2"



begin
  dbms_network_acl_admin.append_host_ace(
    host    => '&hostName'
    , ace   =>  xs$ace_type(
          privilege_list    => xs$name_list( 'connect', 'resolve')
          , principal_name  => '&userName'
          , principal_type  => xs_acl.ptype_db
        )
  );
end;
/



undefine hostName
undefine userName
