create or replace type wbu_header_t force
as object
(
/* db object type: wbu_header_t
  Header of HTTP request.

  SVN root: Oracle/Module/WebUtility
*/

/* var: header_name
  Header name
*/
header_name                  varchar2(100),

/* var: header_value
  Header value
*/
header_value                 varchar2(32767)

)
/
