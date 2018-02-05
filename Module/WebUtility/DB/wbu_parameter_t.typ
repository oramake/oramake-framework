create or replace type wbu_parameter_t force
as object
(
/* db object type: wbu_parameter_t
  Parameter of HTTP request.

  SVN root: Oracle/Module/WebUtility
*/

/* var: parameter_name
  Parameter name
*/
parameter_name                  varchar2(100),

/* var: parameter_value
  Parameter value
*/
parameter_value                 clob

)
/
