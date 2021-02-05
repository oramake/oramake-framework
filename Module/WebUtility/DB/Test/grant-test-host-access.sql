-- script: Test/grant-test-host-access.sql
-- Grant access privileges to hosts, which used in tests.
--
-- Parameters:
-- userName                   - oracle user
--

define userName = "&1"



declare

  userName varchar2(100) := '&userName';

  cursor dataCur is
    select distinct
      substr(
          a.host_path_str
          , 1
          , least(
              instr( a.host_path_str || '/', '/')
              , instr( a.host_path_str || ':', ':')
            )
            - 1
        )
        as test_host
    from
      (
      select
        substr( ov.string_value, instr( ov.string_value, '://') + 3)
          as host_path_str
      from
        v_opt_option_value ov
      where
        ov.module_name = 'WebUtility'
        and ov.object_short_name = 'pkg_WebUtilityTest'
        and ov.object_type_short_name = 'plsql_object'
        and ov.object_type_module_name = 'Option'
        and ov.string_value like '%://%'
      ) a
    order by
      1
  ;

begin
  for rec in dataCur loop
    dbms_network_acl_admin.append_host_ace(
      host    => rec.test_host
      , ace   =>  xs$ace_type(
            privilege_list    => xs$name_list( 'connect', 'resolve')
            , principal_name  => userName
            , principal_type  => xs_acl.ptype_db
          )
    );
    dbms_output.put_line(
      'granted access to host: ' || rec.test_host
    );
  end loop;
end;
/



undefine userName
